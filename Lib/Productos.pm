#########################################################
#Productos - Clase Productos							#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Productos;

use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::WebServicesClient;
use Data::Dump qw(dump);
use strict;

sub new
{
	my $self = {};
	$self->{ID} = undef;
	$self->{STATUS} = undef;
	$self->{PRICE} = undef;
	$self->{NAME} = undef;
	$self->{CODE} = undef;
	$self->{LAST_UPDATED} = undef;
	$self->{NEXT_UPDATE} = undef;
	$self->{NEXT_PRICE} = undef;
	$self->{USUARIO} = undef;
	bless($self);
	return $self;	
}

sub id {
    my ($self) = shift;
    if (@_) { $self->{ID} = shift }        
    return $self->{ID};
}

sub status {
    my ($self) = shift;
    if (@_) { $self->{STATUS} = shift }        
    return $self->{STATUS};
}

sub price {
    my ($self) = shift;
    if (@_) { $self->{PRICE} = shift }        
    return $self->{PRICE};
}

sub name {
    my ($self) = shift;
    if (@_) { $self->{NAME} = shift }        
    return $self->{NAME};
}

sub code {
    my ($self) = shift;
    if (@_) { $self->{CODE} = shift }        
    return $self->{CODE};
}

sub lastUpdated {
    my ($self) = shift;
    if (@_) { $self->{LAST_UPDATED} = shift }        
    return $self->{LAST_UPDATED};
}

sub nextUpdate {
    my ($self) = shift;
    if (@_) { $self->{NEXT_UPDATE} = shift }        
    return $self->{NEXT_UPDATE};
}

sub nextPrice {
    my ($self) = shift;
    if (@_) { $self->{NEXT_PRICE} = shift }        
    return $self->{NEXT_PRICE};
}

sub usuario {
	my $self = shift;
	if (@_) { $self->{USUARIO} = shift }
	return $self->{USUARIO};
}

sub getProductoById{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM productos WHERE id='" . $self->{ID} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row){
		$self->{ID} = $row->{id};
		$self->{STATUS} = $row->{status};
		$self->{PRICE} = $row->{price};
		$self->{NAME} = $row->{NAME};
		$self->{CODE} = $row->{code};
		$self->{LAST_UPDATED} = $row->{last_updated};
		$self->{NEXT_UPDATE} = $row->{next_update};
		$self->{NEXT_PRICE} = $row->{next_price};
		$self->{USUARIO} = $row->{usuario};
		return $row;
	} else {
		return 0;
	}	
}

sub addProductoTransporter{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $preps = "
		INSERT INTO productos (id,status,price,NAME,code,last_updated,next_update,next_price,usuario) VALUES ('" . 
			$self->{ID} . "','" .
			$self->{STATUS} . "','" .
			$self->{PRICE} . "','" .
			$self->{NAME} . "','" .
			$self->{CODE} . "'," .
			"NOW()," .
			"NULL," .
			"NULL," .
			"NULL)";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		return 1;
	} catch {
		return 0;
	}
}

sub programarCambioPrecio {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $preps = "
		UPDATE productos SET " .
			" next_update='" . $self->{NEXT_UPDATE} . "'," .
			" next_price='" . $self->{NEXT_PRICE} . "'," .
			" usuario='" . $self->{USUARIO} . "'" . 
			" WHERE id='" . $self->{ID} . "' LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		return 1;
	} catch {
		return 0;
	}
}

sub getProductos{
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetProductList");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	

	my @productos = ();
	my $existeProductoTransporter = 0;
	if($result->{num_of_products} gt 0){
		my @produkts = @{$result->{a_soProduct}->{soProduct}};
		foreach my $produkt (@produkts) {
			$self->{ID} = $produkt->{id};
			$existeProductoTransporter = getProductoById($self);
			if ($existeProductoTransporter eq 0){
				$self->{STATUS} = $produkt->{status};
				$self->{PRICE} = $produkt->{price};
				$self->{NAME} = $produkt->{name};
				$self->{CODE} = $produkt->{code};
				$self->{LAST_UPDATED} = "";
				$self->{NEXT_UPDATE} = "";
				$self->{NEXT_PRICE} = "";
				$self->{USUARIO} = "";
				if($self->addProductoTransporter($self) eq 0){
					return 0;
				}
			}
			my %producto = (
				"id" => $produkt->{id},
				"NAME" => $produkt->{name},
				"code" => $produkt->{code},
				"status" => $produkt->{status},
				"price" => $produkt->{price},
				"code2" => $produkt->{code2},
				"last_updated" => $self->{LAST_UPDATED},
				"next_update" => $self->{NEXT_UPDATE},
				"next_price" => $self->{NEXT_PRICE},
				"usuario" => $self->{USUARIO}
			);
			push (@productos,\%producto);
		}
	}
	return \@productos;
}

sub getProductosTransporter{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT 
					id ID,
					price PRICE,
					NAME NAME,
					code CODE,
					last_updated LAST_UPDATED,
					next_update NEXT_UPDATE,
					next_price NEXT_PRICE,
					usuario USUARIO
				FROM 
					productos
				WHERE 
					status=2
				AND
					next_update LIKE CONCAT(SUBSTR(NOW(),1,16),'%')"; 
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		if ($sth->rows gt 0) {
			my @productos;
			while (my $producto = $sth->fetchrow_hashref()) {
				bless($producto,"Trate::Lib::Productos");
				push @productos,$producto;
			}
			$sth->finish;
			$connector->destroy();
			return \@productos;	
		} else {
			$sth->finish;
			$connector->destroy();
			return 0;
		}
	} catch {
		return 0;
	}
}

sub cambiarPrecioOrcu
{
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => "",
		product_code => $self->{CODE},
		new_price => $self->{NEXT_PRICE},
		timestamp => $self->{NEXT_UPDATE},
		username => $self->{USUARIO}
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOUpdatePrice");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);

	my $connector = Trate::Lib::ConnectorMariaDB->new();
	LOGGER->debug(dump($result));
	if($result->{rc} eq 0){
		my $result = 0;
		my $preps = "
			UPDATE productos SET " .
				" next_update=NULL," .
				" next_price=NULL," .
				" price='" . $self->{NEXT_PRICE} . "'," .
				" last_updated=NOW()" . 
				" WHERE id='" . $self->{ID} . "' LIMIT 1";
		LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
		try {
			my $sth = $connector->dbh->prepare($preps);
			$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
			$sth->finish;
			$connector->destroy();
			return 1;
		} catch {
			return 0;
		}
		return 1;
	} else {
		return 0;
	}
}


1;
#EOF