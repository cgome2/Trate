#!/usr/bin/perl

use Trate::Lib::Pase;
use Try::Catch;
use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);

use strict;

# (1) salir a menos que envien los 21 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

#if ($num_args != 15) {
#	LOGGER->fatal("Uso: actualiza_pase_trate.pl fecha_solicitud pase viaje camion chofer litros contingencia status litros_real litros_esp viaje_sust supervisor observaciones ultima_modificacion");
#    exit $return;
#}
my ($id,$fecha_solicitud,$pase,$viaje,$camion,$chofer,$litros,$contingencia,$status,$litros_real,$litros_esp,$viaje_sust,$supervisor,$observaciones,$ultima_modificacion) = @ARGV;
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
$PASE->ultimaModificacion($ultima_modificacion);

try {
	LOGGER->debug("\npase " . dump($PASE));
	my $mean = Trate::Lib::Mean->new();
	$mean->name($PASE->camion());
	LOGGER->debug("status " . $status . "\n");
	my $resultado = ($status == 'D' ? $mean->desactivarMean() : $mean->activarMean());	
	LOGGER->info("Resultado de activar/desactivar mean" . $resultado->{rc_desc});
	if($resultado->{rc} eq "0"){
		$return = $PASE->actualizaInformix() or die(LOGGER->fatal("ERROR AL ENVIAR PASE A INFORMIX"));
	} else {
		LOGGER->debug("VALIO VERGA " . $resultado->{rc});
	}
} catch {
    $return = 0;
} finally {
	print "$return\n";
	exit $return;
};
