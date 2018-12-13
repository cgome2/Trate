package Transporter::Static;

use Dancer ':syntax';
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

get '/menu' => sub {
	status 200;
	return {
		title => "Siteomat",
		modules =>[
			{
				label=> "Configuracion",
				path=> "/configuracion",
				icon=>"settings",
				menu=> [
					{
						header=>"Catalogos",
						links=>[
							{
								label=>"Usuarios",
								path =>"/configuracion/catalogos/usuarios"
							},
							{
								label=>"Vehiculos",
								path =>"/configuracion/catalogos/vehiculos"
							}
						]
					}
				]
			}
		]
	};
};

get '/components' => sub {
  status 200;
  return {
    component => "tableLocal",
    endPoint => "/means"
  };
};

my @tipo = [
  { key => 2, value => "Dispositivo montado en vehiculo"},
  { key => 3, value => "Tag tipo vehiculo"},
  { key => 4, value => "Tag despachador"}
];

get '/means/table' => sub {
  status 200;
  return {
    icon => "car",
    title => "Vehiculos",
    editable => 1,
    addButton => 1,
    idField => "id",
    columns => [
      {
        key => "name",
        label => "Nombre"
      },
      {
        key => "plate",
        label => "Placa"
      },
      {
        key => "type",
        label => "Tipo",
        map => @tipo
      },
      {
        key => "status",
        label => "Estatus"
      },
      {
        key => "string",
        label => "String"
      }
    ]
  };
};

my @niveles_usuario = [
  { key => 1, value => "Administrador"},
  { key => 2, value => "Supervisor"},
  { key => 3, value => "Usuario"}
];

my @estatus_usuario = [
  { key => 1, value => "Activo"},
  { key => 0, value => "Inactivo"}
];

get '/usuarios/table' => sub {
  status 200;
  return {
    icon => "user",
    title => "Usuarios",
    editable => 1,
    addButton => 1,
    idField => "idusuarios",
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
        map => @niveles_usuario
      },
      {
        key => "estatus",
        label => "Estatus",
        map => @estatus_usuario
      }
    ]
  };
};

get '/usuarios/form' => sub {
  status 200;
  return {
    icon => "account",
    title => "Usuarios",
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
        key => "nivel",
        label => "Nivel",
        type => "select",
        options => @niveles_usuario
      },
      {
        key => "estatus",
        label => "Estatus",
        type => "select",
        options => @estatus_usuario
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
