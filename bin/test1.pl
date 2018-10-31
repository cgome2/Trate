#!/usr/bin/perl
##########################################################################
# Name:
# Description:
# Author:
# Adapted by:
# Date :
# Version:
##########################################################################
use strict;
use warnings;
use POSIX qw(strftime);
use Orpak::LIB;
use Orpak::Constants;
use DBI;
use Orpak::DbLib;
use Socket;
use File::Copy;
use Orpak::Trate::Trate_functions;


my $utime=time;#unix time
my @time=localtime $utime;
my $stime=strftime("%F %T",@time);#time as outputted to string, 'yyyy-mm-dd hh:mm:ss'

printf $stime;
