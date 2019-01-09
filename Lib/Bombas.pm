package Trate::Lib::Bombas;

use strict;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER ORCUURL);
use Trate::Lib::WebServicesClient;
use LWP::Simple;
use XML::LibXML;

sub new
{
	my $class = shift;
	my $self = {};
	$self->{TANQUES} = [];
	bless($self,$class);
	return $self;	
}

sub bombas {
	my $self = shift;
	return @{$self->{TANQUES}};
}

sub getBombas {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetTankList");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	
	if($result->{num_of_tanks} gt 0){
		my $bomba = Trate::Lib::Tanque->new();
		my @tankes = @{$result->{a_soTank}->{soTank}};
		foreach my $tanke (@tankes) {
			$bomba = Trate::Lib::Tanque->new();
			$bomba->id($tanke->{id});
			$bomba->capacity($tanke->{capacity});
			$bomba->name($tanke->{name});
			$bomba->number($tanke->{number});
			$bomba->productId($tanke->{product_id});
			$bomba->status($tanke->{status});
			push (@{$self->{TANQUES}},$bomba);
		}
	}
	return $self;
}

sub getBombasEstatus {
	my $self = shift;
	getBombas($self);
	my @tanques;
	
	foreach (@{$self->{TANQUES}}){
		
		push @tanques, getTanqueEstatus($_->id,$_->name);
	}
	return @tanques;
}

sub getBombaEstatus {
	my $bomba_id = shift;
	my $bomba_name = shift;
	my $wsc = Trate::Lib::WebServicesClient->new();
	my $url = ORCUURL . "get_tls_wet_inventory.xml?ID=" . $wsc->sessionId() . "&tank_id=" . $bomba_id . "&tank_name=" . $bomba_name;
	my $contents = get($url);
	my %bomba = ();

	my $dom = XML::LibXML->load_xml(string => $contents);
	foreach my $bomba_e ($dom->findnodes('row')) {
		%bomba = (
			"name" => $bomba_name,
			"tank_id" => $bomba_id,
			"date" => $bomba_e->findvalue('date'),
			"date_sql" => $bomba_e->findvalue('date_sql'),
			"fuel_height" => $bomba_e->findvalue('fuel_height'),
			"water_height" => $bomba_e->findvalue('water_height'),
			"fuel_volume" => $bomba_e->findvalue('fuel_volume'),
			"water_volume" => $bomba_e->findvalue('water_volume'),
			"temperature" => $bomba_e->findvalue('temperature'),
			"tc_volume" => $bomba_e->findvalue('tc_volume'),
			"density" => $bomba_e->findvalue('density'),
			"density_15" => $bomba_e->findvalue('density_15'),
			"tlh_id" => $bomba_e->findvalue('tlh_id'),
			"user" => $bomba_e->findvalue('user'),
			"probe_id" => $bomba_e->findvalue('probe_id'),
			"shift_id" => $bomba_e->findvalue('shift_id'),
			"ullage" => $bomba_e->findvalue('ullage')
	    );
	}
	return \%bomba;
}

1;
#EOF