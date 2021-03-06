package Trate::Lib::LimitRule;

#########################################################
#Rule - Clase Rule										#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################
use strict;
use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::Constants qw(LOGGER SITE_CODE);
use Trate::Lib::WebService;

sub new
{
	my $self = {};
	$self->{ID} = undef; 				# Se conforma por {pase}
	$self->{SINGLE} = undef; 			# Se conforma por {pase}
	$self->{DAY} = 0; 		# 1. Limite cantidad, 2. Visitas, 3. Tipo de Combustible
	$self->{WEEK} = 0; 				# Se conforma por {pase}P{litros}Litros
	$self->{MONTH} = 0;
	$self->{TYPE} = undef; 			# 1. inactivo 2. activo
	$self->{YEAR} = 0; 	 

	$self->{SESSIONID} = Trate::Lib::WebService::SessionId;  #SessionID, 
	$self->{SITE_CODE} = SITE_CODE; #site_code, 
	$self->{NUM_LIMITS_RULES} = 1; #num_limits_rules, 
	$self->{SOLIMITSRULE} = Trate::Lib::SoLimitsRule->new();  #SessionIDsoLimitsRule[] a_soLimitsRule{

	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub single {
        my ($self) = shift;
        if (@_) { $self->{SINGLE} = shift }        
        return $self->{SINGLE};
}

sub day {
        my ($self) = shift;
        if (@_) { $self->{DAY} = shift }        
        return $self->{DAY};
}

sub week {
        my ($self) = shift;
        if (@_) { $self->{WEEK} = shift }        
        return $self->{WEEK};
}

sub month {
        my ($self) = shift;
        if (@_) { $self->{MONTH} = shift }        
        return $self->{MONTH};
}

sub type {
        my ($self) = shift;
        if (@_) { $self->{TYPE} = shift }        
        return $self->{TYPE};
}

sub year {
        my ($self) = shift;
        if (@_) { $self->{YEAR} = shift }        
        return $self->{YEAR};
}

sub insertarOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "INSERT INTO limits_rules VALUES ('" . 
										$self->{ID} . "','" .
										$self->{SINGLE} . "','" .
										$self->{DAY} . "','" .
										$self->{WEEK} . "','" .
										$self->{MONTH} . "','" .
										$self->{TYPE} . "','" .
										$self->{YEAR} . "')";
	LOGGER->debug("Ejecutando $query");
	$remex->remoteQuery($query) or die LOGGER->fatal("Error al ejecutar el comando $query");

	return 1;
}

sub insertarOrcuWS {
	my $self = shift;
	
}

sub borrarOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "DELETE FROM limits_rules WHERE id = '" . $self->{ID} . "'";
	LOGGER->debug("Ejecutando $query");
	$remex->remoteQuery($query) or die LOGGER->fatal("Error al ejecutar el comando $query");

	return 1;
}

1;
#EOF