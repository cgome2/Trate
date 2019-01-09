package Transporter::Static;

use Switch;
use Dancer ":syntax";
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Usuarios;

our $VERSION = "0.1";

set serializer => "JSON";

get "/menu" => sub {
	return {
		title => "Siteomat",
		modules => [
			{
				label => "Estatus",
				path => "/estatus",
				icon => "chart-areaspline",
				menu => [
					{
						header => "Dispensarios",
						path => "/estatus/dispensarios"
					},
					{
						header => "Tanques",
						path => "/estatus/tanques"
					}
				]
			},
			{
				label => "Despacho de Combustible",
				path => "/despacho",
				icon => "gas-station",
				menu => [
					{
						header => "Contingencias",
						path => "/despacho/contingencias"
					},
					{
						header => "Jarreos",
						path => "/despacho/jarreos"
					}
				]
			},
			{
				label => "Recepcion de Combustible",
				path => "/recepcion",
				icon => "receipt",
				menu => [
					{
						header => "Documentos",
						path => "/recepcion/documentos"
					},
					{
						header => "Contingencias",
						path => "/recepcion/contingencias"
					},
				]
			},
			{
				label => "Turnos",
				path => "/turnos",
				icon => "timetable",
				menu => [
					{
						header => "Turnos",
						path => "/turnos/turnos"
					}
				]
			},
			{
				label => "Reportes",
				path => "/reportes",
				icon => "clipboard-text",
				menu => [
					{
						header => "Reporte de Transacciones",
						path => "/reportes/transacciones"
					},
					{
						header => "Reporte de Turnos",
						path => "/reportes/turnos"
					}
				]
			},
			{
				label => "Configuracion",
				path => "/configuracion",
				icon => "settings",
				menu => [
					{
						header => "Usuarios",
						path => "/configuracion/usuarios"
					},
					{
						header => "Perfiles",
						path => "/configuracion/perfiles"
					},
					{
						header => "Vehiculos",
						path => "/configuracion/vehiculos"
					}
				]
			}
		]
	};
};

get "/estatus" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) { status 401; }
};
get "/despacho" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) { status 401; }
};
get "/recepcion" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) { status 401; }
};
get "/turnos" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) { status 401; }
};
get "/reportes" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) { status 401; }
};
get "/configuracion" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) { status 401; }
};


get "/components" => sub {
  if (Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0) {
    status 401;
  }
  my $uri = request->params->{uri};
  $uri =~ /\/(\d+)/;
  my $id = $1;
  $uri =~ s/\/(\d+|nuevo)/\/id/;

  my $component;
  my $endpoint;

  switch ($uri) {
    case "/estatus/dispensarios"        { $component = "superFrame"; $endpoint = "/estatusBombas"; }
    case "/estatus/tanques"             { $component = "tanks"; $endpoint = "/estatusTanques"; }

    case "/despacho/contingencias"      { $component = "superTable"; $endpoint = "/pases"; }
    # case "/despacho/jarreos"            { $component = "superTable"; $endpoint = ""; }

    case "/recepcion/documentos"        { $component = "superTable"; $endpoint = "/lecturas_tls"; }

    # case "/turnos/turnos"               { $component = "superTable"; $endpoint = ""; }

    # case "/reportes/transacciones"      { $component = "superTable"; $endpoint = ""; }
    # case "/reportes/turnos"             { $component = "superTable"; $endpoint = ""; }

    case "/configuracion/usuarios"      { $component = "superTable"; $endpoint = "/usuarios"; }
    # case "/configuracion/perfiles"      { $component = "superTable"; $endpoint = ""; }
    case "/configuracion/vehiculos"     { $component = "superTable"; $endpoint = "/means"; }
  }

  return {
    component => $component,
    endPoint => $endpoint,
    id => $id
  };
};

get "/lecturas_tls/table" => sub {
  return {
    icon => "file-document",
    title => "Documentos",
    id => "id",
    buttons => [
      {
        icon => 'receipt',
        label => 'Nueva Factura',
        action => {
          type => 'form',
          form => '/lecturas_tls'
        }
      }
    ],
    columns => [
      {
        key => "start_delivery_timestamp",
        label => "Fecha inicial de recepcion"
      },
      {
        key => "end_delivery_timestamp",
        label => "Fecha final de recepcion"
      },
      {
        key => "start_volume",
        label => "Volumen inicial",
        format => "number:1.2-2:",
        align => "right"
      },
      {
        key => "end_volume",
        label => "Volumen final",
        format => "number:1.2-2:",
        align => "right"
      },
      {
        key => "volume",
        label => "Volumen recibido",
        format => "number:1.2-2:",
        operations => "end_volume -start_volume",
        footer => "sum",
        align => "right"
      },
      {
        key => "ci_movimientos",
        label => "Numero de movimiento",
        align => "right"
      }
    ]
  };
};

get "/lecturas_tls/form" => sub {
  return {
    icon => "receipt",
    title => "Agregar Documento",
    fields => [
      {
        key => "fecha_documento",
        label => "Fecha del Documento",
        type => "date",
        required => 1
      },
      {
        key => "tipo",
        label => "Tipo",
        type => "select",
        options => [
          { key => "CP", value => "CP"},
          { key => "RP", value => "RP"}
        ],
        required => 1
      },
      {
        key => "terminal_embarque",
        label => "Terminal de Embarque",
        type => "text",
        minlength => 3,
        maxlength => 3,
        regex => "[0-9]{3}",
        required => 1
      },
      {
        key => "folio_documento",
        label => "Folio Documento",
        type => "text",
        required => 1
      },
      {
        key => "sello_pemex",
        label => "Sello PEMEX",
        type => "text",
        required => 1
      },
      {
        key => "serie_documento",
        label => "Serie Documento",
        type => "text",
        required => 1
      },
      {
        key => "vol_factura",
        label => "Volumen Factura",
        type => "number",
        required => 1
      },
      {
        key => "importe_factura",
        label => "Importe Factura",
        type => "number",
        required => 1
      },
      {
        key => "ppv",
        label => "Precio por litro",
        type => "number",
        readonly => 1,
        operation => "division",
        operands => ["importe_factura", "vol_factura"],
        required => 1
      },
      {
        key => "numero_vehiculo",
        label => "Numero Vehiculo",
        type => "number",
        required => 1
      }
    ],
    details => [
      {
        key => "tls",
        label => " Lecturas",
        endpoint => "lecturas_tls/lecturas",
        columns => [
          {
            key => "start_delivery_timestamp",
            label => "Fecha inicial de recepcion"
          },
          {
            key => "end_delivery_timestamp",
            label => "Fecha final de recepcion"
          },
          {
            key => "start_volume",
            label => "Volumen inicial",
            format => "number:1.2-2:",
            align => "right"
          },
          {
            key => "end_volume",
            label => "Volumen final",
            format => "number:1.2-2:",
            align => "right"
          },
          {
            key => "volume",
            label => "Volumen recibido",
            format => "number:1.2-2:",
            operations => "end_volume -start_volume",
            align => "right"
          },
          {
            key => "ci_movimientos",
            label => "Numero de movimiento",
            align => "right"
          }
        ],
        unique => "ci_movimientos",
        required  => 1,
      }
    ]
  };
};


get "/pases/table" => sub {
  return {
    icon => "alarm-light",
    title => "Contingencias",
    id => "pase_id",
    remote => 1,
    searchBy => [
      { key => 'pase', label => 'Buscar Pase' }, 
      { key => 'camion', label => 'Buscar Camion' }
    ],
    columns => [
      {
        key => "pase_id",
        label => "Pase"
      },
      {
        key => "status",
        label => "Estatus"
      },
      {
        key => "camion",
        label => "Camion"
      },
      {
        key => "viaje",
        label => "Viaje"
      },
      {
        key => "fecha_solicitud",
        label => "Fecha de Solicitud"
      }
    ],
    options => [
      {
        icon => 'undo',
        label => 'Reabrir',
        condition => "status D",
        action => {
          type => 'form',
          form => '/pases/reabrir'
        }
      },
      {
        icon => 'transfer',
        label => 'Reasignar',
        condition => "status A|T|R",
        action => {
          type => 'form',
          form => '/pases/reasignar'
        }
      },
      {
        icon => 'hand',
        label => 'Manual',
        condition => "status A|T|R",
        action => {
          type => 'form',
          form => '/pases/manual'
        }
      }
    ]
  };
};


get "/pases/reabrir/form" => sub {
  return {
    icon => "undo",
    title => "Reabrir",
    getFrom => "/pases",
    sendTo => "/pases",
    override => { status => "R" },
    fields => [
      {
        key => "pase_id",
        label => "Pase",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_solicitud",
        label => "Fecha de Solicitud",
        type => "text",
        readonly => 1
      },
      {
        key => "viaje",
        label => "Viaje",
        type => "text",
        readonly => 1
      },
      {
        key => "camion",
        label => "Camion",
        type => "text",
        readonly => 1
      },
      {
        key => "observaciones",
        label => "Observaciones",
        type => "text",
        required => 1
      }
    ]
  };
};


get "/pases/reasignar/form" => sub {
  return {
    icon => "transfer",
    title => "Reasignar",
    getFrom => "/pases",
    sendTo => "/pases",
    override => { status => "T" },
    fields => [
      {
        key => "pase_id",
        label => "Pase",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_solicitud",
        label => "Fecha de Solicitud",
        type => "text",
        readonly => 1
      },
      {
        key => "viaje",
        label => "Viaje",
        type => "text",
        readonly => 1
      },
      {
        key => "camion",
        label => "Camion",
        type => "select",
        optionsSource => "/means/auttyp/20",
        optionsKey => "NAME",
        optionsValue => "NAME"
      }
    ]
  };
};

get "/pases/manual/form" => sub {
  return {
    icon => "hand",
    title => "Manual",
    getFrom => "/pases",
    sendTo => "/pases/manual",
    fields => [
      {
        key => "pase_id",
        label => "Pase",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_solicitud",
        label => "Fecha de Solicitud",
        type => "text",
        readonly => 1
      },
      {
        key => "viaje",
        label => "Viaje",
        type => "text",
        readonly => 1
      },
      {
        key => "camion",
        label => "Camion",
        type => "text",
        readonly => 1
      },
      {
        key => "despachador",
        label => "Despachador",
        type => "select",
        optionsSource => "/despachadores",
        optionsKey => "mean_id",
        optionsValue => "NAME",
        required => 1
      },
      {
        key => "producto",
        label => "Producto",
        type => "select",
        optionsSource => "/productos",
        optionsKey => "id",
        optionsValue => "name",
        required => 1
      },
      {
        key => "litros",
        label => "Litros Despachados",
        type => "number",
        required => 1
      },
      {
        key => "bomba",
        label => "Bomba",
        type => "select",
        optionsSource => "/bombas",
        optionsKey => "id_bomba",
        optionsValue => "bomba",
        required => 1
      },
      {
        key => "fecha_transaccion",
        label => "Fecha Transaccion",
        type => "date",
        required => 1
      },
      {
        key => "hora_transaccion",
        label => "Hora Transaccion",
        type => "time",
        required => 1
      },
      {
        key => "observaciones",
        label => "Observaciones",
        type => "text",
        required => 1
      }
    ]
  };
};

my @means_type_options = [
  { from => 2, to => "Dispositivo montado en vehiculo"},
  { from => 3, to => "Tag tipo vehiculo"},
  { from => 4, to => "Tag despachador"}
];

my @means_auttyp_options = [
  { from => 1,  to => "Tag" },
  { from => 2,  to => "VIU 3" },
  { from => 3,  to => "VIU 4" },
  { from => 4,  to => "VIU 45" },
  { from => 5,  to => "Electronic Key" },
  { from => 6,  to => "Montado al Vehiculo" },
  { from => 7,  to => "Authorizer" },
  { from => 8,  to => "Master Authorizer" },
  { from => 9,  to => "VIU 35" },
  { from => 10, to => "TRU" },
  { from => 14, to => "Fuel Card" },
  { from => 20, to => "Gasboy Key" },
  { from => 21, to => "Manual Entry" },
  { from => 22, to => "VIU 35 E" },
  { from => 23, to => "VIU 35 NT" },
  { from => 25, to => "FP HS" },
  { from => 26, to => "DP only" },
  { from => 27, to => "DP H" },
  { from => 30, to => "FP + DP" },
  { from => 40, to => "FP HS + DP" },
  { from => 41, to => "URD" },
  { from => 42, to => "URD + DP" }
];

my @means_status_options = [
  { from => 1, to => "Inactivo"},
  { from => 2, to => "Activo"},
];

get "/means/table" => sub {
  return {
    icon => "car",
    title => "Vehiculos",
    id => "id",
    options => [
      {
        icon => 'pencil',
        label => 'Editar',
        action => {
          type => 'form',
          form => '/means'
        }
      }
    ],
    buttons => [
      {
        icon => 'plus',
        label => 'Nuevo',
        action => {
          type => 'form',
          form => '/means'
        }
      }
    ],
    columns => [
      {
        key => "NAME",
        label => "Nombre"
      },
      {
        key => "plate",
        label => "Placa"
      },
      {
        key => "TYPE",
        label => "Tipo",
        map => @means_type_options
      },
      {
        key => "auttyp",
        label => "Tipo de auto",
        map => @means_auttyp_options
      },
      {
        key => "status",
        label => "Estatus",
        map => @means_status_options
      },
      {
        key => "string",
        label => "String"
      }
    ]
  };
};

get "/means/form" => sub {
  return {
    icon => "car",
    title => "Vehiculo",
    fields => [
      {
        key => "NAME",
        label => "Nombre",
        type => "text"
      },
      {
        key => "plate",
        label => "Placa",
        type => "text"
      },
      {
        key => "TYPE",
        label => "Tipo",
        type => "select",
        options => @means_type_options,
        optionsKey => 'from',
        optionsValue => 'to'
      },
      {
        key => "auttyp",
        label => "Tipo de auto",
        type => "select",
        options => @means_auttyp_options,
        optionsKey => 'from',
        optionsValue => 'to'
      },
      {
        key => "status",
        label => "Estatus",
        type => "select",
        options => @means_status_options,
        optionsKey => 'from',
        optionsValue => 'to'
      },
      {
        key => "string",
        label => "String",
        type => "text"
      }
    ]
  };
};

my @usuarios_nivel_options = [
  { from => 1, to => "Administrador"},
  { from => 2, to => "Supervisor"},
  { from => 3, to => "Usuario"}
];

my @usuarios_estatus_options = [
  { from => 1, to => "Activo"},
  { from => 0, to => "Inactivo"}
];

get "/usuarios/table" => sub {
  status 200;
  return {
    icon => "account-multiple",
    title => 'Usuarios',
    id => "idusuarios",
    columns => [
      {
        key => "usuario",
        label => "Usuario"
      },
      {
        key => "nombre",
        label => "Nombre"
      },
      {
        key => "nivel",
        label => "Nivel",
        map => @usuarios_nivel_options
      },
      {
        key => "estatus",
        label => "Estatus",
        map => @usuarios_estatus_options
      },
      {
        key => "numero_empleado",
        label => "Numero de Empleado"
      }
    ],
    options => [
      {
        icon => 'pencil',
        label => 'Editar',
        action => {
          type => 'form',
          form => '/usuarios'
        }
      }
    ],
    buttons => [
      {
        icon => 'plus',
        label => 'Nuevo',
        action => {
          type => 'form',
          form => '/usuarios'
        }
      }
    ]
  };
};

get "/usuarios/form" => sub {
  status 200;
  return {
    icon => "account",
    title => "Usuario",
    fields => [
      {
        key => "usuario",
        label => "Usuario",
        type => "text",
      },
      {
        key => "nombre",
        label => "Nombre",
        type => "text"
      },
      {
        key => "numero_empleado",
        label => "Numero de Empleado",
        type => "number"
      },
      {
        key => "nivel",
        label => "Nivel",
        type => "select",
        options => @usuarios_nivel_options,
        optionsKey => 'from',
        optionsValue => 'to'
      },
      {
        key => "estatus",
        label => "Estatus",
        type => "select",
        options => @usuarios_estatus_options,
        optionsKey => 'from',
        optionsValue => 'to'
      },
      {
        key => "password",
        label => "Password",
        type => "password",
        minlength => 6,
        hint => "Deja el campo en blanco para conservar el password actual"
      }
    ]
  }
};
