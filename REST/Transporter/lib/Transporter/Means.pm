package Transporter::Means;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Mean;
use Data::Dump qw(dump);


our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
    template 'index';
};

get '/means' => sub {
	my $MEAN = Trate::Lib::Mean->new();
	my $means = $MEAN->getMeans();
	LOGGER->info(dump($means));
	return $means;
};

get '/means/:id' => sub {
    my $id = params->{id};
    my $MEAN = Trate::Lib::Mean->new();
    $MEAN->id($id);
    my $mean = $MEAN->getMeanFromId();
    LOGGER->info(dump($mean));
    return {data => $mean};
};

put '/means' => sub {
	my $request = Dancer::Request->new(env => \%ENV);
	my $post = from_json( request->body );
	my $MEAN = Trate::Lib::Mean->new();
	$MEAN->id($post->{soMean}->[0]->{id});
	$MEAN->rule($post->{soMean}->[0]->{rule});
	$MEAN->deptId($post->{soMean}->[0]->{dept_id});
	$MEAN->employeeType($post->{soMean}->[0]->{employee_type});
	$MEAN->availableAmount($post->{soMean}->[0]->{available_amount});
	$MEAN->fleetId($post->{soMean}->[0]->{fleet_id});
	$MEAN->hardwareType($post->{soMean}->[0]->{hardware_type});
	$MEAN->auttyp($post->{soMean}->[0]->{auttyp});
	$MEAN->modelId($post->{soMean}->[0]->{model_id});
	$MEAN->name($post->{soMean}->[0]->{name});
	$MEAN->odometer($post->{soMean}->[0]->{odometer});
	$MEAN->plate($post->{soMean}->[0]->{plate});
	$MEAN->string($post->{soMean}->[0]->{string});
	$MEAN->type($post->{soMean}->[0]->{type});
	$MEAN->status($post->{soMean}->[0]->{status});
	$MEAN->nr2stageElements($post->{soMean}->[0]->{nr_2stage_elements});
	
	LOGGER->info(dump($MEAN));

	my $return = $MEAN->createMeanOrcu();	
	
	return $return;
};

patch '/means' => sub {
	my $request = Dancer::Request->new(env => \%ENV);
	my $post = from_json( request->body );
	my $MEAN = Trate::Lib::Mean->new();
	$MEAN->id($post->{soMean}->[0]->{id});
	$MEAN->rule($post->{soMean}->[0]->{rule});
	$MEAN->deptId($post->{soMean}->[0]->{dept_id});
	$MEAN->employeeType($post->{soMean}->[0]->{employee_type});
	$MEAN->availableAmount($post->{soMean}->[0]->{available_amount});
	$MEAN->fleetId($post->{soMean}->[0]->{fleet_id});
	$MEAN->hardwareType($post->{soMean}->[0]->{hardware_type});
	$MEAN->auttyp($post->{soMean}->[0]->{auttyp});
	$MEAN->modelId($post->{soMean}->[0]->{model_id});
	$MEAN->name($post->{soMean}->[0]->{name});
	$MEAN->odometer($post->{soMean}->[0]->{odometer});
	$MEAN->plate($post->{soMean}->[0]->{plate});
	$MEAN->string($post->{soMean}->[0]->{string});
	$MEAN->type($post->{soMean}->[0]->{type});
	$MEAN->status($post->{soMean}->[0]->{status});
	$MEAN->nr2stageElements($post->{soMean}->[0]->{nr_2stage_elements});
	
	LOGGER->info(dump($MEAN));

	$MEAN->updateMeanMariaDb();	
	
	return 1;
};

del '/means' => sub {
	my $request = Dancer::Request->new(env => \%ENV);
	my $post = from_json( request->body );
	my $MEAN = Trate::Lib::Mean->new();
	$MEAN->id($post->{soMean}->[0]->{id});
	$MEAN->rule($post->{soMean}->[0]->{rule});
	$MEAN->deptId($post->{soMean}->[0]->{dept_id});
	$MEAN->employeeType($post->{soMean}->[0]->{employee_type});
	$MEAN->availableAmount($post->{soMean}->[0]->{available_amount});
	$MEAN->fleetId($post->{soMean}->[0]->{fleet_id});
	$MEAN->hardwareType($post->{soMean}->[0]->{hardware_type});
	$MEAN->auttyp($post->{soMean}->[0]->{auttyp});
	$MEAN->modelId($post->{soMean}->[0]->{model_id});
	$MEAN->name($post->{soMean}->[0]->{name});
	$MEAN->odometer($post->{soMean}->[0]->{odometer});
	$MEAN->plate($post->{soMean}->[0]->{plate});
	$MEAN->string($post->{soMean}->[0]->{string});
	$MEAN->type($post->{soMean}->[0]->{type});
	$MEAN->status(1);
	$MEAN->nr2stageElements($post->{soMean}->[0]->{nr_2stage_elements});
	
	LOGGER->info(dump($MEAN));

	$MEAN->updateMeanMariaDb();	
	
	return 1;
};


true;
