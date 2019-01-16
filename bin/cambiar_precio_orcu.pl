#!/usr/bin/perl

# Name:			cambiar_precio_orcu.pl 
# Description:  verifica si es necesario ejecutar un cambio de precio debido a una programación del mismo
# Author: 		carlos gomez
# Adapted by: 	maacsa
# Date : 		enero 2019
# Version: 		1.0


use strict;
use warnings;
use Trate::Lib::Productos;
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;
use Data::Dump qw(dump);

my $return = 0;
my $productos = Trate::Lib::Productos->new();
try {
	my @produktos = @{$productos->getProductosTransporter()};
	foreach (@produktos){
		if($_->cambiarPrecioOrcu() eq 1){
			$return = 1;
		} else {
			$return = 0;
			return $return;
		}
	}
} catch {
	$return = 0;
} finally {
	print $return;
};

