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

package DSC::mysql;

use DBI;
use Data::Dumper;
use POSIX;

use strict;

BEGIN {
        use Exporter   ();
        use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
        $VERSION     = 1.00;
        @ISA         = qw(Exporter);
        @EXPORT      = qw(
		&mysql_connect
		&mysql_disconnect
		&mysql_table_exists
		&mysql_create_table
		&mysql_create_2d_table
		&mysql_insert
		&mysql_store
		&mysql_store_accum
		&mysql_selectall_hashref
	 );
        %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
        @EXPORT_OK   = qw();
}
use vars      @EXPORT;
use vars      @EXPORT_OK;

END { }

my $time_fmt = '%Y-%m-%d %H:%M:%S';
my $dbh = undef;

sub tablename {
	my $node = shift || die;
	my $table = shift || die;
	$node =~ s/-/_/g;
	$node =~ s/\+/_/g;
	"${node}_${table}";
}

sub mysql_connect {
	my $dbname = shift || die;
	$dbname =~ s/-/_/g;
	my $dsn = "DBI:mysql:host=localhost;database=$dbname";
	if (defined ($ENV{GATEWAY_INTERFACE})) {
		$dsn .= ";mysql_read_default_file=/httpd/conf/my.conf";
	} else {
		$dsn .= ";mysql_read_default_file=$ENV{HOME}/.my.cnf";
	}
	$dbh = DBI->connect($dsn, undef, undef)
        	or die "Cannot connect to mysql server";
	1;
}

sub mysql_disconnect {
	$dbh->disconnect();
	$dbh = undef;
}

sub mysql_table_exists {
	my $a1 = shift;
	my $a2 = shift;
	my $tablename = defined($a2) ? tablename($a1,$a2) : $a1;
	my $sql = "show tables like '${tablename}';";
	return $dbh->selectrow_array($sql) ? 1 : 0;
}

sub mysql_create_table {
        my $node = shift || die;
        my $table = shift || die;
        my $cols = shift || die;
        my $tablename = tablename($node,$table);
	my @safecols = @$cols;
	grep(s/[-\.]/_/g, @safecols);
	return 1 if &mysql_table_exists($tablename);
	my $sql = "create table ${tablename} ("
        	. join(',', 'time datetime', map("$_ int", @safecols))
        	. ");";
	print STDERR $sql;
	return if ($main::debugonly);
	$dbh->do($sql) or die "$sql";
}

sub mysql_create_2d_table {
        my $node = shift || die;
        my $table = shift || die;
	my $keycol = shift || die;
        my $cols = shift || die;
        my $tablename = tablename($node,$table);
	my @safecols = @$cols;
	grep(s/[-\.]/_/g, @safecols);
	return 1 if &mysql_table_exists($tablename);
	my $sql = "create table ${tablename} ("
        	. join(',',
			'time datetime',
			$keycol,
			map("$_ int", @safecols)
		)
        	. ");";
	print STDERR $sql;
	return if ($main::debugonly);
	$dbh->do($sql) or die "$sql";
}

sub mysql_insert {
        my $node = shift || die;
        my $table = shift || die;
        my $ts = shift || die;
        my $cols = shift || die;
        my $vals = shift || die;
        my $tablename = tablename($node,$table);
        my $sql;
        $sql = "insert into ${tablename}"
                . " (" . join(',', 'time', @$cols) . ")"
                . " values"
                . " (" . join(',', map($dbh->quote($_), $ts, @$vals)) . ")"
                . ";";
	if ($main::debugonly) {
		print STDERR $sql;
		return;
	}
	$dbh->do($sql) or die "$sql";
}

sub mysql_update_add {
	my $node = shift || die;
	my $table = shift || die;
	my $time = shift || die;
	my $val = pop;
	my @cols = @_;
	my @quoted;
	my $tablename = tablename($node,$table);
	my $sql;
	my $k;
	$sql = "update ${tablename}";
	$sql .= " set count=count+$val";
	$sql .= " where time='$time'";
	$sql .= " and key1='$k'" if ($k = shift @cols);
	$sql .= " and key2='$k'" if ($k = shift @cols);
	$sql .= ";";
	if ($main::debugonly) {
		print STDERR $sql;
		return;
	}
	my $count = $dbh->do($sql);
	$count + 0;	# force numeric context
}

sub mysql_update_add_or_insert {
	mysql_update_add(@_) or mysql_insert(@_);
}

sub mysql_store_common {
	my $SERVER = shift || die "expected SERVER";
	my $NODE = shift || die "expected NODE";
	my $TBL = shift || die "expected TBL";
	my $dim = shift || die "expected dim";
	my $ts = shift || die "expected ts";
	my $hashref = shift || die "expected hashref";
	my $func = shift || die "expected func";
	my $formatted_time = strftime($time_fmt, gmtime($ts));
	my $already_connected = defined($dbh) ? 1 : 0;

	&mysql_connect($SERVER) unless $already_connected;
	&mysql_create_table($NODE, $TBL, [keys %$hashref]);

	die unless ($dim == 1);
	&$func($NODE,$TBL,$formatted_time,[keys %$hashref],[values %$hashref]);
	&mysql_disconnect() unless $already_connected;
}

sub mysql_store {
	mysql_store_common(@_, \&mysql_insert);
}

sub mysql_store_accum {
	mysql_store_common(@_, \&mysql_update_add_or_insert);
}

sub mysql_selectall_hashref {
	my $q = shift || die;
	my $keyfield = shift || die;
	return $dbh->selectall_hashref("select $q;", $keyfield);
}

1;
