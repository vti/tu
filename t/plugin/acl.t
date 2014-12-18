use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::Builder;
use Tu::ServiceContainer;
use Tu::Plugin::ACL;

subtest 'adds middleware in correct order' => sub {
    my $builder = _build_builder();
    my $plugin = _build_plugin(builder => $builder);

    $builder->add_middleware('RequestDispatcher');
    $builder->add_middleware('ActionDispatcher');

    $plugin->startup;

    is_deeply $builder->list_middleware, [
        qw/
          Session::Cookie
          User
          RequestDispatcher
          ACL
          ActionDispatcher
          /
    ];
};

done_testing;

sub _build_builder  { Tu::Builder->new }
sub _build_services { Tu::ServiceContainer->new }

sub _mock_acl {
    my (%params) = @_;

    Test::MonkeyMock->new;
}

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _build_services();
    $params{builder}  ||= _build_builder();

    Tu::Plugin::ACL->new(user_loader => sub { }, acl => _mock_acl(), %params);
}
