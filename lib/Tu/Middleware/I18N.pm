package Tu::Middleware::I18N;

use strict;
use warnings;

use base 'Tu::Middleware::LanguageDetection';

use Carp qw(croak);
use Tu::Scope;

sub new {
    my $class = shift;
    my (%params) = @_;

    croak 'i18n is required' unless my $i18n = delete $params{i18n};

    $params{default_language} = $i18n->default_language;
    $params{languages}        = [$i18n->languages];

    my $self = $class->SUPER::new(%params);

    $self->{i18n} = $i18n;

    return $self;
}

sub _detect_language {
    my $self = shift;
    my ($env) = @_;

    $self->SUPER::_detect_language($env);

    my $scope = Tu::Scope->new($env);

    my $language = $scope->i18n->language;

    my $maketext_cb = $self->{i18n}->handle($language);
    $scope->register('i18n.maketext' => $maketext_cb);

    $scope->displayer->vars->{loc} =
      sub { $env->{'tu.i18n.maketext'}->loc(@_) };

    $scope->displayer->vars->{lang} = $language;
}

1;
