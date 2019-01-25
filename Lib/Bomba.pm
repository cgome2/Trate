package Trate::Lib::Bomba;

use strict;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;
use Data::Dump qw(dump);


sub new
{
	my $self = {};
	$self->{ID} = undef;
	$self->{PUMP_HEAD} = undef;
	$self->{NOZZLES} = undef; 
	$self->{SIDE} = undef; 
	$self->{STATUS_CODE} = undef;
        $self->{TOTALIZADOR} = 0;

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

sub totalizador {
        my ($self) = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT totalizador FROM transacciones WHERE bomba= '" . $self->{PUMP_HEAD} . "' ORDER BY idtransacciones DESC LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
        $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
        my $row = $sth->fetchrow_array();
        LOGGER->info(dump($row));
        $self->{TOTALIZADOR} = defined $row ? $row : 0;
	$sth->finish;
	$connector->destroy();
        return $self->{TOTALIZADOR};
}

1;
#EOF
