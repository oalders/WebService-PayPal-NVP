package WebService::PayPal::NVP::Response;

use Moo;
has 'success' => ( is => 'rw', default => sub { 0 } );
has 'errors'  => ( is => 'rw', default => sub { [] } );
has 'branch'  => ( is => 'rw', isa => sub {
    die "Response branch expects 'live' or 'sandbox' only\n"
        if $_[0] ne 'live' and $_[0] ne 'sandbox';
} );

sub express_checkout_uri {
    my ($self) = @_;
    if ($self->can('token')) {
        my $www = $self->branch eq 'live' ?
            'www' : 'www.sandbox';
        return "https://${www}.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=" .
            $self->token . "&useraction=commit";
    }

    return;
}

sub has_arg {
    my ($self, $arg) = @_;
    return $self->can($arg);
}

sub has_errors {
    my $self = shift;
    return scalar @{$self->errors} > 0;
}

sub args {
    my ($self) = @_;
    my @moothods = qw/
        around before can after
        import with new has
        options errors extends
    /;
    my @options;
    listmethods: {
        no strict 'refs';
        foreach my $key (keys %{"WebService::PayPal::NVP::Response::"}) {
            if ($key =~ /^[a-z]/ and not grep { $_ eq $key } @moothods) {
                push @options, $key;
            }
        }
    }

    return wantarray ? @options : \@options;
}

1;
__END__

=head1 NAME

WebService::PayPal::NVP::Response - PayPal NVP API response object

=pod

=head2 success

Returns true on success, false on failure.

=head2 branch

Returns either 'live' or 'sandbox'.

=head2 errors

Returns an C<ArrayRef> of errors.  The ArrayRef is empty when there are no
errors.

=head2 has_errors

Returns true if C<errors()> is non-empty.

=cut
