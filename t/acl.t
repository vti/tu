use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::ACL;

subtest 'denied_by_default' => sub {
    my $acl = _build_acl();

    ok !$acl->is_allowed('admin', 'login');
};

subtest 'throw when allow unknown role' => sub {
    my $acl = _build_acl();

    like exception { $acl->allow('admin', 'foo') }, qr/Unknown role/;
};

subtest 'allow_allowed_action' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');

    ok $acl->is_allowed('admin', 'foo');
};

subtest 'throw when deny unknown role' => sub {
    my $acl = _build_acl();

    like exception { $acl->deny('admin', 'foo') }, qr/Unknown role/;
};

subtest 'deny_unknown_role' => sub {
    my $acl = _build_acl();

    ok !$acl->is_allowed('admin', 'foo');
};

subtest 'deny_unknown_action' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');

    ok !$acl->is_allowed('admin', 'bar');
};

subtest 'deny_denied_action' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');
    $acl->deny('admin', 'bar');

    ok !$acl->is_allowed('admin', 'bar');
};

subtest 'allow_everything_with_star' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', '*');

    ok $acl->is_allowed('admin', 'foo');
};

subtest 'deny_action_despite_of_star' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', '*');
    $acl->deny('admin', 'foo');

    ok !$acl->is_allowed('admin', 'foo');
};

subtest 'inherit_rules' => sub {
    my $acl = _build_acl();

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    $acl->add_role('admin', 'user');

    ok $acl->is_allowed('admin', 'foo');
};

subtest 'allow_everyone' => sub {
    my $acl = _build_acl();

    $acl->add_role('user1');
    $acl->add_role('user2');
    $acl->allow('*', 'foo');

    ok $acl->is_allowed('user1', 'foo');
    ok $acl->is_allowed('user2', 'foo');
};

subtest 'allow_everyone_everything' => sub {
    my $acl = _build_acl();

    $acl->add_role('user1');
    $acl->add_role('user2');
    $acl->allow('*', '*');

    ok $acl->is_allowed('user1', 'foo');
    ok $acl->is_allowed('user2', 'foo');
};

subtest 'deny_everyone' => sub {
    my $acl = _build_acl();

    $acl->add_role('user1');
    $acl->add_role('user2');
    $acl->allow('*', '*');

    $acl->deny('*', 'foo');

    ok !$acl->is_allowed('user1', 'foo');
    ok !$acl->is_allowed('user2', 'foo');
};

subtest 'denies by regex' => sub {
    my $acl = _build_acl();

    $acl->add_role('user');
    $acl->add_role('admin');
    $acl->allow('user',  '*');
    $acl->allow('admin', '*');

    $acl->deny('user', qr/^admin/);

    ok $acl->is_allowed('user',  'foo');
    ok $acl->is_allowed('admin', 'foo');
    ok !$acl->is_allowed('user', 'admin_foo');
    ok $acl->is_allowed('admin', 'admin_foo');
};

subtest 'allows by when' => sub {
    my $acl = _build_acl();

    $acl->add_role('user');
    $acl->allow('user', 'foo');
    $acl->deny('user', 'foo', when => sub { 0 });

    ok $acl->is_allowed('user', 'foo');
};

subtest 'denies by when' => sub {
    my $acl = _build_acl();

    $acl->add_role('user');
    $acl->allow('user', '*', when => sub { 0 });

    ok !$acl->is_allowed('user', 'foo');
};

sub _build_acl {
    return Tu::ACL->new(@_);
}

done_testing;
