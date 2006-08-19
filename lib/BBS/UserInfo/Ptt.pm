package BBS::UserInfo::Ptt;

use warnings;
use strict;

use Expect;

=head1 NAME

BBS::UserInfo::Ptt - Get user information of PTT-style BBS

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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
    my $self = shift();

    my %this = {
	'password' => '',	# incomplete function
	'port' => 23,
	'server' => undef,
	'telnet' => 'telnet',
	'timeout' => 10,
	'username' => 'guest'	# incomplete function
    };

    my %params = @_;
    while (my ($k, $v) = each(%params)) {
	$this{$k} = $v if (exists $this{$k});
    }

    return bless($self, \%this);
}

=head2 connect()

Connect to the BBS server.

=cut

sub connect {
    my ($self, $this) = @_;

    $this->{'expect'} = Expect->spawn($this->{'telnet'},
	    quotemeta($this->{'server'}), $this->{'port'});

    $self->login($self, $this);

    return $this->{'expect'};
}

sub login {
    my ($self, $this) = @_;

    my $bot = $this->{'expect'};

    $bot->expect($this->{'timeout'}, '½Ð¿é¤J¥N¸¹');
    $bot->send($this->{'username'}, "\r\n[D[D");
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
    my ($self, $this, $user) = @_;

    my $bot = $this->{'expect'};
    my $timeout = $this->{'timeout'};
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
