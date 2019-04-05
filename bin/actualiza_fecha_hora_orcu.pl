#!/usr/bin/perl
use strict;
use warnings;

use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Utilidades;

LOGGER->debug("Ejecutando actualizacion de fecha y hora para orcu");
print Trate::Lib::Utilidades->updateDateTimeOrcu() . "\n";