package WWW::FreshBooks::API;
use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.1');

use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw/svc_url auth_token method r_args ua xs/ );

use LWP::UserAgent;
use XML::Simple;

sub new {
	my $class = shift;
	my $args  = shift;

	$class = ref($class) || $class;
	my $self = bless {}, $class;

	if (! $self->init($args)) {
		undef $self;
		}

	return $self;
	}

sub init {
	my $self = shift;
	my $args = shift;

	my $flag = 0;
	foreach my $r('svc_url','auth_token') {
		if (! exists $args->{$r}) {
			warn "Required parameter " . $r . " is not set.";
			$flag = 1;
			}
		}

	return 0 if ($flag);

	$self->svc_url($args->{'svc_url'});
	$self->auth_token($args->{'auth_token'});
	$self->ua(LWP::UserAgent->new(agent => $self->_agent, timeout => 30));
	$self->xs(XML::Simple->new(NoAttr => 1,RootName => ''));

	return 1;
	}

sub call {
	my $self   = shift;
	my $method = shift;
	my $args   = shift;

	$self->r_args($args);
	$self->method($method);

	my $req = HTTP::Request->new(POST => $self->svc_url);
	$req->authorization_basic($self->auth_token, "X");
	$req->content($self->_rxml);

	my $resp = $self->ua->request($req);
	if ($resp->code != 200) {
		return(0,$resp);
		}

	my $ref = XMLin($resp->content);
	return ($ref,$resp);
	}


sub _rxml {
	my $self = shift;
	my $w = $self->_xwrap();
	my $x = $self->xs->XMLout($self->r_args);
	my $fnr = {
		'__M__' => $self->method,
		'__X__' => $x,
		};

	foreach my $f(keys %{$fnr}) {
		$w =~ s/$f/$fnr->{$f}/g;
		}
	print STDERR "XML: " . $w . "\n";
	return $w;
	}

sub _xwrap {
	return qq{<?xml version="1.0" encoding="UTF-8"?>
<request method="__M__">
__X__
</request>};
	}

sub _agent { __PACKAGE__ . "/" . $VERSION }


1; # End of WWW::FreshBooks::API


=head1 NAME

WWW::FreshBooks::API - Perl interface to the FreshBooks API v2.0

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

    use WWW::FreshBooks::API;

    my $fb = WWW::FreshBooks::API->new({
				svc_url => "https://sample.freshbooks.com/api/xml-in",
				auth_token => "somemd5hashedstringforyouraccount",
				});
    my ($ref,$resp) = $fb->call('client.list', {
				$arg1 => 'val1',
				$arg2 => 'val2',
				});

    # $ref is a hash reference created from the xml response.
    # $resp is an HTTP::Response object containg the response.

    # Verifies that the request was completed successfully.
    # Displays the client_id of the first client in the list.
    if ($ref) {
        $ref->{'client'}[0]->{'client_id'};
    }

    #Displays the response content as a string
    $resp->as_string;

=head1 METHODS/SUBROUTINES

=over 4

=item C<new($args)>

Constructs a new WWW::FreshBooks::API object storing you C<svc_url> and C<auth_token>.

=item C<call($method, $args)>

Calls the specified C<$method> passing through all C<$args> in XML format.  Formatting
for the request body is done with L<XML::Simple>.  A hash reference created from the
response xml and an L<HTTP::Response> object is returned.  If the request fails, the
hashref will return 0.

=back

=head1 DEPENDENCIES

L<Class::Accessor>
L<LWP::UserAgent>

=head1 AUTHOR

Anthony Decena, C<< <anthony at mindelusions.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Anthony Decena, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

