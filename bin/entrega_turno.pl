#!/usr/bin/perl
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use Try::Catch;
use Trate::Lib::Constants qw(LOGGER);
use strict;

# Obtiene lecturas de tanque desde ORCU
# Obtiene totalizadores de bombas desde ORCU
# Cierra shift_instance en ORCU
# Desactiva todos los tag de despachador (driver) para autorización en 2 etapas
# Escribe registros ci_cortes en MariaDB -> trigger escribe registros ci_cortes en trate
# Obtiene lectura de tanques desde ORCU
# Inserta shift_instance en ORCU
# Activa tag de despachador (driver) seleccionado desde web para autorización en 2 etapas
