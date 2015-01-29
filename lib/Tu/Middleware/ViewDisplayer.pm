package Tu::Middleware::ViewDisplayer;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Encode            ();
use String::CamelCase ();
use Tu::Scope;

use Plack::Util::Accessor qw(encoding displayer);

sub prepare_app {
    my $self = shift;

    $self->{encoding} ||= 'UTF-8';

    $self->{displayer} ||= $self->service('displayer');

    croak 'displayer required' unless $self->{displayer};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_display($env);
    return $res if $res;

    return $self->app->($env);
}

sub _display {
    my $self = shift;
    my ($env) = @_;

    my $template = $self->_find_template($env);
    return unless defined $template;

    my $displayer_scope = Tu::Scope->new($env)->displayer;

    my %args;
    $args{vars}   = $displayer_scope->vars;
    $args{layout} = $displayer_scope->layout
      if $displayer_scope->exists('layout');

    my $body = $self->{displayer}->render($template, %args);

    my $content_type = 'text/html';

    my $encoding = $self->encoding;
    if ($encoding && $encoding ne 'raw') {
        $body = Encode::encode($encoding, $body);
        $content_type .= '; charset=' . lc($encoding);
    }

    return [
        200,
        [
            'Content-Length' => length($body),
            'Content-Type'   => $content_type
        ],
        [$body]
    ];
}

sub _find_template {
    my $self = shift;
    my ($env) = @_;

    my $scope = Tu::Scope->new($env);

    my $template =
      $scope->displayer->exists('template') ? $scope->displayer->template : '';
    return $template if $template;

    my $dispatched_request = $scope->dispatched_request;

    if (my $action = $dispatched_request->action) {
        my $template_from_action = String::CamelCase::decamelize($action);
        $template_from_action =~ s{::}{_}g;
        return $template_from_action;
    }

    return;
}

1;
