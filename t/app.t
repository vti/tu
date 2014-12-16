use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu;

subtest 'returns coderef' => sub {
    my $app = TestApp->new;

    is ref $app->to_app, 'CODE';
};

subtest 'defaults to 404' => sub {
    my $app = Tu->new;

    like exception { $app->to_app->() }, qr/Not Found/;
};

subtest 'calls startup' => sub {
    my $app = TestAppWithStartup->new;

    is_deeply $app->to_app->(), [200, [], ['from startup']];
};

subtest 'adds middleware' => sub {
    my $app = TestApp->new;
    $app->add_middleware(
        sub {
            sub { [200, [], ['OK']] }
        }
    );

    is_deeply $app->to_app->(), [200, [], ['OK']];
};

subtest 'registers services' => sub {
    my $app = TestApp->new(home => '/foo/bar');

    my $home = $app->service('home');
    is $home, '/foo/bar';

    my $app_class = $app->service('app_class');
    is $app_class, 'TestApp';
};

subtest 'registers plugin' => sub {
    my $app = TestApp->new;
    $app->register_plugin('Nifty');

    is_deeply $app->to_app->(), [200, [], ['from plugin']];
};

done_testing;

package TestApp;
use parent 'Tu';

sub startup { }

package TestAppWithStartup;
use parent 'Tu';

sub startup {
    my $self = shift;

    $self->add_middleware(
        sub {
            sub { [200, [], ['from startup']] }
        }
    );
}

package TestApp::Plugin::Nifty;
use parent 'Tu::Plugin';

sub startup {
    my $self = shift;

    $self->builder->add_middleware(
        sub {
            sub { [200, [], ['from plugin']] }
        }
    );
}
