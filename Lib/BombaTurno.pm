package Trate::Lib::BombaTurno;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID_TURNO} = undef;
	$self->{ID_BOMBA} = undef;
	$self->{ID_MANGUERA} = undef; 
	$self->{TOTALIZADOR_AL_ABRIR} = undef; 
	$self->{TOTALIZADOR_AL_CERRAR} = undef;
	$self->{TIMESTAMP_ABRIR} = undef;
	$self->{TIMESTAMP_CERRAR} = undef;

	bless($self);
	return $self;	
}

sub idTurno {
        my ($self) = shift;
        if (@_) { $self->{ID_TURNO} = shift }        
        return $self->{ID_TURNO};
}

sub idBomba {
        my ($self) = shift;
        if (@_) { $self->{ID_BOMBA} = shift }        
        return $self->{ID_BOMBA};
}

sub idManguera {
        my ($self) = shift;
        if (@_) { $self->{ID_MANGUERA} = shift }        
        return $self->{ID_MANGUERA};
}

sub totalizadorAlAbrir {
        my ($self) = shift;
        if (@_) { $self->{TOTALIZADOR_AL_ABRIR} = shift }        
        return $self->{TOTALIZADOR_AL_ABRIR};
}

sub totalizadorAlCerrar {
        my ($self) = shift;
        if (@_) { $self->{TOTALIZADOR_AL_CERRAR} = shift }        
        return $self->{TOTALIZADOR_AL_CERRAR};
}

sub timestampAbrir {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_ABRIR} = shift }        
        return $self->{TIMESTAMP_ABRIR};
}

sub timestampCerrar {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_CERRAR} = shift }        
        return $self->{TIMESTAMP_CERRAR};	
}

1;
#EOF
