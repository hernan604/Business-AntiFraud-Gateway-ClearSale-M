package Business::AntiFraud::Buyer::ClearSale::M;
use Moo;

extends qw/Business::AntiFraud::Buyer/;

=head1 NAME

Business::AntiFraud::Buyer::ClearSale::M

=head1 DESCRIPTION

extends Business::AntiFraud::Buyer
and adds some extra attributes specific to moip

=head1 ATTRIBUTES

=head2 phone
buyer phone number
=cut

has phone => (
    is => 'rw',
);

=head2 id_pagador
de acordo com os docs: http://labs.moip.com.br/referencia/integracao_xml_identificacao/
id_pagador is the user_id on moip??
TODO: verificar..
=cut

has id_pagador => (
    is => 'rw',
);



1;
