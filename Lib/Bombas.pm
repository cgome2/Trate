package Trate::Lib::Bombas;

use strict;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER ORCUURL DELIVERY_PUMPS);
use Trate::Lib::WebServicesClient;
use Trate::Lib::Bomba;
use LWP::Simple;
use XML::LibXML;
use Data::Structure::Util qw( unbless );

sub new()
{
	my $class = shift;
	my $self = {};
	$self->{BOMBAS} = [];
	bless($self,$class);
	return $self;	
}

sub bombas {
	my $self = shift;
	return @{$self->{BOMBAS}};
}

sub getBombas {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetStationSetup");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);	
	my @bombas = @{$result->{SiteOmat}->{setup}->{pumps}->{pump}};
	my $bomba;

	my $DPs = DELIVERY_PUMPS;
	my @deliveryPumps = @$DPs;
	my $esdelivery = 0;

	foreach (@bombas){
		foreach my $dp (@deliveryPumps){
			if($_->{side}==$dp->{pump_number}){
				$esdelivery = 1;
				last;
			} else {
				$esdelivery = 0;
			}
		}
		if($esdelivery == 0){
			$bomba = Trate::Lib::Bomba->new();
			$bomba->id($_->{id});
			$bomba->pumpHead($_->{side});
			$bomba->side($_->{side});
			$bomba->nozzles($_->{nozzles});
			$bomba->statusCode($_->{status_code});
			$bomba->totalizador();
			unbless($bomba);
			push (@{$self->{BOMBAS}},$bomba);
		}
	}
	#LOGGER->debug(dump(\@{$self->{BOMBAS}}));
	return \@{$self->{BOMBAS}};	
}

sub getBombaEstatus {
	my $id = pop;
	my %params = (
		SessionID => "",
		site_code => "",
		pump_num => $id
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetPumpRunningData");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);
	LOGGER->debug(dump($result));
	return $result->{a_soPumpData}->{soPumpData};
}

sub getBombasEstatus {
	my $id = pop;
	my %params = (
		SessionID => "",
		site_code => "",
		pump_num => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetPumpRunningData");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);	
	my @resultado = @{$result->{a_soPumpData}->{soPumpData}};
	my @bombas;
	my $DPs = DELIVERY_PUMPS;
	my @deliveryPumps = @$DPs;
	my $esdelivery = 0;

	foreach my $b (@resultado){
		foreach my $dp (@deliveryPumps){
			if($b->{pump_num}==$dp->{pump_number}){
				$esdelivery = 1;
				last;
			} else {
				$esdelivery = 0;
			}
		}
		if($esdelivery == 0){
			my $bomba = Trate::Lib::Bomba->new();
			$bomba->{PUMP_HEAD} = $b->{pump_num};
			$b->{totalizador} = $bomba->totalizador();
			push @bombas,$b;
		}
	}
	return \@bombas;
}

1;
#EOF

