#########################################################
#ProductIeps - Clase ProductIeps						#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::ProductIeps;

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use strict;

sub new
{
	my $self = {};
	$self->{PRODUCT_ID} = undef;
	$self->{PRODUCT_IEPS} = undef;
	$self->{PRODUCT_IVA} = undef;
	$self->{CONFIGURATION_APPLIES_FROM} = undef;
	$self->{CONFIGURATION_APPLIES_UNTIL} = undef;
	$self->{STATUS} = undef;
	bless($self);
	return $self;	
}

sub productId {
        my ($self) = @_;
        return $self->{PRODUCT_ID};
}

sub productIeps {
        my ($self) = @_;
        return $self->{PRODUCT_IEPS};
}

sub productIva {
        my ($self) = @_;
        return $self->{PRODUCT_IVA};
}

sub configurationAppliesFrom {
        my ($self) = @_;
        return $self->{CONFIGURATION_APPLIES_FROM};
}

sub configurationAppliesUntil {
        my ($self) = @_;
        return $self->{CONFIGURATION_APPLIES_UNTIL};
}

sub status {
        my ($self) = @_;
        return $self->{STATUS};
}

1;
#EOF