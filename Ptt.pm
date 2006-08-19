package BBS::UserInfo::Ptt;

use warnings;
use strict;

use Carp;
use Expect;

=head1 NAME

BBS::UserInfo::Ptt - Get user information of PTT-style BBS

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

    use BBS::UserInfo::Ptt;

    # create object
    my $bot = BBS::UserInfo::Ptt->new(
	    'port' => 23,
	    'server' => 'ptt.cc',
	    'telnet' => '/usr/bin/telnet'
	    );

    # connect to the server
    $bot->connect() or die('Unable to connect BBS');

    my $userdata = $bot->query('username');

    # available: nickname, logintimes, posttimes, lastlogintime, lastloginip
    print($userdata->{'logintimes'});

=head1 FUNCTIONS

=head2 new()

Create a BBS::UserInfo::Ptt object, there are some parameters that you
can define:

    server => 'ptt.cc'	# Necessary, server name
    port => 23		# Optional, server port
    telnet => 'telnet'	# Optional, telnet program

=cut

sub new {
    my ($class, %params) = @_;

    my %self = (
	'password' => '',	# incomplete function
	'port' => 23,
	'server' => undef,
	'telnet' => 'telnet',
	'timeout' => 10,
	'username' => 'guest'	# incomplete function
    );

    while (my ($k, $v) = each(%params)) {
	$self{$k} = $v if (exists $self{$k});
    }

    return bless(\%self, $class);
}

=head2 connect()

Connect to the BBS server.

=cut

sub connect {
    my $self = shift();

    $self->{'expect'} = Expect->spawn($self->{'telnet'}, $self->{'server'},
	$self->{'port'});
    $self->{'expect'}->log_stdout(0);

    $self->_login($self);

    return $self->{'expect'};
}

sub _login {
    my $self = shift();

    my $bot = $self->{'expect'};

    $bot->expect($self->{'timeout'}, '½Ð¿é¤J¥N¸¹');
    $bot->send($self->{'username'}, "\r\n[D[D");
}

=head2 query()

Query user information and return a hash reference with:

=over 4

=item * nickname

=item * logintimes

=item * posttimes

=item * lastlogintime

=item * lastloginip

=back

=cut

sub query {
    my ($self, $user) = @_;

    my $bot = $self->{'expect'};
    my $timeout = $self->{'timeout'};
    $bot->send("[D[Dt\r\nq\r\n", $user, "\r\n");

    my %h;
    $bot->expect($timeout, /¡m¢×¢Ò¼ÊºÙ¡n\w+\(.+\)\s+¡m\s/);
    $h{'nickname'} = $bot->match();

    $bot->expect($timeout, /¡m¤W¯¸¦¸¼Æ¡n(\d+)¦¸/);
    $h{'logintimes'} = $bot->match();

    $bot->expect($timeout, /¡m¤å³¹½g¼Æ¡n(\d+)½g/);
    $h{'posttimes'} = $bot->match();

    $bot->expect($timeout, /¡m¤W¦¸¤W¯¸¡n(\w+\s\w+\s\w+)\s/);
    $h{'lastlogintime'} = $bot->match();

    $bot->expect($timeout, /¡m¤W¦¸¬G¶m¡n(\w+)/);
    $h{'lastloginip'} = $bot->match();

    return \%h;
}

=head1 AUTHOR

Gea-Suan Lin, C<< <gslin at gslin.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2006 Gea-Suan Lin, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of BBS::UserInfo::Ptt
