# Copyright (c) 2016, OARC, Inc.
# Copyright (c) 2007, The Measurement Factory, Inc.
# Copyright (c) 2007, Internet Systems Consortium, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

package DSC::extractor;

use POSIX;
use Digest::MD5;
#use File::Flock;
use File::NFSLock;

use strict;

BEGIN { }

END { }


$DSC::extractor::SKIPPED_KEY = "-:SKIPPED:-";	# must match dsc source code
$DSC::extractor::SKIPPED_SUM_KEY = "-:SKIPPED_SUM:-";	# must match dsc source code

#my $lockfile_template = '/tmp/%F.lck';
#my $lockfile_template = '%f.lck';
my $LOCK_RETRY_DURATION = 45;
my $MD5_frequency = 500;

sub yymmdd {
	my $t = shift;
	my @t = gmtime($t);
	POSIX::strftime "%Y%m%d", @t;
}

# was used by old LockFile::Simple code
#
sub lockfile_format {
	my $fn = shift;
	my @x = stat ($fn);
	unless (defined ($x[0]) && defined($x[1])) {
		open(X, ">$fn");
		close(X);
	}
	@x = stat ($fn);
	die "$fn: $!" unless (defined ($x[0]) && defined($x[1]));
	'/tmp/' . join('.', $x[0], $x[1], 'lck');
}

sub lock_file {
	my $fn = shift;
#	return new File::Flock($fn);
	return File::NFSLock->new($fn, 'BLOCKING');
}


#
# time k1 v1 k2 v2 ...
#
sub read_data {
	my $href = shift;
	my $fn = shift;
	my $nl = 0;
	my $md = Digest::MD5->new;
	return 0 unless (-f $fn);
	if (open(IN, "$fn")) {
	    while (<IN>) {
		$nl++;
		if (/^#MD5 (\S+)/) {
			if ($1 ne $md->hexdigest) {
				warn "MD5 checksum error in $fn at line $nl\n".
					"found $1 expect ". $md->hexdigest. "\n".
					"exiting";
				return -1;
			}
			next;
		}
		$md->add($_);
		chomp;
		my ($k, %B) = split;
		$href->{$k} = \%B;
	    }
	    close(IN);
	}
	$nl;
}

#
# time k1 v1 k2 v2 ...
#
sub write_data {
	my $A = shift;
	my $fn = shift;
	my $nl = 0;
	my $B;
	my $lock = lock_file($fn);
	my $md = Digest::MD5->new;
	open(OUT, ">$fn.new") || die "$fn.new: $!";
	foreach my $k (sort {$a <=> $b} keys %$A) {
		next unless defined($B = $A->{$k});
		my $line = join(' ', $k, %$B) . "\n";
		next unless ($line =~ /\S/);
		print OUT $line;
		$md->add($line);
		$nl++;
		print OUT "#MD5 ", $md->hexdigest, "\n" if (0 == ($nl % $MD5_frequency));
	}
	print OUT "#MD5 ", $md->hexdigest, "\n" if (0 != ($nl % $MD5_frequency));
	close(OUT);
	rename "$fn.new", $fn || die "$fn.new: $!";
	print "wrote $nl lines to $fn\n";
}

# a 1-level hash database with no time dimension
#
# ie: key value
#
sub read_data2 {
	my $href = shift;
	my $fn = shift;
	my $nl = 0;
	my $md = Digest::MD5->new;
	return 0 unless (-f $fn);
	if (open(IN, "$fn")) {
	    while (<IN>) {
		$nl++;
		if (/^#MD5 (\S+)/) {
			if ($1 ne $md->hexdigest) {
				warn "MD5 checksum error in $fn at line $nl\n".
					"found $1 expect ". $md->hexdigest. "\n".
					"exiting";
				return -1;
			}
			next;
		}
		$md->add($_);
		chomp;
		my ($k, $v) = split;
		$href->{$k} = $v;
	    }
	    close(IN);
	}
	$nl;
}


# a 1-level hash database with no time dimension
#
# ie: key value
#
sub write_data2 {
	my $A = shift;
	my $fn = shift;
	my $nl = 0;
	my $lock = lock_file($fn);
	my $md = Digest::MD5->new;
	open(OUT, ">$fn.new") || die $!;
	foreach my $k (sort {$a cmp $b} keys %$A) {
		my $line = "$k $A->{$k}\n";
		print OUT $line;
		$md->add($line);
		$nl++;
		print OUT "#MD5 ", $md->hexdigest, "\n" if (0 == ($nl % $MD5_frequency));
	}
	print OUT "#MD5 ", $md->hexdigest, "\n" if (0 != ($nl % $MD5_frequency));
	close(OUT);
	rename "$fn.new", $fn || die "$fn.new: $!";
	print "wrote $nl lines to $fn\n";
}

# reads a 2-level hash database with no time dimension
# ie: key1 key2 value
#
sub read_data3 {
	my $href = shift;
	my $fn = shift;
	my $nl = 0;
	my $md = Digest::MD5->new;
	return 0 unless (-f $fn);
	if (open(IN, "$fn")) {
	    while (<IN>) {
		$nl++;
		if (/^#MD5 (\S+)/) {
			if ($1 ne $md->hexdigest) {
				warn "MD5 checksum error in $fn at line $nl\n".
					"found $1 expect ". $md->hexdigest. "\n".
					"exiting";
				return -1;
			}
			next;
		}
		$md->add($_);
		chomp;
		my ($k1, $k2, $v) = split;
		next unless defined($v);
		$href->{$k1}{$k2} = $v;
	    }
	    close(IN);
	}
	$nl;
}

# writes a 2-level hash database with no time dimension
# ie: key1 key2 value
#
sub write_data3 {
	my $href = shift;
	my $fn = shift;
	my $nl = 0;
	my $lock = lock_file($fn);
	my $md = Digest::MD5->new;
	open(OUT, ">$fn.new") || return;
	foreach my $k1 (keys %$href) {
		foreach my $k2 (keys %{$href->{$k1}}) {
			my $line = "$k1 $k2 $href->{$k1}{$k2}\n";
			print OUT $line;
			$md->add($line);
			$nl++;
			print OUT "#MD5 ", $md->hexdigest, "\n" if (0 == ($nl % $MD5_frequency));
		}
	}
	print OUT "#MD5 ", $md->hexdigest, "\n" if (0 != ($nl % $MD5_frequency));
	close(OUT);
	rename "$fn.new", $fn || die "$fn.new: $!";
	print "wrote $nl lines to $fn\n";
}


# reads a 2-level hash database WITH time dimension
# ie: time k1 (k:v:k:v) k2 (k:v:k:v)
#
sub read_data4 {
	my $href = shift;
	my $fn = shift;
	my $nl = 0;
	my $md = Digest::MD5->new;
	return 0 unless (-f $fn);
	if (open(IN, "$fn")) {
	    while (<IN>) {
		$nl++;
		if (/^#MD5 (\S+)/) {
			if ($1 ne $md->hexdigest) {
				warn "MD5 checksum error in $fn at line $nl\n".
					"found $1 expect ". $md->hexdigest. "\n".
					"exiting";
				return -1;
			}
			next;
		}
		$md->add($_);
		chomp;
		my ($ts, %foo) = split;
		while (my ($k,$v) = each %foo) {
			my %bar = split(':', $v);
			$href->{$ts}{$k} = \%bar;
		}
	    }
	    close(IN);
	}
	$nl;
}

# writes a 2-level hash database WITH time dimension
# ie: time k1 (k:v:k:v) k2 (k:v:k:v)
#
sub write_data4 {
	my $href = shift;
	my $fn = shift;
	my $nl = 0;
	my $lock = lock_file($fn);
	my $md = Digest::MD5->new;
	open(OUT, ">$fn.new") || return;
	foreach my $ts (sort {$a <=> $b} keys %$href) {
		my @foo = ();
		foreach my $k1 (keys %{$href->{$ts}}) {
			push(@foo, $k1);
			push(@foo, join(':', %{$href->{$ts}{$k1}}));
		}
		my $line = join(' ', $ts, @foo) . "\n";
		print OUT $line;
		$md->add($line);
		$nl++;
		print OUT "#MD5 ", $md->hexdigest, "\n" if (0 == ($nl % $MD5_frequency));
	}
	print OUT "#MD5 ", $md->hexdigest, "\n" if (0 != ($nl % $MD5_frequency));
	close(OUT);
	rename "$fn.new", $fn || die "$fn.new: $!";
	print "wrote $nl lines to $fn\n";
}

##############################################################################

sub grok_1d_xml {
	my $XML = shift || die "grok_1d_xml() expected XML obj";
	my $L2 = shift || die "grok_1d_xml() expected L2";
	my %result;
	my $aref = $XML->{data}[0]->{All};
	foreach my $k1ref (@$aref) {
		foreach my $k2ref (@{$k1ref->{$L2}}) {
			my $k2 = $k2ref->{val};
			$result{$k2} = $k2ref->{count};
		}
	}
	($XML->{start_time}, \%result);
}

sub grok_2d_xml {
	my $XML = shift || die "grok_2d_xml() expected XML obj";
	my $L1 = shift || die;
	my $L2 = shift || die;
	my %result;
	my $aref = $XML->{data}[0]->{$L1};
	foreach my $k1ref (@$aref) {
		my $k1 = $k1ref->{val};
		foreach my $k2ref (@{$k1ref->{$L2}}) {
			my $k2 = $k2ref->{val};
			$result{$k1}{$k2} = $k2ref->{count};
		}
	}
	($XML->{start_time}, \%result);
}

#sub grok_array_xml {
#	my $fname = shift || die;
#	my $L2 = shift || die;
#	my $XS = new XML::Simple(searchpath => '.', forcearray => 1);
#	my $XML = $XS->XMLin($fname);
#	my $aref = $XML->{data}[0]->{All};
#	my @result;
#	foreach my $k1ref (@$aref) {
#		my $rcode_aref = $k1ref->{$L2};
#		foreach my $k2ref (@$rcode_aref) {
#			my $k2 = $k2ref->{val};
#			$result[$k2] = $k2ref->{count};
#		}
#	}
#	($XML->{start_time}, @result);
#}

sub elsify_unwanted_keys {
	my $hashref = shift;
	my $keysref = shift;
	foreach my $k (keys %{$hashref}) {
		next if ('else' eq $k);
		next if (grep {$k eq $_} @$keysref);
		$hashref->{else} += $hashref->{$k};
		delete $hashref->{$k};
	}
}

sub replace_keys {
	my $oldhash = shift;
	my $oldkeys = shift;
	my $newkeys = shift;
	my @newkeycopy = @$newkeys;
	my %newhash = map { $_ => $oldhash->{shift @$oldkeys}} @newkeycopy;
	\%newhash;
}

##############################################################################
