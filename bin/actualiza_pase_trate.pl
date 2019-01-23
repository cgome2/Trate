#!/usr/bin/perl

use Trate::Lib::Pase;
use Try::Catch;
use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER WITHINFORMIX INFORMIX_SERVER);
use Data::Dump qw(dump);

$ENV{INFORMIXSERVER} = INFORMIX_SERVER;

use warnings;

# (1) salir a menos que envien los 19 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

if ($num_args != 19) {
	LOGGER->fatal("Uso:perl actualiza_pase_trate.pl accion id fecha_solicitud pase viaje camion chofer litros contingencia status litros_real litros_esp viaje_sust supervisor observaciones old_status mean_contingencia ultima_modificacion old_mean");
    exit $return;
}

my ($accion,$id,$fecha_solicitud,$pase,$viaje,$camion,$chofer,$litros,$contingencia,$status,$litros_real,$litros_esp,$viaje_sust,$supervisor,$observaciones,$old_status,$mean_contingencia,$ultima_modificacion,$old_mean) = @ARGV;
my $PASE = Trate::Lib::Pase->new();
$PASE->fechaSolicitud($fecha_solicitud);
$PASE->pase($pase);
$PASE->viaje($viaje);
$PASE->camion($camion);
$PASE->chofer($chofer);
$PASE->litros($litros);
$PASE->contingencia($contingencia);
$PASE->status($status);
$PASE->litrosReal($litros_real);
$PASE->litrosEsp($litros_esp);
$PASE->viajeSust($viaje_sust);
$PASE->supervisor($supervisor);
$PASE->observaciones($observaciones);
$PASE->meanContingencia($mean_contingencia);
$PASE->ultimaModificacion($ultima_modificacion);
LOGGER->debug(dump($PASE));

my $mean = Trate::Lib::Mean->new();

# Reasignacion desactiva camion y activa nuevo dispositivo asignado
if(length($mean_contingencia) gt 0 && ($status eq "T" || $status eq "R" )){
	$mean->name($camion);
	$mean->desactivarMean();
	
	$mean->name($mean_contingencia);
	$mean->activarMean();
}

# Si ya trae un mean de contingencia y se cierra el pase de forma contingencia o manual
# Se desactiva el mean_contingencia y el camion del pase
if(length($mean_contingencia) gt 0 && ($status eq "C" || $status eq "M" )){
	$mean->name($camion);
	$mean->desactivarMean();
	
	$mean->name($mean_contingencia);
	$mean->desactivarMean();	
}

# Si no trae un mean de contingencia y se reabre el pase
# Se sactiva el camion
if(length($mean_contingencia) le 0 && ($status eq "R")){
	$mean->name($mean_contingencia);
	$mean->activarMean();
}

# Despachado desactiva camion
if($status eq "D"){
	$mean->name($camion);
	$mean->desactivarMean();	
}

try { 
	if(WITHINFORMIX eq 1){
		$return = $PASE->actualizaInformix($old_status) or warn(LOGGER->fatal("ERROR AL ENVIAR PASE A INFORMIX"));
	} else {
		$return = 1;
	}
} catch {
	$return = 0;
} finally {
	$return = $return;
};

print $return;
