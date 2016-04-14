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

package DSC::extractor::config;

BEGIN {
	use Exporter   ();
	use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 1.00;
	@ISA         = qw(Exporter);
	@EXPORT      = qw(
	        %DATASETS
	);
	%EXPORT_TAGS = ( );
	@EXPORT_OK   = qw();
}
use vars      @EXPORT;
use vars      @EXPORT_OK;

END { }

use strict;
use warnings;

my $client_subnet2_keys =   [ qw(
	ok
	non-auth-tld
	root-servers.net
	localhost
	a-for-a
	a-for-root
	rfc1918-ptr
	funny-qclass
	funny-qtype
	src-port-zero
	malformed
	) ];

my $port_range_keys = [ qw(
0-1023 1024-2047 2048-3071 3072-4095 4096-5119 5120-6143 6144-7167 7168-8191
8192-9215 9216-10239 10240-11263 11264-12287 12288-13311 13312-14335 14336-15359 15360-16383
16384-17407 17408-18431 18432-19455 19456-20479 20480-21503 21504-22527 22528-23551 23552-24575
24576-25599 25600-26623 26624-27647 27648-28671 28672-29695 29696-30719 30720-31743 31744-32767
32768-33791 33792-34815 34816-35839 35840-36863 36864-37887 37888-38911 38912-39935 39936-40959
40960-41983 41984-43007 43008-44031 44032-45055 45056-46079 46080-47103 47104-48127 48128-49151
49152-50175 50176-51199 51200-52223 52224-53247 53248-54271 54272-55295 55296-56319 56320-57343
57344-58367 58368-59391 59392-60415 60416-61439 61440-62463 62464-63487 63488-64511 64512-65535
)];

%DATASETS = (

  qtype => {
    ndim	=> 1,
    type1	=> 'Qtype',
    outputs	=> {
      qtype => {
	keys	=> [ qw(1 2 5 6 12 15 28 33 38 255 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
      dnssec_qtype => {
	keys	=> [ qw(24 25 30 43 46 47 50 48) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  rcode => {
    ndim	=> 1,
    type1	=> 'Rcode',
    outputs	=> {
      rcode => {
	keys	=> [ qw(0 2 3 5 8 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  opcode => {
    ndim	=> 1,
    type1	=> 'Opcode',
    outputs	=> {
      opcode => {
	keys	=> [ qw(0 1 2 4 5 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  edns_version => {
    ndim	=> 1,
    type1	=> 'EDNSVersion',
    outputs	=> {
      edns_version => {
	keys	=> [ qw(none 0 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  rd_bit => {
    ndim	=> 1,
    type1	=> 'RD',
    outputs	=> {
      rd_bit => {
	keys	=> [ qw(set clr) ],
	data_merger => \&main::merge_trace,
	data_reader => \&DSC::extractor::read_data,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  tc_bit => {
    ndim	=> 1,
    type1	=> 'TC',
    outputs	=> {
      tc_bit => {
	keys	=> [ qw(set clr) ],
	data_merger => \&main::merge_trace,
	data_reader => \&DSC::extractor::read_data,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  idn_qname => {
    ndim	=> 1,
    type1	=> 'IDNQname',
    outputs	=> {
      idn_qname => {
	keys	=> [ qw(normal idn) ],
	data_merger => \&main::merge_trace,
	data_reader => \&DSC::extractor::read_data,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  do_bit => {
    ndim	=> 1,
    type1	=> 'D0',	## legacy typo!
    outputs	=> {
      do_bit => {
	keys	=> [ qw(set clr) ],
	data_merger => \&main::merge_trace,
	data_reader => \&DSC::extractor::read_data,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  client_subnet => {
    ndim	=> 1,
    type1	=> 'ClientSubnet',
    outputs	=> {
      client_subnet_count => {
	data_munger	=> \&main::accum1d_to_count,
	data_reader	=> \&DSC::extractor::read_data2,
	data_merger	=> \&main::merge_trace,
	data_writer	=> \&DSC::extractor::write_data2,
      },
      client_subnet_accum => {
	data_merger	=> \&main::merge_accum1d,
	data_reader	=> \&DSC::extractor::read_data2,
	data_writer	=> \&DSC::extractor::write_data2,
      },
    },
  },

  client_subnet2 => {
    ndim	=> 2,
    type1	=> 'Class',
    type2	=> 'ClientSubnet',
    outputs	=> {
      client_subnet2_trace => {
	keys	=> $client_subnet2_keys,
	data_munger => \&main::accum2d_to_trace,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
      client_subnet2_count => {
	keys	=> $client_subnet2_keys,
	data_munger => \&main::accum2d_to_count,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
      client_subnet2_accum => {
	keys	=> $client_subnet2_keys,
	data_munger => \&main::swap_dimensions,
	data_reader => \&DSC::extractor::read_data3,
	data_merger => \&main::merge_accum2d,
	data_writer => \&DSC::extractor::write_data3,
	data_trimer => \&main::trim_accum2d,
      },
    },
  },

  certain_qnames_vs_qtype => {
    ndim	=> 2,
    type1	=> 'CertainQnames',
    type2	=> 'Qtype',
    outputs	=> {
      certain_qnames_vs_qtype => {
	keys2	=> [ qw(1 2 5 6 12 15 28 33 38 255 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

  qtype_vs_tld => {
    ndim	=> 2,
    type1	=> 'Qtype',
    type2	=> 'TLD',
    outputs	=> {
      qtype_vs_tld => {
	keys2	=> [ qw(1 2 5 6 12 15 28 33 38 255 else) ],
	data_munger	=> \&main::swap_dimensions,
	data_reader	=> \&DSC::extractor::read_data3,
	data_merger	=> \&main::merge_accum2d,
	data_writer	=> \&DSC::extractor::write_data3,
	data_trimer	=> \&main::trim_accum2d,
      },
    },
  },

  client_addr_vs_rcode => {
    ndim	=> 2,
    type1	=> 'Rcode',
    type2	=> 'ClientAddr',
    outputs	=> {
      client_addr_vs_rcode_accum => {
	data_munger => \&main::swap_dimensions,
	data_reader => \&DSC::extractor::read_data3,
	data_merger => \&main::merge_accum2d,
	data_writer => \&DSC::extractor::write_data3,
      },
    },
  },

  direction_vs_ipproto => {
    ndim	=> 2,
    type1	=> 'Direction',
    type2	=> 'IPProto',
    outputs	=> {
      direction_vs_ipproto => {
	keys2	=> [ qw(icmp tcp udp) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

  idn_vs_tld => {
    ndim	=> 1,
    type1	=> 'TLD',
    outputs	=> {
      idn_vs_tld => {
	data_reader	=> \&DSC::extractor::read_data2,
	data_merger	=> \&main::merge_accum1d,
	data_writer	=> \&DSC::extractor::write_data2,
      },
    },
  },

  ipv6_rsn_abusers => {
    ndim	=> 1,
    type1	=> 'ClientAddr',
    outputs	=> {
      ipv6_rsn_abusers_count => {
	data_munger	=> \&main::accum1d_to_count,
	data_reader	=> \&DSC::extractor::read_data2,
	data_merger	=> \&main::merge_trace,
	data_writer	=> \&DSC::extractor::write_data2,
      },
      ipv6_rsn_abusers_accum => {
	data_reader	=> \&DSC::extractor::read_data2,
	data_merger	=> \&main::merge_accum1d,
	data_writer	=> \&DSC::extractor::write_data2,
      },
    },
  },

  qtype_vs_qnamelen => {
    ndim	=> 2,
    type1	=> 'Qtype',
    type2	=> 'QnameLen',
    outputs	=> {
      qtype_vs_qnamelen => {
	data_reader => \&DSC::extractor::read_data3,
	data_merger => \&main::merge_accum2d,
	data_writer => \&DSC::extractor::write_data3,
      },
    },
  },

  rcode_vs_replylen => {
    ndim	=> 2,
    type1	=> 'Rcode',
    type2	=> 'ReplyLen',
    outputs	=> {
      rcode_vs_replylen => {
	data_reader => \&DSC::extractor::read_data3,
	data_merger => \&main::merge_accum2d,
	data_writer => \&DSC::extractor::write_data3,
      },
    },
  },

  chaos_types_and_names => {
    ndim	=> 2,
    type1	=> 'Qtype',
    type2	=> 'Qname',
    outputs	=> {
      chaos_types_and_names => {
	keys2	=> [ qw(hostname.bind version.bind other) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

  transport_vs_qtype => {
    ndim	=> 2,
    type1	=> 'Transport',
    type2	=> 'Qtype',
    outputs	=> {
      transport_vs_qtype => {
	keys2	=> [ qw(1 2 5 6 12 15 28 33 38 255 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

  dns_ip_version_vs_qtype => {
    ndim	=> 2,
    type1	=> 'IPVersion',
    type2       => 'Qtype',
    outputs	=> {
      dns_ip_version => {
	keys2	=> [ qw(1 2 5 6 12 15 28 33 38 255 else) ],
	data_munger => \&main::munge_elsify,
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
      dns_ip_version_vs_qtype => {
	keys2	=> [ qw(1 2 5 6 12 15 28 33 38 255 else) ],
	data_munger	=> \&main::munge_elsify,
	data_reader	=> \&DSC::extractor::read_data3,
	data_merger	=> \&main::merge_accum2d,
	data_writer	=> \&DSC::extractor::write_data3,
	#data_trimer	=> \&main::trim_accum2d,
      },
    },
  },

  client_ports => {
    ndim	=> 1,
    type1	=> 'Port',
    outputs	=> {
      client_ports_count => {
	data_munger	=> \&main::accum1d_to_count,
	data_reader	=> \&DSC::extractor::read_data2,
	data_merger	=> \&main::merge_trace,
	data_writer	=> \&DSC::extractor::write_data2,
      },
      client_ports_accum => {
	data_merger	=> \&main::merge_accum1d,
	data_reader	=> \&DSC::extractor::read_data2,
	data_writer	=> \&DSC::extractor::write_data2,
      },
    },
  },

  client_port_range => {
    ndim	=> 1,
    type1	=> 'PortRange',
    outputs	=> {
      client_port_range => {
	keys        => $port_range_keys,
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  edns_bufsiz => {
    ndim	=> 1,
    type1	=> 'EDNSBufSiz',
    outputs	=> {
      edns_bufsiz => {
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  second_ld_vs_rcode => {
    ndim	=> 2,
    type1	=> 'Rcode',
    type2	=> 'SecondLD',
    outputs	=> {
      second_ld_vs_rcode_accum => {
	data_munger => \&main::swap_dimensions,
	data_reader => \&DSC::extractor::read_data3,
	data_merger => \&main::merge_accum2d,
	data_writer => \&DSC::extractor::write_data3,
      },
    },
  },

  third_ld_vs_rcode => {
    ndim	=> 2,
    type1	=> 'Rcode',
    type2	=> 'ThirdLD',
    outputs	=> {
      third_ld_vs_rcode_accum => {
	data_munger => \&main::swap_dimensions,
	data_reader => \&DSC::extractor::read_data3,
	data_merger => \&main::merge_accum2d,
	data_writer => \&DSC::extractor::write_data3,
      },
    },
  },

  pcap_stats => {
    ndim	=> 2,
    type1	=> 'ifname',
    type2	=> 'pcap_stat',
    outputs	=> {
      pcap_stats => {
	data_munger => \&main::swap_dimensions,
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

  priming_queries => {
    ndim	=> 2,
    type1	=> 'Transport',
    type2	=> 'EDNSBufSiz',
    outputs	=> {
      priming_queries => {
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

  priming_responses => {
    ndim	=> 1,
    type1	=> 'ReplyLen',
    outputs	=> {
      priming_responses => {
	data_reader => \&DSC::extractor::read_data,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data,
      },
    },
  },

  qr_aa_bits => {
    ndim	=> 2,
    type1	=> 'Direction',
    type2	=> 'QRAABits',
    outputs	=> {
      qr_aa_bits => {
	data_reader => \&DSC::extractor::read_data4,
	data_merger => \&main::merge_trace,
	data_writer => \&DSC::extractor::write_data4,
      },
    },
  },

);

1;
