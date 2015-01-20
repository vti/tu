package Tu::ObservableMixin;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT_OK = qw(observe notify);

my $KEY = '__observable_mixin__';

sub observe {
    my $self = shift;
    my ($observer) = @_;

    $self->{$KEY} ||= {};

    my $events = $observer->events;

    foreach my $event (keys %$events) {
        push @{$self->{$KEY}->{$event}}, $events->{$event};
    }
}

sub notify {
    my $self = shift;
    my ($event, @args) = @_;

    my $observers = $self->{$KEY}->{$event};
    return unless $observers;

    foreach my $observer (@$observers) {
        $observer->($self, @args);
    }
}

1;
