%{
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    #include "musicCompiler.tab.h"
    #include "utils/variable_types.h"
    #include "utils/string_utils.h"

    variable_type_t getVarType(char * s);
    double freq(char * note_name);
%}

alpha [A-Za-z]
digit [0-9]
double -?[0-9]+\.[0-9]+

/* Mi (E) y Si (B) no tienen sostenido (#) */
note  ([ACDFG]#?|[BE])[0-8]

bool_op (<|>)=?|== 

%%

[\t \n \r]
"bpm"                               {yylval.string=dupstr(yytext); return BPM;}
"volume"                            {yylval.string=dupstr(yytext); return VOLUME;}
"note"                              {yylval.string=dupstr(yytext); return NOTE_T;}
"int"                               {yylval.string=dupstr(yytext); return INT_T;}
"double"                            {yylval.string=dupstr(yytext); return DOUBLE_T;}
"play"                              {yylval.string=dupstr(yytext); return PLAY;}
"during"                            {yylval.string=dupstr(yytext); return DURING;}
"if"                                {yylval.string=dupstr(yytext); return IF;}
"while"                             {yylval.string=dupstr(yytext); return WHILE;}
"length"                            {yylval.string=dupstr("len"); return LENGTH;}
"as"                                {yylval.string=dupstr(yytext); return AS;}
"guitar"                            {yylval.string=dupstr(yytext); return GUITAR;}
"piano"                             {yylval.string=dupstr(yytext); return PIANO;}
"in"                                {yylval.string=dupstr(yytext); return IN;}
"thread_"{digit}+                   {yylval.string=dupstr(yytext); return THREAD;}
{bool_op}                           {yylval.string=dupstr(yytext); return BOOL_OP;}
{digit}+                            {yylval.integer=atoi(yytext); return INTEGER;}
{double}                            {yylval.decimal=atof(yytext); return DOUBLE;}
"S"                                 {yylval.decimal=0; return NOTE;} /* Importante que este arriba de los IDs! */
{note}                              {yylval.decimal=freq(yytext); return NOTE;} /* Importante que este arriba de los IDs! */
{alpha}({alpha}|{digit}|"_")*       {
                                        yylval.string=dupstr(yytext);
                                        switch (getVarType(yylval.string)) {
                                            case variable_type_int_: return INT_VAR;
                                            case variable_type_double_: return DOUBLE_VAR;
                                            case variable_type_note_: return NOTE_VAR;
                                            case variable_type_int_array_: return INT_ARRAY_VAR;
                                            case variable_type_double_array_: return DOUBLE_ARRAY_VAR;
                                            case variable_type_note_array_: return NOTE_ARRAY_VAR;
                                            default: return NEW_ID; // Si no tiene un tipo antes, falla en el yacc
                                        }
                                    }
"//".*                              {/** Comment **/}
.                                   return yytext[0];

%%

double freq(char * note_name){
    int base;
    switch(note_name[0]){
        case 'A':
        base = 0;
        break;
        case 'B':
        base = 2;
        break;
        case 'C':
        base = -9;
        break;
        case 'D':
        base = -7;
        break;
        case 'E':
        base = -5;
        break;
        case 'F':
        base = -4;
        break;
        case 'G':
        base = -2;
        break;
    }
    int octet;
    if(note_name[1] == '#'){
        base++;
        octet = note_name[2] - '0';
    }
    else{
        octet = note_name[1] - '0';
    }

    return 440 * pow(2, base/12.0 + octet-4);
}