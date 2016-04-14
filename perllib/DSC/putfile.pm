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
#
# routines used to receive PUT requests from an HTTP/CGI server
#

package DSC::putfile;

use strict;
use warnings;

use POSIX;
use File::Flock;
use File::Temp qw();
use Digest::MD5;


BEGIN {
        use Exporter   ();
        use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
        $VERSION     = 1.00;
        @ISA         = qw(Exporter);
        @EXPORT      = qw(
		&run
	);
        %EXPORT_TAGS = ( );
        @EXPORT_OK   = qw();
}
use vars      @EXPORT;
use vars      @EXPORT_OK;

END { }

my $putlog;
my $TOPDIR;

my $filename;
my $clength;
my $method;
my $remaddr;
my $timestamp;
my $SERVER;
my $NODE;
my %MD5;
my $debug;

sub run {
	$debug = 0;
	$putlog = "/usr/local/dsc/var/log/put-file.log";
	$TOPDIR = "/usr/local/dsc/data";

	$filename = '-';
	$clength = $ENV{CONTENT_LENGTH};
	$method = $ENV{REQUEST_METHOD} || '-';
	$remaddr = $ENV{REMOTE_ADDR} || '-';
	$timestamp = strftime("[%d/%b/%Y:%H:%M:%S %z]", localtime(time));
	$SERVER = get_envar(qw(SSL_CLIENT_S_DN_OU REDIRECT_SSL_CLIENT_OU));
	$NODE = get_envar(qw(SSL_CLIENT_S_DN_CN SSL_CLIENT_CN));
	%MD5 = ();

	umask 022;

	# Check we are using PUT method
	&reply(500, "No request method") unless defined ($method);
	&reply(500, "Request method is not PUT") if ($method ne "PUT");

	# Check we got some content
	&reply(500, "Content-Length missing or zero") if (!$clength);


	mkdir("$TOPDIR/$SERVER", 0700) unless (-d "$TOPDIR/$SERVER");
	mkdir("$TOPDIR/$SERVER/$NODE", 0700) unless (-d "$TOPDIR/$SERVER/$NODE");
	chdir "$TOPDIR/$SERVER/$NODE" || die "$TOPDIR/$SERVER/$NODE: $!";

	# Check we got a destination filename
	my $path = $ENV{PATH_TRANSLATED};
	&reply(500, "No PATH_TRANSLATED") if (!$path);
	my @F = split('/', $path);
	$filename = pop @F;
	my $TF = new File::Temp(TEMPLATE=>"put.XXXXXXXXXXXXXXXX", DIR=>'.');

	&reply(409, "File Exists") if (-f $filename);

	# Read the content itself
	my $toread = $clength;
	my $content = "";
	while ($toread > 0) {
    		my $data;
    		my $nread = read(STDIN, $data, $toread);
    		&reply(500, "Error reading content") if !defined($nread);
    		$toread -= $nread;
    		$content .= $data;
	}

	print $TF $content;
	close($TF);

	if ($filename =~ /\.xml$/) {
		&reply(500, "$filename Exists") if (-f $filename);
		&reply(500, "rename $TF $filename: $!") unless rename($TF, $filename);
		chmod 0644, $filename;
		&reply(201, "Stored $filename\n");
	} elsif ($filename =~ /\.tar$/) {
		my $tar_output = '';
		print STDERR "running tar -xzvf $TF\n" if ($debug);
		open(CMD, "tar -xzvf $TF 2>&1 |") || die;
		#
		# gnutar prints extracted files on stdout, bsdtar prints
		# to stderr and adds "x" to beginning of each line.  F!
		#
		my @files;
		while (<CMD>) {
			chomp;
			my @x = split;
			my $f = pop(@x);
			push(@files, $f);
		}
		close(CMD);
		load_md5s();
		foreach my $f (@files) {
			next if ($f eq 'MD5s');
			if (check_md5($f)) {
				$tar_output .= "Stored $f\n";
			} else {
				unlink($f);
			}
		}
		close(CMD);
		unlink($TF);
		&reply(201, $tar_output);
	} else {
		&reply(500, "unknown file type ($filename)");
	}
}

#
# Send back reply to client for a given status.
#

sub reply {
    my $status = shift;
    my $message = shift;
    my $logline;

    $clength = '-' unless defined($clength);
    $remaddr = sprintf "%-15s", $remaddr;
    $logline = "$remaddr - - $timestamp \"$method $TOPDIR/$SERVER/$NODE/$filename\" $status $clength";

    print "Status: $status\n";
    print "Content-Type: text/plain\n\n";

    if ($status >= 200 && $status < 300) {
	print $message;
    } else {
	print "Error Transferring File\n";
	print "An error occurred publishing this file: $message\n";
	$logline .= " ($message)" if defined($message);
    }

    &log($logline);
    exit(0);
}

sub log {
	my $msg = shift;
	my $lock = new File::Flock($putlog);
	if (open (LOG, ">> $putlog")) {
		print LOG "$msg\n";
		close(LOG);
	}
}

sub get_envar {
	my $val = undef;
	foreach my $name (@_) {
		last if defined($val = $ENV{$name});
	}
	&reply(500, 'No ' . join(' or ', @_)) unless defined($val);
	$val =~ tr/A-Z/a-z/;
	$val;
}

sub load_md5s {
	unless (open(M, "MD5s")) {
		warn "MD5s: $!";
		return;
	}
	while (my $line = <M>) {
		chomp $line;
		my ($hash, $fn) = split (/\s+/, $line);
		unless (defined($hash) && defined($fn)) {
			warn $line;
			next;
		}
		$MD5{$fn} = $hash;
		print STDERR "loaded $fn hash $hash\n" if ($debug);
	}
	close(M);
}

sub md5_file {
	my $fn = shift;
	my $ctx = Digest::MD5->new;
	open(F, $fn) || return "$!";
	$ctx->addfile(*F{IO});
	close(F);
	$ctx->hexdigest;
}

sub check_md5 {
	my $fn = shift;
	print STDERR "checking $fn\n" if ($debug);
	return 0 unless defined($MD5{$fn});
	my $file_hash = md5_file($fn);
	if ($MD5{$fn} eq $file_hash) {
		print STDERR "MD5s match!\n" if ($debug);
		return 1;
	}
	print STDERR "md5 mismatch for: $fn\n";
	print STDERR "orig hash = $MD5{$fn}\n";
	print STDERR "file hash = $file_hash\n";
	return 0;
}

1;
