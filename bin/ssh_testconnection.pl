#!/usr/bin/perl
use strict;
use Trate::Lib::RemoteExecutor;

my $remex = Trate::Lib::RemoteExecutor->new();
my $query = "SELECT * FROM devices WHERE NAME LIKE '%e%'";
$remex->remoteQuery($query);
exit;
