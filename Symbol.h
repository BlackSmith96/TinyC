//
// Created by 缪征 on 2019/5/15.
//

#ifndef SIMPLEC_SYMBOL_H
#define SIMPLEC_SYMBOL_H

#include <iostream>
#include <vector>
#include <stack>

enum S_Type {S_int, S_char, S_array, S_struct, S_func, S_void};

class Symbol {
protected:
    std::string id;
    S_Type stype;
    int offset;
public:
    std::string getID() {
        return id;
    }

    S_Type getType() {
        return stype;
    }

    int getOffset() {
        return offset;
    }

    int getHash() {
        int v = 0;
        for (int i = 0; i < id.size(); ++i)
            v = v + 17 + id[i] - '0';
        return v;
    }

    friend class SymbolTable;
};

class ArraySymbol:public Symbol{
};

class IntSymbol:public Symbol{
public:
    IntSymbol(std::string s, int off){
        id = s;
        stype = S_int;
        offset = off;
    }
};

class StructSymbol:public Symbol{
};

class FuncSymbol:public Symbol{
private:
    std::vector<std::string> paraNames;
    std::vector<S_Type> paraTypes;
public:
    void addPara(std::string pName, S_Type pType) {
        paraNames.push_back(pName);
        paraTypes.push_back(pType);
    }

    void setName(std::string name) {
        id = name;
    }

    void setType(S_Type t) {
        stype = t;
    }

    void clear() {
        paraNames.clear();
        paraTypes.clear();
    }

    void showPara() {
        std::cout << "Function Name is " << id << std::endl;
        std::cout << "Return Type is " << stype << std::endl;
        for (int i = 0; i < paraNames.size(); ++i){
            std::cout << "Para " << paraNames[i] << " Type " << paraTypes[i] << std::endl;
        }
    }

    int getParaNum() {
        return paraTypes.size();
    }
};

class SymbolTable{
private:
    SymbolTable * pp;   // pointer to parent, used in block
    std::vector<Symbol *> table;
    int paraOffset, varOffset;
public:
    // Insert a element in table
    void insert(Symbol *);

    // Delete a element in table
    void remove(Symbol);

    // Search for a symbol
    Symbol * lookup(std::string);

    // Default Constructor
    SymbolTable(): pp(nullptr) {
        paraOffset = 16;
        varOffset = -8;
    }

    // Add Symbol
    void addPara(S_Type, std::string);

    // Add Var
    void addVar(S_Type, std::string);

    // Show Offset info of para
    void showTable();

    // Get var or para Assembly Present
    std::string getRbpStr(std::string);

    // Get sum of para and var
    int getSymbolNum();
};

class GenLabel{
private:
    static int labelNum;
    static int ifLabelNum;
    static int whileLabelNum;

    static std::stack<int> s_whileLabel;
    static std::stack<int> s_ifLabel;

public:
    static std::string getLabel();
    static void addLabel();

    static void beginIf();
    static void endIf();
    static std::string getBeginIfLabel();
    static std::string getElseLabel();
    static std::string getEndIfLabel();

    static void beginWhile();
    static void endWhile();
    static std::string getBeginWhileLabel();
    static std::string getEndWhileLabel();

    static std::string getPrintMessageLabel();
};


#endif //SIMPLEC_SYMBOL_H