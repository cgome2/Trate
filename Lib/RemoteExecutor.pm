package Trate::Lib::RemoteExecutor;

#########################################################
#RemoteExecutor - Ejecutor de comandos remotos en orcu	#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#														#
#########################################################

use strict;

sub new
{
	my $self = {};
	$self->{COMMAND} = undef;
	$self->{QUERY} = undef;
	$self->{ORCU} = "root\@192.168.2.20";
	$self->{SQLITE_DATABASE} = "/opt/BOS_DATA.DB";
	bless($self);
	return $self;	
}

sub command {
	my $self = shift;
	if(@_) { $self->{COMMAND} = shift }
	return $self->{COMMAND};
}

sub remoteQuery {
	my $self = shift;
	$self->{QUERY} = shift;
	$self->{COMMAND} = "ssh " . $self->{ORCU} . " \"sqlite3 " . $self->{SQLITE_DATABASE} . " \\\"" . $self->{QUERY} . ";\\\" \\\".exit\\\"\"";
	print $self->{COMMAND} . "\n";
	my $response = `$self->{COMMAND}`;
	my @responseArray = split(/\n/,$response);
	print "RESULTADOS:\n";
	print $responseArray[0] . "\n";
	print $responseArray[1] . "\n";
	return $self;
}

1;

#EOF
