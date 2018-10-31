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


my $DRIVER = "mysql";
my $DATABASE = "orpak";
my $DSN = "DBI:$DRIVER:database=$DATABASE";
my $USER = "root";
my $PASSWORD = "maacsaco";

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
