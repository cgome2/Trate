package Trate::Lib::Movimiento;

#########################################################
#Movimiento - Clase Movimiento							#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################


use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER ESTACION);
use strict;

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
	bless($self);
	return $self;	
}

sub fechaHora {
        my ($self) = shift;
        if (@_) { $self->{FECHA_HORA} = shift }        
        return $self->{FECHA_HORA};
}


sub estacion {
        my ($self) = @_;
        if (@_) { $self->{ESTACION} = shift }
        return $self->{ESTACION};
}

sub dispensador {
        my ($self) = @_;
        if (@_) { $self->{DISPENSADOR} = shift }
        return $self->{DISPENSADOR};
}

sub supervisor {
        my ($self) = @_;
        if (@_) { $self->{SUPERVISOR} = shift }
        return $self->{SUPERVISOR};
}

sub despachador {
        my ($self) = @_;
        if (@_) { $self->{DESPACHADOR} = shift }
        return $self->{DESPACHADOR};
}

sub viaje {
        my ($self) = @_;
        if (@_) { $self->{VIAJE} = shift }
        return $self->{VIAJE};
}

sub camion {
        my ($self) = @_;
        if (@_) { $self->{CAMION} = shift }
        return $self->{CAMION};
}

sub chofer {
        my ($self) = @_;
        if (@_) { $self->{CHOFER} = shift }
        return $self->{CHOFER};
}

sub sello {
        my ($self) = @_;
        if (@_) { $self->{SELLO} = shift }
        return $self->{SELLO};
}

sub tipoReferencia {
        my ($self) = @_;
        if (@_) { $self->{TIPO_REFERENCIA} = shift }
        return $self->{TIPO_REFERENCIA};
}

sub serie {
        my ($self) = @_;
        if (@_) { $self->{SERIE} = shift }
        return $self->{SERIE};
}

sub referencia {
        my ($self) = @_;
        if (@_) { $self->{REFERENCIA} = shift }
        return $self->{REFERENCIA};
}

sub movimiento {
        my ($self) = @_;
        if (@_) { $self->{MOVIMIENTO} = shift }
        return $self->{MOVIMIENTO};
}

sub litrosEsp {
        my ($self) = @_;
        if (@_) { $self->{LITROS_ESP} = shift }
        return $self->{LITROS_ESP};
}

sub litrosReal {
        my ($self) = @_;
        if (@_) { $self->{LITROS_REAL} = shift }
        return $self->{LITROS_REAL};
}

sub costoEsp {
        my ($self) = @_;
        if (@_) { $self->{COSTO_ESP} = shift }
        return $self->{COSTO_ESP};
}

sub costoReal {
        my ($self) = @_;
        if (@_) { $self->{COSTO_REAL} = shift }
        return $self->{COSTO_REAL};
}

sub iva {
        my ($self) = @_;
        if (@_) { $self->{IVA} = shift }
        return $self->{IVA};
}

sub ieps {
        my ($self) = @_;
        if (@_) { $self->{IEPS} = shift }
        return $self->{IEPS};
}

sub status {
        my ($self) = @_;
        if (@_) { $self->{STATUS} = shift }
        return $self->{STATUS};
}

sub procesada {
        my ($self) = @_;
        if (@_) { $self->{PROCESADA} = shift }
        return $self->{PROCESADA};
}

sub transactionId {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_ID} = shift }
        return $self->{TRANSACTION_ID};
}

sub insertaMDB{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO ci_movimientos VALUES('"  .
			$self->{FECHA_HORA} . "','" .
			$self->{ESTACION} . "','" .
			$self->{DISPENSADOR} . "','" . 
			$self->{SUPERVISOR} . "','" . 
			$self->{DESPACHADOR} . "','" . 
			$self->{VIAJE} . "','" . 
			$self->{CAMION} . "','" .
			$self->{CHOFER} . "','" .
			$self->{SELLO} . "','" .
			$self->{TIPO_REFERENCIA} . "','" .
			$self->{SERIE} . "','" .
			$self->{REFERENCIA} . "','" .
			$self->{MOVIMIENTO} . "','" .
			$self->{LITROS_ESP} . "','" .
			$self->{LITROS_REAL} . "','" .
			$self->{COSTO_ESP} . "','" .
			$self->{COSTO_REAL} . "','" .
			$self->{IVA} . "','" .
			$self->{IEPS} . "','" .
			$self->{STATUS} . "','" .
			$self->{PROCESADA} . "','" .
			$self->{TRANSACTION_ID} . "')";
	LOGGER->debug("Ejecutando sql[ ". $preps . " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;
}

sub insertaInf{
	my $self = shift;
	my $connector = Trate::Lib::Informix->new();
	my $preps = "
		INSERT INTO ci_movimientos VALUES('"  .
			$self->{FECHA_HORA} . "','" .
			$self->{ESTACION} . "','" .
			$self->{DISPENSADOR} . "','" . 
			$self->{SUPERVISOR} . "','" . 
			$self->{DESPACHADOR} . "','" . 
			$self->{VIAJE} . "','" . 
			$self->{CAMION} . "','" .
			$self->{CHOFER} . "','" .
			$self->{SELLO} . "','" .
			$self->{TIPO_REFERENCIA} . "','" .
			$self->{SERIE} . "','" .
			$self->{REFERENCIA} . "','" .
			$self->{MOVIMIENTO} . "','" .
			$self->{LITROS_ESP} . "','" .
			$self->{LITROS_REAL} . "','" .
			$self->{COSTO_ESP} . "','" .
			$self->{COSTO_REAL} . "','" .
			$self->{IVA} . "','" .
			$self->{IEPS} . "','" .
			$self->{STATUS} . "','" .
			$self->{PROCESADA} . "','" .
			$self->{TRANSACTION_ID} . "')";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
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
					"dispensador='" . $self->{DISPENSADOR} . "'," .
					"supervisor='" . $self->{SUPERVISOR} . "'," .
					"despachador='" . $self->{DESPACHADOR} . "'," .
					"viaje='" . $self->{VIAJE} . "'," .
					"camion='" . $self->{CAMION} . "'," .
					"chofer='" . $self->{CHOFER} . "'," .
					"sello='" . $self->{SELLO} . "'," .
					"tipo_referencia='" . $self->{TIPO_REFERENCIA} . "'," .
					"serie='" . $self->{SERIE} . "'," .
					"referencia='" . $self->{REFERENCIA} . "'," . 
					"movimiento='" . $self->{MOVIMIENTO} . "'," .
					"litros_esp='" . $self->{LITROS_ESP} . "'," .
					"litros_real='" . $self->{LITROS_REAL} . "'," .
					"costo_esp='" . $self->{COSTO_ESP} . "'," .
					"costo_real='" . $self->{COSTO_REAL} . "'," .
					"iva='" . $self->{IVA} . "'," .
					"ieps='" . $self->{IEPS} . "'," .
					"status='" . $self->{STATUS} . "'," .
					"procesada='" . $self->{PROCESADA} . "'," .
					"transaction_id='" . $self->{TRANSACTION_ID} . "' WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;	
}

sub actualizaInf{
	my $self = shift;
	my $connector = Trate::Lib::Informix->new();
	my $preps = "
				UPDATE ci_movimientos SET fecha_hora = '" . $self->{FECHA_HORA} . "'," .
					"estacion='" . $self->{ESTACION} . "'," .
					"dispensador='" . $self->{DISPENSADOR} . "'," .
					"supervisor='" . $self->{SUPERVISOR} . "'," .
					"despachador='" . $self->{DESPACHADOR} . "'," .
					"viaje='" . $self->{VIAJE} . "'," .
					"camion='" . $self->{CAMION} . "'," .
					"chofer='" . $self->{CHOFER} . "'," .
					"sello='" . $self->{SELLO} . "'," .
					"tipo_referencia='" . $self->{TIPO_REFERENCIA} . "'," .
					"serie='" . $self->{SERIE} . "'," .
					"referencia='" . $self->{REFERENCIA} . "'," . 
					"movimiento='" . $self->{MOVIMIENTO} . "'," .
					"litros_esp='" . $self->{LITROS_ESP} . "'," .
					"litros_real='" . $self->{LITROS_REAL} . "'," .
					"costo_esp='" . $self->{COSTO_ESP} . "'," .
					"costo_real='" . $self->{COSTO_REAL} . "'," .
					"iva='" . $self->{IVA} . "'," .
					"ieps='" . $self->{IEPS} . "'," .
					"status='" . $self->{STATUS} . "'," .
					"procesada='" . $self->{PROCESADA} . "'," .
					"transaction_id='" . $self->{TRANSACTION_ID} . "' WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
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
	my $connector = Trate::Lib::Informix->new();
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
	insertaMDB($self);
	#insertaInf($self);
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

1;
#EOF