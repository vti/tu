package Tu::Middleware::I18N;

use strict;
use warnings;

use parent 'Tu::Middleware::LanguageDetection';

use Carp qw(croak);
use Tu::Scope;

use Plack::Util::Accessor qw(i18n);

sub prepare_app {
    my $self = shift;

    $self->{i18n} ||= $self->service('i18n');

    croak 'i18n is required' unless my $i18n = $self->{i18n};

    $self->{default_language} ||= $i18n->default_language;
    $self->{languages} ||= [$i18n->languages];

    return $self->SUPER::prepare_app;
}

sub _detect_language {
    my $self = shift;
    my ($env) = @_;

    $self->SUPER::_detect_language($env);

    my $scope = Tu::Scope->new($env);

    my $language = $scope->i18n->language;

    my $maketext_cb = $self->{i18n}->handle($language);
    $scope->set('i18n.maketext' => $maketext_cb);

    $scope->displayer->vars->{loc} =
      sub { $env->{'tu.i18n.maketext'}->loc(@_) };

    $scope->displayer->vars->{lang} = $language;
}

1;
