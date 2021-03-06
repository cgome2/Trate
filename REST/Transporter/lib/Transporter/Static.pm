package Transporter::Static;

use Switch;
use Dancer ":syntax";
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Usuarios;
use utf8;

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
					},
					{
						header => "Turno",
						path => "/estatus/turno",
						level => 1
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
					},
					{
						header => "Precios",
						path => "/despacho/precios"
					}
				]
			},
			{
				label => "Recepción de Combustible",
				path => "/recepcion",
				icon => "receipt",
				menu => [
					{
						header => "Documentos",
						path => "/recepcion/documentos"
					},
					{
						header => "Lecturas",
						path => "/recepcion/lecturas"
					},
				]
			},
			{
				label => "Turnos",
				icon => "timetable",
				path => "/turnos"
			},
			{
				label => "Reportes",
				path => "/reportes",
				icon => "clipboard-text",
				menu => [
					{
						header => "Transacciones",
						path => "/reportes/transacciones"
					}
				]
			},
			{
				label => "Configuracion",
				path => "/configuracion",
				icon => "settings",
        level => 1,
				menu => [
					{
						header => "Usuarios",
						path => "/configuracion/usuarios"
					},
					{
						header => "Vehiculos",
						path => "/configuracion/vehiculos"
					}
				]
			},
			{
				label => "Cambiar contrasena",
				icon => "account-key",
				path => "/cambiar-contrasena",
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
    case "/estatus/dispensarios"        { $component = "pumps"; }
    case "/estatus/tanques"             { $component = "tanks"; }
    case "/estatus/turno"                { $component = "transporter"; }

    case "/despacho/contingencias"      { $component = "superTable"; $endpoint = "/pases"; }
    case "/despacho/jarreos"            { $component = "jarreos"; $endpoint = "/jarreos"; }
    case "/despacho/precios"            { $component = "superTable"; $endpoint = "/productos"; }

    case "/recepcion/documentos"        { $component = "superTable"; $endpoint = "/recepciones_combustible"; }
    case "/recepcion/lecturas"          { $component = "superTable"; $endpoint = "/lecturas_tls"; }

    case "/turnos"                      { $component = "superTable"; $endpoint = "/shifts"; }

    case "/reportes/transacciones"      { $component = "reporter"; $endpoint = "/transacciones"; }

    case "/configuracion/usuarios"      { $component = "superTable"; $endpoint = "/usuarios"; }
    case "/configuracion/vehiculos"     { $component = "superTable"; $endpoint = "/means"; }
    case "/cambiar-contrasena"          { $component = "superForm"; $endpoint = "/pass"; }
  }

  return {
    component => $component,
    endPoint => $endpoint,
    id => $id
  };
};

get "/transacciones/form" => sub {
  return {
    icon => "account-key",
    title => "Transacciones",
    sqlDates => 1,
    fields => [
      {
        key => "date_from",
        label => "Fecha (desde)",
        type => "datetime"
      },
      {
        key => "date_to",
        label => "Fecha (hasta)",
        type => "datetime"
      },
      {
        key => "transaction_from",
        label => "Transacción (desde)",
        type => "number"
      },
      {
        key => "transaction_to",
        label => "Transacción (hasta)",
        type => "number"
      },
      {
        key => "pase_desde",
        label => "Pase (desde)",
        type => "number"
      },
      {
        key => "pase_hasta",
        label => "Pase (hasta)",
        type => "number"
      },
      {
        key => "litros_desde",
        label => "Litros (desde)",
        type => "number"
      },
      {
        key => "litros_hasta",
        label => "Litros (hasta)",
        type => "number"
      },
      {
        key => "camiones",
        label => "Dispositivos",
        type => "select",
        multiple => 1,
        optionsSource => "/means",
        optionsKey => "id",
        optionsValue => "NAME"
      },
      {
        key => "bombas",
        label => "Bombas",
        type => "select",
        multiple => 1,
        options => [
          { key => "1", value => "1" },
          { key => "2", value => "2" },
          { key => "3", value => "3" },
          { key => "4", value => "4" }
        ]
      },
      {
        key => "estatus_pase",
        label => "Estatus del Pase",
        type => "select",
        multiple => 1,
        options => [
          { key => "A", value => "Activo" },
          { key => "D", value => "Despachado" },
          { key => "R", value => "Reabierto" },
          { key => "T", value => "Transferido" },
          { key => "C", value => "Despachado en contingencia" },
          { key => "M", value => "Despachado en manual" }
        ]
      },
      {
        key => "group",
        label => "Agrupar por",
        type => "select",
        options => [
          { key => "", value => "Ninguno" },
          { key => "bomba", value => "Bomba" },
          { key => "camion", value => "Camión" },
          { key => "despachador", value => "Despachador" },
          { key => "dispositivo", value => "Dispositivo" },
          { key => "estatus_pase", value => "Estatus de pase" },
          { key => "fecha", value => "Fecha" },
        ]
      },
      {
        key => "order",
        label => "Ordenar por",
        type => "select",
        value => "fecha",
        options => [
          { key => "", value => "Ninguno" },
          { key => "bomba", value => "Bomba" },
          { key => "camion", value => "Camión" },
          { key => "despachador", value => "Despachador" },
          { key => "dispositivo", value => "Dispositivo" },
          { key => "estatus_pase", value => "Estatus de pase" },
          { key => "fecha", value => "Fecha" },
        ]
      },
      {
        key => "detalle",
        label => "Detalle",
        type => "checkbox",
        value => 1,
      }
    ]
  };
};

get "/pass/form" => sub {
  return {
    icon => "account-key",
    title => "Cambiar contrasena",
    sendTo => "/usuarios/cambiarpassword",
    fields => [
      {
        key => "actual",
        label => "Contrasena actual",
        type => "password"
      },
      {
        key => "nueva",
        label => "Nueva contrasena",
        type => "password"
      }
    ]
  };
};

get "/shifts/table" => sub {
  return {
    icon => "timetable",
    title => "Turnos",
    byDate => 1,
    remote => 1,
    options => [
      {
        icon => 'eye',
        label => 'Ver',
        action => {
          type => 'form',
          form => '/shifts/ver',
          id => "id_turno",
          readonly => 1
        }
      },
      {
        icon => 'pencil',
        label => 'Editar',
        condition => {
          status => 2
        },
        action => {
          type => 'form',
          form => '/shifts',
          id => "id_turno"
        }
      },
      {
        icon => 'close',
        label => 'Cerrar',
        condition => {
          status => 2
        },
        action => {
          type => 'http',
          endpoint => '/shifts',
          verb => 'patch',
          override => { status => 1 },
          block => "Cerrando turno"
        }
      }
    ],
    buttons => [
      {
        icon => 'plus',
        label => 'Abrir turno',
        action => {
          type => 'form',
          form => '/shifts/nuevo',
          preload => 'nuevo'
        }
      }
    ],
    columns => [
      {
        key => "id_turno",
        label => "Id"
      },
      {
        key => "usuario_abre",
        label => "Supervisor"
      },
      {
        key => "fecha_abierto",
        label => "Fecha"
      },
      {
        key => "usuario_cierra",
        label => "Supervisor cierre"
      },
      {
        key => "fecha_cierre",
        label => "Fecha de cierre"
      },
      {
        key => "status",
        label => "Estatus",
        map => [
          { from => 2, to => 'Abierto' },
          { from => 1, to => 'Cerrado' }
        ]
      }
    ]
  };
};


get "/shifts/form" => sub {
  return {
    block => "Actualizando turno",
    icon => "timetable",
    title => "Turno",
    getFrom => "/shifts",
    sendTo => "/shifts",
    sqlDates => 1,
    fields => [
      {
        key => "id_turno",
        label => "Id",
        type => "text",
        readonly => 1
      },
      {
        key => "usuario_abre",
        label => "Supervisor",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_abierto",
        label => "Fecha",
        type => "text",
        readonly => 1
      },
    ],
    details => [
      {
        key => "MEANS_TURNO",
        label => "Despachadores",
        required => 1,
        unique => 'mean_id',
        columns => [
          {
            key => "activo",
            label => "Activo",
            type => "checkbox"
          },
          {
            key => "despachador",
            label => "Despachador"
          },
          {
            key => "status",
            label => "Estatus"
          },
          {
            key => "usuario_add",
            label => "Agregado por"
          },
          {
            key => "usuario_rm",
            label => "Removido por"
          },
          {
            key => "litros_despachados",
            label => "Litros despachados"
          }
        ]
      },
      {
        key => "BOMBAS_TURNO",
        label => "Bombas",
        readonly => 1,
        columns => [
          {
            key => "bomba",
            label => "Bomba"
          },
          {
            key => "totalizador_al_abrir",
            label => "Totalizador al Abrir"
          },
          {
            key => "totalizador_al_cerrar",
            label => "Totalizador al cerrar"
          },
          {
            key => "litros_despachados",
            label => "Litros despachados"
          }
        ]
      },
      {
        key => "TANQUES_TURNO",
        label => "Tanques",
        readonly => 1,
        columns => [
          {
            key => "tank_name",
            label => "Tanque"
          },
          {
            key => "volumen_inicial",
            label => "Volumen inicial"
          },
          {
            key => "volumen_final",
            label => "Volumen final"
          },
          {
            key => "volumen_final",
            label => "Volumen final"
          },
          {
            key => "volumen_diferencia",
            label => "Diferencia volumen"
          }
        ]
      },
      {
        key => "RECEPCIONES_COMBUSTIBLE_TURNO",
        label => "Recepciones",
        readonly => 1,
        columns => [
          {
            key => "id_recepecion",
            label => "Número"
          },
          {
            key => "inicio_descarga",
            label => "Fecha inicio"
          },
          {
            key => "fin_descarga",
            label => "Fecha fin"
          },
          {
            key => "volumen_descarga",
            label => "Volumen"
          },
          {
            key => "tanque",
            label => "Tanque"
          },
          {
            key => "tipo_registro",
            label => "Tipo"
          },
          {
            key => "status",
            label => "Estatus"
          },
          {
            key => "factura",
            label => "Factura"
          },
          {
            key => "supervisor",
            label => "Registró"
          },
        ]
      }
    ]
  };
};


get "/shifts/nuevo/form" => sub {
  return {
    block => "Abriendo turno",
    icon => "timetable",
    title => "Turno",
    getFrom => "/shifts",
    sendTo => "/shifts",
    sqlDates => 1,
    fields => [
      {
        key => "usuario_abre",
        label => "Supervisor",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_abierto",
        label => "Fecha",
        type => "text",
        readonly => 1
      },
    ],
    details => [
      {
        key => "MEANS_TURNO",
        label => "Despachadores",
        required => 1,
        unique => 'mean_id',
        columns => [
          {
            key => "activo",
            label => "Activo",
            type => "checkbox"
          },
          {
            key => "mean_id",
            label => "Id"
          },
          {
            key => "despachador",
            label => "Despachador"
          }
        ]
      }
    ]
  };
};


get "/shifts/ver/form" => sub {
  return {
    icon => "timetable",
    title => "Turno",
    getFrom => "/shifts",
    sendTo => "/shifts",
    sqlDates => 1,
    print => 1,
    fields => [
      {
        key => "id_turno",
        label => "Id",
        type => "text",
        readonly => 1
      },
      {
        key => "usuario_abre",
        label => "Supervisor",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_abierto",
        label => "Fecha",
        type => "text",
        readonly => 1
      },
      {
        key => "usuario_cierra",
        label => "Supervisor cierre",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_cierre",
        label => "Fecha de cierre",
        type => "text",
        readonly => 1
      },
    ],
    details => [
      {
        key => "MEANS_TURNO",
        label => "Despachadores",
        readonly => 1,
        columns => [
          {
            key => "despachador",
            label => "Despachador"
          },
          {
            key => "status",
            label => "Estatus"
          },
          {
            key => "usuario_add",
            label => "Agregado por"
          },
          {
            key => "usuario_rm",
            label => "Removido por"
          },
          {
            key => "litros_despachados",
            label => "Litros despachados"
          }
        ]
      },
      {
        key => "BOMBAS_TURNO",
        label => "Bombas",
        readonly => 1,
        columns => [
          {
            key => "bomba",
            label => "Bomba"
          },
          {
            key => "totalizador_al_abrir",
            label => "Totalizador al Abrir"
          },
          {
            key => "totalizador_al_cerrar",
            label => "Totalizador al cerrar"
          },
          {
            key => "litros_despachados",
            label => "Litros despachados"
          }
        ]
      },
      {
        key => "TANQUES_TURNO",
        label => "Tanques",
        readonly => 1,
        columns => [
          {
            key => "tank_name",
            label => "Tanque"
          },
          {
            key => "volumen_inicial",
            label => "Volumen inicial"
          },
          {
            key => "volumen_final",
            label => "Volumen final"
          },
          {
            key => "volumen_diferencia",
            label => "Diferencia volumen"
          },
        ]
      },
      {
        key => "RECEPCIONES_COMBUSTIBLE_TURNO",
        label => "Recepciones",
        readonly => 1,
        columns => [
          {
            key => "id_recepecion",
            label => "Número"
          },
          {
            key => "inicio_descarga",
            label => "Fecha inicio"
          },
          {
            key => "fin_descarga",
            label => "Fecha fin"
          },
          {
            key => "volumen_descarga",
            label => "Volumen"
          },
          {
            key => "tanque",
            label => "Tanque"
          },
          {
            key => "tipo_registro",
            label => "Tipo"
          },
          {
            key => "status",
            label => "Estatus"
          },
          {
            key => "factura",
            label => "Factura"
          },
          {
            key => "supervisor",
            label => "Registró"
          },
        ]
      }
    ]
  };
};

get "/productos/table" => sub {
  return {
    icon => "currency-usd",
    title => "Precios",
    options => [
      {
        icon => 'currency-usd',
        label => 'Cambio de precio',
        action => {
          type => 'form',
          form => '/productos',
          id => "id",
        }
      }
    ],
    columns => [
      {
        key => "NAME",
        label => "Nombre"
      },
      {
        key => "price",
        label => "Precio",
        format => "currency"
      },
      {
        key => "last_updated",
        label => "Ultimo cambio"
      },
      {
        key => "next_price",
        label => "Proximo precio",
        format => "currency"
      },
      {
        key => "next_update",
        label => "Proximo cambio"
      }
    ]
  };
};

get "/productos/form" => sub {
  return {
    icon => "currency-usd",
    title => "Precios",
    getFrom => "/productos",
    sendTo => "/productos",
    sqlDates => 1,
    fields => [
      {
        key => "NAME",
        label => "Nombre",
        type => "text",
        readonly => 1
      },
      {
        key => "last_updated",
        label => "Ultimo cambio",
        type => "text",
        readonly => 1
      },
      {
        key => "price",
        label => "Precio",
        type => "text",
        readonly => 1
      },
      {
        key => "next_price",
        label => "Proximo precio",
        type => "number", 
        required => 1
      },
      {
        key => "next_update",
        label => "Proximo cambio",
        type => "datetime", 
        required => 1
      }
    ],
  };
};


get "/recepciones_combustible/table" => sub {
  return {
    icon => "file-document",
    title => "Documentos",
    buttons => [
      {
        icon => 'receipt',
        label => 'Nueva Factura',
        action => {
          type => 'form',
          form => '/recepciones_combustible'
        }
      }
    ],
    options => [
      {
        icon => 'receipt',
        label => 'Editar',
        condition => {
          status => '1'
        },
        action => {
          type => 'form',
          form => '/recepciones_combustible',
          id => "id_recepcion"
        }
      },
      {
        icon => 'playlist-plus',
        label => 'Agregar TLS',
        condition => {
          status => '1'
        },
        action => {
          type => 'form',
          form => '/recepciones_combustible/tls',
          id => "id_recepcion"
        }
      }
    ],
    columns => [
      {
        key => "id_recepcion",
        label => "Recepcion"
      },
      {
        key => "folio_documento",
        label => "Folio"
      },
      {
        key => "fecha_recepcion",
        label => "Fecha de recepcion",
      },
      {
        key => "fecha_documento",
        label => "Fecha"
      },
      {
        key => "litros_documento",
        label => "Litros",
      },
      {
        key => "importe_documento",
        label => "Importe",
      },
      {
        key => "empleado_captura",
        label => "Empleado",
      },
      {
        key => "status",
        label => "Estatus",
        map => [
          { from => 1, to => 'Sin TLS' },
          { from => 2, to => 'Procesado' }
        ]
      },
    ]
  };
};

get "/recepciones_combustible/form" => sub {
  return {
    icon => "receipt",
    title => "Agregar Documento",
    getFrom => "/recepciones_combustible",
    sendTo => "/recepciones_combustible",
    sqlDates => 1,
    fields => [
      {
        key => "fecha_recepcion",
        label => "Fecha de Recepcion",
        type => "date",
        required => 1
      },
      {
        key => "fecha_documento",
        label => "Fecha del Documento",
        type => "date",
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
        key => "sello_pemex",
        label => "Sello PEMEX",
        type => "text",
        required => 1
      },
      {
        key => "folio_documento",
        label => "Folio Documento",
        type => "text",
        required => 1
      },
      {
        key => "tipo_documento",
        label => "Tipo",
        type => "select",
        options => [
          { key => "CP", value => "CP"},
          { key => "RP", value => "RP"}
        ],
        required => 1
      },
      {
        key => "serie_documento",
        label => "Serie Documento",
        type => "text",
        required => 1
      },
      {
        key => "numero_proveedor",
        label => "Proveedor",
        type => "select",
        optionsSource => "/proveedores",
        optionsKey => "id",
        optionsValue => "proveedor",
        required => 1
      },
      {
        key => "litros_documento",
        label => "Litros",
        type => "number",
        required => 1
      },
      {
        key => "importe_documento",
        label => "Importe",
        type => "number",
        required => 1
      },
      {
        key => "ppv_documento",
        label => "Precio por Litro",
        type => "number",
        operation => "division",
        operands => ["importe_documento", "litros_documento"],
        readonly => 1,
        required => 1
      },
      {
        key => "iva_documento",
        label => "IVA",
        type => "number",
        required => 1
      },
      {
        key => "ieps_documento",
        label => "IEPS",
        type => "number",
        required => 1
      },
    ],
  };
};

get "/recepciones_combustible/tls/form" => sub {
  return {
    icon => "playlist-plus",
    title => "Agregar TLS",
    getFrom => "/recepciones_combustible",
    sendTo => "/recepciones_combustible",
    override => { status => "2" },
    sqlDates => 1,
    fields => [
       {
        key => "fecha_recepcion",
        label => "Fecha de Recepcion",
        type => "text",
        readonly => 1
      },
      {
        key => "fecha_documento",
        label => "Fecha del Documento",
        type => "text",
        readonly => 1
      },
      {
        key => "terminal_embarque",
        label => "Terminal de Embarque",
        type => "text",
        readonly => 1
      },
      {
        key => "sello_pemex",
        label => "Sello PEMEX",
        type => "text",
        readonly => 1
      },
      {
        key => "folio_documento",
        label => "Folio Documento",
        type => "text",
        readonly => 1
      },
      {
        key => "tipo_documento",
        label => "Tipo",
        type => "text",
        readonly => 1
      },
      {
        key => "serie_documento",
        label => "Serie Documento",
        type => "text",
        readonly => 1
      },
      {
        key => "numero_proveedor",
        label => "Proveedor",
        type => "select",
        optionsSource => "/proveedores",
        optionsKey => "id",
        optionsValue => "proveedor",
        readonly => 1
      },
      {
        key => "litros_documento",
        label => "Litros",
        type => "text",
        readonly => 1
      },
      {
        key => "importe_documento",
        label => "Importe",
        type => "text",
        readonly => 1
      },
      {
        key => "ppv_documento",
        label => "Precio por Litro",
        type => "text",
        readonly => 1
      },
      {
        key => "iva_documento",
        label => "IVA",
        type => "text",
        readonly => 1
      },
      {
        key => "ieps_documento",
        label => "IEPS",
        type => "text",
        readonly => 1
      }
    ],
    details => [
      {
        key => "lecturas_combustible",
        label => " Lecturas",
        checkboxes => "Seleccionar",
        columns => [
          {
            key => "id_tank_delivery_reading",
            label => "Id"
          },
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
            format => "number:1.2-2:"
          },
          {
            key => "end_volume",
            label => "Volumen final",
            format => "number:1.2-2:"
          },
          {
            key => "origen_registro",
            label => "Origen"
          }
        ],
        required  => 1,
      }
    ]
  };
};


get "/lecturas_tls/table" => sub {
  return {
    icon => "ruler",
    title => "Lecturas",
    columns => [
      {
        key => "id_tank_delivery_reading",
        label => "Id",
      },
      {
        key => "tank_name",
        label => "Tanque",
      },
      {
        key => "start_volume",
        label => "Volumen inicial"
      },
      {
        key => "end_volume",
        label => "Volumen final"
      },
      # {
      #   key => "start_temp",
      #   label => "Temperatura inicial"
      # },
      # {
      #   key => "end_temp",
      #   label => "Temperatura final"
      # },
      # {
      #   key => "start_water",
      #   label => "Agua inicial"
      # },
      # {
      #   key => "end_water",
      #   label => "Agua final"
      # },
      {
        key => "start_delivery_timestamp",
        label => "Fecha de inicio"
      },
      {
        key => "end_delivery_timestamp",
        label => "Fecha de fin"
      },
      {
        key => "origen_registro",
        label => "Origen"
      }
    ],
    options => [
      {
        icon => 'eye',
        label => 'Ver',
        action => {
          type => 'form',
          form => '/lecturas_tls/ver',
          id => "id_tank_delivery_reading"
        }
      },
      {
        icon => 'pencil',
        label => 'Editar',
        condition => {
          origen_registro => "MANUAL"
        },
        action => {
          type => 'form',
          form => '/lecturas_tls',
          id => "id_tank_delivery_reading"
        }
      },
      {
        icon => 'delete',
        label => 'Eliminar',
        condition => {
          origen_registro => "MANUAL"
        },
        action => {
          type => 'http',
          verb => 'delete',
          endpoint => '/lecturas_tls/:id_tank_delivery_reading:'
        }
      },
    ],
    buttons => [
      {
        icon => 'plus',
        label => 'Nueva lectura',
        action => {
          type => 'form',
          form => '/lecturas_tls'
        }
      },
    ]
  };
};

get "/lecturas_tls/form" => sub {
  return {
    icon => "ruler",
    title => "Lectura",
    getFrom => "/lecturas_tls",
    sendTo => "/lecturas_tls",
    sqlDates => 1,
    override => {
      origen_registro => "MANUAL",
      start_tc_volume => "",
      end_tc_volume => ""
    },
    fields => [
      {
        key => "tank",
        label => "Tanque",
        type => "select",
        optionsSource => "/tanques",
        optionsKey => "ID",
        optionsValue => "NAME",
        storeObject => 1,
        required => 1
      },
      {
        key => "start_volume",
        label => "Volumen inicial",
        type => "number",
        required => 1
      },
      {
        key => "end_volume",
        label => "Volumen final",
        type => "number",
        required => 1
      },
      {
        key => "start_temp",
        label => "Temperatura inicial",
        type => "number",
        required => 1
      },
      {
        key => "end_temp",
        label => "Temperatura final",
        type => "number",
        required => 1
      },
      {
        key => "start_water",
        label => "Agua inicial",
        type => "number",
        required => 1
      },
      {
        key => "end_water",
        label => "Agua final",
        type => "number",
        required => 1
      },
      {
        key => "start_height",
        label => "Altura inicial",
        type => "number",
        required => 1
      },
      {
        key => "end_height",
        label => "Altura final",
        type => "number",
        required => 1
      },
      {
        key => "start_delivery_timestamp",
        label => "Fecha de inicio",
        type => "datetime",
        lowerThan => "end_delivery_timestamp",
        lowerThanError => "Debe ser menor a fecha fin",
        required => 1
      },
      {
        key => "end_delivery_timestamp",
        label => "Fecha fin",
        type => "datetime",
        greaterThan => "start_delivery_timestamp",
        greaterThanError => "Debe ser mayor a fecha de inicio",
        required => 1
      }
    ]
  };
};

get "/lecturas_tls/ver/form" => sub {
  return {
    icon => "ruler",
    title => "Lectura",
    getFrom => "/lecturas_tls",
    sendTo => "/asdf",
    fields => [
      {
        key => "tank",
        label => "Tanque",
        type => "select",
        optionsSource => "/tanques",
        optionsKey => "ID",
        optionsValue => "NAME",
        storeObject => 1,
        readonly => 1
      },
      {
        key => "start_volume",
        label => "Volumen inicial",
        type => "text",
        readonly => 1
      },
      {
        key => "end_volume",
        label => "Volumen final",
        type => "text",
        readonly => 1
      },
      {
        key => "start_temp",
        label => "Temperatura inicial",
        type => "text",
        readonly => 1
      },
      {
        key => "end_temp",
        label => "Temperatura final",
        type => "text",
        readonly => 1
      },
      {
        key => "start_water",
        label => "Agua inicial",
        type => "text",
        readonly => 1
      },
      {
        key => "end_water",
        label => "Agua final",
        type => "text",
        readonly => 1
      },
      {
        key => "start_height",
        label => "Altura inicial",
        type => "text",
        readonly => 1
      },
      {
        key => "end_height",
        label => "Altura final",
        type => "text",
        readonly => 1
      },
      {
        key => "start_delivery_timestamp",
        label => "Fecha de inicio",
        type => "text",
        readonly => 1
      },
      {
        key => "end_delivery_timestamp",
        label => "Fecha fin",
        type => "text",
        readonly => 1
      }
    ]
  };
};


get "/pases/table" => sub {
  return {
    icon => "alarm-light",
    title => "Contingencias",
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
        key => "mean_contingencia",
        label => "Tag de Contingencia"
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
        condition => {
          status => "D|C|M"
        },
        action => {
          type => 'form',
          form => '/pases/reabrir',
          id => "pase_id"
        }
      },
      {
        icon => 'transfer',
        label => 'Reasignar',
        condition => { 
          status => "A|T|R"
        },
        action => {
          type => 'form',
          form => '/pases/reasignar',
          id => "pase_id"
        }
      },
      {
        icon => 'hand',
        label => 'Manual',
        condition => {
          status => "A|T|R"
        },
        action => {
          type => 'form',
          form => '/pases/manual',
          id => "pase_id"
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
        key => "mean_contingencia",
        label => "Tag de Contingencia",
        type => "select",
        optionsSource => "/means/contingencia",
        optionsKey => "NAME",
        optionsValue => "NAME",
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
        key => "mean_contingencia",
        label => "Tag de Contingencia",
        type => "select",
        optionsSource => "/means/contingencia",
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
    sendTo => "/transacciones",
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
        optionsKey => "id",
        optionsValue => "NAME",
        required => 1
      },
      {
        key => "producto",
        label => "Producto",
        type => "select",
        optionsSource => "/productos",
        optionsKey => "code",
        optionsValue => "NAME",
        required => 1
      },
      {
        key => "litros",
        label => "Litros Despachados",
        type => "number",
        required => 1
      },
      {
        key => "totalizador",
        label => "Totalizador electronico",
        type => "number",
        required => 1
      },
      {
        key => "bomba",
        label => "Bomba",
        type => "select",
        optionsSource => "/bombas",
        optionsKey => "PUMP_HEAD",
        optionsValue => "PUMP_HEAD",
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

get "/means/table" => sub {
  return {
    icon => "car",
    title => "Vehiculos",
    options => [
      {
        icon => 'pencil',
        label => 'Editar',
        action => {
          type => 'form',
          form => '/means/editar',
          id => "id"
        }
      },
      {
        icon => 'water',
        label => 'Activar',
        condition => {
          auttyp => '21',
          hardware_type => '1',
          TYPE => '2',
          status => '1'
        },
        action => {
          type => 'http',
          endpoint => '/means',
          verb => 'patch',
          override => { status => 2 }
        }
      },
      {
        icon => 'water-off',
        label => 'Desactivar',
        condition => {
          auttyp => '21',
          hardware_type => '1',
          TYPE => '2',
          status => '2'
        },
        action => {
          type => 'http',
          endpoint => '/means',
          verb => 'patch',
          override => { status => 1 }
        }
      },
      {
        icon => 'close',
        label => 'Eliminar',
        action => {
          type => 'http',
          endpoint => '/means',
          verb => 'patch',
          override => { status => 0 }
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
        key => "label",
        label => "Tipo",
      },
      {
        key => "status",
        label => "Estatus",
        map => [
          { from => "1", to => "Inactivo"},
          { from => "2", to => "Activo"},
        ]
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
    title => "Vehículo",
    transformer => { typeee => 'TYPE,hardware_type,auttyp' },
    fields => [
      {
        required => 1,
        key => "NAME",
        label => "Nombre",
        type => "text"
      },
      {
        required => 1,
        key => "plate",
        label => "Placa",
        type => "text"
      },
      {
        required => 1,
        key => "typeee",
        label => "Tipo de dispositivo",
        type => "select",
        optionsSource => '/means/types/mono',
        optionsKey => 'value',
        optionsValue => 'label',
        storeObject => 1
      },
      {
        key => "string",
        label => "String",
        type => "text",
        bindings => {
          disable => "typeee.value.TYPE==3,typeee.value.auttyp==1,typeee.value.hardware_type==6"
        }
      },
      {
        required => 1,
        key => "numero_strings",
        label => "Número de dispositivos asociados",
        type => "select",
        options => [
          { key => "1", value => "1"},
          { key => "2", value => "2"},
          { key => "3", value => "3"},
          { key => "4", value => "4"},
          { key => "5", value => "5"}
        ],
        bindings => {
          enable => "typeee.value.TYPE==3,typeee.value.auttyp==1,typeee.value.hardware_type==6"
        }
      }
    ]
  };
};

get "/means/editar/form" => sub {
  return {
    icon => "car",
    title => "Vehículo",
    getFrom => "/means",
    sendTo => "/means",
    transformer => { typeee => 'TYPE,hardware_type,auttyp' },
    fields => [
      {
        required => 1,
        key => "NAME",
        label => "Nombre",
        type => "text"
      },
      {
        required => 1,
        key => "plate",
        label => "Placa",
        type => "text"
      },
      {
        required => 1,
        key => "typeee",
        label => "Tipo de dispositivo",
        type => "select",
        readonly => 1,
        optionsSource => '/means/types/mono',
        optionsKey => 'value',
        optionsValue => 'label',
        storeObject => 1
      },
      {
        required => 1,
        key => "string",
        label => "String",
        type => "text",
        bindings => {
          disable => "typeee.value.TYPE==3,typeee.value.auttyp==1,typeee.value.hardware_type==6"
        }
      },
      {
        required => 1,
        key => "numero_strings",
        label => "Número de dispositivos asociados",
        type => "select",
        options => [
          { key => "1", value => "1"},
          { key => "2", value => "2"},
          { key => "3", value => "3"},
          { key => "4", value => "4"},
          { key => "5", value => "5"}
        ],
        bindings => {
          enable => "typeee.value.TYPE==3,typeee.value.auttyp==1,typeee.value.hardware_type==6"
        }
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
          form => '/usuarios',
          id => "idusuarios"
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
        type => "text"
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
