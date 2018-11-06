package Trate::Lib::TankDeliveryReading;

#########################################################
#TankDeliveryReading - Clase TankDeliveryReading		#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{RECEPTION_UNIQUE_ID} = undef;
	$self->{TANK_ID} = undef;
	$self->{START_VOLUME} = undef;
	$self->{END_VOLUME} = undef;
	$self->{END_TEMP} = undef;
	$self->{START_DELIVERY_TIMESTAMP} = undef;
	$self->{END_DELIVERY_TIMESTAMP} = undef;
	$self->{RUI} = undef;
	$self->{STATUS} = undef;
	$self->{START_TC_VOLUME} = undef;
	$self->{END_TC_VOLUME} = undef;
	$self->{START_HEIGHT} = undef;
	$self->{END_HEIGHT} = undef;
	$self->{START_WATER} = undef;
	$self->{END_WATER} = undef;
	$self->{START_TEMP} = undef;
	$self->{END_TEMP} = undef;
	$self->{PRODUCT_ID} = undef;
	$self->{INVOICE_ID} = undef;
	bless($self);
	return $self;	
}

sub receptionUniqueId {
        my ($self) = @_;
        return $self->{RECEPTION_UNIQUE_ID};
}

sub tankId {
        my ($self) = @_;
        return $self->{TANK_ID};
}

sub startVolume {
        my ($self) = @_;
        return $self->{START_VOLUME};
}

sub endVolume {
        my ($self) = @_;
        return $self->{END_VOLUME};
}

sub startTemp {
        my ($self) = @_;
        return $self->{START_TEMP};
}

sub endTemp {
        my ($self) = @_;
        return $self->{END_TEMP};
}

sub startDeliveryTimestamp {
        my ($self) = @_;
        return $self->{START_DELIVERY_TIMESTAMP};
}

sub endDeliveryTimestamp {
        my ($self) = @_;
        return $self->{END_DELIVERY_TIMESTAMP};
}

sub rui {
        my ($self) = @_;
        return $self->{RUI};
}

sub statur {
        my ($self) = @_;
        return $self->{STATUS};
}

sub startTcVolume {
        my ($self) = @_;
        return $self->{START_TC_VOLUME};
}

sub endTcVolume {
        my ($self) = @_;
        return $self->{END_TC_VOLUME};
}

sub startHeight {
        my ($self) = @_;
        return $self->{START_HEIGHT};
}

sub endHeight {
        my ($self) = @_;
        return $self->{END_HEIGHT};
}

sub startWater {
        my ($self) = @_;
        return $self->{START_WATER};
}

sub endWater {
        my ($self) = @_;
        return $self->{END_WATER};
}

sub startTemp {
        my ($self) = @_;
        return $self->{START_TEMP};
}

sub endTemp {
        my ($self) = @_;
        return $self->{END_TEMP};
}

sub productId {
        my ($self) = @_;
        return $self->{PRODUCT_ID};
}

sub invoiceId {
        my ($self) = @_;
        return $self->{INVOICE_ID};
}

1;
#EOF