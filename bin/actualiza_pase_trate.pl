#!/usr/bin/perl

use Trate::Lib::Pase;
use Try::Catch;
use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER WITHINFORMIX INFORMIX_SERVER);
use Data::Dump qw(dump);

$ENV{INFORMIXSERVER} = INFORMIX_SERVER;

use warnings;

# (1) salir a menos que envien los 16 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

if ($num_args != 17) {
	LOGGER->fatal("Uso:perl actualiza_pase_trate.pl accion id fecha_solicitud pase viaje camion chofer litros contingencia status litros_real litros_esp viaje_sust supervisor observaciones ultima_modificacion old_mean");
    exit $return;
}
my ($accion,$id,$fecha_solicitud,$pase,$viaje,$camion,$chofer,$litros,$contingencia,$status,$litros_real,$litros_esp,$viaje_sust,$supervisor,$observaciones,$ultima_modificacion,$old_mean) = @ARGV;
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
LOGGER->debug(dump($PASE));

my $mean = Trate::Lib::Mean->new();
$mean->name($old_mean);
$mean->desactivarMean();

$mean->name($camion);
my $resultado = ($accion eq 1 ? $mean->desactivarMean() : $mean->activarMean());	

if($resultado->{rc} eq 0){
	try { 
		if(WITHINFORMIX eq 1){
			$return = $PASE->actualizaInformix() or warn(LOGGER->fatal("ERROR AL ENVIAR PASE A INFORMIX"));
		} else {
			$return = 1;
		}
	} catch {
		$return = 0;
	} finally {
		print $return;
	};
}
print $return;
