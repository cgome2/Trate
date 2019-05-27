package Trate::Lib::Recibo;

##########################################
##  RecepcionCombustible - Clase Recibo	##
##                   			##
## Autor: Ramses     			##
## Fecha: Abril, 2019			##
## Revision: 1.0     			##
##                   			##
##########################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE HO_ROLE PROVEEDOR R_HEADER);
use Try::Catch;
use Data::Dump qw(dump);

sub new
{
	my $self = {};
	$self->{HEADER} = undef;
	$self->{COPIA} = undef;
	$self->{FECHA_RECIBO} = undef;
	$self->{HORA_RECIBO} = undef;
	$self->{NUMERO_RECIBO} = undef;
	$self->{BOMBA} = undef;
	$self->{PRODUCTO} = undef;
	$self->{CANTIDAD} = undef;
	$self->{VENTA} = undef;
	$self->{PPV} = PROVEEDOR;
	$self->{PASE} = undef;
	$self->{CAMION} = undef;
	$self->{VENTA_TOTAL} = undef;
	$self->{CONDUCTOR} = undef;
	$self->{DESPACHADOR} = undef;
	$self->{FLOTA} = undef;
	$self->{STATUS} = undef;
	$self->{ID_TRANSACCION} = undef;

	bless($self);
	return $self;	
}

sub header {
        my ($self) = shift;
        if (@_) { $self->{HEADER} = shift }        
        return $self->{HEADER};
}

sub copia {
        my ($self) = shift;
        if (@_) { $self->{COPIA} = shift }        
        return $self->{COPIA};
}

sub fechaRecibo {
        my ($self) = shift;
        if (@_) { $self->{FECHA_RECIBO} = shift }        
        return $self->{FECHA_RECIBO};
}

sub horaRecibo {
        my ($self) = shift;
        if (@_) { $self->{HORA_RECIBO} = shift }        
        return $self->{HORA_RECIBO};
}

sub numeroRecibo {
        my ($self) = shift;
        if (@_) { $self->{NUMERO_RECIBO} = shift }        
        return $self->{NUMERO_RECIBO};
}

sub bomba {
        my ($self) = shift;
        if (@_) { $self->{BOMBA} = shift }        
        return $self->{BOMBA};
}

sub producto {
        my ($self) = shift;
        if (@_) { $self->{PRODUCTO} = shift }        
        return $self->{PRODUCTO};
}

sub cantidad {
        my ($self) = shift;
        if (@_) { $self->{CANTIDAD} = shift }        
        return $self->{CANTIDAD};
}

sub venta {
        my ($self) = shift;
        if (@_) { $self->{VENTA} = shift }        
        return $self->{VENTA};
}

sub ppv {
        my ($self) = shift;
        if (@_) { $self->{PPV} = shift }        
        return $self->{PPV};
}

sub pase {
        my ($self) = shift;
        if (@_) { $self->{PASE} = shift }        
        return $self->{PASE};
}

sub camion {
        my ($self) = shift;
        if (@_) { $self->{CAMION} = shift }        
        return $self->{CAMION};
}

sub venta_total {
        my ($self) = shift;
        if (@_) { $self->{VENTA_TOTAL} = shift }        
        return $self->{VENTA_TOTAL};
}

sub conductor {
        my ($self) = shift;
        if (@_) { $self->{CONDUCTOR} = shift }        
        return $self->{CONDUCTOR};
}

sub despachador {
        my ($self) = shift;
        if (@_) { $self->{DESPACHADOR} = shift }        
        return $self->{DESPACHADOR};
}

sub flota {
        my ($self) = shift;
        if (@_) { $self->{FLOTA} = shift }        
        return $self->{FLOTA};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub idTransaccion {
        my ($self) = shift;
        if (@_) { $self->{ID_TRANSACCION} = shift }        
        return $self->{ID_TRANSACCION};
}

# @author CG
# Insert current object locally at transporter
# @params: No params required
# @return: current object
sub insertaRecibo {
	my $self = shift;
	my $return = 0;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO recibos( " .
			"id_recibo," .
			"id_transaccion," .
			"copia," .
			"fecha_recibo," .
			"hora_recibo," .
			"bomba," .
			"producto," .
			"cantidad," .
			"total," .
			"ppv," .
			"pase," .
			"camion," .
			"venta_total," .
			"conductor," .
			"despachador," .
			"flota," .
			"status" .
			") VALUES("  .
			("NULL,'" .
			$self->{ID_TRANSACCION} . "','" .
			$self->{COPIA} . "','" .
			$self->{FECHA_RECIBO} . "','" .
			$self->{HORA_RECIBO} . "','" .
			$self->{BOMBA} . "','" .
			$self->{PRODUCTO} . "','" .
			$self->{CANTIDAD} . "','" .
			$self->{VENTA} . "','" .
			$self->{PPV} . "','" .
			$self->{PASE} . "','" .
			$self->{CAMION} . "','" .
			$self->{VENTA_TOTAL} . "','" .
			$self->{CONDUCTOR} . "','" .
			$self->{DESPACHADOR} . "','" .
			$self->{FLOTA} . "','" .
			$self->{STATUS} . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$return = $self;
}

sub imprimirRecibo {
	my $self = shift;
	my $recibo = "\"";
	$recibo .= R_HEADER . "\n";;
	$recibo .= "\n";
	$recibo .= ($self->{COPIA} eq 0 ? "-Original-" : "Copia No. " . $self->{COPIA}) . "\n";
	$recibo .= "Fecha: " . $self->{FECHA_RECIBO} . "\n";
	$recibo .= "Hora: " . $self->{HORA_RECIBO} . "\n";
	$recibo .= "Recibo: " . $self->{NUMERO_RECIBO} . "\n";
	$recibo .= "\n";
	$recibo .= "Bomba: " . $self->{BOMBA} . "\n";
	$recibo .= "Producto: " . $self->{PRODUCTO} . "\n";
	$recibo .= "Cantidad: " . $self->{CANTIDAD} . " Litros\n";
	$recibo .= "Venta: \$" . $self->{VENTA} . " Pesos\n";
	$recibo .= "PPV: \$" . $self->{PPV} . " Pesos\n";
	$recibo .= "\n";
	$recibo .= "Pase: " . $self->{PASE} . "\n";
	$recibo .= "Camion: " . $self->{CAMION} . "\n";
	$recibo .= "Venta total: \$" . $self->{VENTA} . " Pesos\n";
	$recibo .= "\n";
	$recibo .= "\n";
	$recibo .= "Conductor: " . $self->{CONDUCTOR} . "\n";
	$recibo .= "Despachador: " . $self->{DESPACHADOR} . "\n";
	$recibo .= "Numero de flota: " . $self->{FLOTA} . "\n";
	$recibo .= "Nombre de la flota: " . R_FLOTAL . "\n";
	$recibo .= "\n";
	$recibo .= "Firma \n";
	$recibo .= "\n";
	$recibo .= "\n";
	$recibo .= "\n";
	$recibo .= "________________________\n";
	$recibo .= "\n";
	$recibo .= "\n";
	$recibo .= "\n";
	$recibo .= "\n";
	$recibo .= "\n";
	\"";

	my $comando = "echo " . $recibo . " | lp -d BIXOLON";
	system $comando;

	my $cut = "\"\\\\\$(printf %o 27)i\"";

	$comando = "printf " . $cut . " | lp -d BIXOLON";
	#print $comando . "\n";
	system $comando;	
}

1;
#EOF