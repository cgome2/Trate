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
use Trate::Lib::Constants qw(ORCU_ADDRESS SQLITE_DATABASE);

sub new
{
	my $self = {};
	$self->{COMMAND} = undef;
	$self->{QUERY} = undef;
	$self->{ORCU} = ORCU_ADDRESS;
	$self->{SQLITE_DATABASE} = SQLITE_DATABASE;
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
	#print $self->{COMMAND} . "\n";
	#my $comando = $self->{COMMAND};
	#system("echo $comando >> /tmp/logfile.log");
	my $response = `$self->{COMMAND}`;
	my @responseArray = split(/\n/,$response);
	print "TOTAL DE RESULTADOS: [" . @responseArray . "]\n";
	foreach my $row (@responseArray){
		print $row . "\n";
	}
	return $self;
}

1;

#EOF
