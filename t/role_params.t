#!/usr/bin/env perl

use Test::More tests => 3;

use Emma::Role::Params;
my $params = Emma::Role::Params->meta;

is_deeply(
    [ sort $params->get_attribute_list() ],
    [ 'concurrency', 'debug', 'filename', 'from', 'leg', 'password', 'proxy', 
        'registrar', 'timeout', 'to', 'username' ],
    '... got the right attribute list');

ok($params->get_attribute('to')->is_required);
ok($params->get_attribute('proxy')->is_required);
1;

