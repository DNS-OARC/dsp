#!/usr/bin/env perl
#
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

use strict;
use warnings;
use Digest::MD5;

my $MD5_frequency = 500;

foreach my $fn (@ARGV) {
	do_file($fn);
}


sub do_file {
    my $fn = shift;
    open(I, $fn) or die "$fn: $!";
    open(O, ">$fn.fixed") or die "$fn.fixed: $!";
    my $nl = 0;
    my $md = Digest::MD5->new;
    my $buf = '';
    my $errs = 0;
    while (<I>) {
        $nl++;
	$buf .= $_;
        if (/^#MD5 (\S+)/) {
                if ($1 ne $md->hexdigest) {
                        warn "$fn: MD5 checksum error at line $nl\n";
                        $errs++;
                } else {
			#print "$fn: good up to line $nl\n";
			print O $buf;
		}
		$buf = '';
                next;
        }
        $md->add($_);
    }
    if ($errs == 0) {
	unlink("$fn.fixed");
#	print "$fn: okay\n";
    } else {
	# give fixed file the same uid:gid as old file
	my @sb = stat($fn);
	chown $sb[4], $sb[5], "$fn.fixed";
	rename ("$fn", "$fn.bad");
	rename ("$fn.fixed", "$fn");
	print "$fn: FIXED\n";
    }
}
