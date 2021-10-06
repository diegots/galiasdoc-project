%{
#include "IE6364992H.tab.h"
#include "flex-prologue.h"
%}

%option noyywrap
%option nounput
%option noinput

word [\ 0-9A-Za-zÁÉÍÓÚÑáéíóúñ\.\,\-\$\%&\*\?\(\)\"\_\:\'\/\|\+]+
number [0-9]+

%%

"└" {return COL_START;}
"┘" {return COL_END;}
"►" {return LINE_START;}
"◄" {return LINE_END;}
"R1_END" {return R1_END;}
"R1_START" {return R1_START;}
"R2_END" {return R2_END;}
"R2_START" {return R2_START;}
"T2_END" {return T2_END;}
"T2_START" {return T2_START;}
"R3_END" {return R3_END;}
"R3_START" {return R3_START;}

"P"{number}"·H"{number}"·a·" {return A;}
"P"{number}"·H"{number}"·artículo·" {return ARTICULO;}
"P"{number}"·H"{number}"·Artículos·" {return ARTICULOS;}
"P"{number}"·H"{number}"·Cantidad·" {return CANTIDAD;}
"P"{number}"·H"{number}"·"[cC]"liente":?"·" {return CLIENTE;}
"P"{number}"·H"{number}"·crédito·" {return CREDITO;}
"P"{number}"·H"{number}"·Código·" {return CODIGO;}
"P"{number}"·H"{number}"·Contacto·" {return CONTACTO;}
"P"{number}"·H"{number}"·de·" {return DE;}
"P"{number}"·H"{number}"·Divisa·" {return DIVISA;}
"P"{number}"·H"{number}"·envío·" {return ENVIO;}
"P"{number}"·H"{number}"·facturación:·" {return FACTURACION;}
"P"{number}"·H"{number}"·Fecha·" {return FECHA;}
"P"{number}"·H"{number}"·"[Ff]"actura":?"·" {return FACTURA;}
"P"{number}"·H"{number}"·Forma·" {return FORMA;}
"P"{number}"·H"{number}"·Gastos·" {return GASTOS;}
"P"{number}"·H"{number}"·Importe·" {return IMPORTE;}
"P"{number}"·H"{number}"·incluido·" {return INCLUIDO;}
"P"{number}"·H"{number}"·IVA·" {return IVA;}
"P"{number}"·H"{number}"·la·" {return LA;}
"P"{number}"·H"{number}"·nota·" {return NOTA;}
"P"{number}"·H"{number}"·Número·" {return NUMERO;}
"P"{number}"·H"{number}"·pagar·" {return PAGAR;}
"P"{number}"·H"{number}"·pago·" {return PAGO;}
"P"{number}"·H"{number}"·pedido·" {return PEDIDO;}
"P"{number}"·H"{number}"·Precio·" {return PRECIO;}
"P"{number}"·H"{number}"·producto·" {return PRODUCTO;}
"P"{number}"·H"{number}"·/·" {return '/';}
"P"{number}"·H"{number}"·Tipo·" {return TIPO;}
"P"{number}"·H"{number}"·"[Tt]"otal·" {return TOTAL;}
"P"{number}"·H"{number}"·N.°·" {return NUMERO;}
"P"{number}"·H"{number}"·y·" {return Y;}
"P"{number}"·H"{number}"·descripción·" {return DESCRIPCION;}

"P"{number}"·W"{number}"·N.°·" {return NUMERO;}
"P"{number}"·W"{number}"·"{word}"·" {
    PRINTF("WORD[%s]\n", yytext); yylval.word_value = split_id_value(yytext);
    return WORD;
}

"\n" {PRINTF("NEW_LINE\n");}
. {}

%%
