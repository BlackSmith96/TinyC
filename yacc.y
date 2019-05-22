%{
#include "main.h"
#include "Symbol.h"


extern "C"
{
    void yyerror(const char *s);
    extern int yylex(void);
}

SymbolTable * curFuncTable;
SymbolTable funcSet;
FuncSymbol *func, *tf;
S_Type varType, funcType;
int GenLabel::labelNum = 1;
int GenLabel::ifLabelNum = 0;
int GenLabel::whileLabelNum = 0;
std::stack<int> GenLabel::s_whileLabel = std::stack<int>();
std::stack<int> GenLabel::s_ifLabel = std::stack<int>();
std::string codeHead, codeText, codeData;
int argNum;
%}

%token T_Void T_Int T_While T_If T_Else T_Return T_Break T_Continue
%token T_Print T_ReadInt T_Le T_Ge T_Eq T_Ne T_And T_Or
%token T_IntConstant T_StringConstant T_Identifier

%left '='
%left T_Or
%left T_And
%left T_Eq T_Ne
%left '<' '>' T_Le T_Ge
%left '+' '-'
%left '*' '/' '%'
%left '!'

%%
Start:
    Program                         { /* empty */ }
;

Program:
    /* empty */                     { /* empty */ }
|   Program FuncDef                 { /* empty */ }
;

FuncDef:
    FuncType  FuncName Args Vars Stmts EndFuncDef  {}
;

FuncType:
    T_Int                           {func = new FuncSymbol;func->setType(S_int);}
|   T_Void                          {func = new FuncSymbol;func->setType(S_void);}
;

FuncName:
    T_Identifier                    {
                                    func->setName($1);
                                    curFuncTable = new SymbolTable();
                                    codeText += $1;
                                    codeText += ":\n";
                                    codeText += "\tpush rbp\n";
                                    codeText += "\tmov  rbp, rsp\n";
                                    }
;

Args:
    '(' ')'                         { /* empty */ }
|   '(' _Args ')'                   { /* empty */ }
;

_Args:
    T_Int T_Identifier              {func->addPara($2,S_int); curFuncTable->addPara(S_int,$2);}
|   _Args ',' T_Int T_Identifier    {func->addPara($4,S_int); curFuncTable->addPara(S_int,$4);}
;

Vars:
    _Vars                           { funcSet.insert(func);}
;

_Vars:
    '{'                             { /* empty */ }
|   _Vars Var ';'                   { codeText += "\tsub  rsp, ";
                                      codeText += std::to_string(8*(curFuncTable->getSymbolNum()-func->getParaNum()));
                                      codeText += "\n";
                                    }
;

Var:
    T_Int T_Identifier              { varType = S_int; curFuncTable->addVar(varType, $2);}
|   Var ',' T_Identifier            { curFuncTable->addVar(varType, $3); }
;

Stmts:
    /* empty */                     { /* empty */ }
|   Stmts Stmt                      { /* empty */ }
;

EndFuncDef:
    '}'                             {/*func->showPara();curFuncTable->showTable()*/;delete curFuncTable;}
;

Stmt:
    AssignStmt                      { /* empty */ }
|   CallStmt                        { /* empty */ }
|   IfStmt                          { /* empty */ }
|   WhileStmt                       { /* empty */ }
|   BreakStmt                       { /* empty */ }
|   ContinueStmt                    { /* empty */ }
|   ReturnStmt                      { /* empty */ }
|   PrintStmt                       { /* empty */ }
;

AssignStmt:
    T_Identifier '=' Expr ';'       {std::string lcode =  std::string("\tpop  ") + curFuncTable->getRbpStr($1) + "\n";codeText += lcode;}
;

CallStmt:
    CallExpr ';'                    {}
;

IfStmt:
    If '(' Expr ')' Then '{' Stmts '}' EndThen EndIf
                                    { /* empty */ }
|   If '(' Expr ')' Then '{' Stmts '}' EndThen T_Else '{' Stmts '}' EndIf
                                    { /* empty */ }
;

If:
    T_If            {GenLabel::beginIf();codeText += GenLabel::getBeginIfLabel();codeText += ":\n";}
;

Then:
    /* empty */     {codeText = codeText + string("\tjz ") + GenLabel::getElseLabel(); codeText += "\n";}
;

EndThen:
    /* empty */     {codeText = codeText + string("\tjmp ") + GenLabel::getEndIfLabel(); codeText += "\n";
                     codeText += GenLabel::getElseLabel(); codeText += ":\n";
                    }
;

EndIf:
    /* empty */     {codeText = codeText + GenLabel::getEndIfLabel(); codeText += ":\n"; GenLabel::endIf();}
;

WhileStmt:
    While '(' Expr ')' Do '{' Stmts '}' EndWhile
                    { /* empty */ }
;

While:
    T_While         {GenLabel::beginWhile();codeText = codeText + GenLabel::getBeginWhileLabel() + std::string(":\n");}
;

Do:
    /* empty */     {codeText += "\tjz "; codeText += GenLabel::getEndWhileLabel(); codeText += "\n";}
;

EndWhile:
    /* empty */     {codeText += "\tjmp "; codeText += GenLabel::getBeginWhileLabel(); codeText += "\n"; codeText += GenLabel::getEndWhileLabel();codeText += ":\n";GenLabel::endWhile();}
;

BreakStmt:
    T_Break ';'     {codeText += "\tjmp "; codeText += GenLabel::getEndWhileLabel(); codeText += "\t; Break\n";}
;

ContinueStmt:
    T_Continue ';'  {codeText += "\tjmp "; codeText += GenLabel::getBeginWhileLabel(); codeText += "\t; Continue\n";}
;

ReturnStmt:
    T_Return ';'            {codeText += "\tmov  rsp, rbp\n"; codeText += "\tpop  rbp\n";codeText += "\tret\n";}
|   T_Return Expr ';'       {codeText += "\tpop  rax\n";codeText += "\tmov  rsp, rbp\n"; codeText += "\tpop  rbp\n";codeText += "\tret\n";}
;

PrintStmt:
    TT_Print '(' T_StringConstant ',' PrintIntArgs ')' ';'
                    {
                     codeText += "\tpush qword "; codeText += std::to_string(argNum); codeText += "\n";
                     codeText += "\tpush ";codeText += GenLabel::getPrintMessageLabel(); codeText += "\n";
                     codeData += GenLabel::getPrintMessageLabel(); codeData += " db "; codeData += std::string($3);
                     codeData += " , 10, 0\n";
                     GenLabel::addLabel();
                     codeText += "\tcall print\n";
                     codeText += "\tadd  rsp,"; codeText += std::to_string(argNum * 8 + 16); codeText += "\n";
                    }
|   TT_Print '(' T_StringConstant')' ';'
                    {
                     codeText += "\tpush qword 0\n";
                     codeText += "\tpush ";codeText += GenLabel::getPrintMessageLabel(); codeText += "\n";
                     codeData += GenLabel::getPrintMessageLabel(); codeData += " db "; codeData += std::string($3);
                     codeData += " , 10, 0\n";
                     GenLabel::addLabel();
                     codeText += "\tcall print\n";
                     codeText += "\tadd  rsp, 16\n";
                    }
;

TT_Print:
    T_Print                  { argNum = 0; }
;
PrintIntArgs:
    /* empty */              { /* empty */ }
|   PExpr                    { /* empty */ }
|   PExpr ',' PrintIntArgs   { /* empty */ }
;

PExpr:
    Expr                    { argNum += 1; }
;

Expr:
    T_IntConstant           {codeText += "\tpush qword "; codeText += std::string($1); codeText += "\n";}
|   T_Identifier            {codeText += std::string("\tpush qword "); codeText += curFuncTable->getRbpStr($1); codeText += "\n";}
|   Expr '+' Expr           {codeText += std::string("\tadd\n");}
|   Expr '-' Expr           {codeText += std::string("\tsub\n");}
|   Expr '*' Expr           {codeText += std::string("\tmul\n");}
|   Expr '/' Expr           {codeText += std::string("\tdiv\n");}
|   Expr '%' Expr           {codeText += std::string("\tmod\n");}
|   Expr '>' Expr           {codeText += std::string("\tcmpgt\n");}
|   Expr '<' Expr           {codeText += std::string("\tcmplt\n");}
|   Expr T_Ge Expr          {codeText += std::string("\tcmpge\n");}
|   Expr T_Le Expr          {codeText += std::string("\tcmple\n");}
|   Expr T_Eq Expr          {codeText += std::string("\tcmpeq\n");}
|   Expr T_Ne Expr          {codeText += std::string("\tcmpne\n");}
|   Expr T_Or Expr          {codeText += std::string("\tor\n");}
|   Expr T_And Expr         {codeText += std::string("\tand\n");}
|   '-' Expr %prec '!'      {codeText += std::string("\tneg\n");}
|   '!' Expr                {codeText += std::string("\tnot\n");}
|   ReadInt                 { /* empty */ }
|   CallExpr                { /* empty */ }
|   '(' Expr ')'            { /* empty */ }
;

ReadInt:
    T_ReadInt '(' ')'
                            {codeText += "\tsub  rsp, 8\n";codeText += "\tcall readint     ; The Return Value has been put into stack\n";
                            }
;

CallExpr:
    T_Identifier Actuals
                            {
                                
                                tf = (FuncSymbol *)funcSet.lookup($1);
                                codeText += "\tcall ";codeText += tf->getID(); codeText += "\n";
                                // We also have to clear prepuhed parameters
                                codeText += "\tadd  rsp, ";
                                codeText += std::to_string(tf->getParaNum() * 8);
                                codeText += "\n";
                                if(tf != nullptr && tf->getType() != S_void) 
                                    codeText += "\tpush  rax\n";
                            }
;

Actuals:
    '(' ')'                  {}                 
|   '(' _Actuals ')'         {}
;

_Actuals:
    Expr                     {}
|   _Actuals ',' Expr        {}
;   

%%

void yyerror(const char *s)    //当yacc遇到语法错误时，会回调yyerror函数，并且把错误信息放在参数s中
{
    cerr<<s<<endl;//直接输出错误信息
}

int main(int argc, char * argv[])
{
    //const char* sFile="file.txt";//打开要读取的文本文件

    if (argc < 2) {
        std::cout << "usage: tinyC source.c" << std::endl;
        return 1;
    }

    //FILE* fp=fopen(sFile, "r");
    FILE* fp=fopen(argv[1], "r");

    if(fp==NULL)
    {
        printf("Cannot open %s\n", argv[1]);
        return -1;
    }

    codeHead += "%include\"macro.inc\"\n";
    codeHead += "global _start\n";

    codeText += "   section     .text\n";
    codeText += "_start:\n";
    codeText += "\tcall main\n";
    codeText += "\texit rax\n";

    codeData += "   section     .data\n";

    extern FILE* yyin;    //yyin和yyout都是FILE*类型
    yyin=fp;//yacc会从yyin读取输入，yyin默认是标准输入，这里改为磁盘文件。yacc默认向yyout输出，可修改yyout改变输出目的

    //printf("-----begin parsing %s\n", sFile);
    yyparse();//使yacc开始读取输入和解析，它会调用lex的yylex()读取记号
    //puts("-----end parsing");
    //cout << codeHead << codeText << codeData;
    std::ofstream ofile;
    std::string ofileName(argv[1]);
    ofileName += ".asm";
    ofile.open(ofileName);
    ofile << codeHead << codeText << codeData;
    ofile.close();
    fclose(fp);

    return 0;
}