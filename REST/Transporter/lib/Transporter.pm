package Transporter;

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
    return {message => "Aqui se procesara el mean : $id"};
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

#update '/means' => sub {
#	my $request = Dancer::Request->new(env => \%ENV);
#	my $post = from_json( request->body );
#	my $MEAN = Trate::Lib::Mean->new();
#	$MEAN->id($post->{soMean}->[0]->{id});
#	$MEAN->rule($post->{soMean}->[0]->{rule});
#	$MEAN->deptId($post->{soMean}->[0]->{dept_id});
#	$MEAN->employeeType($post->{soMean}->[0]->{employee_type});
#	$MEAN->availableAmount($post->{soMean}->[0]->{available_amount});
#	$MEAN->fleetId($post->{soMean}->[0]->{fleet_id});
#	$MEAN->hardwareType($post->{soMean}->[0]->{hardware_type});
#	$MEAN->auttyp($post->{soMean}->[0]->{auttyp});
#	$MEAN->modelId($post->{soMean}->[0]->{model_id});
#	$MEAN->name($post->{soMean}->[0]->{name});
#	$MEAN->odometer($post->{soMean}->[0]->{odometer});
#	$MEAN->plate($post->{soMean}->[0]->{plate});
#	$MEAN->string($post->{soMean}->[0]->{string});
#	$MEAN->type($post->{soMean}->[0]->{type});
#	$MEAN->status($post->{soMean}->[0]->{status});
#	$MEAN->nr2stageElements($post->{soMean}->[0]->{nr_2stage_elements});
#	
#	LOGGER->info(dump($MEAN));
#
#	my $return = $MEAN->updateMeanMariaDb();	
#	
#	return $return;
#};

#delete '/means' => sub {
#	my $request = Dancer::Request->new(env => \%ENV);
#	my $post = from_json( request->body );
#	my $MEAN = Trate::Lib::Mean->new();
#	$MEAN->id($post->{soMean}->[0]->{id});
#	$MEAN->rule($post->{soMean}->[0]->{rule});
#	$MEAN->deptId($post->{soMean}->[0]->{dept_id});
#	$MEAN->employeeType($post->{soMean}->[0]->{employee_type});
#	$MEAN->availableAmount($post->{soMean}->[0]->{available_amount});
#	$MEAN->fleetId($post->{soMean}->[0]->{fleet_id});
#	$MEAN->hardwareType($post->{soMean}->[0]->{hardware_type});
#	$MEAN->auttyp($post->{soMean}->[0]->{auttyp});
#	$MEAN->modelId($post->{soMean}->[0]->{model_id});
#	$MEAN->name($post->{soMean}->[0]->{name});
#	$MEAN->odometer($post->{soMean}->[0]->{odometer});
#	$MEAN->plate($post->{soMean}->[0]->{plate});
#	$MEAN->string($post->{soMean}->[0]->{string});
#	$MEAN->type($post->{soMean}->[0]->{type});
#	$MEAN->status(1);
#	$MEAN->nr2stageElements($post->{soMean}->[0]->{nr_2stage_elements});
#	
#	LOGGER->info(dump($MEAN));
#
#	my $return = $MEAN->updateMeanMariaDb();	
#	
#	return $return;
#};


get '/vehiculos' => sub{

	my @means = ();
	push (@means, ["900002690","1","1426498","GRUPO MAYA","8.00","0.00","0","0.00","TOYOTA","HILUX","4X2","70.00"],["900002074","WT-14","958772","ROD","0.00","0.00","0","0.00","null","null","null","null"],['900002188','WT-15','1024116','ROD','0.00','0.00','0','0.00','null','null','null','null'],['900002204','WT-1HSHBAAN7YH339999','1038757','SIEMENS','0.00','0.00','0','0.00','null','null','null','null'],['900002486','WT-561','1275836','PE\u00d1ASQUITO','0.00','0.00','0','0.00','null','null','null','null'],['900001969','WT-A8361137','905712','ROD','0.00','0.00','0','0.00','null','null','null','null'],['900002642','WT-C196','1399139','1','0.00','0.00','0','0.00','null','null','null','null'],['900001552','WT-EZ72162','754167','PE\u00d1ASQUITO','3.00','0.00','0','0.00','null','null','null','null'],['900000789','WT-ZJ-1892','941929','PE\u00d1ASQUITO','0.00','0.00','0','4449.00','null','null','null','null'],['900000074','WT01','406510','11410000','0.00','0.00','9999999','999999.00','null','null','null','null'],['900000075','WT02','774721','11422031','2.00','0.00','0','54903.00','KOMATSU','PIPA','AUXILIAR','2000.00'],['900001778','WT02','774721','11422031','0.00','0.00','0','0.00','null','null','null','null'],['900000956','WT07','774725','11422031','2.00','0.00','0','7425.00','KOMATSU','PIPA','AUXILIAR','2000.00'],['900000080','WT07','406515','1','0.00','0.00','9999999','999999.00','null','null','null','null'],['900000082','WT09','406516','11410000','0.00','0.00','0','10734.00','null','null','null','null'],['900000083','WT10','406517','11410000','0.00','0.00','9999999','999999.00','null','null','null','null'],['900001303','ZDD136Y TRANS','646079','1','6.00','0.00','0','0.00','CHEVROLET','EXPRESS VAN','VAN','120.00']);
    
    #push @array, $datos;
    my	%vehiculos;
    $vehiculos{data} = \@means;
	LOGGER->info(dump(%vehiculos));
	LOGGER->info("Desde dancer");


    return \%vehiculos;
};

true;
