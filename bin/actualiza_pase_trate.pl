#!/usr/bin/perl

use Trate::Lib::Pase;
use Try::Catch;
use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);

use warnings;

# (1) salir a menos que envien los 16 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

if ($num_args != 16) {
	LOGGER->fatal("Uso:perl actualiza_pase_trate.pl accion id fecha_solicitud pase viaje camion chofer litros contingencia status litros_real litros_esp viaje_sust supervisor observaciones ultima_modificacion");
    exit $return;
}
my ($accion,$id,$fecha_solicitud,$pase,$viaje,$camion,$chofer,$litros,$contingencia,$status,$litros_real,$litros_esp,$viaje_sust,$supervisor,$observaciones,$ultima_modificacion) = @ARGV;
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

LOGGER->debug("\npase " . dump($PASE));
my $mean = Trate::Lib::Mean->new();
$mean->name($PASE->camion());

try {
	my $resultado = ($accion eq 1 ? $mean->desactivarMean() : $mean->activarMean());	
	LOGGER->info("Resultado de activar/desactivar mean " . dump($resultado));

	if($resultado->{rc} eq 0){
		$return = $PASE->actualizaInformix() or warn(LOGGER->fatal("ERROR AL ENVIAR PASE A INFORMIX"));
	}
} catch {
    $return = 0;
} finally {
	LOGGER->debug("el return: $return");
	($return == 0 ? $PASE->queueMe() : exit $return);
	exit $return;
};