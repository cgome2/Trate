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
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;

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

sub inserta {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO jarreos_t VALUES('"  .
			$self->{TRANSACTION_ID} . "','" .
			$self->{TRANSACTION_TIMESTAMP} . "','" .
			$self->{TRANSACTION_DISPENSED_QUANTITY} . "','" .
			$self->{TRANSACTION_PPV} . "','" .
			$self->{TRANSACTION_TOTAL_PRICE} . "','" .
			$self->{TRANSACTION_IVA} . "','" .
			$self->{TRANSACTION_IEPS} . "','" .
			$self->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE} . "','" .
			$self->{RETURN_TIMESTAMP} . "','" .
			$self->{RETURN_TOTAL_PRICE} . "','" .
			$self->{RETURN_TANK_OBJECT_ID} . "','" .
			$self->{RETURN_DATE} . "','" .
			$self->{RETURN_TIME} . "','" .
			$self->{STATUS_CODE} . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return $self;
}

sub getJarreos{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT 
					transaction_id,
					transaction_timestamp,
					transaction_dispensed_quantity,
					transaction_ppv,
					transaction_total_price,
					transaction_pump_head_external_code,
					status_code
				FROM 
					jarreos_t 
				WHERE 
					status_code=2 ORDER BY transaction_id DESC"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		if ($sth->rows gt 0) {
			my @jarreos;
			while (my $jarreo = $sth->fetchrow_hashref()) {
				push @jarreos,$jarreo;
			}
			$sth->finish;
			$connector->destroy();
			return \@jarreos;	
		} else {
			$sth->finish;
			$connector->destroy();
			return 0;
		}
	} catch {
		return 0;
	}
}

sub fillJarreoFromTransactionId {
	my $self = shift;
	LOGGER->info($self->{TRANSACTION_ID});
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT 
					*
				FROM 
					jarreos_t 
				WHERE transaction_id='" . $self->{TRANSACTION_ID} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row){
		$self->{TRANSACTION_ID} = $row->{transaction_id};
		$self->{TRANSACTION_TIMESTAMP} = $row->{transaction_timestamp};
		$self->{TRANSACTION_DISPENSED_QUANTITY} = $row->{transaction_dispensed_quantity};
		$self->{TRANSACTION_PPV} = $row->{transaction_ppv};
		$self->{TRANSACTION_TOTAL_PRICE} = $row->{transaction_total_price};
		$self->{TRANSACTION_IVA} = $row->{transaction_iva};
		$self->{TRANSACTION_IEPS} = $row->{transaction_ieps};
		$self->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE} = $row->{transaction_pump_head_external_code};
		$self->{RETURN_TIMESTAMP} = $row->{return_timestamp};
		$self->{RETURN_TOTAL_PRICE} = $row->{return_total_price};
		$self->{RETURN_TANK_OBJECT_ID} = $row->{return_tank_object_id};
		$self->{RETURN_DATE} = $row->{return_date};
		$self->{RETURN_TIME} = $row->{return_time};
		$self->{STATUS_CODE} = $row->{status_code};
		LOGGER->debug(dump($self));
		return $self;
	} else {
		return 0;
	}
}

sub insertaDevolucionJarreo {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "UPDATE jarreos_t SET 
					return_timestamp=NOW(),
					return_total_price=transaction_total_price,
					return_date=NOW(),
					return_time=NOW(),
					status_code=1
				WHERE transaction_id='" . $self->{TRANSACTION_ID} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
    try {
		my $sth = $connector->dbh->prepare($preps);
	    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		return 1;
    } catch {
		return 0;				    
    }
}

1;
#EOF