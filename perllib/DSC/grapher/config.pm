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

package DSC::grapher::config;

BEGIN {
        use Exporter   ();
        use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
        $VERSION     = 1.00;
        @ISA         = qw(Exporter);
        @EXPORT      = qw(
		&read_config
        );
        %EXPORT_TAGS = ( );
        @EXPORT_OK   = qw();
}
use vars      @EXPORT;
use vars      @EXPORT_OK;

use IO::File;	# for debugging

END { }

use strict;
use warnings;

my %CONFIG;

sub read_config {
	my $f = shift;
	open(F, $f) || die "$f: $!\n";
	while (<F>) {
		my @x = split;
		next unless @x;
		my $directive = shift @x;
		if ($directive eq 'server') {
			my $servername = shift @x;
			push (@{$CONFIG{serverlist}}, $servername);
			foreach my $t (@x) {
				my $fn = $t;	# fake name
				my @rn = ($t);	# real name
				if ($fn =~ /^([^=]+)=(.*)$/) {
					$fn = $1;
					@rn = split(/,/, $2);
				}
				push (@{$CONFIG{servers}{$servername}}, $fn);
				$CONFIG{nodemap}{$servername}{$fn} = \@rn;
			}
		} elsif ($directive =~ /windows$/) {
			$CONFIG{$directive} = \@x;
		} elsif ($directive eq 'embargo') {
			$CONFIG{$directive} = $x[0];
		} elsif ($directive eq 'anonymize_ip') {
			$CONFIG{$directive} = 1;
		} elsif ($directive eq 'no_http_header') {
			$CONFIG{$directive} = 1;
		} elsif ($directive eq 'hide_nodes') {
			$CONFIG{$directive} = 1;
		} elsif ($directive eq 'timezone') {
			$ENV{TZ} = $x[0];
		} elsif ($directive eq 'domain_list') {
			my $listname = shift @x;
			die "Didn't find list-name after domain_list" unless defined($listname);
			push(@{$CONFIG{domain_list}{$listname}}, @x);
		} elsif ($directive eq 'valid_domains') {
			my $server = shift @x;
			die "Didn't find server-name after valid_domains" unless defined($server);
			my $listname = shift @x;
			die "domain list-name $listname does not exist"
				unless defined($CONFIG{domain_list}{$listname});
			$CONFIG{valid_domains}{$server} = $listname;
		} elsif ($directive eq 'debug_file') {
			my $fn = shift @x;
			$CONFIG{debug_fh} = new IO::File("> $fn");
		} elsif ($directive eq 'debug_level') {
			$CONFIG{debug_level} = shift @x;
		}
	}
	close(F);
	\%CONFIG;
}

sub get_valid_domains {
	my $server = shift;
	#print STDERR "get_valid_domains: server is $server\n";
	my $listname = $CONFIG{valid_domains}{$server};
	#print STDERR "get_valid_domains: listname is $listname\n";
	return (undef) unless defined ($listname);
	return (undef) unless defined ($CONFIG{domain_list}{$listname});
	#print STDERR "get_valid_domains: $server valid domain list is $listname\n";
	@{$CONFIG{domain_list}{$listname}};
}

1;
