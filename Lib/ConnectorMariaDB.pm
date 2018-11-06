package Trate::Lib::ConnectorMariaDB;

#########################################################
#ConnectorMariaDB - Factory para conexiones MariaDB		#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#														#
#########################################################

use DBI;
use strict;
use Trate::Lib::Constants qw(DRIVER_MARIADB DATABASE_MARIADB DSN_MARIADB USER_MARIADB PASSWORD_MARIADB LOGGER);

my $DRIVER = DRIVER_MARIADB;
my $DATABASE = DATABASE_MARIADB;
my $DSN = DSN_MARIADB;
my $USER = USER_MARIADB;
my $PASSWORD = PASSWORD_MARIADB;

sub new
{
	my $self = {};
	$self->{DBH} = undef;
	bless($self);
	return $self;	
}

sub dbh {
	my $self = shift;
	if(@_) { $self->{DBH} = shift }
	$self->{DBH} = DBI->connect($DSN, $USER, $PASSWORD) or die LOGGER->fatal("Error fatal, no se pudo conectar con el servidor MariaDB" . $DBI::errstr);
	return $self->{DBH};
}

sub destroy {
	my $self = shift;
	$self->{DBH}->disconnect;
	return $self;
}

1;

#EOF
