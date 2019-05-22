package Trate::Lib::Utilidades;

#########################################################
#Utilidades - Clase Utilidades							#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE);
use Data::Dump qw(dump);
use Digest::SHA1 qw(sha1_hex);
use Trate::Lib::WebServicesClient;

sub getCurrentTimestampMariaDB {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $mysqlDate = $year + 1900;
	$mysqlDate .= "-";
	$mysqlDate .= sprintf("%02d", $mon + 1);
	$mysqlDate .= "-";
	$mysqlDate .= sprintf("%02d", $mday);
	$mysqlDate .= " ";
	$mysqlDate .= sprintf("%02d", $hour);
	$mysqlDate .= ":";
	$mysqlDate .= sprintf("%02d", $min);
	$mysqlDate .= ":";
	$mysqlDate .= sprintf("%02d", $sec);
	return $mysqlDate;
}

sub getInformixDate($){
	my $mariaDBdate = shift;
	my @fechawhenfull = split/ /,$mariaDBdate;
	my @fecha = split /-/, $fechawhenfull[0];
	my $year = $fecha[0];
	my $month = $fecha[1];
	my $day = $fecha[2];
	my $informixDate = $day . "/" . $month . "/" . $year;
	LOGGER->debug($informixDate);
	return $informixDate
}

sub getSha1($){
	my $string = pop;
	return sha1_hex($string);
}

sub getMariaDBDateFromJason {
	my $date = pop;
	$date = substr($date,0,19);
	my $return = $date =~ s/T/ /r;
	return $return;
}

sub getCurrentDate {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $date = $year + 1900;
	$date .= "-";
	$date .= sprintf("%02d", $mon + 1);
	$date .= "-";
	$date .= sprintf("%02d", $mday);
	return $date;
}

sub getCurrentTime {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $time;
	$time .= sprintf("%02d", $hour);
	$time .= ":";
	$time .= sprintf("%02d", $min);
	$time .= ":";
	$time .= sprintf("%02d", $sec);
	return $time;
}

sub updateDateTimeOrcu {
	my %params = (
		SessionID => "",
		site_code => "",
		Date => &getCurrentDate(),
		Time => &getCurrentTime(),
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOHOBOSSetTimeDate");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);
	return $result;
}
1;
#EOF