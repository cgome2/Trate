package Trate::Lib::Tanque;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID} = undef;
	$self->{NAME} = undef;
	$self->{STATUS} = undef;
	$self->{PRODUCT_ID} = undef; 
	$self->{CAPACITY} = undef; 
	$self->{NUMBER} = undef;

	bless($self);
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

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub productId {
        my ($self) = shift;
        if (@_) { $self->{PRODUCT_ID} = shift }        
        return $self->{PRODUCT_ID};
}

sub capacity {
        my ($self) = shift;
        if (@_) { $self->{CAPACITY} = shift }        
        return $self->{CAPACITY};
}

sub number {
        my ($self) = shift;
        if (@_) { $self->{NUMBER} = shift }        
        return $self->{NUMBER};
}

1;
#EOF