#################################################
# Corte - Clase Corte				#                                                       #
# Autor: Ramses                                 #
# Fecha: Octubre, 2018                          #
# Revision: 1.0                                 #
#################################################

package Trate::Lib::Corte;

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER ESTACION);
use Data::Dump qw(dump);

use strict;

sub new
{
	my $self = {};
	$self->{FOLIO} = undef;
	$self->{FECHA_HORA} = undef;
	$self->{ESTACION} = ESTACION;
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
	$self->{CONTADOR_FINAL} = undef;
	$self->{VSERIE} = undef;
	$self->{PROCESADA} = undef;
	bless($self);
	return $self;	
}

sub folio {
        my ($self) = shift;
        if (@_) { $self->{FOLIO} = shift }        
        return $self->{FOLIO};
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

sub entregaTurno {
        my ($self) = shift;
        if (@_) { $self->{ENTREGA_TURNO} = shift }        
        return $self->{ENTREGA_TURNO};
}

sub recibeTurno {
        my ($self) = shift;
        if (@_) { $self->{RECIBE_TURNO} = shift }        
        return $self->{RECIBE_TURNO};
}

sub fechaHoraRecep {
        my ($self) = shift;
        if (@_) { $self->{FECHA_HORA_RECEP} = shift }        
        return $self->{FECHA_HORA_RECEP};
}

sub inventarioRecibidoLts {
        my ($self) = shift;
        if (@_) { $self->{INVENTARIO_RECIBIDO_LTS} = shift }        
        return $self->{INVENTARIO_RECIBIDO_LTS};
}

sub movtosTurnoLts {
        my ($self) = shift;
        if (@_) { $self->{MOVTOS_TURNO_LTS} = shift }        
        return $self->{MOVTOS_TURNO_LTS};
}

sub inventarioEntregadoLts {
        my ($self) = shift;
        if (@_) { $self->{INVENTARIO_ENTREGADO_LTS} = shift }        
        return $self->{INVENTARIO_ENTREGADO_LTS};
}

sub diferenciaLts {
        my ($self) = shift;
        if (@_) { $self->{DIFERENCIA_LTS} = shift }        
        return $self->{DIFERENCIA_LTS};
}

sub inventarioRecibidoCto {
        my ($self) = shift;
        if (@_) { $self->{INVENTARIO_RECIBIDO_CTO} = shift }        
        return $self->{INVENTARIO_RECIBIDO_CTO};
}

sub movtosTurnoCto {
        my ($self) = shift;
        if (@_) { $self->{MOVTOS_TURNO_CTO} = shift }        
        return $self->{MOVTOS_TURNO_CTO};
}

sub inventarioEntregadoCto {
        my ($self) = shift;
        if (@_) { $self->{INVENTARIO_ENTREGADO_CTO} = shift }        
        return $self->{INVENTARIO_ENTREGADO_CTO};
}

sub diferenciaCto {
        my ($self) = shift;
        if (@_) { $self->{DIFERENCIA_CTO} = shift }        
        return $self->{DIFERENCIA_CTO};
}

sub autorizoDif {
        my ($self) = shift;
        if (@_) { $self->{AUTORIZO_DIF} = shift }        
        return $self->{AUTORIZO_DIF};
}

sub contadorInicial {
        my ($self) = shift;
        if (@_) { $self->{CONTADOR_INICIAL} = shift }        
        return $self->{CONTADOR_INICIAL};
}

sub contadorFinal {
        my ($self) = shift;
        if (@_) { $self->{CONTADOR_FINAL} = shift }        
        return $self->{CONTADOR_FINAL};
}


sub vserie {
        my ($self) = shift;
        if (@_) { $self->{VSERIE} = shift }        
        return $self->{VSERIE};
}

sub procesada {
        my ($self) = shift;
        if (@_) { $self->{PROCESADA} = shift }        
        return $self->{PROCESADA};
}

sub insertaMDB{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO ci_cortes " .
		"(" .
		"folio," .
		"fecha_hora," .
		"estacion," .
		"dispensador," .
		"entrega_turno," .
		"recibe_turno," .
		"fecha_hora_recep," .
		"inventario_recibido_lts," .
		"movtos_turno_lts," .
		"inventario_entregado_lts," .
		"diferencia_lts," .
		"inventario_recibido_cto," .
		"movtos_turno_cto," .
		"inventario_entregado_cto," .
		"diferencia_cto," .
		"autorizo_dif," .
		"contador_inicial," .
		"contador_final," .
		"vserie," .
		"procesada" .
		") VALUES ("  .
		(length($self->{FOLIO}) gt 0 ? ("'" . $self->{FOLIO} . "'") : ("NULL") )  . ",'" . 
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
		$self->{DIFERENCIA_CTO} . "'," . 
		(length($self->{AUTORIZO_DIF}) gt 0 ? ("'" . $self->{AUTORIZO_DIF} . "'") : ("NULL") )  . "," . 
		(length($self->{CONTADOR_INICIAL}) gt 0 ? ("'" . $self->{CONTADOR_INICIAL} . "'") : ("NULL") )  . "," . 
		(length($self->{CONTADOR_FINAL}) gt 0 ? ("'" . $self->{CONTADOR_FINAL} . "'") : ("NULL") )  . "," . 
		(length($self->{VSERIE}) gt 0 ? ("'" . $self->{VSERIE} . "'") : ("NULL") )  . "," . 
		(length($self->{PROCESADA}) gt 0 ? ("'" . $self->{PROCESADA} . "'") : ("NULL") )  . 
		")";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;	
	$sth = $connector->dbh->prepare("SELECT max(folio) as folio FROM ci_cortes");
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$self->{FOLIO} = $sth->fetchrow_array();
	
	$connector->destroy();	
	return $self;		
}

sub insertaInf {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "
		INSERT INTO ci_cortes " .
			"(" .
			"folio," .
			"fecha_hora," .
			"estacion," .
			"dispensador," .
			"entrega_turno," .
			"recibe_turno," .
			"fecha_hora_recep," .
			"inventario_recibido_lts," .
			"movtos_turno_lts," .
			"inventario_entregado_lts," .
			"diferencia_lts," .
			"inventario_recibido_cto," .
			"movtos_turno_cto," .
			"inventario_entregado_cto," .
			"diferencia_cto," .
			"autorizo_dif," .
			"contador_inicial," .
			"contador_final," .
			"vserie," .
			"procesada" .
			") VALUES ("  .
			(length($self->{FOLIO}) gt 0 ? ("'" . $self->{FOLIO} . "'") : ("NULL") )  . ",'" . 
			substr($self->{FECHA_HORA},0,16) . "','" .
			$self->{ESTACION} . "','" .
			$self->{DISPENSADOR} . "','" . 
			$self->{ENTREGA_TURNO} . "','" . 
			$self->{RECIBE_TURNO} . "','" . 
			substr($self->{FECHA_HORA_RECEP},0,16) . "','" . 
			$self->{INVENTARIO_RECIBIDO_LTS} . "','" . 
			$self->{MOVTOS_TURNO_LTS} . "','" . 
			$self->{INVENTARIO_ENTREGADO_LTS} . "','" . 
			$self->{DIFERENCIA_LTS} . "','" . 
			$self->{INVENTARIO_RECIBIDO_CTO} . "','" . 
			$self->{MOVTOS_TURNO_CTO} . "','" . 
			$self->{INVENTARIO_ENTREGADO_CTO} . "','" . 
			$self->{DIFERENCIA_CTO} . "'," . 
			(length($self->{AUTORIZO_DIF}) gt 0 ? ("'" . $self->{AUTORIZO_DIF} . "'") : ("NULL") )  . "," . 
			(length($self->{CONTADOR_INICIAL}) gt 0 ? ("'" . $self->{CONTADOR_INICIAL} . "'") : ("NULL") )  . "," . 
			(length($self->{CONTADOR_FINAL}) gt 0 ? ("'" . $self->{CONTADOR_FINAL} . "'") : ("NULL") )  . "," . 
			(length($self->{VSERIE}) gt 0 ? ("'" . $self->{VSERIE} . "'") : ("NULL") )  . "," . 
			(length($self->{PROCESADA}) gt 0 ? ("'" . $self->{PROCESADA} . "'") : ("NULL") )  . 
			")";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:trate: $preps");
	$sth->finish;
	$connector->destroy();	
	return $self;		
}

sub inserta{
	my $self = shift;
	insertaMDB($self);
	insertaInf($self);
	return $self;	
}

sub getFromId(){
	my $self = shift;
	my $corte = shift;

	$self->{FOLIO} = $corte;
	my $id;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM ci_cortes WHERE folio = '" . $self->{FOLIO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");

	(
	$self->{FOLIO},
	$self->{FECHA_HORA},
	$self->{ESTACION},
	$self->{DISPENSADOR},
	$self->{ENTREGA_TURNO},
	$self->{RECIBE_TURNO},
	$self->{FECHA_HORA_RECEP},
	$self->{INVENTARIO_RECIBIDO_LTS},
	$self->{MOVTOS_TURNO_LTS},
	$self->{INVENTARIO_ENTREGADO_LTS},
	$self->{DIFERENCIA_LTS},
	$self->{INVENTARIO_RECIBIDO_CTO},
	$self->{MOVTOS_TURNO_CTO},
	$self->{INVENTARIO_ENTREGADO_CTO},
	$self->{DIFERENCIA_CTO},
	$self->{AUTORIZO_DIF},
	$self->{CONTADOR_INICIAL},
	$self->{CONTADOR_FINAL},
	$self->{VSERIE},
	$self->{PROCESADA}
	) = $sth->fetchrow_array;
	$sth->finish;
	$connector->destroy();
	return $self;	
}

1;
#EOF