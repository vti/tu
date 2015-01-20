package Tu::Factory::Observable;

use strict;
use warnings;

use base 'Tu::Factory';

my $seen = {};

sub build {
    my $self = shift;
    my ($class_name, %options) = @_;

    my $observer_names = delete $options{observers};

    my $object = $self->SUPER::build($class_name, %options);
    return $object unless $observer_names;

    foreach my $observer_name (@$observer_names) {
        my $observer_class = $self->_build_class_name($observer_name);
        $observer_class = $self->_load_class($observer_class);

        my $observer = $observer_class->new;

        $object->observe($observer);
    }

    return $object;
}

1;
