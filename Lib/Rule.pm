package Trate::Lib::Rule;

use strict;
use Trate::Lib::Constants qw(LOGGER SITE_CODE);
use Trate::Lib::WebServicesClient;

sub new 
{
	my $self = {};
	$self->{ID} = undef;
	$self->{SINGLE} = undef;
	$self->{DAY} = 0;
	$self->{WEEK} = 0;
	$self->{MONTH} = 0;
	$self->{TYPE} = undef;
	$self->{YEAR} = 0;

	$self->{SESSIONID} = Trate::Lib::WebService::SessionId;		#SessionID, 
	$self->{SITE_CODE} = SITE_CODE; 							#site_code, 
	$self->{NUM_LIMITS_RULES} = 1; 								#num_limits_rules, 
	$self->{SOLIMITSRULE} = Trate::Lib::SoLimitsRule->new();	#SessionIDsoLimitsRule[] a_soLimitsRule{

	bless($self);
	return $self;	

}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub single {
        my ($self) = shift;
        if (@_) { $self->{SINGLE} = shift }        
        return $self->{SINGLE};
}

sub day {
        my ($self) = shift;
        if (@_) { $self->{DAY} = shift }        
        return $self->{WEEK};
}

sub week {
        my ($self) = shift;
        if (@_) { $self->{WEEK} = shift }        
        return $self->{WEEK};
}

sub month {
        my ($self) = shift;
        if (@_) { $self->{MONTH} = shift }        
        return $self->{MONTH};
}

sub type {
        my ($self) = shift;
        if (@_) { $self->{TYPE} = shift }        
        return $self->{TYPE};
}

sub year {
        my ($self) = shift;
        if (@_) { $self->{YEAR} = shift }        
        return $self->{YEAR};
}

sub sessionId {
        my ($self) = shift;
        if (@_) { $self->{SESSION_ID} = shift }        
        return $self->{SESSION_ID};
}

sub siteCode {
        my ($self) = shift;
        if (@_) { $self->{SITE_CODE} = shift }        
        return $self->{SITE_CODE};
}

sub numLimitsRules {
        my ($self) = shift;
        if (@_) { $self->{NUM_LIMITS_RULES} = shift }        
        return $self->{NUM_LIMITS_RULES};
}

sub SOLimitsRule {
        my ($self) = shift;
        if (@_) { $self->{SOLIMITSRULE} = shift }        
        return $self->{SOLIMITSRULE};
}

1;
#EOF