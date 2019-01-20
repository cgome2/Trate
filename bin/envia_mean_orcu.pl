#!/usr/bin/perl
use strict;
use warnings;

use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;
use Data::Dump qw(dump);


my $num_args = $#ARGV + 1;

my $return = 0;

if ($num_args != 15) {
	LOGGER->fatal("Uso:perl envia_mean_orcu.pl id rule dept_id employee_type available_amount fleet_id hardware_type auttyp model_id name odometer plate status string type");
    print $return;
}
my ($id,$rule,$dept_id,$employee_type,$available_amount,$fleet_id,$hardware_type,$auttyp,$model_id,$name,$odometer,$plate,$status,$string,$type) = @ARGV;

my $mean = Trate::Lib::Mean->new();
$mean->id($id);
$mean->rule($rule);
$mean->deptId($dept_id);
$mean->employeeType($employee_type);
$mean->availableAmount($available_amount);
$mean->fleetId($fleet_id);
$mean->hardwareType($hardware_type);
$mean->auttyp($auttyp);
$mean->modelId($model_id);
$mean->name($name);
$mean->odometer($odometer);
$mean->plate($plate);
$mean->status($status);
$mean->string($string);
$mean->type($type);
LOGGER->debug(dump($mean));
try {
	$return = $mean->createMeanOrcu();
} catch {
	$return = 0;
};
LOGGER->debug("RETURN en la evaluación del trigger>" . $return);
print $return;
