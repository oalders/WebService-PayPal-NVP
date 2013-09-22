package WebService::PayPal::NVP::Response;

use Moo;
has 'success' => ( is => 'rw', default => sub { 0 } );
has 'errors'  => ( is => 'rw', default => sub { [] } );

sub options {
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
