package Trate::Lib::WebServicesClientHttps;

use Trate::Lib::Constants qw(LOGGER HO_ROLE WSURI WSPROXY WSUSER WSPASSWORD SITE_CODE WSXMLSCHEMA USERHOCOMMUNICATOR PASSHOCUMMUNICATOR);
use SOAP::Lite 'trace','debug';
#use SOAP::Lite on_fault => sub {my($soap, $res) = @_; die LOGGER->error(ref $res) ? LOGGER->error($res->faultdetail) : LOGGER->info($soap->transport->status),"\n"};
use SOAP::Lite;
use XML::Twig;
use Data::Dump qw(dump);
use Trate::Lib::Utilidades;
use Trate::Lib::ConnectorMariaDB;

sub new 
{
	my $self = {};
	$self->{CALL_NAME} = undef;
	$self->{PARAMS} = undef;
	$self->{SOAP} = SOAP::Lite->proxy('https://maac-lab.ddns.net/SiteOmatService/SiteOmatService.asmx');
	$self->{SOAP}->readable(1);
	$self->{SOAP}->ns('http://orpak.com/SiteOmatServices', 'sit');
	$self->{SESSIONID} = undef;

	bless($self);
	return $self;
}

sub callName {
    my ($self) = shift;
    if (@_) { $self->{CALL_NAME} = shift }        
    return $self->{CALL_NAME};
}

sub params {
    my ($self) = shift;
    if (@_) { $self->{PARAMS} = shift }        
    return $self->{PARAMS};
}

sub sessionId {
	my $self = shift;
	LOGGER->debug("Obeniendo SessionID from ORCU");
	my %parametros = (
		"user" => WSUSER,
		"password" => WSPASSWORD
	);
		
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:SOLogin')->attr({'xmlns:ns1' => 'http://orpak.com/SiteOmatServices/'});
	my @params;	
	for my $parametro (keys %parametros) {
		push @params, SOAP::Data->name($parametro => $parametros{$parametro});
	}
	my $xmlResponse = $soap->call($method => @params)->result;
	$self->{SESSIONID} = $xmlResponse->{SessionID};
	return $self->{SESSIONID};
}

1;
#EOF
