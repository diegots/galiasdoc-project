%{
#include "A48941488.tab.h"
#include "flex-prologue.h"

#include <stdio.h>
#include "strbuf.h"
%}

%option noyywrap
%option nounput
%option noinput
word [0-9A-Za-zÁÉÍÓÚÑáéíóúñº’\.\-–\$&\*\?\"\_:\'\/\|\+€,()\% ]+
number [0-9]+
char_ad "\xad"
char_c2 "\xc2"

%%

"R2_START" {return R2_START;}
"R2_END" {return R2_END;}
"R3_START" {return R3_START;}
"R3_END" {return R3_END;}
"T1_START" {return T1_START;}
"T1_END" {return T1_END;}
"└" {return COL_START;}
"┘" {return COL_END;}
"►" {return LINE_START;}
"◄" {return LINE_END;}

"P"{number}"·H"{number}"·de·" {return DE;}
"P"{number}"·H"{number}"·Descripción·" {return DESCRIPCION;}
"P"{number}"·H"{number}"·Euros·" {return EUROS;}
"P"{number}"·H"{number}"·Importe·" {return IMPORTE;}
"P"{number}"·H"{number}"·Impuestos·" {return IMPUESTOS;}
"P"{number}"·H"{number}"·Factura·" {return FACTURA;}
"P"{number}"·H"{number}"·Fecha·" {return FECHA;}
"P"{number}"·H"{number}"·"[Gg]"ravable·" {return GRAVABLE;}
"P"{number}"·H"{number}"·NIF/CIF·" {return NIF_CIF;}
"P"{number}"·H"{number}"·neto·" {return NETO;}
"P"{number}"·H"{number}"·No·" {return NO;}
"P"{number}"·H"{number}"·Referencia·" {return REFERENCIA;}
"P"{number}"·H"{number}"·Total·" {return TOTAL;}
"P"{number}"·H"{number}"·vencimiento·" {return VENCIMIENTO;}

"P"{number}"·W"{number}"·Base·" {return BASE;}
"P"{number}"·W"{number}"·Condiciones·" {return CONDICIONES;}
"P"{number}"·W"{number}"·de·" {}
"P"{number}"·W"{number}"·IVA·" {return IVA;}
"P"{number}"·W"{number}"·Importe·" {return IMPORTE;}
"P"{number}"·W"{number}"·pago·" {return PAGO;}
"P"{number}"·W"{number}"·Total·" {return TOTAL;}

"P"{number}"·W"{number}"·Prodware·" {yylval.word_value = split_id_value(yytext); return PRODWARE;}
"P"{number}"·W"{number}"·CIF·" {return CIF;}
"P"{number}"·W"{number}"·Domicilio:·" {return DOMICILIO;}

"P"{number}"·W"{number}"·"{char_c2}{char_ad}{word}"·" {
    /* En dos documentos existen caracteres erroneos que son tratados en esta regla.
     * Los caracteres son \xc2\xad. En lugar de estos caractares debiera estar un
     * signo negativo (-) */
    PRINTF("WORD[%s]\n", yytext);

    yylval.word_value = split_id_value(yytext);
    strbuf b = strbufnew();
    b = strbufprintf(b, "-%s", ++yylval.word_value->value);
    yylval.word_value->value--;
    free(yylval.word_value->value);
    yylval.word_value->value = strbuf2str_dup(b);
    free(b);

    return WORD;
}

"P"{number}"·W"{number}"·"{word}{char_c2}{char_ad}{word}"·" {
    remove_char(yytext, 0xc2);
    remove_char(yytext, 0xad);
    yylval.word_value = split_id_value(yytext);
    return WORD;
}

"P"{number}"·W"{number}"·"{word}"·" {
    PRINTF("WORD[%s]\n", yytext); yylval.word_value = split_id_value(yytext);
    return WORD;
}

"\n" {PRINTF("NEW_LINE\n");}
. {}

%%
