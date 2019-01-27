package Trate::Lib::Index;

use Trate::Lib::ConnectorMariaDB;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER);

use strict;

sub new
{
	my $self = {};
	$self->{INDEX_TYPE} = undef;
	$self->{VALUE} = undef;
	bless($self);
	return $self;	
}

sub consumeIndex {
    my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT value FROM indexes WHERE index_type='" . $self->{INDEX_TYPE} . "' LIMIT 1";
    my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
    if (length($row->{value} gt 0)){
        $preps = "UPDATE indexes SET value = value+1 WHERE index_type='" . $self->{INDEX_TYPE} . "' LIMIT 1";
        $sth = $connector->dbh->prepare($preps);
        $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    	$sth->finish;
	    $connector->destroy();
        return $row->{value};
    }
	$sth->finish;
	$connector->destroy();
    return 0;
}

1;
#EOF
