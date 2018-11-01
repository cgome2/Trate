#!/usr/bin/perl -w
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use strict;
use Trate::Lib::Rule;
use Trate::Lib::LimitRule;
use Trate::Lib::GroupRule;
use Trate::Lib::Vehiculo;

# (1) salir a menos que envien los 3 argumentos
my $num_args = $#ARGV + 1;
system("echo \"Executing with $num_args arguments pase: $ARGV[0] camion: $ARGV[1] litros: $ARGV[2]\" >> /tmp/logfile.log");
if ($num_args != 3) {
    print "\nUso: assign_pase_orcu.pl pase camion litros\n";
    exit;
}

my ($pase,$camion,$litros) = @ARGV;
my $rule = Trate::Lib::Rule->new();
my $limitRule = Trate::Lib::LimitRule->new();
my $groupRule = Trate::Lib::GroupRule->new();
my $mean = Trate::Lib::Vehiculo->new();

#Agregar la definicion de la regla
$rule->id($pase);
$rule->ruleId($pase);
$rule->ruleType(1);
$rule->name($pase . "P" . $litros . "Litros");
$rule->description($rule->name());
$rule->status(2);
$rule->contentSummary("Limit: Type:Volume; Single:" . $litros . ";");
print $rule->insertarOrcu() . "\n";

#Agregar la regla de límite de combustible
$limitRule->id($pase);
$limitRule->single($litros);
$limitRule->type(1);
$limitRule->insertarOrcu() . "\n";

#Agregar la regla de grupo
$groupRule->id($pase + 10000000);
$groupRule->limits($pase);
$groupRule->visits(0);
$groupRule->fuel(0);
$groupRule->name($rule->name());
$groupRule->description($rule->description());
$groupRule->contentSummary($rule->contentSummary());
print $groupRule->insertarOrcu() . "\n";

#Asignar regla de grupo a vehículo (mean)
$mean->name($camion);
$mean->rule($groupRule->id());
print $mean->assignRuleToVehicleOrcu();
