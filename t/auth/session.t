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

    ok !$auth->load({'psgix.session' => {user_id => 5}});
};

subtest 'loads undef when user found' => sub {
    my $auth = _build_auth();

    ok $auth->load({'psgix.session' => {user_id => 1}});
};

subtest 'creates session on login' => sub {
    my $auth = _build_auth();

    my $user = TestUserLoader->new;

    my $env = {'psgix.session' => {}, 'psgix.session.options' => {}};
    $auth->login($env, $user->id);

    is $env->{'psgix.session'}->{user_id}, 1;
};

subtest 'expires session on logout' => sub {
    my $auth = _build_auth();

    my $env =
      {'psgix.session' => {user_id => 1}, 'psgix.session.options' => {}};
    $auth->logout($env);

    is_deeply $env,
      {'psgix.session' => {}, 'psgix.session.options' => {expire => 1}};
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

sub load_by_auth_id {
    my $self = shift;
    my ($id) = @_;

    return $self if $id == $self->id;
    return;
}

1;
