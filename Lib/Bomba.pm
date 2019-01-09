package Trate::Lib::Bomba;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{NUMBER} = undef;
	$self->{STATUS} = undef;
	$self->{FUEL_ID} = undef; 
	$self->{FUEL_SALE} = undef; 
	$self->{FUEL_VOLUME} = undef;
	$self->{NOZZLE_ID} = undef;

	bless($self);
	return $self;	
}

sub number {
        my ($self) = shift;
        if (@_) { $self->{NUMBER} = shift }        
        return $self->{NUMBER};
}


sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub fuel_id {
        my ($self) = shift;
        if (@_) { $self->{FUEL_ID} = shift }        
        return $self->{FUEL_ID};
}

sub fuel_sale {
        my ($self) = shift;
        if (@_) { $self->{FUEL_SALE} = shift }        
        return $self->{FUEL_SALE};
}

sub fuel_volume {
        my ($self) = shift;
        if (@_) { $self->{FUEL_VOLUME} = shift }        
        return $self->{FUEL_VOLUME};
}

sub nozzle_id {
        my ($self) = shift;
        if (@_) { $self->{NOZZLE_ID} = shift }        
        return $self->{NOZZLE_ID};
}

1;
#EOF
