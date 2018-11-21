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
use Trate::Lib::Constants qw(ORCU_ADDRESS SQLITE_DATABASE LOGGER);

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
	my $response = "";
	my @responseArray = [];
	my $ret;
	$self->{COMMAND} = "ssh " . $self->{ORCU} . " \"sqlite3 " . $self->{SQLITE_DATABASE} . " \\\"" . $self->{QUERY} . ";\\\" \\\".exit\\\"\"";
	LOGGER->info($self->{COMMAND});

    unless (eval { $response = `$self->{COMMAND}`; @responseArray = split(/\n/,$response); $ret = \@responseArray;}) {
        $ret = 0;
    }
	return $ret;
}

sub remoteQueryDevelopment {
	my $self = shift;
	$self->{QUERY} = shift;
	my $response = "";
	my @responseArray = [];
	my $ret;
	$self->{ORCU} = "ramses\@192.168.1.222";
	$self->{SQLITE_DATABASE} = "/Users/ramses/Desktop/BOS_DATA.DB";
	$self->{COMMAND} = "ssh " . $self->{ORCU} . " \"sqlite3 " . $self->{SQLITE_DATABASE} . " \\\"" . $self->{QUERY} . ";\\\" \\\".exit\\\"\"";
	LOGGER->debug("COMMAND > " . $self->{COMMAND});
	
    unless (eval { $response = `$self->{COMMAND}`; @responseArray = split(/\n/,$response); $ret = \@responseArray;}) {
        $ret = 0;
    }
	return $ret;
}

1;

#EOF
