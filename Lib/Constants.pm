package Trate::Lib::Constants;

##########################################################
#Constants- Global statics							     #
#                                                        #
#Autor: Ramses                                           #
#Fecha: Octubre, 2018                                    #
#Revision: 1.0                                           #
#                                                        #
##########################################################

use strict;
use warnings;
use Log::Log4perl qw(get_logger);
Log::Log4perl->init("/usr/local/orpak/perl/Trate/logger.conf");

use constant LOGGER => get_logger("Trate");

use constant DRIVER_INFORMIX => 'Informix';
use constant DATABASE_INFORMIX => 'master';
use constant DSN_INFORMIX => "DBI:" . DRIVER_INFORMIX . ":" . DATABASE_INFORMIX;
use constant USER_INFORMIX => "trateusr";
use constant PASSWORD_INFORMIX => "t1710e";

use constant DRIVER_MARIADB => "mysql";
use constant DATABASE_MARIADB => "orpak";
use constant DSN_MARIADB => "DBI:" . DRIVER_MARIADB . ":database=" . DATABASE_MARIADB;
use constant USER_MARIADB => "trateuser";
use constant PASSWORD_MARIADB => "tratepassword";

use constant DEFAULT_FLEET_ID => "200000129";
use constant DEFAULT_DEPT_ID => "200000129";

use constant ORCU_ADDRESS => "root\@192.168.1.105";
use constant SQLITE_DATABASE => "/usr/local/orpak/BOS/DB/DATA.DB";

use constant TRUE => 1;
use constant FALSE => 0;

use Exporter qw(import);
our @EXPORT_OK = qw(DRIVER_INFORMIX DATABASE_INFORMIX DSN_INFORMIX USER_INFORMIX PASSWORD_INFORMIX DRIVER_MARIADB DATABASE_MARIADB DSN_MARIADB USER_MARIADB PASSWORD_MARIADB DEFAULT_FLEET_ID DEFAULT_DEPT_ID ORCU_ADDRESS SQLITE_DATABASE LOGGER TRUE FALSE);

1;
#EOF
