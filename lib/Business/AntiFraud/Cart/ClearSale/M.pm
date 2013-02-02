package Business::AntiFraud::Cart::ClearSale::M;
use Business::AntiFraud::Item::ClearSale::M;
use Moo;
use Business::AntiFraud::Types qw/stringified_money/;

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
    required => 1,
);

=head2 formas_pagamento
Numerico Obrigatório
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
    required => 1,
);

has pedido_id => (
    is => 'rw',
    required => 1,
);

=head2 tipo_cartao
Numerico Opcional
Aqui vc precisa passar o código respectivo ao cartão
1 Diners
2 MasterCard
3 Visa
4 Outros
5 American Express
6 HiperCard
7 Aura
=cut

has tipo_cartao => (
    is => 'rw',
    coerce => sub { 0 + $_[0] },
);

has total => (
    is => 'rw',
    required => 1,
    coerce => \&stringified_money,
);

has data => (
    is => 'rw',
    required => 1,
    coerce => sub {
        my $data = $_[0];
        if ( ref $data && ref $data eq 'DateTime' ) {
            return $data->dmy('-').' '.$data->hms(':');
        }
        return $data;
    },
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
