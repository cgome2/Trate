#!perl -w
use SOAP::Lite +trace => 'debug';

my $uri = 'https://192.168.1.105/SiteOmatService/';
my $proxy = 'https://192.168.1.105/SiteOmatService/SiteOmatService.asmx';
my $sessionId = "EMb8WXcVeIuKgOV2yhp2jrtraULRrK5sOrQS3r2HEEqantzR5jUM";
my $siteCode = "5";
my $pumpId = "1";

my $soap = SOAP::Lite->uri($uri)->proxy($proxy)->xmlschema('2001');
$soap->readable(1);
print $soap->call('ns1:SOGetPumpStatus',
        SOAP::Data->name("SessionID")->value($sessionId)->type(''),
        SOAP::Data->name("site_code")->value($siteCode)->type(''),
        SOAP::Data->name("pump_id")->value(''))->result;