package Transporter::Transacciones;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Bombas;
use Trate::Lib::Mean;
use Trate::Lib::Transacciones;
use Data::Dump qw(dump);
use List::Util qw(all);
use Trate::Lib::Utilidades;
use utf8;


our $VERSION = '0.1';

set serializer => 'JSON';

get '/bombas' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $bombas = Trate::Lib::Bombas->new();
	return $bombas->getBombas();	
};

get '/despachadores' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $MEAN = Trate::Lib::Mean->new();
	return $MEAN->getDespachadores();	
};

patch '/transacciones' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}	

	LOGGER->info("El usuario " . $usuario->{idusuarios} . " solicita insertar una transacción");

	my $post = from_json( request->body );
	
	my $transaccion = Trate::Lib::Transacciones->new();
	$transaccion->{IDPRODUCTOS} = $post->{producto};				
	$transaccion->{IDVEHICULOS} = 0;
	$transaccion->{IDDESPACHADORES} = $post->{despachador};
	$transaccion->{FECHA} = substr($post->{fecha_transaccion},0,10) . " " . $post->{hora_transaccion} . ":00";
	$transaccion->{BOMBA} = $post->{bomba};
	$transaccion->{CANTIDAD} = $post->{litros}; 					
	$transaccion->{PLACA} = length($post->{mean_contingencia}) gt 0 ? $post->{mean_contingencia} : $post->{camion};
	$transaccion->{TOTALIZADOR} = $post->{totalizador}; 				
	$transaccion->{VENTA} = $post->{litros}; 					
	$transaccion->{PASE}->{PASE} = $post->{pase_id};	
	$transaccion->{PASE}->{LITROS_REAL} = $post->{litros_real} + $post->{litros};	
	$transaccion->{PASE}->{MEAN_CONTINGENCIA} = length($post->{mean_contingencia}) gt 0 ? $post->{mean_contingencia} : "";
	$transaccion->{PASE}->{STATUS} = "M";
	$transaccion->{PASE}->{VIAJE} = $post->{viaje};
	$transaccion->{PASE}->{CAMION} = $post->{camion};
	$transaccion->{PASE}->{CHOFER} = $post->{chofer};
	$transaccion->{PASE}->{OBSERVACIONES} = $post->{observaciones};

	$transaccion->insertaTransaccionManual();
	return {message=>"Ok"};
};

post '/transacciones' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}	

	LOGGER->info("El usuario " . $usuario->{idusuarios} . " solicita reporte de transacciones");

	my $post = from_json( request->body );

	my $filter = " WHERE 1=1 ";
	$filter = $filter . ($post->{date_from} ne "" ? (" AND t.fecha >= '" . Trate::Lib::Utilidades->getMariaDBDateFromJason($post->{date_from}) . "' ") : "" );
	$filter = $filter . ($post->{date_to} ne "" ? (" AND t.fecha <= '" . Trate::Lib::Utilidades->getMariaDBDateFromJason($post->{date_to}) . "' ") : "" );
	$filter = $filter . ($post->{transaction_from} ne "" ? (" AND t.idtransacciones >= '" . $post->{transaction_from} . "' ") : "" );
	$filter = $filter . ($post->{transaction_to} ne "" ? (" AND t.idtransacciones <= '" . $post->{transaction_to} . "' ") : "" );
	$filter = $filter . ($post->{litros_desde} ne "" ? (" AND t.cantidad >= '" . $post->{litros_desde} . "' ") : "" );
	$filter = $filter . ($post->{litros_hasta} ne "" ? (" AND t.cantidad <= '" . $post->{litros_hasta} . "' ") : "" );

	my @means;
	my $mean;
	if($post->{camiones} ne ""){
		if(@{$post->{camiones}} gt 0){
			@means=@{$post->{camiones}};
			$filter = $filter . " AND t.idvehiculos IN (";
			foreach $mean (@means){
				$filter = $filter . $mean . ",";
			}
			$filter .= "'')";
		}
	}

	my @bombas;
	my $bomba;
	if($post->{bombas} ne ""){
		if(@{$post->{bombas}} gt 0) {
			@bombas=@{$post->{bombas}};
			$filter .= " AND t.bomba IN (";
			foreach $bomba (@bombas){
				$filter .= $bomba . ",";
			}
			$filter .= "'')";
		}
	}

	$filter .= " AND ((";

	my @estatus_pase;
	my $estatus_p;
	if($post->{estatus_pase} ne ""){
		if(@{$post->{estatus_pase}} gt 0) {
			@estatus_pase=@{$post->{estatus_pase}};
			$filter .= " cp.status IN (";
			foreach $estatus_p (@estatus_pase){
				$filter .= "'" . $estatus_p . "'" . ",";
			}
			$filter .= "'') AND ";
		}
	}
	$filter .= ($post->{pase_desde} ne "" ? (" t.pase >= '" . $post->{pase_desde} . "' ") : "1=1" );
	$filter .= ($post->{pase_hasta} ne "" ? (" AND t.pase <= '" . $post->{pase_hasta} . "' ") : "1=1" );

	$filter .= ") ";
	$filter .= " OR (cp.status IS NULL and t.pase=0)";
	
	$filter .= ")";

	$filter =~ s/,''\)/\)/g;

	$filter .= $post->{order} ne "" ? " ORDER BY " . $post->{order} . " " : "";

	my @blocks;
	my %block;

	# Datos del bloque
	my $transaccion = Trate::Lib::Transacciones->new();
	my $transacciones = $transaccion->getTransaccionesReporte($filter);

	$block{data} = $transacciones;

	# Columnas del bloque por nivel de agrupamiento
	my @columns;
	my @columns_l1 = (
		{"key" => "bomba", "label" => "Bomba", "proportion" => 5, "type" => "string"},
		{"key" => "cantidad", "label" => "Litros", "align" => "right", "totalKey" => "True", "type" => "number"},
		{"key" => "sale", "label" => "Total", "align" => "right", "totalKey" => "True", "type" => "number"}
	);
	push(@columns,\@columns_l1);

	my @columns_l2 = (
		{"key" => "despachador", "label" => "Despachador", "proportion" => 5, "type" => "string"},
		{"key" => "cantidad", "label" => "Litros", "align" => "right", "totalKey" => "True", "type" => "number"},
		{"key" => "sale", "label" => "Total", "align" => "right", "totalKey" => "True", "type" => "number"}
	);
	push(@columns,\@columns_l2);

	my @columns_l3 = (
		{"key" => "camion", "label" => "Camión", "type" => "string"},
		{"key" => "mean", "label" => "Dispositivo", "type" => "string"},
		{"key" => "tipo_mean", "label" => "Tipo de dispositivo", "type" => "string", "proportion" => 3},
		{"key" => "cantidad", "label" => "Litros", "align" => "right", "totalKey" => "True", "type" => "number"},
		{"key" => "sale", "label" => "Total", "align" => "right", "totalKey" => "True", "type" => "number"}
	);
	push(@columns,\@columns_l3);

	my @columns_l4 = (
		{"key" => "pase", "label" => "Pase", "type" => "string"},
		{"key" => "estatus_pase", "label" => "Estatus pase", "proportion" => 4, "type" => "string"},
		{"key" => "cantidad", "label" => "Litros", "align" => "right", "totalKey" => "True", "type" => "number"},
		{"key" => "sale", "label" => "Total", "align" => "right", "totalKey" => "True", "type" => "number"}
	);
	push(@columns,\@columns_l4);

	if($post->{detalle} ne 0){
		my @columns_l5 = (
			{"key" => "idtransaccion", "label" => "Transacción", "type" => "string"},
			{"key" => "fecha", "label" => "Fecha", "align" => "right", "type" => "string", "proportion" => 2},
			{"key" => "cantidad", "label" => "Litros", "align" => "right", "type" => "number"},
			{"key" => "totalizador", "label" => "Totalizador", "align" => "right", "type" => "number"},
			{"key" => "ppv", "label" => "PPV", "align" => "right", "type" => "number"},
			{"key" => "sale", "label" => "Total pesos", "align" => "right", "type" => "number"},
			{"key" => "duration", "label" => "Duración", "align" => "right", "type" => "string"}
		);
		push(@columns,\@columns_l5);
	}

	$block{columns} = \@columns;
	
	# Mapeo de campos para excel para el bloque
	my @block_excel = (
		{"key" => "bomba","label" => "Bomba", "proportion" => 6, "type" => "string"},
		{"key" => "despachador","label" => "Despachador", "proportion" => 6, "type" => "string"},
		{"key" => "camion","label" => "Camion", "type" => "string"},
		{"key" => "mean","label" => "Dispositivo", "proportion" => 6, "type" => "string"},
		{"key" => "tipo_mean","label" => "Tipo de dispositivo", "type" => "string"},
		{"key" => "pase","label" => "Pase", "type" => "string"},
		{"key" => "estatus_pase","label" => "Estatus pase", "type" => "string"},
		{"key" => "idtransaccion", "label" => "Transacción", "type" => "string"},
		{"key" => "fecha", "label" => "Fecha", "type" => "string"},
		{"key" => "cantidad", "label" => "Litros", "type" => "number"},
		{"key" => "totalizador", "label" => "Totalizador", "type" => "number"},
		{"key" => "ppv","label" => "Ppv","type" => "number"},
		{"key" => "sale","label" => "Total en pesos","type" => "number"},
		{"key" => "duration", "label" => "Duración", "type" => "string"}
	);
	$block{excel} = \@block_excel;

	# Campos de agrupamiento
	
	my @groupBy = (
		$post->{group} ne "" ? $post->{group} : "bomba"
	);
	$block{groupBy} = \@groupBy;

	push @blocks,\%block;

	my %responsepayload;

	# Encabezados del reporte
	$responsepayload{title} = "Reporte de movimientos";
	my @subtitle = (
		"Estación: 1457",
		"Periodo " .
		($post->{date_from} ne "" ? (" desde: " . Trate::Lib::Utilidades->getMariaDBDateFromJason($post->{date_from}) . " ") : " desde inicio de operaciones ") .
		($post->{date_to} ne "" ? (" hasta: " . Trate::Lib::Utilidades->getMariaDBDateFromJason($post->{date_to}) . " ") : " hasta " . Trate::Lib::Utilidades->getCurrentTimestampMariaDB()),
		"Pases " .
		($post->{pase_desde} ne "" ? (" desde: " . $post->{pase_desde} . " ") : " desde inicio de operaciones ") .
		($post->{pase_hasta} ne "" ? (" hasta: " . $post->{pase_hasta} . " ") : ""),
		"Transacciones " .
		($post->{transaction_from} ne "" ? (" desde: " . $post->{transaction_from} . " ") : " desde inicio de operaciones ") .
		($post->{transaction_to} ne "" ? (" hasta: " . $post->{transaction_to} . " ") : ""),
		"Despachos " .
		($post->{litros_desde} ne "" ? (" desde: " . $post->{litros_desde} . " ") : " desde 0 ") .
		($post->{litros_hasta} ne "" ? (" hasta: " . $post->{litros_hasta} . " Litros") : "Litros")
	);
	$responsepayload{subtitle} = \@subtitle;
	
	# Inclusión de detalle de bloques del reporte
	$responsepayload{blocks} = \@blocks;

	return \%responsepayload;
};
true;
