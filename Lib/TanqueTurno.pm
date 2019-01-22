package Trate::Lib::TanqueTurno;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID_TURNO} = undef;
	$self->{TANK_ID} = undef;
	$self->{TANK_NAME} = undef;
	$self->{VOLUMEN_INICIAL} = undef; 
	$self->{VOLUMEN_FINAL} = undef; 
	$self->{TIMESTAMP_INICIAL} = undef;
	$self->{TIMESTAMP_FINAL} = undef;

	bless($self);
	return $self;	
}

sub idTurno {
        my ($self) = shift;
        if (@_) { $self->{ID_TURNO} = shift }        
        return $self->{ID_TURNO};
}

sub tankId {
        my ($self) = shift;
        if (@_) { $self->{TANK_ID} = shift }        
        return $self->{TANK_ID};
}

sub tankName {
	my $self = shift;
	if(@_) { $self->{TANK_NAME} = shift }
	return $self->{TANK_NAME};
}


sub volumenInicial {
        my ($self) = shift;
        if (@_) { $self->{VOLUMEN_INICIAL} = shift }        
        return $self->{VOLUMEN_INICIAL};
}

sub volumenFinal {
        my ($self) = shift;
        if (@_) { $self->{VOLUMEN_FINAL} = shift }        
        return $self->{VOLUMEN_FINAL};
}

sub timestampInicial {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_INICIAL} = shift }        
        return $self->{TIMESTAMP_INICIAL};
}

sub timestampFinal {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_FINAL} = shift }        
        return $self->{TIMESTAMP_FINAL};
}

1;
#EOF
