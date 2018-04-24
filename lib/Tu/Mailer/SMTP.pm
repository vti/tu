package Tu::Mailer::SMTP;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{ssl}      = $params{ssl};
    $self->{host}     = $params{host};
    $self->{port}     = $params{port};
    $self->{username} = $params{username};
    $self->{password} = $params{password};

    return $self;
}

sub send_message {
    my $self = shift;
    my ($message) = @_;

    require Email::Sender::Simple;
    require Email::Sender::Transport::SMTP;

    my $sender = Email::Sender::Transport::SMTP->new(
        host => $self->{host},
        port => $self->{port},
        $self->{ssl} ? (ssl => $self->{ssl}) : (),
        $self->{username} && $self->{password}
        ? (
            sasl_username => $self->{username},
            sasl_password => $self->{password}
          )
        : ()
    );

    Email::Sender::Simple->send($message, {transport => $sender});

    return $self;
}

1;
