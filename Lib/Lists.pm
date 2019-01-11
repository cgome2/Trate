#########################################################
#Lists - Clase Lists									#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Enero, 2019                                   	#
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Lists;

use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use XML::LibXML;

use strict;

sub new
{
	my $self = {};
	bless($self);
	return $self;	
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
	if($result->{num_of_products} gt 0){
		my @produkts = @{$result->{a_soProduct}->{soProduct}};
		foreach my $produkt (@produkts) {
			my %producto = (
				"id" => $produkt->{id},
				"name" => $produkt->{name},
				"code" => $produkt->{code},
				"status" => $produkt->{status}
			);
			push (@productos,\%producto);
		}
	}
	return \@productos;
}

sub getDespachadores{
	my @despachadores = ();
	push @despachadores, {'mean_id' => 1, 'NAME' => 'Despachador 1'};
	push @despachadores, {'mean_id' => 2, 'NAME' => 'Despachador 2'};
	return \@despachadores;	
}

sub getBombas {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetStationSetup");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	
	my @bombas = @{$result->{SiteOmat}->{setup}->{pumps}->{pump}};
	foreach (@bombas){
		delete $_->{add_tot_to_txn};
		delete $_->{auth_retry_interval};
		delete $_->{auth_retry_num};
		delete $_->{bus_name};
		delete $_->{cluster};
		delete $_->{currency_factor};
		delete $_->{default_device_type};
		delete $_->{enable_ext_eft};
		delete $_->{flow_ratio_per_min};
		delete $_->{lift_nzl_policy_flag};
		delete $_->{master_pump};
		delete $_->{model_code};
		delete $_->{payment_method};
		delete $_->{ppv_no_match_price_update};
		delete $_->{presetfuc};
		delete $_->{presetfucvol};
		delete $_->{price_factor};
		delete $_->{nozzle_mode};
		delete $_->{price_update_flag};
		delete $_->{price_update_retry};
		delete $_->{prifac};
		delete $_->{pump_type_flag};
		delete $_->{pumpserver_name};
		delete $_->{specific};
		delete $_->{suspend_auth_check_interval};
		delete $_->{tot_curfac};
		delete $_->{tot_ppvfac};
		delete $_->{tot_volfac};
		delete $_->{volume_factor};
	}	
	return \@bombas;	
}

sub getProveedoresTrate {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT id,proveedor FROM proveedores_trate WHERE status = 2";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		my @proveedores;
		while (my $ref = $sth->fetchrow_hashref()) {
    		push @proveedores,$ref;
		}
		LOGGER->{dump(@proveedores)};
		$sth->finish;
		$connector->destroy();
		return \@proveedores;	
		} catch {
			return 0;
		}	
}

1;
#EOF