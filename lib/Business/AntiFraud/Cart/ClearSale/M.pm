package Business::AntiFraud::Cart::ClearSale::M;
use Business::AntiFraud::Item::ClearSale::M;
use Moo;

extends qw/Business::AntiFraud::Cart/;

=head1 NAME

Business::AntiFraud::Cart::ClearSale::M

=head1 DESCRIPTION

extends Business::AntiFraud::Cart
and adds some extra attributes specific to clearsale

=head2 parcelas

Inteiro, inidica quantas vezes o produto foi parcelado

=cut

has parcelas => (
    is => 'rw',
);

=head2 formas_pagamento
Aqui vc precisa passar o código respectivo ao meio de pagamento.
A seguir a lista de código e meios de pagamento:

1  Cartão de Crédito
2  Boleto Bancário
3  Débito Bancário
4  Débito Bancário - Dinheiro
5  Débito Bancário - Cheque
6  Transferência Bancária
7  Sedex a cobrar
8  Cheque
9  Dinheiro
10 Financiamento
11 Fatura
12 Cupom
13 Multicheque
14 Outros

=cut

has tipo_de_pagamento => (
    is => 'rw',
);

sub add_item {
    my ($self, $info) = @_;
    my $item = ref $info && ref $info eq 'Business::AntiFraud::Item::ClearSale::M' ?
        $info
        :
        Business::AntiFraud::Item::ClearSale::M->new($info);

    push @{ $self->_items }, $item;

    return $item;
}

1;
