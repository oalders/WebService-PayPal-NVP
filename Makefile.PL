use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'WebService-PayPal-NVP';
all_from 'lib/WebService/PayPal/NVP.pm';
author   q{Brad Haywood <brad@geeksware.com>};
license  'artistic2';

perl_version 5.006;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#WebService-PayPal-NVP',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   #repository => 'git://github.com/Brad Haywood/WebService-PayPal-NVP.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-PayPal-NVP',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

install_as_cpan;
auto_install;
WriteAll;
