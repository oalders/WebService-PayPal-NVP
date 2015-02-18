use 5.010;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'WebService::PayPal::NVP',
    VERSION_FROM    => 'lib/WebService/PayPal/NVP.pm',
    ABSTRACT        => 'PayPal Name-Value-Pair API',
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0, },
    DISTNAME        => 'WebService-PayPal-NVP',
    TEST_REQUIRES   => {
        'Test::More' => 0,
        'YAML::Syck' => 0,
    },
    LICENSE         => 'perl_5',
    PREREQ_PM       => {
        'Moo'               => 0,
        'LWP::UserAgent'    => 0,
        'URI::Escape'       => 0,
        'DateTime'          => 0,
        'YAML::Syck'        => 0,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
         resources => {
             repository => {
                 type => 'git',
                 url  => 'https://github.com/bradhaywood/WebService-PayPal-NVP.git',
                 web  => 'https://github.com/bradhaywood/WebService-PayPal-NVP',
             },
         },
    },
);
