package Trate::Lib::Movimiento;

#########################################################
#Movimiento - Clase Movimiento							#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Try::Catch;
use Trate::Lib::Constants qw(LOGGER ESTACION);
use Data::Dump qw(dump);

use strict;

our $return = 0;

sub new
{
	my $self = {};
	$self->{FECHA_HORA} = undef;
	$self->{ESTACION} = ESTACION;
	$self->{DISPENSADOR} = undef;
	$self->{SUPERVISOR} = undef;
	$self->{DESPACHADOR} = undef;
	$self->{VIAJE} = undef;
	$self->{CAMION} = undef;
	$self->{CHOFER} = undef;
	$self->{SELLO} = undef;
	$self->{TIPO_REFERENCIA} = undef;
	$self->{SERIE} = undef;
	$self->{REFERENCIA} = undef;
	$self->{MOVIMIENTO} = undef;
	$self->{LITROS_ESP} = undef;
	$self->{LITROS_REAL} = undef;
	$self->{COSTO_ESP} = undef;
	$self->{COSTO_REAL} = undef;
	$self->{IVA} = undef;
	$self->{IEPS} = undef;
	$self->{STATUS} = undef;
	$self->{PROCESADA} = undef;
	$self->{TRANSACTION_ID} = undef;
	$self->{ID} = undef;
	$self->{ID_RECEPCION} = undef;
	bless($self);
	return $self;	
}

sub fechaHora {
        my ($self) = shift;
        if (@_) { $self->{FECHA_HORA} = shift }        
        return $self->{FECHA_HORA};
}

sub estacion {
        my ($self) = shift;
        if (@_) { $self->{ESTACION} = shift }        
        return $self->{ESTACION};
}

sub dispensador {
        my ($self) = shift;
        if (@_) { $self->{DISPENSADOR} = shift }        
        return $self->{DISPENSADOR};
}

sub supervisor {
        my ($self) = shift;
        if (@_) { $self->{SUPERVISOR} = shift }        
        return $self->{SUPERVISOR};
}

sub despachador {
        my ($self) = shift;
        if (@_) { $self->{DESPACHADOR} = shift }        
        return $self->{DESPACHADOR};
}

sub viaje {
        my ($self) = shift;
        if (@_) { $self->{VIAJE} = shift }        
        return $self->{VIAJE};
}

sub camion {
        my ($self) = shift;
        if (@_) { $self->{CAMION} = shift }        
        return $self->{CAMION};
}

sub chofer {
        my ($self) = shift;
        if (@_) { $self->{CHOFER} = shift }        
        return $self->{CHOFER};
}

sub sello {
        my ($self) = shift;
        if (@_) { $self->{SELLO} = shift }        
        return $self->{SELLO};
}

sub tipoReferencia {
        my ($self) = shift;
        if (@_) { $self->{TIPO_REFERENCIA} = shift }        
        return $self->{TIPO_REFERENCIA};
}

sub serie {
        my ($self) = shift;
        if (@_) { $self->{SERIE} = shift }        
        return $self->{SERIE};
}

sub referencia {
        my ($self) = shift;
        if (@_) { $self->{REFERENCIA} = shift }        
        return $self->{REFERENCIA};
}

sub movimiento {
        my ($self) = shift;
        if (@_) { $self->{MOVIMIENTO} = shift }        
        return $self->{MOVIMIENTO};
}

sub litrosEsp {
        my ($self) = shift;
        if (@_) { $self->{LITROS_ESP} = shift }        
        return $self->{LITROS_ESP};
}

sub litrosReal {
        my ($self) = shift;
        if (@_) { $self->{LITROS_REAL} = shift }        
        return $self->{LITROS_REAL};
}

sub costoEsp {
        my ($self) = shift;
        if (@_) { $self->{COSTO_ESP} = shift }        
        return $self->{COSTO_ESP};
}

sub costoReal {
        my ($self) = shift;
        if (@_) { $self->{COSTO_REAL} = shift }        
        return $self->{COSTO_REAL};
}

sub iva {
        my ($self) = shift;
        if (@_) { $self->{IVA} = shift }        
        return $self->{IVA};
}

sub ieps {
        my ($self) = shift;
        if (@_) { $self->{IEPS} = shift }        
        return $self->{IEPS};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub procesada {
        my ($self) = shift;
        if (@_) { $self->{PROCESADA} = shift }        
        return $self->{PROCESADA};
}

sub transactionId {
        my ($self) = shift;
        if (@_) { $self->{TRANSACTION_ID} = shift }        
        return $self->{TRANSACTION_ID};
}

sub idRecepcion {
	my $self = shift;
	if(@_) { $self->{ID_RECEPCION} = shift }
	return $self->{ID_RECEPCION};
}

sub insertaMDB{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $return = 0;
	my $preps = "
		INSERT INTO ci_movimientos (" .
                        "fecha_hora," .
                        "estacion," .
                        "dispensador," .
                        "supervisor," .
                        "despachador," .
                        "viaje," .
                        "camion," .
                        "chofer," .
                        "sello," .
                        "tipo_referencia," .
                        "serie," .
                        "referencia," .
                        "movimiento," .
                        "litros_esp," .
                        "litros_real," .
                        "costo_esp," .
                        "costo_real," .
                        "iva," .
                        "ieps," .
                        "status," .
                        "procesada," .
			"transaction_id," .
			"id," .
                        "id_recepcion) " .
                        "VALUES('"  .
			$self->{FECHA_HORA} . "','" .
			$self->{ESTACION} . "'," .
			(length($self->{DISPENSADOR}) gt 0 ? ("'" . $self->{DISPENSADOR} . "'") : "NULL") . "," . 
			"'" . $self->{SUPERVISOR} . "'," . 
			(length($self->{DESPACHADOR}) gt 0 ? ("'" . $self->{DESPACHADOR} . "'") : "NULL") . "," . 
			(length($self->{VIAJE}) gt 0 ? ("'" . $self->{VIAJE} . "'") : "NULL") . "," . 
			(length($self->{CAMION}) gt 0 ? ("'" . $self->{CAMION} . "'") : "NULL") . "," .
			(length($self->{CHOFER}) gt 0 ? ("'" . $self->{CHOFER} . "'") : "NULL") . "," .
			(length($self->{SELLO}) gt 0 ? ("'" . $self->{SELLO} . "'") : "NULL") . "," .
			(length($self->{TIPO_REFERENCIA}) gt 0 ? ("'" . $self->{TIPO_REFERENCIA} . "'") : "NULL") . "," .
			"'" . $self->{SERIE} . "'," .
			(length($self->{REFERENCIA}) gt 0 ? ("'" . $self->{REFERENCIA} . "'") : "NULL") . "," .
			"'" . $self->{MOVIMIENTO} . "'," .
			(length($self->{LITROS_ESP}) gt 0 ? ("'" . $self->{LITROS_ESP} . "'") : "NULL") . "," .
			"'" . $self->{LITROS_REAL} . "','" .
			$self->{COSTO_ESP} . "','" .
			$self->{COSTO_REAL} . "','" .
			$self->{IVA} . "','" .
			$self->{IEPS} . "','" .
			$self->{STATUS} . "','" .
			$self->{PROCESADA} . "'," .
			(length($self->{TRANSACTION_ID}) gt 0 ? ("'" . $self->{TRANSACTION_ID} . "'") : "NULL") . "," .
			"NULL,'" . 
			$self->{ID_RECEPCION} . "')";
	LOGGER->debug("Ejecutando sql[ ". $preps . " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	    	$sth->finish;
		$connector->destroy();
		$return = 1;
	} catch {
		$return = 0;
	} finally {
		return $return;		
	};
}

sub insertaInf{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "
		INSERT INTO ci_movimientos (" .
			"fecha_hora," .
			"estacion," .
			"dispensador," .
			"supervisor," .
			"despachador," .
			"viaje," .
			"camion," .
			"chofer," .
			"sello," .
			"tipo_referencia," .
			"serie," .
		       	"referencia," .	
			"movimiento," .
			"litros_esp," .
			"litros_real," .
			"costo_esp," .
			"costo_real," .
			"iva," .
			"ieps," .
			"status," .
			"procesada," .
			"transaction_id) " .
			"VALUES('"  .
			$self->{FECHA_HORA} . "','" .
			$self->{ESTACION} . "'," .
			(length($self->{DISPENSADOR}) gt 0 ? ("'" . $self->{DISPENSADOR} . "'") : "NULL" ) . "," .
			"'" . $self->{SUPERVISOR} . "'," .
			(length($self->{DESPACHADOR}) gt 0 ? ("'" . $self->{DESPACHADOR} . "'") : "NULL") . "," .
			(length($self->{VIAJE}) gt 0 ? ("'" . $self->{VIAJE} . "'") : "NULL") . "," .
			(length($self->{CAMION}) gt 0 ? ("'" . $self->{CAMION} . "'") : "NULL") . "," .
			(length($self->{CHOFER}) gt 0 ? ("'" . $self->{CHOFER} . "'") : "NULL") . "," .
			(length($self->{SELLO}) gt 0 ? ("'" . $self->{SELLO} . "'") : "NULL") . "," . 
                        (length($self->{TIPO_REFERENCIA}) gt 0 ? ("'" . $self->{TIPO_REFERENCIA} . "'") : "NULL") . "," .
                        "'" . $self->{SERIE} . "'," .
                        (length($self->{REFERENCIA}) gt 0 ? ("'" . $self->{REFERENCIA} . "'") : "NULL") . "," .
                        "'" . $self->{MOVIMIENTO} . "'," .
                        (length($self->{LITROS_ESP}) gt 0 ? ("'" . $self->{LITROS_ESP} . "'") : "NULL") . "," .
                        "'" . $self->{LITROS_REAL} . "','" .
			$self->{COSTO_ESP} . "','" .
			$self->{COSTO_REAL} . "','" .
			$self->{IVA} . "','" .
			$self->{IEPS} . "','" .
			$self->{STATUS} . "','" .
			$self->{PROCESADA} . "','" .
			(length($self->{TRANSACTION_ID}) gt 0 ? ("'" . $self->{TRANSACTION_ID} . "'") : "NULL") . ")";
	
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps");
    	$sth->finish;
	$connector->destroy();
	return $self;
}

sub actualizaMDB{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
				UPDATE ci_movimientos SET fecha_hora = '" . $self->{FECHA_HORA} . "'," .
					"estacion='" . $self->{ESTACION} . "'," .
					"dispensador=" . (length($self->{DISPENSADOR}) gt 0 ? ("'" . $self->{DISPENSADOR} . "'") : "NULL") . "," .
					"supervisor='" . $self->{SUPERVISOR} . "'," .
					"despachador=" . (length($self->{DESPACHADOR}) gt 0 ? ("'" . $self->{DESPACHADOR} . "'") : "NULL") . "," .
					"viaje=" . (length($self->{VIAJE}) gt 0 ? ("'" . $self->{VIAJE} . "'") : "NULL") . "," .
					"camion=" . (length($self->{CAMION}) gt 0 ? ("'" . $self->{CAMION} . "'") : "NULL") . "," .
					"chofer=" . (length($self->{CHOFER}) gt 0 ? ("'" . $self->{CHOFER} . "'") : "NULL") . "," .
					"sello=" . (length($self->{SELLO}) gt 0 ? ("'" . $self->{SELLO} . "'") : "NULL") . "," .
					"tipo_referencia=" . (length($self->{TIPO_REFERENCIA}) gt 0 ? ("'" . $self->{TIPO_REFERENCIA} . "'") : "NULL") . "," .
					"serie='" . (length($self->{SERIE}) gt 0 ? ("'" . $self->{SERIE} . "'") : "NULL") . "," .
					"referencia=" . (length($self->{REFERENCIA}) gt 0 ? ("'" . $self->{REFERENCIA} . "'") : "NULL") . "," . 
					"movimiento='" . $self->{MOVIMIENTO} . "'," .
					"litros_esp=" . (length($self->{LITROS_ESP}) gt 0 ? ("'" . $self->{LITROS_ESP} . "'") : "NULL") . "," .
					"litros_real='" . $self->{LITROS_REAL} . "'," .
					"costo_esp='" . $self->{COSTO_ESP} . "'," .
					"costo_real='" . $self->{COSTO_REAL} . "'," .
					"iva='" . $self->{IVA} . "'," .
					"ieps='" . $self->{IEPS} . "'," .
					"status='" . $self->{STATUS} . "'," .
					"procesada='" . $self->{PROCESADA} . "'," .
					"transaction_id=" . (length($self->{TRANSACTION_ID}) gt 0 ? ("'" . $self->{TRANSACTION_ID} . "'") : "NULL") . "," .
					"id_recepcion='" . $self->{ID_RECEPCION} . "' WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;	
}

sub actualizaInf{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "
				UPDATE ci_movimientos SET fecha_hora = '" . $self->{FECHA_HORA} . "'," .
					"estacion='" . $self->{ESTACION} . "'," .
					"dispensador=" . (length($self->{DISPENSADOR}) gt 0 ? ("'" . $self->{DISPENSADOR} . "'") : "NULL") . "," .
					"supervisor='" . $self->{SUPERVISOR} . "'," .
					"despachador=" . (length($self->{DESPACHADOR}) gt 0 ? ("'" . $self->{DESPACHADOR} . "'") : "NULL") . "," .
					"viaje=" . (length($self->{VIAJE}) gt 0 ? ("'" . $self->{VIAJE} . "'") : "NULL") . "," .
					"camion=" . (length($self->{CAMION}) gt 0 ? ("'" . $self->{CAMION} . "'") : "NULL") . "," .
					"chofer=" . (length($self->{CHOFER}) gt 0 ? ("'" . $self->{CHOFER} . "'") : "NULL") . "," .
					"sello=" . (length($self->{SELLO}) gt 0 ? ("'" . $self->{SELLO} . "'") : "NULL") . "," .
                                        "tipo_referencia=" . (length($self->{TIPO_REFERENCIA}) gt 0 ? ("'" . $self->{TIPO_REFERENCIA} . "'") : "NULL") . "," .
                                        "serie=" . (length($self->{SERIE}) gt 0 ? ("'" . $self->{SERIE} . "'") : "NULL") . "," .
                                        "referencia=" . (length($self->{REFERENCIA}) gt 0 ? ("'" . $self->{REFERENCIA} . "'") : "NULL") . "," .
                                        "movimiento='" . $self->{MOVIMIENTO} . "'," .
                                        "litros_esp=" . (length($self->{LITROS_ESP}) gt 0 ? ("'" . $self->{LITROS_ESP} . "'") : "NULL") . "," .
					"litros_real='" . $self->{LITROS_REAL} . "'," .
					"costo_esp='" . $self->{COSTO_ESP} . "'," .
					"costo_real='" . $self->{COSTO_REAL} . "'," .
					"iva='" . $self->{IVA} . "'," .
					"ieps='" . $self->{IEPS} . "'," .
					"status='" . $self->{STATUS} . "'," .
					"procesada='" . $self->{PROCESADA} . "'," .
					"transaction_id=" . (length($self->{TRANSACTION_ID}) gt 0 ? ("'" . $self->{TRANSACTION_ID} . "'") : "NULL") . "' WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps");
    $sth->finish;
	$connector->destroy();	
	return $self;	
}

sub borraMDB{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "DELETE FROM ci_movimientos WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";	
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;
}

sub borraInf{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "DELETE FROM ci_movimientos WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";	
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;
}

sub inserta{
	my $self = shift;
	$self = insertaMDB($self);
	return $self;
}

sub actualiza{
	my $self = shift;
	$self = actualizaMDB($self);
	$self = actualizaInf($self);
}

sub borra{
	my $self = shift;
	$self = borraMDB($self);
	$self = borraInf($self);	
}

# To use this method it is necessary to fill up the class first
# This method insert a local instance of movimiento into trate
sub enviarMovimientoInformix {
	my $self = shift;
	my $return = 0;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "INSERT INTO ci_movimientos(fecha_hora,estacion,dispensador,supervisor,despachador,viaje,camion,chofer,sello,tipo_referencia,serie,referencia,movimiento,litros_esp,litros_real,costo_esp,costo_real,iva,ieps,status,procesada,transaction_id) VALUES(
	";
		$preps .= $self->{FECHA_HORA} eq '' ?  "NULL," : "'" . substr($self->{FECHA_HORA},0,16) . "',";
		$preps .= "'" . $self->{ESTACION} . "',";
		$preps .= $self->{DISPENSADOR} eq '' ?  "NULL," : "'" . $self->{DISPENSADOR} . "',";
		$preps .= $self->{SUPERVISOR} eq '' ?  "NULL," : "'" . $self->{SUPERVISOR} . "',";
		$preps .= $self->{DESPACHADOR} eq '' ?  "NULL," : "'" . $self->{DESPACHADOR} . "',";
		$preps .= $self->{VIAJE} eq '' ?  "NULL," : "'" . $self->{VIAJE} . "',";
		$preps .= $self->{CAMION} eq '' ?  "NULL," : "'" . $self->{CAMION} . "',";
		$preps .= $self->{CHOFER} eq '' ?  "NULL," : "'" . $self->{CHOFER} . "',";
		$preps .= $self->{SELLO} eq '' ?  "NULL," : "'" . $self->{SELLO} . "',";
		$preps .= $self->{TIPO_REFERENCIA} eq '' ?  "NULL," : "'" . $self->{TIPO_REFERENCIA} . "',";
		$preps .= $self->{SERIE} eq '' ?  "NULL," : "'" . $self->{SERIE} . "',";
		$preps .= $self->{REFERENCIA} eq '' ?  "NULL," : "'" . $self->{REFERENCIA} . "',";
		$preps .= $self->{MOVIMIENTO} eq '' ?  "NULL," : "'" . $self->{MOVIMIENTO} . "',";
		$preps .= $self->{LITROS_ESP} eq '' ?  "NULL," : "'" . $self->{LITROS_ESP} . "',";
		$preps .= $self->{LITROS_REAL} eq '' ?  "NULL," : "'" . $self->{LITROS_REAL} . "',";
		$preps .= $self->{COSTO_ESP} eq '' ?  "NULL," : "'" . $self->{COSTO_ESP} . "',";
		$preps .= $self->{COSTO_REAL} eq '' ?  "NULL," : "'" . $self->{COSTO_REAL} . "',";
		$preps .= $self->{IVA} eq '' ?  "NULL," : "'" . $self->{IVA} . "',";
		$preps .= $self->{IEPS} eq '' ?  "NULL," : "'" . $self->{IEPS} . "',";
		$preps .= $self->{STATUS} eq '' ?  "NULL," : "'" . $self->{STATUS} . "',";
		$preps .= $self->{PROCESADA} eq '' ?  "NULL," : "'" . $self->{PROCESADA} . "',";
		$preps .= $self->{TRANSACTION_ID} eq '' ?  "NULL)" : "'" . $self->{TRANSACTION_ID} . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");

	try {
		my $sth = $connector->dbh->prepare($preps) or die(LOGGER->fatal("NO PUDO OBTENER UN CONECTOR DEL FACTORY"));
		$sth->execute() or die(LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps"));
		$sth->finish;
		$connector->destroy();
		$return = 1;
	} catch {
		LOGGER->fatal("NO SE CONCRETO LA TRANSACCION SOLICITADA");
		$return = 0;
	} finally {
		LOGGER->debug("EL RESULTADO DE LA TRANSACCION ES: $return");
		return $return;
	};
}

sub getFromId {
	my $self = shift;
	if (@_) { 
		$self->{ID} = shift;
	} else {
		return $self;	
	}
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM ci_movimientos WHERE id = '" . $self->{ID} . "' LIMIT 1";	
	LOGGER->debug("Ejecutando sql[ " . $preps . " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	return $row;	
}

1;
#EOF
