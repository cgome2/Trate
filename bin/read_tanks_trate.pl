#!/usr/bin/perl
##########################################################################
# Name: read_tanks.pl							 #
# Description: this script receives a list of tank external codes and    #
# Reads their related probes						 #
# Author: lior Dratler							 #
# Date : $Date: 2005/01/17 17:45:38 $                                    #
# Revision: $Revision: 1.10 $   	                                 	 #
# Tag : $Name: SCU_1_300 $   		                                         #
##########################################################################

#Set up environment 
BEGIN 
{
        require Cwd;
        my $cwd = &Cwd::getcwd;
        my @tokens = split(m|/|, $0);
        pop @tokens;
        chdir join("/", @tokens);
        my $in = &Cwd::getcwd;
        chdir $cwd;
        $in =~ s|/bin$|/perl|;
        unshift(@INC, $ENV{'ORPAK_HOME'} . '/perl', $in);
}


use vars qw($REVISION $VERSION);
$REVISION = '$Revision: 1.10 $';

# Modules 
require '/usr/local/orpak/perl/startup.pl';
use vars qw($opt_s $opt_d $opt_i);
use Getopt::Std;
use Orpak::Constants;
use strict;

#################################################################
sub ReadTank
{

	#my ($t_ext_code) = @_;
	my ($tank) = @_;
	#return $FALSE unless $t_ext_code;
	#print STDERR $t_ext_code;
	
	my $db = Orpak::DbLib->new();
	my $station = Orpak::Generic::GetParam('object_id');
	
	# Lets find the tank
	#my ($tank) = $db->GetPopulationByID("PNVTRE",$TYP_TANK,$station,"object_external_code='$t_ext_code'");
	return $FALSE unless $tank;	
	
	#print STDERR $tank;
	# Lets find the probes
	my @probes = $db->GetPopulationByObject("PNVTRE" , $TYP_PROBE , $tank);

	
	# Lets find the TLS device
	my ($tls_oid) = $db->GetPopulationByID("PNVTRE" , $TYP_LOC , $tank);
	return $FALSE unless $tls_oid;

	my ($p , $msg, $odi , $counter, $objstate);

	# OK lets send the electronic read commands to all the tank's probes
	if ($opt_d)	
	{
	($msg, $odi) = Orpak::Generic::MakeMessage($tls_oid, "DLVRPT");
	}
	else
	{
	($msg, $odi) = Orpak::Generic::MakeMessage($tls_oid, "TNKSTS");
	}
	foreach $p(@probes)
	{

		$counter = 0;
		$objstate = Orpak::ObjState->new($p->object_id);
		$objstate->proces_code('SEND');
		$msg->tank($p->object_external_code);

		while ($objstate->proces_code ne 'DONE' and $counter < 5)
		{
                       	$odi->SendResponse($msg);
			#select(undef,undef,undef, 0.800);
			sleep 3;
			$objstate->Invalidate();
			$counter++;
		}#while
		if ($objstate->proces_code ne 'DONE' and $counter >= 5)	
		{
			Orpak::Generic::Debug("Probe Oid " ,  $p->object_id , " Tank " ,  $p->object_external_code ," Fail");
			return $FALSE;
		}#if		
		if ($opt_i)
		{
			#need to get data from objects_state_t, move it to inventory_t
			my $dbh=$db->{dbh};
			my $p_oid=$p->object_id;
			my $p_sql="SELECT field6 AS fuel_volume,
					field7 AS tc_volume,
					field9 AS f_height,
					field10 AS w_height,
					field12 AS water_volume,
					field11 AS temperature,
					field8 as ullage
					FROM objects_state_t
					WHERE object_id = $p_oid";
			my($fuel_volume,$tc_volume,$f_height,$w_height,$water_volume,$temperature,$ullage);
			($fuel_volume,$tc_volume,$f_height,$w_height,
				$water_volume,$temperature,$ullage) = $dbh->selectrow_array($p_sql);
			#summon forth product id
			my ($tank_oid) = $db->GetPopulationByID('PNVTRE' , $TYP_TANK, $p_oid);
			my ($tank_obj)= Orpak::Tank->new($tank_oid);
			my ($prd_obj) = $tank_obj->Product;
			my ($prod_id)=$prd_obj->{product_id};
			print STDOUT $fuel_volume;
			#
			
			my($index)=Orpak::DbLib::ConsumeIndex("INVENT");
			#now push it in the inventory_t
			my $i_sql = "INSERT INTO inventory_t
			(inventory_id,
			tank_warehouse_object_id,
			inventory_date,
			inventory_time,
			msrmen_code,
			fuel_volume,
			water_height,
			fuel_height,
			temperature,
			tc_volume,
			water_volume,
			ullage,
			inventory_timestamp,
			product_id
			)
			VALUES (
			'$index',		-- inventory_id
			'$tank_oid',	-- tank_warehouse_object_id
			NOW(),		-- inventory_date
			NOW(),		-- inventory_time
			'TLS',		-- msrmen_code
			'$fuel_volume',	-- fuel_volume
			'$w_height',-- water_height
			'$f_height',	-- fuel_height
			'$temperature',	-- temperature
			'$tc_volume',	-- tc_volume
			'$water_volume',-- water_volume
			'$ullage',	-- ullage
			NOW(),		-- inventory_timestamp
			'$prod_id'	-- product_id
			)";
#			$dbh->do($i_sql);
		}

	}#foreach

	return $TRUE;
}
##################################################################
sub Main
{

	getopts("di");
	$opt_s = 1;

	my $return = $TRUE;
	my @tanks  = @ARGV;

	# if no tanks are specified we real the statuses of all tanks
	#if ($#tanks == -1 or $opt_d)
	if ($#tanks == -1)
	{
		my $dblib = Orpak::DbLib->new();
		@tanks = $dblib->GetPopulationByID('INVTRE' , $TYP_TANK , Orpak::Generic::GetParam('object_id'));
	}

	foreach (@tanks)
	{	
		$return  = $return * &ReadTank($_) unless $_ eq lc("d");

	}
#	print STDOUT $return;
	return $return;
}
##################################################################
&Main();

1;











