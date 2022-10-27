#! /usr/bin/perl -w
# $Id: check_hgsc_ftp,v 1.1 2007/01/02 16:11:33 root Exp root $

#
# Checks an ftp site
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);  if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA
#
use strict;
use Getopt::Long;
use Net::FTP;
use vars qw($PROGNAME);
use lib "/usr/lib/icinga2/custom_plugins" ;
use utils qw (%ERRORS &print_revision &support);

sub print_help ();
sub print_usage ();

my ($opt_host, $opt_user, $opt_pass, $opt_dir, $opt_file, $opt_v, $opt_h) = 
   ("",        "",        "",        "",       "");
my $result;

my $outstring="";

$PROGNAME="check_ftp";


GetOptions(
	"version"	=> \$opt_v,
	"help"		=> \$opt_h,
	"host=s"	=> \$opt_host,
	"user=s"	=> \$opt_user,
	"password=s"	=> \$opt_pass,
	"dir=s"		=> \$opt_dir,
	"file=s"	=> \$opt_file,
	);

if ($opt_v) {
	print_revision($PROGNAME, '$Id: check_hgsc_ftp,v 1.1 2007/01/02 16:11:33 root Exp root $');
        exit $ERRORS{'OK'};
}

if ($opt_h) {
	print_help();
        exit $ERRORS{'OK'};
}

unless ($opt_host) {
	print "must supply hostname with --host\n";
	print_usage();
	exit $ERRORS{'UNKNOWN'};
}

$result = 'OK';

my $ftp;
unless ($ftp = Net::FTP -> new($opt_host,
				Debug => 0,
				Passive => 1 #must be in passive mode to work
	)) {

	$result="CRITICAL";
	print "CRITICAL: Cannot connect to host: $opt_host\n";
	exit $ERRORS{$result};
} else {
	$outstring .="Connected to $opt_host, ";
}

$opt_user ||= "anonymous";
$opt_pass||= "nagios";

unless ($ftp->login($opt_user, $opt_pass)){
        $result="CRITICAL";
	print "CRITICAL: Cannot login as user $opt_user\n";
	exit $ERRORS{$result};
} else {
	$outstring .="logged in as $opt_user, ";
}

if ($opt_dir ne ""){
	unless ($ftp->cwd($opt_dir)){
	        $result="CRITICAL";
		print "CRITICAL: Cannot change directory to $opt_dir\n";
		exit $ERRORS{$result};
	} else {
		$outstring .="changed directory to $opt_dir, ";
	}
}

if ($opt_file ne ""){
	unless ($ftp->get($opt_file, "/dev/null")){
	        $result="CRITICAL";
		print "CRITICAL: Cannot get file: $opt_file\n";
		exit $ERRORS{$result};
	} else {
		$outstring .="downloaded $opt_file, ";
	}
}

print "OK: $outstring\n";
exit $ERRORS{$result};

sub print_usage () {
	print "Usage:\n";
	print "  $PROGNAME --host <host> [--user <user>][--password <password>][--dir <dir>][--file <file>]\n";
	print "  $PROGNAME [--help]\n";
	print "  $PROGNAME [--version]\n";
}

sub print_help () {
	print_revision($PROGNAME, '$Id: check_hgsc_ftp,v 1.1 2007/01/02 16:11:33 root Exp root $');
	print "Copyright (c) 2007 Paul Archer\n\n";
	print_usage();
	print "\n";
	print "  --host		host to check\n";
	print "  --user		username to use (uses 'anonymous' if user not given)\n";
	print "  --password		password to use (uses 'nagios' if password not given)\n";
	print "  --dir			cd to this directory (stays in base directory otherwise)\n";
	print "  --file		file to retrieve (can be absolute path, or relative to 'dir' (or / if no 'dir' given))\n";
	print "\n";
	print "Will return CRITICAL if host cannot be contacted or logged into.\n";
	print "Will return WARNING if specified directory or file isn't accessible.\n";
	print "\n";
	support();
}
