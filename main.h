#ifndef MAIN_HPP
#define MAIN_HPP

#include <iostream>//使用C++库
#include <fstream>
#include <string>
#include <vector>
#include <stdio.h>//printf和FILE要用的

using namespace std;


#define YYSTYPE char * //把YYSTYPE(即yylval变量)重定义为struct Type类型，这样lex就能向yacc返回更多的数据了

#endif