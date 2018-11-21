package Trate::Lib::Shift;

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
	$self->{ID} = undef; 							# id@shift_instance
	$self->{NAME} = undef; 							# NAME@shift_instance
	$self->{OPENED_BY} = undef; 					# opened_by@shift_instance
	$self->{OPENED_BY_NAME} = 'BOS';				# opened_by_name@shift_instance
	$self->{OPEN_TIMESTAMP} = undef; 				# open_timestamp@shift_instance
	$self->{CLOSED_BY} = undef; 					# closed_by@shift_instance
	$self->{CLOSED_BY_NAME} = undef; 	 			# closed_by_name@shift_instance
	$self->{CLOSED_TIMESTAMP} = undef; 	 			# closed_timestamp@shift_instance
	$self->{STATUS} = undef;						# status@shift_instance
	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub name {
        my ($self) = shift;
        if (@_) { $self->{NAME} = shift }        
        return $self->{NAME};
}

sub openedBy {
        my ($self) = shift;
        if (@_) { $self->{OPENED_BY} = shift }        
        return $self->{OPENED_BY};
}

sub openedByName {
        my ($self) = shift;
        if (@_) { $self->{OPENED_BY_NAME} = shift }        
        return $self->{OPENED_BY_NAME};
}

sub openTimestamp {
        my ($self) = shift;
        if (@_) { $self->{OPEN_TIMESTAMP} = shift }        
        return $self->{OPEN_TIMESTAMP};
}

sub closedBy {
        my ($self) = shift;
        if (@_) { $self->{CLOSED_BY} = shift }        
        return $self->{CLOSED_BY};
}

sub closedByName {
        my ($self) = shift;
        if (@_) { $self->{CLOSED_BY_NAME} = shift }        
        return $self->{CLOSED_BY_NAME};
}

sub closedTimestamp {
        my ($self) = shift;
        if (@_) { $self->{CLOSED_TIMESTAMP} = shift }        
        return $self->{CLOSED_TIMESTAMP};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub createShiftOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "
				INSERT INTO   
				        shift_instance(id,NAME,opened_by,opened_by_name,)
				VALUES
						t.id>" . 
						$self->{LAST_TRANSACTION_ID} . " AND t.TIMESTAMP>'" .
						$self->{LAST_TRANSACTION_TIMESTAMP} . "' limit 1";
	LOGGER->debug($query);
	#return $remex->remoteQuery($query);
	return $remex->remoteQueryDevelopment($query);
	#please implement me
}

sub closeShiftOrcu {
	#please implement me
}

1;
#EOF