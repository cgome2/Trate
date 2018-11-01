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

use Trate::Lib::Vehiculo;

my $mean = Trate::Lib::Vehiculo->new();
$mean->name('AutoTag');
$mean->rule(10001);
print $mean->assignRuleToVehicleOrcu();
