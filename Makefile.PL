
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'App::Emma::Voip',
    VERSION_FROM => "bin/emma",    
    ABSTRACT => 'Simple telephone operator for send a file',
    PREREQ_PM => {
        'Module::Build' => 0.36,
        'ExtUtils::MakeMaker' => 6.31,
        'ExtUtils::Install' => 1.46,
        'Test::More' => 0.90,
        'Net::SIP' => 0.59,
        'POE' => 1.289,
        'Getopt::Long' => 2.37,
        'Text::CSV' => 1.18,
    },
    LICENSE => 'perl',
    EXE_FILES => [ 'bin/emma' ],
);

