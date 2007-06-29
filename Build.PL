use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::FreshBooks::API',
    license             => 'perl',
    dist_author         => 'Anthony Decena <anthony@mindelusions.com>',
    dist_version_from   => 'lib/WWW/FreshBooks/API.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'WWW-FreshBooks-API-*' ],
);

$builder->create_build_script();
