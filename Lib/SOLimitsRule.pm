package Trate::Lib::SOLimitsRule;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID} = undef; 				
	$self->{NAME} = undef; 			
	$self->{STATUS} = undef;
	$self->{TYPE} = undef;
	$self->{RULE_ID} = undef;
	$self->{DESCRIPTION} = undef;
	$self->{CONTENT_SUMMARY} = undef;
	$self->{LIMIT_ID} = undef;
	$self->{LIMIT_TYPE} = undef;
	$self->{SINGLE} = undef;
	$self->{DAY} = 0;
	$self->{WEEK} = 0;
	$self->{MONTH} = 0;
	$self->{YEAR} = 0;

	bless $self;
	return $self;	
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub name {
        my ($self) = shift;
        if (@_) { $self->{NAME} = shift }        
        return $self->{NAME};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub type {
        my ($self) = shift;
        if (@_) { $self->{TYPE} = shift }        
        return $self->{TYPE};
}

sub ruleId {
        my ($self) = shift;
        if (@_) { $self->{RULE_ID} = shift }        
        return $self->{RULE_ID};
}

sub description {
        my ($self) = shift;
        if (@_) { $self->{DESCRIPTION} = shift }        
        return $self->{DESCRIPTION};
}

sub contentSummary {
        my ($self) = shift;
        if (@_) { $self->{CONTENT_SUMMARY} = shift }        
        return $self->{CONTENT_SUMMARY};
}

sub limitId {
        my ($self) = shift;
        if (@_) { $self->{LIMIT_ID} = shift }        
        return $self->{LIMIT_ID};
}

sub limitType {
        my ($self) = shift;
        if (@_) { $self->{LIMIT_TYPE} = shift }        
        return $self->{LIMIT_TYPE};
}

sub limitType {
        my ($self) = shift;
        if (@_) { $self->{LIMIT_TYPE} = shift }        
        return $self->{LIMIT_TYPE};
}

sub single {
        my ($self) = shift;
        if (@_) { $self->{SINGLE} = shift }        
        return $self->{SINGLE};
}

sub day {
        my ($self) = shift;
        if (@_) { $self->{DAY} = shift }        
        return $self->{DAY};
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

sub year {
        my ($self) = shift;
        if (@_) { $self->{YEAR} = shift }        
        return $self->{YEAR};
}

1;
#EOF