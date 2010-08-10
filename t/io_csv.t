#!/usr/bin/env perl

use File::Temp qw/ tempfile :seekable /;

use Test::More tests => 7;
use strict;

use_ok('Emma::IO::CSV');

my $obj = Emma::IO::CSV->new;
eval { $obj->file('/dev/null') };
is($@, '', 'set a file for read');

my ($fh, $filename) = tempfile();
ok($filename);
ok($fh);

close $fh;
$fh = File::Temp->new;
print $fh "from,to\n" for 1 .. 5;
seek($fh, 0, 0);

$obj->file($fh->filename);

my @rows = $obj->read;
is(scalar(@rows), 5, 'scalar of rows');

is($rows[int(rand(5))]->{from}, 'from', 'value of from');
is($rows[int(rand(5))]->{to}, 'to', 'value of to');

1;

