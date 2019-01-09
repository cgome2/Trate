package Trate::Lib::Bombas;

use strict;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER ORCUURL);
use Trate::Lib::WebServicesClient;
use LWP::Simple;
use XML::LibXML;

sub new()
{
	my $class = shift;
	my $self = {};
	$self->{NUMBER} = undef;
	bless($self,$class);
	return $self;	
}

sub number {
        my ($self) = shift;
        if (@_) { $self->{NUMBER} = shift }        
        return $self->{NUMBER};
}

sub getStatus {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => "",
		pump_num => $self->{NUMBER}
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetPumpRunningData");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	

	return $result->{a_soPumpData}->{soPumpData};
}


1;
#EOF

