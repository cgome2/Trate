package Trate::Lib::RecepcionCombustible;

#########################################################
#LecturasTLS - Clase RecepcionCombustible				#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE HO_ROLE PROVEEDOR);
use Trate::Lib::LecturasTLS;
use Trate::Lib::Factura;
use Trate::Lib::Movimiento;
use Trate::Lib::ConnectorMariaDB;
use Try::Catch;
use Data::Dump qw(dump);

sub new
{
	my $self = {};
	$self->{LECTURA_TLS} = Trate::Lib::LecturasTLS->new();
	$self->{FACTURA} = Trate::Lib::Factura->new();
	$self->{MOVIMIENTO_INVENTARIO} = Trate::Lib::Movimiento->new();
	$self->{MOVIMIENTO_RECEPCION} = Trate::Lib::Movimiento->new();
	
	
	$self->{ID_RECEPCION} = undef;
	$self->{FECHA_RECEPCION} = undef;
	$self->{FECHA_DOCUMENTO} = undef;
	$self->{TERMINAL_EMBARQUE} = undef;
	$self->{SELLO_PEMEX} = undef;
	$self->{FOLIO_DOCUMENTO} = undef;
	$self->{TIPO_DOCUMENTO} = undef;
	$self->{SERIE_DOCUMENTO} = undef;
	$self->{NUMERO_PROVEEDOR} = PROVEEDOR;
	$self->{EMPLEADO_CAPTURA} = undef;
	$self->{LITROS_DOCUMENTO} = undef;
	$self->{PPV_DOCUMENTO} = undef;
	$self->{IMPORTE_DOCUMENTO} = undef;
	$self->{IVA_DOCUMENTO} = undef;
	$self->{IEPS_DOCUMENTO} = undef;
	$self->{STATUS} = undef;

	bless($self);
	return $self;	
}

sub lecturaTls {
        my ($self) = shift;
        if (@_) { $self->{LECTURA_TLS} = shift }        
        return $self->{LECTURA_TLS};
}

sub factura {
        my ($self) = shift;
        if (@_) { $self->{FACTURA} = shift }        
        return $self->{FACTURA};
}

sub movimientoInventario {
        my ($self) = shift;
        if (@_) { $self->{MOVIMIENTO_INVENTARIO} = shift }        
        return $self->{MOVIMIENTO_INVENTARIO};
}

sub movimientoRecepcion {
        my ($self) = shift;
        if (@_) { $self->{MOVIMIENTO_RECEPCION} = shift }        
        return $self->{MOVIMIENTO_RECEPCION};
}

sub idRecepcion {
        my ($self) = shift;
        if (@_) { $self->{ID_RECEPCION} = shift }        
        return $self->{ID_RECEPCION};
}

sub fechaRecepcion {
        my ($self) = shift;
        if (@_) { $self->{FECHA_RECEPCION} = shift }        
        return $self->{FECHA_RECEPCION};
}

sub fechaDocumento {
        my ($self) = shift;
        if (@_) { $self->{FECHA_DOCUMENTO} = shift }        
        return $self->{FECHA_DOCUMENTO};
}

sub terminalEmbarque {
        my ($self) = shift;
        if (@_) { $self->{TERMINAL_EMBARQUE} = shift }        
        return $self->{TERMINAL_EMBARQUE};
}

sub selloPemex {
        my ($self) = shift;
        if (@_) { $self->{SELLO_PEMEX} = shift }        
        return $self->{SELLO_PEMEX};
}

sub folioDocumento {
        my ($self) = shift;
        if (@_) { $self->{FOLIO_DOCUMENTO} = shift }        
        return $self->{FOLIO_DOCUMENTO};
}

sub tipoDocumento {
        my ($self) = shift;
        if (@_) { $self->{TIPO_DOCUMENTO} = shift }        
        return $self->{TIPO_DOCUMENTO};
}

sub serieDocumento {
        my ($self) = shift;
        if (@_) { $self->{SERIE_DOCUMENTO} = shift }        
        return $self->{SERIE_DOCUMENTO};
}

sub numeroProveedor {
        my ($self) = shift;
        if (@_) { $self->{NUMERO_PROVEEDOR} = shift }        
        return $self->{NUMERO_PROVEEDOR};
}

sub empleadoCaptura {
        my ($self) = shift;
        if (@_) { $self->{EMPLEADO_CAPTURA} = shift }        
        return $self->{EMPLEADO_CAPTURA};
}

sub litrosDocumento {
        my ($self) = shift;
        if (@_) { $self->{LITROS_DOCUMENTO} = shift }        
        return $self->{LITROS_DOCUMENTO};
}

sub ppvDocumento {
        my ($self) = shift;
        if (@_) { $self->{PPV_DOCUMENTO} = shift }        
        return $self->{PPV_DOCUMENTO};
}

sub importeDocumento {
        my ($self) = shift;
        if (@_) { $self->{IMPORTE_DOCUMENTO} = shift }        
        return $self->{IMPORTE_DOCUMENTO};
}

sub ivaDocumento {
        my ($self) = shift;
        if (@_) { $self->{IVA_DOCUMENTO} = shift }        
        return $self->{IVA_DOCUMENTO};
}

sub iepsDocumento {
        my ($self) = shift;
        if (@_) { $self->{IEPS_DOCUMENTO} = shift }        
        return $self->{IEPS_DOCUMENTO};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub insertarRecepcionCombustible {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $return = 0;
	my $preps = "
		INSERT INTO recepciones_combustible VALUES("  .
			"NULL,'" .
			$self->{FECHA_RECEPCION} . "','" .
			$self->{FECHA_DOCUMENTO} . "','" .
			$self->{TERMINAL_EMBARQUE} . "','" .
			$self->{SELLO_PEMEX} . "','" .
			$self->{FOLIO_DOCUMENTO} . "','" .
			$self->{TIPO_DOCUMENTO} . "','" .
			$self->{SERIE_DOCUMENTO} . "','" .
			$self->{NUMERO_PROVEEDOR} . "','" .
			$self->{EMPLEADO_CAPTURA} . "','" .
			$self->{LITROS_DOCUMENTO} . "','" .
			$self->{PPV_DOCUMENTO} . "','" .
			$self->{IMPORTE_DOCUMENTO} . "','" .
			$self->{IVA_DOCUMENTO} . "','" .
			$self->{IEPS_DOCUMENTO} . "','" .
			$self->{STATUS} . "')";

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

sub getRecepcionesCombustible {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT
					id_recepcion,
					fecha_recepcion,
					fecha_documento,
					terminal_embarque,
					sello_pemex,
					folio_documento,
					tipo_documento,
					serie_documento,
					numero_proveedor,
					empleado_captura,
					litros_documento,
					ppv_documento,
					importe_documento,
					iva_documento,
					ieps_documento,
					status
				FROM
					recepciones_combustible
				ORDER BY
					fecha_recepcion
				DESC";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		if ($sth->rows gt 0) {
			my @rrc;
			while (my $rc = $sth->fetchrow_hashref()) {
				push @rrc,$rc;
			}
			$sth->finish;
			$connector->destroy();
			return \@rrc;	
		} else {
			$sth->finish;
			$connector->destroy();
			return 0;
		}
	} catch {
		return 0;
	}
}

sub getFromId{
	my $self = shift;
	my $idRecepcion = pop;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT
					id_recepcion,
					fecha_recepcion,
					fecha_documento,
					terminal_embarque,
					sello_pemex,
					folio_documento,
					tipo_documento,
					serie_documento,
					numero_proveedor,
					empleado_captura,
					litros_documento,
					ppv_documento,
					importe_documento,
					iva_documento,
					ieps_documento,
					status
				FROM
					recepciones_combustible
				WHERE
					id_recepcion = " . $idRecepcion;
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		if ($sth->rows gt 0) {		
			my $row = $sth->fetchrow_hashref();
			$sth->finish;
			$connector->destroy();
			return $row;
		} else {
			$sth->finish;
			$connector->destroy();
			return 0;
		}
	} catch {
		return 0;
	}	
}

sub actualizarRecepcionCombustible {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $return = 0;
	my $preps = "
		UPDATE recepciones_combustible SET " .
				"fecha_recepcion='" . $self->{FECHA_RECEPCION} . "'," .
				"fecha_documento='" . $self->{FECHA_DOCUMENTO} . "'," .
				"terminal_embarque='" . $self->{TERMINAL_EMBARQUE} . "'," .
				"sello_pemex='" . $self->{SELLO_PEMEX} . "'," .
				"folio_documento='" . $self->{FOLIO_DOCUMENTO} . "'," .
				"tipo_documento='" . $self->{TIPO_DOCUMENTO} . "'," .
				"serie_documento='" . $self->{SERIE_DOCUMENTO} . "'," .
				"numero_proveedor='" . $self->{NUMERO_PROVEEDOR} . "'," .
				"empleado_captura='" . $self->{EMPLEADO_CAPTURA} . "'," .
				"litros_documento='" . $self->{LITROS_DOCUMENTO} . "'," .
				"ppv_documento='" . $self->{PPV_DOCUMENTO} . "'," .
				"importe_documento='" . $self->{IMPORTE_DOCUMENTO} . "'," .
				"iva_documento='" . $self->{IVA_DOCUMENTO} . "'," .
				"ieps_documento='" . $self->{IEPS_DOCUMENTO} . "'," .
				"status='" . $self->{STATUS} . 
				"' WHERE id_recepcion = '" . $self->{ID_RECEPCION} . "'";
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

1;
#EOF