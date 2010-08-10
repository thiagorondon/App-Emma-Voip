
package Emma::Role::Params;

use Moose::Role;
use Moose::Util::TypeConstraints;

subtype 'IpPort'
    => as 'Str'
    => where { $_ =~ /.*:[0-9]*/ };

has debug => (
    is => 'rw', 
    isa => 'Bool',
    documentation => 'Enable debugging',
    default => 0,
);

has proxy => (
    is => 'rw',
    isa => 'IpPort',
    documentation => 'Use outgoing proxy, register there unless registrar
    given',
    default => '',
    required => 1
);

has registrar => (
    is => 'rw',
    isa => 'IpPort',
    documentation => 'Register at given address',
    default => '',
    lazy => 1,
    default => sub { shift->proxy }
);

has filename => (
    is => 'rw',
    isa => 'Str',
    documentation => 'Send content of file, can be given multiple times',
    default => '',
);

has leg => (
    is => 'rw',
    isa => 'IpPort',
    documentation => 'Use given local ip[:port] for outgoing leg',
    default => '',
);

has timeout => (
    is => 'rw',
    isa => 'Num',
    documentation => 'timeout and cancel invite after N seconds, default is
    30',
    default => 30
);

has username => (
    is => 'rw',
    isa => 'Str',
    documentation => 'Username for authorization',
);

has password => (
    is => 'rw',
    isa => 'Str',
    documentation => 'Password for authorization'
);

has from => (
    is => 'rw',
    isa => 'Str',
    documentation => 'from sip address',
    default => ''
);

has to => (
    is => 'rw',
    isa => 'Str',
    documentation => 'to sip address',
    required => 1
);

has concurrency => (
    is => 'rw',
    isa => 'Str',
    documentation => 'How many simultaneous calls do you want to do ?',
    default => 1
);


1;


