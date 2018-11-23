package Trate::Lib::ConnectorInformix;

##########################################################
#ConnectorInformix- Factory para conexiones Informix     #
#                                                        #
#Autor: Ramses                                           #
#Fecha: Octubre, 2018                                    #
#Revision: 1.0                                           #
#                                                        #
##########################################################

use DBI;
use strict;
use Try::Catch;
use Trate::Lib::Constants qw(DRIVER_INFORMIX DATABASE_INFORMIX DSN_INFORMIX USER_INFORMIX PASSWORD_INFORMIX LOGGER);

my $DRIVER = DRIVER_INFORMIX;
my $DATABASE = DATABASE_INFORMIX;
my $DSN = DSN_INFORMIX;
my $USER = USER_INFORMIX;
my $PASSWORD = PASSWORD_INFORMIX;

sub new
{
	my $self = {};
	$self->{DBH} = undef;
	$self->{ACTION} = undef;
	bless($self);
	return $self;	
}

sub dbh {
	my $self = shift;
	if(@_) { $self->{DBH} = shift }

	try{
		$self->{DBH} = DBI->connect($DSN, $USER, $PASSWORD) or warn LOGGER->fatal("Error fatal, no se pudo conectar con el servidor Informix" . $DBI::errstr);
	} catch {
	    $self->{DBH} = 0;
	} finally {
		return $self->{DBH};	
	};
}

sub action {
	my $self = shift;
	if(@_) { $self->{ACTION} = shift }
	return $self->{ACTION};
}

sub destroy {
	my $self = shift;
	$self->{DBH}->disconnect;
	return $self;
}

1;

#EOF
