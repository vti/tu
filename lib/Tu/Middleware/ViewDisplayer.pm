package Tu::Middleware::ViewDisplayer;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Encode ();
use Plack::MIME;
use String::CamelCase ();
use Tu::Scope;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{encoding} = $params{encoding};
    $self->{encoding} = 'UTF-8' unless exists $params{encoding};

    $self->{displayer} =
         $params{displayer}
      || $self->{services}->service('displayer')
      || croak 'displayer required';

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

    my $content_type = Plack::MIME->mime_type('.html');

    if (my $encoding = $self->{encoding}) {
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
