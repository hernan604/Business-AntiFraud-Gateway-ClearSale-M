package Business::AntiFraud::Item::ClearSale::M;
use Moo;

extends qw/Business::AntiFraud::Item/;
has name => (
    is => 'rw',
    coerce => sub { '' . $_[0] },
);

has category => (
    is => 'rw',
    coerce => sub { '' . $_[0] },
);

1;
