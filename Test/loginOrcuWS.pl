#!perl -w

use Trate::Lib::WebServicesClient;
use Data::Dump qw(dump);

my %params = (
	tank_name => 'Magna1',
);
my $wsc = Trate::Lib::WebServicesClient->new();
$wsc->callName("SOGetTankLevel");
$wsc->sessionId();
my $result = $wsc->execute(\%params);
print dump($result);
print $result->{level};
print "\n";
exit 1;