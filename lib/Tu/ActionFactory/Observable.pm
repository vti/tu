package Tu::ActionFactory::Observable;

use strict;
use warnings;

use base 'Tu::ActionFactory';

use Tu::Factory::Observable;

sub new {
    shift->SUPER::new(factory => Tu::Factory::Observable->new(try => 1, @_));
}

sub build {
    my $self = shift;
    my ($action, %args) = @_;

    my $env                = $args{env};
    my $dispatched_request = $env->{'tu.dispatched_request'};
    my $params             = $dispatched_request->params;

    if (my $observers = $params->{observers}) {
        $args{observers} = $observers;
    }

    return $self->{factory}->build($action, %args);
}

1;
