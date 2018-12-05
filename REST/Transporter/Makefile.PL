use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on them.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'Transporter',
    AUTHOR              => q{CARLOS GOMEZ <cgomez@tecflo.com.mx>},
    VERSION_FROM        => 'lib/Transporter/Means.pm',
    ABSTRACT            => 'TRANSPORTADOR DE INFORMACION ENTRE MASTER@FARMACIAS_DE_GUADALAJARA Y ORCU@ORPAK_GASBOY',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer'     => 1.3500,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Transporter-*' },
);
