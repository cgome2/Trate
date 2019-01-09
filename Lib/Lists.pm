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
	LOGGER->info($result);

	#my @bombas = ();
	#my %tanque = ();

	#my $dom = XML::LibXML->load_xml(string => $result);
	#foreach my $tanque_e ($dom->findnodes('row')) {
	#	%tanque = (
	#		"name" => $tanque_name,
	#		"tank_id" => $tanque_id,
	#		"date" => $tanque_e->findvalue('date'),
	#		"date_sql" => $tanque_e->findvalue('date_sql'),
	#		"fuel_height" => $tanque_e->findvalue('fuel_height'),
	#		"water_height" => $tanque_e->findvalue('water_height'),
	#		"fuel_volume" => $tanque_e->findvalue('fuel_volume'),
	#		"water_volume" => $tanque_e->findvalue('water_volume'),
	#		"temperature" => $tanque_e->findvalue('temperature'),
	#		"tc_volume" => $tanque_e->findvalue('tc_volume'),
	#		"density" => $tanque_e->findvalue('density'),
	#		"density_15" => $tanque_e->findvalue('density_15'),
	#		"tlh_id" => $tanque_e->findvalue('tlh_id'),
	#		"user" => $tanque_e->findvalue('user'),
	#		"probe_id" => $tanque_e->findvalue('probe_id'),
	#		"shift_id" => $tanque_e->findvalue('shift_id'),
	#		"ullage" => $tanque_e->findvalue('ullage')
	#   );
	#}
	#return \%tanque;


	my @bombas = ();
	push @bombas, {'id_bomba' => 1, 'bomba' => 'Posicion de carga 1'};
	push @bombas, {'id_bomba' => 2, 'bomba' => 'Posicion de carga 2'};
	return \@bombas;
	
		
}
1;
#EOF