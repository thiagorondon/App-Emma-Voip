
package Emma::IO::CSV;

use Moose;
use namespace::autoclean;
use Text::CSV;

has file => (
    is => 'rw', 
    isa => 'Str'
);

after file => sub {
    my ($self, $file) = @_;
#    die "Cannot open file" unless -r $file;
};

has rows => (
    traits => ['Array'],
    isa => 'ArrayRef[HashRef]',
    default => sub { [] },
    is => 'ro',
    handles => {
        all_rows => 'elements',
        count_rows => 'count',
        add_rows => 'push',
        get_rows => 'shift'
    }
);

sub read {
    my $self = shift;
    my @rows;
    my $csv = Text::CSV->new() or die "cannot use csv";

    open my $fh, "<:encoding(utf8)", $self->file 
        or die join(':', $self->file . $!);

    while (my $row = $csv->getline($fh) ) {
        my $message = { from => $row->[0], to => $row->[1] };

        $self->add_rows($message)
    }

    $csv->eof and close $fh;
    return $self->all_rows;
}

__PACKAGE__->meta->make_immutable;

1;

