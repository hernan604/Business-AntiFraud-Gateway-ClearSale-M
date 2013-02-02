package Business::AntiFraud::Buyer::ClearSale::M;
use Moo;

extends qw/Business::AntiFraud::Buyer/;

=head1 NAME

Business::AntiFraud::Buyer::ClearSale::M

=head1 DESCRIPTION

extends Business::AntiFraud::Buyer
and adds some extra attributes specific to moip

=head1 ATTRIBUTES

=head2 ip
holds the buyers IP
=cut

has ip => (
    is => 'rw',
);


1;
