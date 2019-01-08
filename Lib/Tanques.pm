package Trate::Lib::Tanques;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{TANQUES} = ();

	bless($self);
	return $self;	
}

sub getTanques {
	
}
1;
#EOF