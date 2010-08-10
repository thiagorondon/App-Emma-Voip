
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'App::Emma',
    VERSION_FROM => "bin/emma",    
    ABSTRACT => 'Simple telephone operator for send an audio file',
    PREREQ_PM => {
        'Module::Build' => 0.36,
        'ExtUtils::MakeMaker' => 6.31,
        'ExtUtils::Install' => 1.46,
        'Test::More' => 0.90,
        'Net::SIP' => 0.59,
        'POE' => 1.289,
        'Text::CSV' => 1.18,
        'Moose' => 1.09,
        'MooseX::Getopt' => 0.31,
    },
    LICENSE => 'perl',
    EXE_FILES => [ 'bin/emma' ],
);

