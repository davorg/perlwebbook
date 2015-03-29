package Person;
use Moose;
use Moose::Util::TypeConstraints;
use DateTime;
use DateTime::Format::Strptime;

subtype 'BirthDate',
    as 'DateTime';

coerce 'BirthDate',
    from 'Str',
    via {
        return DateTime::Format::Strptime->new(
            pattern => '%Y-%m-%d',
        )->parse_datetime($_);
    };

subtype 'Gender',
    as 'Str',
    where { /^[FM]$/ },
    message { "$_ is not a valid gender. It should be F or M" };

has name => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

has dob => (
    isa      => 'BirthDate',
    is       => 'ro',
    required => 1,
    coerce   => 1,
);

has gender => (
    isa      => 'Gender',
    is       => 'rw',
    required => 1,
);

sub age {
    my $self = shift;

    my $duration = DateTime->now - $self->dob;

    return $duration->years;
}

1;
