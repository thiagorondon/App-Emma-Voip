#!/usr/bin/env perl

use Test::More tests => 1;

use Emma::Role::Params;
my $params = Emma::Role::Params->meta;

is_deeply(
    [ sort $params->get_attribute_list() ],
    [ 'debug', 'filename', 'leg', 'password', 'proxy', 'registrar',
       'timeout', 'username' ],
    '... got the right attribute list');


1;

