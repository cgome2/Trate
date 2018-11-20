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




#PARA ASIGNAR SALDO A UN VEHÍCULO

#1.	Insertar pase en ci_pases@transporter
#2.	Ejecutar trigger en ci_pases@transporter
#2.1	Inicia transacción BEGIN
#2.1	Se asegura que el camion del pase tenga la regla 1 (SIN CARGA POSIBLE DE COMBUSTIBLE) ejecutando la asignación de esta regla al vehiculo, esto #se hace en ORCU mediante remoteExecutor
#2.2 Genera regla de carga conforme especificación del pase FUEL_LIMIT
#2.3 Genera regla grupal de carga conforme a regla FUEL_LIMIT
#2.4 Asigna regla de carga grupal al vehiculo
#3.	Mantiene el status del pase como 'A' @transporter cuando todo se ejecuta de forma adecuada COMMIT EXITOSO
#4.	Pone el status del pase como 'F' @master cuando algo fallo COMMIT FALLIDO
#4.1 Elimina las reglas generadas como parte del ROLLBACK
#4.2 Asigna regla 1 (SIN CARGA POSIBLE DE COMBUSTIBLE) al vehiculo como parte del ROLLBACK 


exit 1;