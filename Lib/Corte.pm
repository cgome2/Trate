#########################################################
#Corte - Clase Corte									#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Corte;

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use strict;

sub new
{
	my $self = {};
	$self->{FECHA_HORA} = undef;
	$self->{ESTACION} = undef;
	$self->{DISPENSADOR} = undef;
	$self->{ENTREGA_TURNO} = undef;
	$self->{RECIBE_TURNO} = undef;
	$self->{FECHA_HORA_RECEP} = undef;
	$self->{INVENTARIO_RECIBIDO_LTS} = undef;
	$self->{MOVTOS_TURNO_LTS} = undef;
	$self->{INVENTARIO_ENTREGADO_LTS} = undef;
	$self->{DIFERENCIA_LTS} = undef;
	$self->{INVENTARIO_RECIBIDO_CTO} = undef;
	$self->{MOVTOS_TURNO_CTO} = undef;
	$self->{INVENTARIO_ENTREGADO_CTO} = undef;
	$self->{DIFERENCIA_CTO} = undef;
	$self->{AUTORIZO_DIF} = undef;
	$self->{CONTADOR_INICIAL} = undef;
	$self->{FOLIO} = undef;
	$self->{CONTADOR_FINAL} = undef;
	$self->{VSERIE} = undef;
	$self->{PROCESADA} = undef;
	bless($self);
	return $self;	
}

sub fechaHora {
        my ($self) = @_;
        return $self->{FECHA_HORA};
}

sub estacion {
        my ($self) = @_;
        return $self->{ESTACION};
}

sub dispensador {
        my ($self) = @_;
        return $self->{DISPENSADOR};
}

sub entregaTurno {
        my ($self) = @_;
        return $self->{ENTREGA_TURNO};
}

sub recibeTurno {
        my ($self) = @_;
        return $self->{RECIBE_TURNO};
}

sub fechaHoraRecep {
        my ($self) = @_;
        return $self->{FECHA_HORA_RECEP};
}

sub inventarioRecibidoLts {
        my ($self) = @_;
        return $self->{INVENTARIO_RECIBIDO_LTS};
}

sub movtosTurnoLts {
        my ($self) = @_;
        return $self->{MOVTOS_TURNO_LTS};
}

sub inventarioEntregadoLts {
        my ($self) = @_;
        return $self->{INVENTARIO_ENTREGADO_LTS};
}

sub diferenciaLts {
        my ($self) = @_;
        return $self->{DIFERENCIA_LTS};
}

sub inventarioRecibidoCto {
        my ($self) = @_;
        return $self->{INVENTARIO_RECIBIDO_CTO};
}

sub movtosTurnoCto {
        my ($self) = @_;
        return $self->{MOVTOS_TURNO_CTO};
}

sub inventarioEntregadoCto {
        my ($self) = @_;
        return $self->{INVENTARIO_ENTREGADO_CTO};
}

sub diferenciaCto {
        my ($self) = @_;
        return $self->{DIFERENCIA_CTO};
}

sub autorizoDif {
        my ($self) = @_;
        return $self->{AUTORIZO_DIF};
}

sub contadorInicial {
        my ($self) = @_;
        return $self->{CONTADOR_INICIAL};
}

sub folio {
        my ($self) = @_;
        return $self->{FOLIO};
}

sub contadorFinal {
        my ($self) = @_;
        return $self->{CONTADOR_FINAL};
}


sub vserie {
        my ($self) = @_;
        return $self->{VSERIE};
}

sub procesada {
        my ($self) = @_;
        return $self->{PROCESADA};
}

sub insertaMDB{
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO ci_movimientos VALUES('"  .
			$self->{FECHA_HORA} . "','" .
			$self->{ESTACION} . "','" .
			$self->{DISPENSADOR} . "','" . 
			$self->{ENTREGA_TURNO} . "','" . 
			$self->{RECIBE_TURNO} . "','" . 
			$self->{FECHA_HORA_RECEP} . "','" . 
			$self->{INVENTARIO_RECIBIDO_LTS} . "','" . 
			$self->{MOVTOS_TURNO_LTS} . "','" . 
			$self->{INVENTARIO_ENTREGADO_LTS} . "','" . 
			$self->{DIFERENCIA_LTS} . "','" . 
			$self->{INVENTARIO_RECIBIDO_CTO} . "','" . 
			$self->{MOVTOS_TURNO_CTO} . "','" . 
			$self->{INVENTARIO_ENTREGADO_CTO} . "','" . 
			$self->{DIFERENCIA_CTO} . "','" . 
			$self->{AUTORIZO_DIF} . "','" . 
			$self->{CONTADOR_INICIAL} . "','" . 
			$self->{FOLIO} . "','" . 
			$self->{CONTADOR_FINAL} . "','" . 
			$self->{VSERIE} . "','" . 
			$self->{PROCESADA} . "')";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$connector->destroy();
}

sub insertaInf {
	my $connector = Trate::Lib::Informix->new();
	my $preps = "
		INSERT INTO ci_movimientos VALUES('"  .
			$self->{FECHA_HORA} . "','" .
			$self->{ESTACION} . "','" .
			$self->{DISPENSADOR} . "','" . 
			$self->{ENTREGA_TURNO} . "','" . 
			$self->{RECIBE_TURNO} . "','" . 
			$self->{FECHA_HORA_RECEP} . "','" . 
			$self->{INVENTARIO_RECIBIDO_LTS} . "','" . 
			$self->{MOVTOS_TURNO_LTS} . "','" . 
			$self->{INVENTARIO_ENTREGADO_LTS} . "','" . 
			$self->{DIFERENCIA_LTS} . "','" . 
			$self->{INVENTARIO_RECIBIDO_CTO} . "','" . 
			$self->{MOVTOS_TURNO_CTO} . "','" . 
			$self->{INVENTARIO_ENTREGADO_CTO} . "','" . 
			$self->{DIFERENCIA_CTO} . "','" . 
			$self->{AUTORIZO_DIF} . "','" . 
			$self->{CONTADOR_INICIAL} . "','" . 
			$self->{FOLIO} . "','" . 
			$self->{CONTADOR_FINAL} . "','" . 
			$self->{VSERIE} . "','" . 
			$self->{PROCESADA} . "')";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps");
	$connector->destroy();	
	
}

sub actualizaMDB{
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
				UPDATE ci_movimientos SET fecha_hora = '" . $self->{FECHA_HORA} . "'," .
					"estacion='" . $self->{ESTACION} . "'," .
					"dispensador='" . $self->{DISPENSADOR} . "'," .
					"entrega_turno='" . $self->{ENTREGA_TURNO} . "'," . 
					"recibe_turno='" . $self->{RECIBE_TURNO} . "'," . 
					"fecha_hora_recep='" . $self->{FECHA_HORA_RECEP} . "'," . 
					"inventario_recibido_lts='" . $self->{INVENTARIO_RECIBIDO_LTS} . "'," . 
					"movtos_turno_lts='" . $self->{MOVTOS_TURNO_LTS} . "'," . 
					"inventario_entregado_lts='" . $self->{INVENTARIO_ENTREGADO_LTS} . "'," . 
					"diferencia_lts='" . $self->{DIFERENCIA_LTS} . "'," . 
					"inventario_recibido_cto='" . $self->{INVENTARIO_RECIBIDO_CTO} . "'," . 
					"movtos_turno_cto='" . $self->{MOVTOS_TURNO_CTO} . "'," . 
					"inventario_entregado_cto='" . $self->{INVENTARIO_ENTREGADO_CTO} . "'," . 
					"diferencia_cto='" . $self->{DIFERENCIA_CTO} . "'," . 
					"autorizo_dif='" . $self->{AUTORIZO_DIF} . "'," . 
					"contador_inicial='" . $self->{CONTADOR_INICIAL} . "'," . 
					"folio='" . $self->{FOLIO} . "'," . 
					"contador_final='" . $self->{CONTADOR_FINAL} . "'," . 
					"vserie='" . $self->{VSERIE} . "'," . 
					"procesada='" . $self->{PROCESADA} . "' WHERE id = '" . $self->{ID} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$connector->destroy();	
}

sub actualizaInf{
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
	$connector->destroy();	
	
}

sub borraMDB{
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "DELETE FROM ci_movimientos WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";	
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$connector->destroy();		
}

sub borraInf{
	my $connector = Trate::Lib::Informix->new();
	my $preps = "DELETE FROM ci_movimientos WHERE movimiento = '" . $self->{MOVIMIENTO} . "'";	
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps");
	$connector->destroy();		
}

sub inserta{
	insertaMDB();
	insertaInf();
}

sub actualiza{
	actualizaMDB();
	actualizaInf();
}

sub borra{
	borraMDB();
	borraInf();	
}

1;
#EOF