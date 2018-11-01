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
use Trate::Lib::Constants qw(DRIVER_INFORMIX DATABASE_INFORMIX DSN_INFORMIX USER_INFORMIX PASSWORD_INFORMIX);

my $DRIVER = DRIVER_INFORMIX;
my $DATABASE = DATABASE_INFORMIX;
my $DSN = DSN_INFORMIX;
my $USER = USER_INFORMIX;
my $PASSWORD = PASSWORD_INFORMIX;

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
	$self->{DBH} = DBI->connect($DSN, $USER, $PASSWORD) or die $DBI::errstr;
	return $self->{DBH};
}

sub destroy {
	my $self = shift;
	$self->{DBH}->disconnect;
	return $self;
}

1;

#EOF
