use strict;
use warnings;

use Test::More;

use Tu::Factory::Observable;

subtest 'builds an observable object' => sub {
    my $factory = _build_factory();

    my $foo = $factory->build('+TestFactoryObservable::Foo',
        observers => ['+TestFactoryObservable::Foo::Observer']);

    my $var = {hi => ''};
    $foo->hi($var);

    is $var->{hi}, 'before hi after';
};

sub _build_factory {
    return Tu::Factory::Observable->new(@_);
}

done_testing;

package TestFactoryObservable::Foo;
use Tu::ObservableMixin qw(observe notify);

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub hi {
    my $self = shift;
    my ($foo) = @_;

    $self->notify('BEFORE:hi', $foo);

    $foo->{hi} .= 'hi';

    $self->notify('AFTER:hi', $foo);

    return $foo;
}

package TestFactoryObservable::Foo::Observer;
use parent 'Tu::Observer::Base';

sub _init {
    my $self = shift;

    $self->_register('BEFORE:hi' => sub { $_[1]->{hi} = 'before ' });
    $self->_register('AFTER:hi' => sub { $_[1]->{hi} .= ' after' });
}
