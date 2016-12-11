use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Middleware::User;

subtest 'sets anonymous role when no user' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {}};

    my $res = $mw->call($env);

    is $env->{'tu.user_role'}, 'anonymous';
};

subtest 'sets anonymous role when session but no user' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {foo => 'bar'}};

    my $res = $mw->call($env);

    is $env->{'tu.user_role'}, 'anonymous';
};

subtest 'set anonymous when user not found' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 5}};

    my $res = $mw->call($env);

    is $env->{'tu.user_role'}, 'anonymous';
};

subtest 'sets user and role' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 1}, 'tu.displayer.vars' => {}};

    my $res = $mw->call($env);

    is $env->{'tu.user_role'}, 'user';
    is $env->{'tu.user'}->role, 'user';
};

subtest 'finalizes session' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 1}, 'tu.displayer.vars' => {}};

    my $res = $mw->call($env);

    is_deeply $env->{'psgix.session'}, {id => 1, foo => 'bar'};
};

subtest 'not registers displayer var when user not found' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {}};

    my $res = $mw->call($env);

    ok !$env->{'tu.displayer.vars'}->{user};
};

sub _build_middleware {
    return Tu::Middleware::User->new(
        app => sub { [200, [], ['OK']] },
        user_session_class => 'TestUserLoader'
    );
}

done_testing;

package TestUserLoader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env} = $params{env};

    return $self;
}

sub env { shift->{env} }

sub scope {
    my $self = shift;

    return Tu::Scope->new($self->env);
}

sub role { 'user' }

sub load {
    my $self = shift;

    my $env = $self->env;
    my $options = $env->{'psgix.session'};

    return $self if $options->{id} && $options->{id} == 1;
    return;
}

sub finalize {
    my $self = shift;

    my $env = $self->env;
    $env->{'psgix.session'}->{foo} = 'bar';
}

sub to_hash { {} }
