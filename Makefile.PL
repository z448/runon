use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Runon',
    AUTHOR              => 'Zdenek Bohunek <zed448@icloud.com>',
    VERSION_FROM        => 'lib/App/Runon.pm',
    ABSTRACT_FROM       => 'lib/App/Runon.pm',
    PL_FILES            => {},
    'EXE_FILES'         => ['runon'],
    PREREQ_PM => {
        'JSON::PP'      =>  0,
        'POSIX'         =>  0,
        'Term::ANSIColor'    =>  0,
        'Encode'        =>0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App::Runon-*' },
);
