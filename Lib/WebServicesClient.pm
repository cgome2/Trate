package Trate::Lib::WebServicesClient;

use Trate::Lib::Constants qw(LOGGER WSURI WSPROXY WSUSER WSPASSWORD SITE_CODE WSXMLSCHEMA);
#use SOAP::Lite +trace => 'debug';
use SOAP::Lite on_fault => sub {my($soap, $res) = @_; die LOGGER->info(ref $res) ? LOGGER->info($res->faultdetail) : LOGGER->info($soap->transport->status),"\n"};
use SOAP::Lite;
use XML::Twig;
#use Data::Dump qw(dump);

sub new 
{
	my $self = {};
	$self->{CALL_NAME} = undef;
	$self->{PARAMS} = undef;
	$self->{SOAP} = SOAP::Lite->uri(WSURI)->proxy(WSPROXY)->xmlschema(WSXMLSCHEMA)->autotype(0);
	$self->{SOAP}->readable(1);
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
	LOGGER->debug("Obeniendo SessionID");
	my %parametros = (
		"user" => WSUSER,
		"password" => WSPASSWORD
	);
	
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:SOLogin')->attr({'xmlns:ns1' => WSURI});
	my @params;	
	for my $parametro (keys %parametros) {
		push @params, SOAP::Data->name($parametro => $parametros{$parametro});
	}
	my $xmlResponse = $soap->call($method => @params)->result;
	$self->{SESSIONID} = $xmlResponse->{SessionID};
	LOGGER->debug("SessionID: " . $self->{SESSIONID});
	return $self->{SESSIONID};
}

sub execute{
	my $self = shift;
	my %parametros = %{$_[0]};
	$parametros{'SessionID'}=$self->{SESSIONID};
	$parametros{'site_code'}=SITE_CODE;		
	
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:' . $self->{CALL_NAME})->attr({'xmlns:ns1' => WSURI});
	my @params;
	for my $parametro (keys %parametros) {
		push @params, SOAP::Data->name($parametro => $parametros{$parametro});
	}
	
	return $soap->call($method => @params)->result;	
}

1;
#EOF
