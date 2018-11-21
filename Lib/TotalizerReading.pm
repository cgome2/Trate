package Trate::Lib::TotalizerReading;

#########################################################
#TotalizerReading - Clase TotalizerReading				#
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
	$self->{ID} = undef; 				
	$self->{PUMP} = undef;
	$self->{HOSE_NUM} = undef;
	$self->{SHIFT_ID} = undef;
	$self->{TYPE} = undef;
	$self->{VOLUME} = undef;
	$self->{SALE} = undef; 	 
	$self->{TIMESTAMP} = 0;
	$self->{TOTALIZER_ORIGINAL} = 0;
	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub pump {
        my ($self) = shift;
        if (@_) { $self->{PUMP} = shift }        
        return $self->{PUMP};
}

sub hoseNum {
        my ($self) = shift;
        if (@_) { $self->{HOSE_NUM} = shift }        
        return $self->{HOSE_NUM};
}

sub shiftId {
        my ($self) = shift;
        if (@_) { $self->{SHIFT_ID} = shift }        
        return $self->{SHIFT_ID};
}

sub type {
        my ($self) = shift;
        if (@_) { $self->{TYPE} = shift }        
        return $self->{TYPE};
}

sub volume {
        my ($self) = shift;
        if (@_) { $self->{VOLUME} = shift }        
        return $self->{VOLUME};
}

sub sale {
        my ($self) = shift;
        if (@_) { $self->{SALE} = shift }        
        return $self->{SALE};
}

sub timestamp {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP} = shift }        
        return $self->{TIMESTAMP};
}

sub totalizerOriginal {
        my ($self) = shift;
        if (@_) { $self->{TOTALIZER_ORIGINAL} = shift }        
        return $self->{TOTALIZER_ORIGINAL};
}

sub getTotalizers {
	my $self = shift;
	#please implement me
	return $self;
}

1;
#EOF