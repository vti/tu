use strict;
use warnings;

use Test::More;

use Tu::Observer::Base;

subtest 'registers events' => sub {
    my $observer = _build_observer();

    my $cb = $observer->events->{foo};

    is $cb->(), 'foo';
};

sub _build_observer {
    return TestObserverBase::Foo->new(@_);
}

done_testing;

package TestObserverBase::Foo;
use base 'Tu::Observer::Base';

sub _init {
    my $self = shift;

    $self->_register(foo => sub { 'foo' });
}
