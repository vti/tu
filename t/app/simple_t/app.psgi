#!/usr/bin/env perl

use strict;
use warnings;

use Plack::Builder;
use TestAppSimple;

my $app = TestAppSimple->new;

builder {
    enable
      'ErrorDocument',
      403        => '/forbidden',
      404        => '/not_found',
      subrequest => 1;

    enable 'HTTPExceptions';

    enable '+Tu::Middleware::Defaults',          services => $app->services;
    enable '+Tu::Middleware::RequestDispatcher', services => $app->services;
    enable '+Tu::Middleware::ActionDispatcher',  services => $app->services;
    enable '+Tu::Middleware::ViewDisplayer',     services => $app->services;

    $app->to_app;
}
