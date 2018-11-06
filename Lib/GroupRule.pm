package Trate::Lib::GroupRule;

#########################################################
#Rule - Clase Rule										#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################
use strict;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID} = undef; 				# Se conforma por {pase}
	$self->{LIMITS} = undef; 			# Se conforma por {pase}
	$self->{VISITS} = undef; 		# 1. Limite cantidad, 2. Visitas, 3. Tipo de Combustible
	$self->{FUEL} = undef; 				# Se conforma por {pase}P{litros}Litros
	$self->{TIME} = 0;
	$self->{NAME} = undef; 			# 1. inactivo 2. activo
	$self->{DESCRIPTION} = undef; 	 
	$self->{CONTENT_SUMMARY} = undef;
	$self->{CLUSTER} = 0;
	$self->{SENT_TO_FHO} = 0;
	$self->{SENT_TO_DHO} = 0;
	$self->{DISCOVERED} = 0;
	$self->{DRY} = 0;
	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub limits {
        my ($self) = shift;
        if (@_) { $self->{LIMITS} = shift }        
        return $self->{LIMITS};
}

sub visits {
        my ($self) = shift;
        if (@_) { $self->{VISITS} = shift }        
        return $self->{VISITS};
}

sub fuel {
        my ($self) = shift;
        if (@_) { $self->{FUEL} = shift }        
        return $self->{FUEL};
}

sub time {
        my ($self) = shift;
        if (@_) { $self->{TIME} = shift }        
        return $self->{TIME};
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

sub contentSummary {
        my ($self) = shift;
        if (@_) { $self->{CONTENT_SUMMARY} = shift }        
        return $self->{CONTENT_SUMMARY};
}

sub cluster {
        my ($self) = shift;
        if (@_) { $self->{CLUSTER} = shift }        
        return $self->{CLUSTER};
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

sub dry {
        my ($self) = shift;
        if (@_) { $self->{DRY} = shift }        
        return $self->{DRY};
}

sub insertarOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "INSERT INTO group_rules VALUES ('" . 
										$self->{ID} . "','" .
										$self->{LIMITS} . "','" .
										$self->{VISITS} . "','" .
										$self->{FUEL} . "','" .
										$self->{TIME} . "','" .
										$self->{NAME} . "','" .
										$self->{DESCRIPTION} . "','" .
										$self->{CONTENT_SUMMARY} . "','" .
										$self->{CLUSTER} . "','" .
										$self->{SENT_TO_FHO} . "','" .
										$self->{SENT_TO_DHO} . "','" .
										$self->{DISCOVERED} . "','" .
										$self->{DRY} . "')";
	LOGGER->debug("Ejecutando $query");
	$remex->remoteQuery($query);

	return 1;
}

sub borrarOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "DELETE FROM group_rules WHERE id = '" . $self->{ID} . "'";
	LOGGER->debug("Ejecutando $query");
	$remex->remoteQuery($query);

	return 1;
}

1;
#EOF