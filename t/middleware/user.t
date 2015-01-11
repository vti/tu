use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Middleware::User;

subtest 'sets anonymous role when no user' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {}};

    my $res = $mw->call($env);

    is $env->{'tu.auth_role'}, 'anonymous';
};

subtest 'sets anonymous role when session but no user' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {foo => 'bar'}};

    my $res = $mw->call($env);

    is $env->{'tu.auth_role'}, 'anonymous';
};

subtest 'set anonymous when user not found' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 5}};

    my $res = $mw->call($env);

    is $env->{'tu.auth_role'}, 'anonymous';
};

subtest 'sets user and role' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 1}, 'tu.displayer.vars' => {}};

    my $res = $mw->call($env);

    is $env->{'tu.auth_role'}, 'user';
    is $env->{'tu.user'}->role, 'user';
};

subtest 'finalizes session' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 1}, 'tu.displayer.vars' => {}};

    my $res = $mw->call($env);

    is_deeply $env->{'psgix.session'}, {foo => 'bar'};
};

subtest 'registers displayer var when user found' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {id => 1}, 'tu.displayer.vars' => {}};

    my $res = $mw->call($env);

    is_deeply $env->{'tu.displayer.vars'}->{user}, {};
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
        user_loader => TestUser->new
    );
}

done_testing;

package TestUser;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub role { 'user' }

sub id { 1 }

sub load_auth {
    my $self = shift;
    my ($options) = @_;

    return $self if $options->{id} && $options->{id} == 1;
    return;
}

sub finalize_auth {
    my $self = shift;
    my ($options) = @_;

    return {foo => 'bar'};
}

sub to_hash { {} }
