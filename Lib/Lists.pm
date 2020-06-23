#########################################################
#Lists - Clase Lists									#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Enero, 2019                                   	#
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Lists;

use Trate::Lib::Constants qw(LOGGER DELIVERY_PUMPS);
use Data::Dump qw(dump);
use XML::LibXML;

use strict;

sub new
{
	my $self = {};
	bless($self);
	return $self;	
}

sub getBombas {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => ""
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOGetStationSetup");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);	
	my @pumps = @{$result->{SiteOmat}->{setup}->{pumps}->{pump}};
	my @bombas = ();

	my $DPs = DELIVERY_PUMPS;
	my @deliveryPumps = @$DPs;
	my $esdelivery = 0;

	foreach (@pumps){
		foreach my $dp (@deliveryPumps){
			if($_->{side}==$dp->{pump_number}){
				$esdelivery = 1;
				last;
			} else {
				$esdelivery = 0;
			}
		}
		if($esdelivery == 0){
			delete $_->{add_tot_to_txn};
			delete $_->{auth_retry_interval};
			delete $_->{auth_retry_num};
			delete $_->{bus_name};
			delete $_->{cluster};
			delete $_->{currency_factor};
			delete $_->{default_device_type};
			delete $_->{enable_ext_eft};
			delete $_->{flow_ratio_per_min};
			delete $_->{lift_nzl_policy_flag};
			delete $_->{master_pump};
			delete $_->{model_code};
			delete $_->{payment_method};
			delete $_->{ppv_no_match_price_update};
			delete $_->{presetfuc};
			delete $_->{presetfucvol};
			delete $_->{price_factor};
			delete $_->{nozzle_mode};
			delete $_->{price_update_flag};
			delete $_->{price_update_retry};
			delete $_->{prifac};
			delete $_->{pump_type_flag};
			delete $_->{pumpserver_name};
			delete $_->{specific};
			delete $_->{suspend_auth_check_interval};
			delete $_->{tot_curfac};
			delete $_->{tot_ppvfac};
			delete $_->{tot_volfac};
			delete $_->{volume_factor};
			push @bombas, $_;
		}
	}
	return \@bombas;	
}

1;
#EOF
