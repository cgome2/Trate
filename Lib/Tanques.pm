package Trate::Lib::Tanques;

use strict;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER ORCUURL);
use Trate::Lib::WebServicesClient;
use Trate::Lib::Tanque;
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

sub tanques {
	my $self = shift;
	return @{$self->{TANQUES}};
}

sub getTanques {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetTankList");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	

	my $tanque = Trate::Lib::Tanque->new();
	
	if($result->{num_of_tanks} eq 1) {
		$tanque = Trate::Lib::Tanque->new();	
		my $tanke = $result->{a_soTank}->{soTank};
                $tanque->id($tanke->{id});
                $tanque->capacity($tanke->{capacity});
                $tanque->name($tanke->{name});
                $tanque->number($tanke->{number});
                $tanque->productId($tanke->{product_id});
                $tanque->status($tanke->{status});
		push (@{$self->{TANQUES}},$tanque);
		return \@{$self->{TANQUES}};
		
	} elsif($result->{num_of_tanks} gt 1){
		$tanque = Trate::Lib::Tanque->new();
		
		my @tankes = @{$result->{a_soTank}->{soTank}};
		foreach my $tanke (@tankes) {
			$tanque = Trate::Lib::Tanque->new();
			$tanque->id($tanke->{id});
			$tanque->capacity($tanke->{capacity});
			$tanque->name($tanke->{name});
			$tanque->number($tanke->{number});
			$tanque->productId($tanke->{product_id});
			$tanque->status($tanke->{status});
			push (@{$self->{TANQUES}},$tanque);
		}
		return \@{$self->{TANQUES}};
	} else {
		my @array = ();
		return \@array;
	}
}

sub getTanquesEstatus {
	my $self = shift;
	getTanques($self);
	my @tanques;
	
	foreach (@{$self->{TANQUES}}){
		push @tanques, getTanqueEstatus($_->id,$_->name,$_->capacity);
	}
	return @tanques;
}

sub getTanqueEstatus {
	my $tanque_id = shift;
	my $tanque_name = shift;
	my $tanque_capacity = shift;
	my $wsc = Trate::Lib::WebServicesClient->new();
	my $url = ORCUURL . "get_tls_wet_inventory.xml?ID=" . $wsc->sessionId() . "&tank_id=" . $tanque_id . "&tank_name=" . $tanque_name;
	my $contents = get($url);
	my %tanque = ();

	my $dom = XML::LibXML->load_xml(string => $contents);
	foreach my $tanque_e ($dom->findnodes('row')) {
		%tanque = (
			"name" => $tanque_name,
			"tank_id" => $tanque_id,
			"date" => $tanque_e->findvalue('date'),
			"date_sql" => $tanque_e->findvalue('date_sql'),
			"fuel_height" => $tanque_e->findvalue('fuel_height'),
			"water_height" => $tanque_e->findvalue('water_height'),
			"fuel_volume" => $tanque_e->findvalue('fuel_volume'),
			"water_volume" => $tanque_e->findvalue('water_volume'),
			"temperature" => $tanque_e->findvalue('temperature'),
			"tc_volume" => $tanque_e->findvalue('tc_volume'),
			"density" => $tanque_e->findvalue('density'),
			"density_15" => $tanque_e->findvalue('density_15'),
			"tlh_id" => $tanque_e->findvalue('tlh_id'),
			"user" => $tanque_e->findvalue('user'),
			"probe_id" => $tanque_e->findvalue('probe_id'),
			"shift_id" => $tanque_e->findvalue('shift_id'),
			"ullage" => $tanque_e->findvalue('ullage'),
			"capacity" => $tanque_capacity
	    );
	}
	return \%tanque;
}

1;
#EOF
