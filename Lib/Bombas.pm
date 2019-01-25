package Trate::Lib::Bombas;

use strict;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER ORCUURL);
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
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	
	my @bombas = @{$result->{SiteOmat}->{setup}->{pumps}->{pump}};
	my $bomba;
	foreach (@bombas){
		$bomba = Trate::Lib::Bomba->new();
		$bomba->id($_->{id});
		$bomba->pumpHead($_->{pump_head});
		$bomba->side($_->{side});
		$bomba->nozzles($_->{nozzles});
		$bomba->statusCode($_->{status_code});
		$bomba->totalizador();
		unbless($bomba);
		push (@{$self->{BOMBAS}},$bomba);
	}	
	LOGGER->debug(dump(\@{$self->{BOMBAS}}));
	return \@{$self->{BOMBAS}};	
}

#sub getBombasEstatus {
#	my $self = shift;
#	getBombas($self);
#	my @bombas;
#	foreach (@{$self->{BOMBAS}}){
#		push @bombas, getBombaEstatus($_->pumpHead());
#	}
#	return @bombas;
#}

sub getBombaEstatus {
	my $id = pop;
	my %params = (
		SessionID => "",
		site_code => "",
		pump_num => $id
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetPumpRunningData");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	
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
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	
	LOGGER->info(dump($result));
	return $result->{a_soPumpData}->{soPumpData};
}

1;
#EOF

