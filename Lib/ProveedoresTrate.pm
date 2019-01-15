package Trate::Lib::ProveedoresTrate;
#########################################################
#ProveedoresTrate - Clase ProveedoresTrate				#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use Try::Catch;

sub new
{
	my $self = {};
	$self->{ID} = "";
	$self->{PROVEEDOR} = 0;
	$self->{STATUS} = 0;
	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub proveedor {
        my ($self) = shift;
        if (@_) { $self->{PROVEEDOR} = shift }        
        return $self->{PROVEEDOR};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub getProveedoresTrate {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT id,proveedor FROM proveedores_trate WHERE status = 2";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		my @proveedores;
		while (my $ref = $sth->fetchrow_hashref()) {
    		push @proveedores,$ref;
		}
		LOGGER->{dump(@proveedores)};
		$sth->finish;
		$connector->destroy();
		return \@proveedores;	
		} catch {
			return 0;
		}	
}

1;
#EOF