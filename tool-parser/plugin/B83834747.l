%{
#include "B83834747.tab.h"
#include "flex-prologue.h"
%}

%option noyywrap
%option nounput
%option noinput

word [\ 0-9A-Za-zÁÉÍÓÚÑáéíóúñ\.\-\$&\*\?\"\_\:\'\/\|\+€,()]+
number [0-9]+

%%

"R1_START" {return R1_START;}
"R1_END" {return R1_END;}
"T2_START" {return T2_START;}
"T2_END" {return T2_END;}
"R3_START" {return R3_START;}
"R3_END" {return R3_END;}
"└" {return COL_START;}
"┘" {return COL_END;}
"►" {return LINE_START;}
"◄" {return LINE_END;}

"P"{number}"·H"{number}"·(21·" {return _21;}
"P"{number}"·H"{number}"·%)·" {return PORCENTAJE;}
"P"{number}"·H"{number}"·Cantidad·" {return CANTIDAD;}
"P"{number}"·H"{number}"·cliente:·" {return CLTE;}
"P"{number}"·H"{number}"·de·" {return DE;}
"P"{number}"·H"{number}"·Dominio·" {return DOMINIO;}
"P"{number}"·H"{number}"·Factura":?"·" {return FACTURA;}
"P"{number}"·H"{number}"·Fecha":?"·" {return FECHA;}
"P"{number}"·H"{number}"·ID·" {return ID;}
"P"{number}"·H"{number}"·INSTALACIÓN·" {return INSTALACION;}
"P"{number}"·H"{number}"·IVA·" {return IVA;}
"P"{number}"·H"{number}"·incl.·" {return INCL;}
"P"{number}"·H"{number}"·no·" {return NO;}
"P"{number}"·H"{number}"·OFERTAS·" {return OFERTAS;}
"P"{number}"·H"{number}"·Orden·" {return ORDEN;}
"P"{number}"·H"{number}"·OTROS·" {return OTROS;}
"P"{number}"·H"{number}"·Pago:·" {return PAGO;}
"P"{number}"·H"{number}"·pedido:·" {return PEDIDO;}
"P"{number}"·H"{number}"·Precio·" {return PRECIO;}
"P"{number}"·H"{number}"·RENOVACIÓN·" {return RENOVACION;}
"P"{number}"·H"{number}"·SUSCRIPCIÓN·" {return SUSCRIPCION;}
"P"{number}"·H"{number}"·TOTAL·" {return TOTAL;}
"P"{number}"·H"{number}"·TRANSFERENCIA·" {return TRANSFERENCIA;}
"P"{number}"·H"{number}"·unitario·" {return UNITARIO;}
"P"{number}"·H"{number}"·vencimiento:·" {return VCTO;}

"P"{number}"·W"{number}"·UBTOTAL·" {return SUBTOTAL;}
"P"{number}"·W"{number}"·HISPANO·" {yylval.word_value = split_id_value(yytext); return HISPANO;}
"P"{number}"·W"{number}"·Inscrita·" {return INSCRITA;}
"P"{number}"·W"{number}"·"{word}"·" {
    PRINTF("WORD[%s]\n", yytext); yylval.word_value = split_id_value(yytext);
    return WORD;
}

"\n" {PRINTF("NEW_LINE\n");}
. {}

%%
