use strict;
use warnings;

use Test::More;

subtest 'notifies observers' => sub {
    my $observable = TestObservableMixin::Foo->new;

    my $observer = TestObservableMixin::Observer->new;
    $observable->observe($observer);

    my $bar = {};
    $observable->foo($bar);

    is_deeply $bar, {bar => 2};
};

done_testing;

package TestObservableMixin::Foo;
use Tu::ObservableMixin qw(observe notify);

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub foo {
    my $self = shift;
    my ($foo) = @_;

    $foo->{bar}++;

    $self->notify('AFTER:foo', $foo);
}

package TestObservableMixin::Observer;
use parent 'Tu::Observer::Base';

sub _init {
    my $self = shift;

    $self->_register(
        'AFTER:foo' => sub {
            my $self = shift;
            my ($foo) = @_;

            $foo->{bar}++;
        }
    );
}
