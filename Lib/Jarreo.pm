#########################################################
#Jarreo - Clase Jarreo									#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Jarreo;

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use strict;

sub new
{
	my $self = {};
	$self->{TRANSACTION_ID} = undef;
	$self->{TRANSACTION_TIMESTAMP} = undef;
	$self->{TRANSACTION_DISPENSED_QUANTITY} = undef;
	$self->{TRANSACTION_PPV} = undef;
	$self->{TRANSACTION_TOTAL_PRICE} = undef;
	$self->{TRANSACTION_IVA} = undef;
	$self->{TRANSACTION_IEPS} = undef;
	$self->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE} = undef;
	$self->{RETURN_TIMESTAMP} = undef;
	$self->{RETURN_TOTAL_PRICE} = undef;
	$self->{RETURN_TANK_OBJECT_ID} = undef;
	$self->{RETURN_DATE} = undef;
	$self->{RETURN_TIME} = undef;
	$self->{STATUS_CODE} = undef;
	bless($self);
	return $self;	
}

sub transactionId {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_ID} = shift }
        return $self->{TRANSACTION_ID};
}

sub transactionTimestamp {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_TIMESTAMP} = shift }
        return $self->{TRANSACTION_TIMESTAMP};
}

sub transactionDispensedQuantity {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_DISPENSED_QUANTITY} = shift }
        return $self->{TRANSACTION_DISPENSED_QUANTITY};
}

sub transactionPpv {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_PPV} = shift }
        return $self->{TRANSACTION_PPV};
}

sub transactionTotalPrice {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_TOTAL_PRICE} = shift }
        return $self->{TRANSACTION_TOTAL_PRICE};
}

sub transactionIva {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_IVA} = shift }
        return $self->{TRANSACTION_IVA};
}

sub transactionIeps {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_IEPS} = shift }
        return $self->{TRANSACTION_IEPS};
}

sub transactionPumpHeadExternalCode {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE} = shift }
        return $self->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE};
}

sub returnTimestamp {
        my ($self) = @_;
        if (@_) { $self->{RETURN_TIMESTAMP} = shift }
        return $self->{RETURN_TIMESTAMP};
}

sub returnTotalPrice {
        my ($self) = @_;
        if (@_) { $self->{RETURN_TOTAL_PRICE} = shift }
        return $self->{RETURN_TOTAL_PRICE};
}

sub returnTankObjectId {
        my ($self) = @_;
        if (@_) { $self->{RETURN_TANK_OBJECT_ID} = shift }
        return $self->{RETURN_TANK_OBJECT_ID};
}

sub returnDate {
        my ($self) = @_;
        if (@_) { $self->{RETURN_DATE} = shift }
        return $self->{RETURN_DATE};
}

sub returnTime {
        my ($self) = @_;
        if (@_) { $self->{RETURN_TIME} = shift }
        return $self->{RETURN_TIME};
}

sub statusCode {
        my ($self) = @_;
        if (@_) { $self->{STATUS_CODE} = shift }
        return $self->{STATUS_CODE};
}

1;
#EOF