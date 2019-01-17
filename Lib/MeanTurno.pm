package Trate::Lib::MeanTurno;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID_TURNO} = undef;
	$self->{MEAN_ID} = undef;
	$self->{TIMESTAMP_ADD} = undef; 
	$self->{TIMESTAMP_RM} = undef; 
	$self->{USUARIO_ADD} = undef;
	$self->{USUARIO_RM} = undef;

	bless($self);
	return $self;	
}

sub idTurno {
        my ($self) = shift;
        if (@_) { $self->{ID_TURNO} = shift }        
        return $self->{ID_TURNO};
}

sub meanId {
        my ($self) = shift;
        if (@_) { $self->{MEAN_ID} = shift }        
        return $self->{MEAN_ID};
}

sub timestampAdd {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_ADD} = shift }        
        return $self->{TIMESTAMP_ADD};
}

sub timestampRm {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_RM} = shift }        
        return $self->{TIMESTAMP_RM};
}

sub usuarioAdd {
        my ($self) = shift;
        if (@_) { $self->{USUARIO_ADD} = shift }        
        return $self->{USUARIO_ADD};
}

sub usuarioRm {
        my ($self) = shift;
        if (@_) { $self->{USUARIO_RM} = shift }        
        return $self->{USUARIO_RM};
}

1;
#EOF
