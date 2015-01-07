use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;
use Test::Requires {
    'Locale::Maketext::Lexicon' => '0',
    'I18N::AcceptLanguage'      => '0'
};

use lib 't/plugin/i18n_t/perl/lib';

use Tu::Builder;
use Tu::ServiceContainer;
use Tu::Home;
use Tu::Plugin::I18N;

use TestAppI18N;

subtest 'throws when cannot detect locale_dir' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();
    $services->register(app_class => 'unknown');
    $services->register(home => Tu::Home->new(path => 't/plugin/i18n_t'));

    my $plugin = _build_plugin(builder => $builder, services => $services);

    like exception { $plugin->startup }, qr/Cannot detect locale_dir/;
};

subtest 'detects perl lexicon' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();
    $services->register(app_class => 'TestAppI18N');
    $services->register(home => Tu::Home->new(path => 't/plugin/i18n_t/perl'));

    my $plugin = _build_plugin(builder => $builder, services => $services);

    $builder->add_middleware('RequestDispatcher');

    $plugin->startup;

    ok $services->service('i18n');
};

subtest 'detects gettext lexicon' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();
    $services->register(app_class => 'TestApp');
    $services->register(
        home => Tu::Home->new(path => 't/plugin/i18n_t/gettext'));

    my $plugin = _build_plugin(builder => $builder, services => $services);

    $builder->add_middleware('RequestDispatcher');

    $plugin->startup;

    ok $services->service('i18n');
};

subtest 'adds middleware in correct order' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();
    $services->register(app_class => 'TestAppI18N');
    $services->register(home => Tu::Home->new(path => 't/plugin/i18n_t/perl'));

    my $plugin = _build_plugin(builder => $builder, services => $services);

    $builder->add_middleware('RequestDispatcher');

    $plugin->startup;

    is_deeply $builder->list_middleware, [
        qw/
          I18N
          RequestDispatcher
          /
    ];
};

subtest 'builds i18n perl lexicon with correct args' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();
    $services->register(app_class => 'TestAppI18N');
    $services->register(home => Tu::Home->new(path => 't/plugin/i18n_t/perl'));

    my $plugin = _build_plugin(builder => $builder, services => $services);
    $plugin = Test::MonkeyMock->new($plugin);
    $plugin->mock(_build_i18n => sub { });

    $builder->add_middleware('RequestDispatcher');

    $plugin->startup;

    is_deeply {
        locale_dir => 't/plugin/i18n_t/perl/lib/TestAppI18N/I18N',
        app_class  => 'TestAppI18N',
        lexicon    => 'perl'
      },
      {$plugin->mocked_call_args('_build_i18n')};
};

subtest 'builds i18n gettext lexicon with correct args' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();
    $services->register(app_class => 'TestApp');
    $services->register(
        home => Tu::Home->new(path => 't/plugin/i18n_t/gettext'));

    my $plugin = _build_plugin(builder => $builder, services => $services);
    $plugin = Test::MonkeyMock->new($plugin);
    $plugin->mock(_build_i18n => sub { });

    $builder->add_middleware('RequestDispatcher');

    $plugin->startup;

    is_deeply {
        locale_dir => 't/plugin/i18n_t/gettext/locale',
        app_class  => 'TestApp',
        lexicon    => 'gettext'
      },
      {$plugin->mocked_call_args('_build_i18n')};
};

done_testing;

sub _build_builder  { Tu::Builder->new }
sub _build_services { Tu::ServiceContainer->new }

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _build_services();
    $params{builder}  ||= _build_builder();

    $params{services}->register(config => $params{config} || {});

    Tu::Plugin::I18N->new(%params);
}
