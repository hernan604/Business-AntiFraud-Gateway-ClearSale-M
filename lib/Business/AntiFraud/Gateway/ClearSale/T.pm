package Business::AntiFraud::Gateway::ClearSale::T;
use Moo;
use Carp 'croak';
use bareword::filehandles;
use indirect;
use multidimensional;
use HTTP::Tiny;
use Data::Dumper;
use HTTP::Request::Common;
extends qw/Business::AntiFraud::Gateway::Base/;

=head1 NAME

Business::AntiFraud::Gateway::ClearSale::T - Interface perl para T-ClearSale

=head1 SYNOPSIS

  use Business::AntiFraud::Gateway::ClearSale::T;

=head1 MÉTODOS DA API CLEARSALE-M E CLEARSALE-T

    SendOrders
    Metodos de retorno de status
    GetPackageStatus
    GetOrderStatus
    GetOrdersStatus
    GetAnalystComments

=head1 DESCRIPTION

=head1 TABELAS DE CÓDIGOS

=head2 Tipo de Telefone

    0 Não definido
    1 Residencial
    2 Comercial
    3 Recados
    4 Cobrança
    5 Temporário
    6 Celular

=head2 Tipo de Pessoa

    1 Pessoa Física
    2 Pessoa Jurídica

=head2 Tipo de Sexo

    M Masculino
    F Feminino

=head2 Tipo de Pagamento

     1 Cartão de Crédito
     2 Boleto Bancário
     3 Débito Bancário
     4 Débito Bancário – Dinheiro
     5 Débito Bancário – Cheque
     6 Transferência Bancária
     7 Sedex a Cobrar
     8 Cheque
     9 Dinheiro
    10 Financiamento
    11 Fatura
    12 Cupom
    13 Multicheque
    14 Outros

=head2 Bandera Cartão

    1 Diners
    2 MasterCard
    3 Visa
    4 Outros
    5 American Express
    6 HiperCard
    7 Aura

=head2 Tipo identificação

    1 CPF
    2 CNPJ
    3 RG
    4 IE
    5 Passaporte
    6 CTPS
    7 Título Eleitor

=head2 Lista de Status

    APA (Aprovação Automática) – Pedido foi aprovado automaticamente segundo parâmetros definidos na regra de aprovação automática.
    APM (Aprovação Manual) – Pedido aprovado manualmente por tomada de decisão de um analista.
    RPM (Reprovado Sem Suspeita) – Pedido Reprovado sem Suspeita por falta de contato com o cliente dentro do período acordado e/ou políticas restritivas de CPF (Irregular, SUS ou Cancelados).
    AMA (Análise manual) – Pedido está em fila para análise
    ERR (Erro) - Ocorreu um erro na integração do pedido, sendo necessário analisar um possível erro no XML enviado e após a correção reenvia-lo.
    NVO (Novo) – Pedido importado e não classificado Score pela analisadora (processo que roda o Score de cada pedido).
    SUS (Suspensão Manual) – Pedido Suspenso por suspeita de fraude baseado no contato com o “cliente” ou ainda na base ClearSale.
    CAN (Cancelado pelo Cliente) – Cancelado por solicitação do cliente ou duplicidade do pedido.
    FRD (Fraude Confirmada) – Pedido imputado como Fraude Confirmada por contato com a administradora de cartão e/ou contato com titular do cartão ou CPF do cadastro que desconhecem a compra.
    RPA (Reprovação Automática) – Pedido Reprovado Automaticamente por algum tipo de Regra de Negócio que necessite aplicá-la (Obs: não usual e não recomendado).
    RPP (Reprovação Por Política) – Pedido reprovado automaticamente por política estabelecida pelo cliente ou ClearSale.

=head2 Lista de Status ( de entrada )

*Atenção: Ao enviar o status no pedido é importante ressaltar que este pedido será incluso como histórico e não será analisado pela ClearSale. Somente os pedidos que forem enviados com o status 0 – NVO ou que não tiverem o status definido que serão analisados pelo ClearSale.

     0 Novo (será analisado pelo ClearSale)
     9 Aprovado (irá ao ClearSale já aprovado e não será analisado)
    41 Cancelado pelo cliente (irá ao ClearSale já cancelado e não será analisado)
     5 Reprovado (irá ao ClearSale já reprovado e não será analisado)

=head2 Lista de Produtos

    -1 Outros
     1 A-ClearSale
     2 M-ClearSale
     3 T-ClearSale
     4 TG-ClearSale
     5 TH-ClearSale
     6 TG-LightClearSale
     7 TG-FullClearSale
     8 T-Monitorado
     9 Score de Fraude
    10 ClearID
    11 Análise Internacional

=head2 Lista de Moedas

    US Dollar       USD     840
    Euro            EUR     978
    Balboa          PAB     590
    Brasil Real     BRL     986
    outras: ver pdf de manual de integracao

=cut

#
#
# atualizar_status_pagamento:
# http://homologacao.clearsale.com.br/integracaov2/paymentintegration.asmx
# http://www.clearsale.com.br/integracaov2/paymentintegration.asmx
#
# servico de integracao:
# homologacao webservice: http://homologacao.clearsale.com.br/integracaov2/service.asmx
# homologacao aplicação: http://homologacao.clearsale.com.br/aplicacao/Login.aspx
# producao webservice: http://www.clearsale.com.br/integracaov2/service.asmx
# producao aplicação: http://www.clearsale.com.br/aplicacao/Login.aspx
#
#

1;
