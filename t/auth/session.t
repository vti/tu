use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Auth::Session;

subtest 'loads undef when no session' => sub {
    my $auth = _build_auth();

    ok !$auth->load({'psgix.session' => {}});
};

subtest 'loads undef when no user' => sub {
    my $auth = _build_auth();

    ok !$auth->load({'psgix.session' => {id => 5}});
};

subtest 'loads when user found' => sub {
    my $auth = _build_auth();

    ok $auth->load({'psgix.session' => {id => 1}});
};

subtest 'loads with additional options' => sub {
    my $auth = _build_auth();

    ok !$auth->load({'psgix.session' => {id => 1, fake => 1}});
};

subtest 'creates session on login' => sub {
    my $auth = _build_auth();

    my $user = TestUserLoader->new;

    my $env = {'psgix.session' => {}, 'psgix.session.options' => {}};
    $auth->login($env, {id => $user->id});

    is $env->{'psgix.session'}->{id}, 1;
};

subtest 'saves additional options' => sub {
    my $auth = _build_auth();

    my $user = TestUserLoader->new;

    my $env = {'psgix.session' => {}, 'psgix.session.options' => {}};
    $auth->login($env, {id => $user->id, foo => 'bar'});

    is $env->{'psgix.session'}->{foo}, 'bar';
};

subtest 'expires session on logout' => sub {
    my $auth = _build_auth();

    my $env =
      {'psgix.session' => {id => 1}, 'psgix.session.options' => {}};
    $auth->logout($env);

    is_deeply $env,
      {'psgix.session' => {}, 'psgix.session.options' => {expire => 1}};
};

subtest 'calls finalize' => sub {
    my $auth = _build_auth();

    my $env =
      {'psgix.session' => {id => 1}, 'psgix.session.options' => {}};
    $auth->finalize($env);

    is_deeply $env,
      {
        'psgix.session'         => {id => 1, new => 'options'},
        'psgix.session.options' => {}
      };
};

sub _build_auth {
    return Tu::Auth::Session->new(user_loader => TestUserLoader->new, @_);
}

done_testing;

package TestUserLoader;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub id { 1 }

sub load {
    my $self = shift;
    my ($options) = @_;

    return if $options->{fake};
    return $self if $options->{id} && $options->{id} == $self->id;
    return;
}

sub finalize {
    my $self = shift;
    my ($options) = @_;

    $options->{new} = 'options';
}

1;
