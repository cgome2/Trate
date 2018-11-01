package Trate::Lib::Rule;

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

sub new
{
	my $self = {};
	$self->{ID} = undef; 				# Se conforma por {pase}
	$self->{RULE_ID} = undef; 			# Se conforma por {pase}
	$self->{RULE_TYPE} = undef; 		# 1. Limite cantidad, 2. Visitas, 3. Tipo de Combustible
	$self->{NAME} = undef; 				# Se conforma por {pase}P{litros}Litros
	$self->{DESCRIPTION} = undef;
	$self->{STATUS} = undef; 			# 1. inactivo 2. activo
	$self->{CONTENT_SUMMARY} = undef; 	 
	$self->{SENT_TO_FHO} = 0;
	$self->{SENT_TO_DHO} = 0;
	$self->{DISCOVERED} = 0;
	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub ruleId {
        my ($self) = shift;
        if (@_) { $self->{RULE_ID} = shift }        
        return $self->{RULE_ID};
}

sub ruleType {
        my ($self) = shift;
        if (@_) { $self->{RULE_TYPE} = shift }        
        return $self->{RULE_TYPE};
}

sub name {
        my ($self) = shift;
        if (@_) { $self->{NAME} = shift }        
        return $self->{NAME};
}

sub description {
        my ($self) = shift;
        if (@_) { $self->{DESCRIPTION} = shift }        
        return $self->{DESCRIPTION};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub contentSummary {
        my ($self) = shift;
        if (@_) { $self->{CONTENT_SUMMARY} = shift }        
        return $self->{CONTENT_SUMMARY};
}

sub sentToFho {
        my ($self) = shift;
        if (@_) { $self->{SENT_TO_FHO} = shift }        
        return $self->{SENT_TO_FHO};
}

sub sentToDho {
        my ($self) = shift;
        if (@_) { $self->{SENT_TO_DHO} = shift }        
        return $self->{SENT_TO_DHO};
}

sub discovered {
        my ($self) = shift;
        if (@_) { $self->{DISCOVERED} = shift }        
        return $self->{DISCOVERED};
}

sub insertarOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "INSERT INTO rules VALUES ('" . 
										$self->{ID} . "','" .
										$self->{RULE_ID} . "','" .
										$self->{RULE_TYPE} . "','" .
										$self->{NAME} . "','" .
										$self->{DESCRIPTION} . "','" .
										$self->{STATUS} . "','" .
										$self->{CONTENT_SUMMARY} . "','" .
										$self->{SENT_TO_FHO} . "','" .
										$self->{SENT_TO_DHO} . "','" .
										$self->{DISCOVERED} . "')";
	$remex->remoteQuery($query);

	return 1;
}

1;
#EOF