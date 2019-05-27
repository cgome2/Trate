#!perl -w

use Trate::Lib::WebServicesClientHttps;
use Data::Dump qw(dump);
BEGIN{
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
    $ENV{PERL_LWP_SSL_VERIFY_MODE}=SSL_VERIFY_NONE;
    $ENV{PERL_LWP_SSL_VERIFYCN_SCHEME}=undef;
}

my $wsc = Trate::Lib::WebServicesClientHttps->new();
print dump($wsc->sessionId());
print "\n";
exit 1;
