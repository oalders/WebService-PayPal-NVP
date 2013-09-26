package WebService::PayPal::NVP;

use Moo;
use DateTime;
use LWP::UserAgent ();
use URI::Escape qw/uri_escape uri_unescape/;
use WebService::PayPal::NVP::Response;

our $VERSION = '0.001';

has 'errors' => (
    is => 'rw',
    isa => sub {
        die "errors expects an array reference!\n"
            unless ref $_[0] eq 'ARRAY';
    },
    default => sub { [] },
);

has 'user' => ( is => 'rw', required => 1 );
has 'pwd'  => ( is => 'rw', required => 1 );
has 'sig'  => ( is => 'rw', required => 1 );
has 'url'  => ( is => 'rw' );
has 'branch' => ( is => 'rw', default => sub { 'sandbox' } );
has 'api_ver' => ( is => 'rw', default => sub { 51.0 } );

sub BUILDARGS {
    my ($class, %args) = @_;
    # detect URL if it's missing
    if (not $args{url}) {
        $args{url} = "https://api-3t.sandbox.paypal.com/nvp"
            if $args{branch} eq 'sandbox';

        $args{url} = "https://api-3t.paypal.com/nvp"
            if $args{branch} eq 'live';
    }

    return \%args;
}

sub _do_request {
    my ($self, $args) = @_;
    my $lwp = LWP::UserAgent->new;
    $lwp->agent("p-Webservice-PayPal-NVP/${VERSION}");
    
    my $req = HTTP::Request->new(POST => $self->url);
    $req->content_type('application/x-www-form-urlencoded');

    my $authargs = {
        user      => $self->user,
        pwd       => $self->pwd,
        signature => $self->sig,
        version   => $args->{version}||$self->api_ver,
        subject   => $args->{subject}||'',
    };

    my $allargs = { %$authargs, %$args };
    my $content = $self->_build_content( $allargs );
    $req->content($content);
    my $res = $lwp->request($req);

    unless ($res->code == 200) {
        $self->errors(["Failure: " . $res->code . ": " . $res->message]);
        return;
    }

    my $resp = { map { uri_unescape($_) }
        map { split '=', $_, 2 }
            split '&', $res->content };

    my $res_object = WebService::PayPal::NVP::Response->new(
        branch => $self->branch
    );
;
    if ($resp->{ACK} ne 'Success') {
        $res_object->errors([]);
        my $i = 0;
        while(my $err = $resp->{"L_LONGMESSAGE${i}"}) {
            push @{$res_object->errors},
                $resp->{"L_LONGMESSAGE${i}"};
            $i += 1;
        }

        $res_object->success(0);
    }
    else {
        $res_object->success(1);
    }

    {
        no strict 'refs';
        no warnings 'redefine';
        foreach my $key (keys %$resp) {
            my $val    = $resp->{$key};
            my $lc_key = lc $key;
            if ($lc_key eq 'timestamp') {
                if ($val =~ /(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z/) {
                    my ($day, $month, $year, $hour, $min, $sec)
                     = ($3, $2, $1, $4, $5, $6);
                    
                    $val = DateTime->new(
                        year    => $year,
                        month   => $month,
                        day     => $day,
                        hour    => $hour,
                        minute  => $min,
                        second  => $sec,
                    );
                }
            }
            *{"WebService::PayPal::NVP::Response::$lc_key"} = sub {
                return $val;
            };
        }
    }
    return $res_object; 
}

sub _build_content {
    my ($self, $args) = @_;
    my @args;
    for my $key (keys %$args) {
        $args->{$key} = defined $args->{$key} ? $args->{$key} : '';
        push @args,
            uc(uri_escape($key)) . '=' . uri_escape($args->{$key});
    }

    return (join '&', @args) || '';
}

sub set_express_checkout {
    my ($self, $args) = @_;
    $args->{method} = 'SetExpressCheckout';
    $self->_do_request($args);
}

sub do_express_checkout_payment {
    my ($self, $args) = @_;
    $args->{method} = 'DoExpressCheckoutPayment';
    $self->_do_request($args);
}

sub get_express_checkout_details {
    my ($self, $args) = @_;
    $args->{method} = 'GetExpressCheckoutDetails';
    $self->_do_request($args);
}

sub do_direct_payment {
    my ($self, $args) = @_;
    $args->{method} = 'DoDirectPayment';
    $self->_do_request($args);
}

1;
__END__

=head1 NAME

WebService::PayPal::NVP - PayPal NVP API

=head1 DESCRIPTION

A pure object oriented interface to PayPal's NVP API (Name-Value Pair). A lot of the logic in this module was taken from L<Business::PayPal::NVP>. I re-wrote it because it wasn't working with Catalyst adaptors and I couldn't save instances of it in Moose-type accessors. Otherwise it worked fine. So if you don't need that kind of support you should visit L<Business::PayPal::NVP>!.
Currently supports C<do_direct_payment>, C<do_express_checkout_payment>, C<get_express_checkout_details> and C<set_express_checkout>. Another difference with this module compared to L<Business::PayPal::NVP> is that the keys may be passed as lowercase. Also, a response will return a WebService::PayPal::NVP::Response object where the response values are methods. Timestamps will automatically be converted to DateTime objects for your convenience.


=head1 SYNTAX

    my $nvp = WebService::PayPal::NVP->new(
        user   => 'user.tld'
        pwd    => 'xxx',
        sig    => 'xxxxxxx',
        branch => 'sandbox',
    );
    
    my $res = $nvp->set_express_checkout({
        DESC              => 'Payment for something cool',
        AMT               => 25.00,
        CURRENCYCODE      => 'GBP',
        PAYMENTACTION     => 'Sale',
        RETURNURL         => "http://returnurl.tld",
        CANCELURL         => 'http//cancelurl.tld",
        LANDINGPAGE       => 'Login',
        ADDOVERRIDE       => 1,
        SHIPTONAME        => "Customer Name",
        SHIPTOSTREET      => "7 Customer Street", 
        SHIPTOSTREET2     => "", 
        SHIPTOCITY        => "Town", 
        SHIPTOZIP         => "Postcode", 
        SHIPTOEMAIL       => "customer\@example.com", 
        SHIPTOCOUNTRYCODE => 'GB',
    });
    
    if ($res->success) {
        # timestamps turned into DateTime objects
        say "Response received at "
            . $res->timestamp->dmy . " "
            . $res->timestamp->hms(':');

        say $res->token;

        for my $arg ($res->args) {
            if ($res->has_arg($arg)) {
                say "$arg => " . $res->$arg;
            }
        }

        # get a redirect uri to paypal express checkout
        # the Response object will automatically detect if you have 
        # live or sandbox and return the appropriate url for you
        if (my $redirect_user_to = $res->express_checkout_uri) {
            $web_framework->redirect( $redirect_user_to );
        }
    }
    else {
        say $_
          for @{$res->errors};
    }

=head1 AUTHOR

Brad Haywood <brad@geeksware.com>

=head1 CREDITS

A lot of this module was taken from L<Business::PayPal::NVP> by Scott Wiersdorf. 
It was only rewritten in order to work properly in L<Catalyst::Model::Adaptor>.

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
