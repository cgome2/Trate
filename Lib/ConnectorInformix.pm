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


my $DRIVER = "Informix";
my $DATABASE = "master";
my $DSN = "DBI:$DRIVER:$DATABASE";
my $USER = "trateusr";
my $PASSWORD = "t1710e";

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
