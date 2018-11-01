#!/usr/bin/perl
use strict;
use Trate::Lib::RemoteExecutor;

my $remex = Trate::Lib::RemoteExecutor->new();
my $query = "SELECT * FROM means WHERE status LIKE '%2%'";
$remex->remoteQuery($query);
exit;
