package Trate::Lib::Bomba;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID} = undef;
	$self->{PUMP_HEAD} = undef;
	$self->{NOZZLES} = undef; 
	$self->{SIDE} = undef; 
	$self->{STATUS_CODE} = undef;

	bless($self);
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub pumpHead {
        my ($self) = shift;
        if (@_) { $self->{PUMP_HEAD} = shift }        
        return $self->{PUMP_HEAD};
}

sub nozzles {
        my ($self) = shift;
        if (@_) { $self->{NOZZLES} = shift }        
        return $self->{NOZZLES};
}

sub side {
        my ($self) = shift;
        if (@_) { $self->{SIDE} = shift }        
        return $self->{SIDE};
}

sub statusCode {
        my ($self) = shift;
        if (@_) { $self->{STATUS_CODE} = shift }        
        return $self->{STATUS_CODE};
}

1;
#EOF
