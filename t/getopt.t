#!/usr/bin/env perl

use Test::More tests => 10;
use strict;

use_ok('Emma::Getopt');

local @ARGV = (
    '--debug',
    '--proxy', '127.0.0.1:5060',
    '--registrar', '127.0.0.1:5060', 
    '--filename', '/dev/null',
    '--leg', '127.0.0.1:1010',
    '--timeout', 50,
    '--username', 'foo', 
    '--password', 'baz',
    '--to', 'sip:foo@sip.bar.com',
    '--from', 'sip:baz@sip.bar.com'
);

my $app = Emma::Getopt->new_with_options;
ok($app);

is_deeply($app->debug, 1, 'debug as true');
is_deeply($app->proxy, '127.0.0.1:5060', 'proxy');
is_deeply($app->registrar, '127.0.0.1:5060', 'registrar');
is_deeply($app->filename, '/dev/null', 'filename');
is_deeply($app->leg, '127.0.0.1:1010', 'leg');
is_deeply($app->timeout, 50, 'timeout');
is_deeply($app->username, 'foo', 'username');
is_deeply($app->password, 'baz', 'password');

1;

