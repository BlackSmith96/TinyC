//
// Created by 缪征 on 2019/5/15.
//

#include "Symbol.h"

// Insert a element in SymbolTable
void SymbolTable::insert(Symbol *ps) {
    table.push_back(ps);
}

// Remove a element in SymbolTable
void SymbolTable::remove(Symbol s) {
    std::vector<Symbol *>::iterator it;
    for (it = table.begin(); it != table.end(); ++it) {
        if ((*it)->getID() == s.getID()) {
            break;
        }
    }
    if (it != table.end()) {
        Symbol * tp = *it;
        delete tp;
        table.erase(it);
    }
}

// Search for a symbol
Symbol* SymbolTable::lookup(std::string s) {
    std::vector<Symbol *>::iterator it;
    for (it = table.begin(); it != table.end(); ++it)
        if ((*it)->getID() == s)
            break;

    if (it != table.end())
        return *it;
    else
        return nullptr;
}

// Add a Para Symbol
void SymbolTable::addPara(S_Type t, std::string s) {
    Symbol *ps;
    if (t == S_int) {
        ps = new IntSymbol(s, paraOffset);
        paraOffset += 8;
    }
    table.push_back(ps);
}

// Add a Var Symbol
void SymbolTable::addVar(S_Type t, std::string s) {
    Symbol *ps;
    if (t == S_int) {
        ps = new IntSymbol(s, varOffset);
        varOffset -= 8;
    }
    table.push_back(ps);
}

// Show Offset info of para
void SymbolTable::showTable() {
    for (int i = 0; i < table.size(); ++i) {
        std::cout << "Var " << table[i]->id << " Offset " << table[i]->offset << std::endl;
    }
}

// Get var or para Assembly Present
std::string SymbolTable::getRbpStr(std::string id) {
    std::string res;
    for (int i = 0; i < table.size(); ++i) {
        if(table[i]->id == id) {
            int off = table[i]->offset; 
            res = "[rbp";
            if(off > 0)
                res = res + std::string("+")+ std::to_string(off);
            else
                res = res + std::to_string(off);
            res += "]";
            return res;
        }
    }
    return res;
}

int SymbolTable::getSymbolNum() {
    return table.size();
}


void GenLabel::addLabel() {
    labelNum++;
}

void GenLabel::beginIf() {
    ifLabelNum++;
    s_ifLabel.push(ifLabelNum);
}

void GenLabel::endIf() {
    s_ifLabel.pop();
}

// Return Begin If Label
std::string GenLabel::getBeginIfLabel() {
    std::string s = "_beg_if_";
    s += std::to_string(s_ifLabel.top());
    return s;
}

// Return Else If Label
std::string GenLabel::getElseLabel() {
    std::string s = "_else_";
    s += std::to_string(s_ifLabel.top());
    return s;
}

// Return End If Label
std::string GenLabel::getEndIfLabel() {
    std::string s = "_end_if_";
    s += std::to_string(s_ifLabel.top());
    return s;
}

void GenLabel::beginWhile() {
    whileLabelNum++;
    s_whileLabel.push(whileLabelNum);
}

void GenLabel::endWhile() {
    s_whileLabel.pop();
}

// Return Begin While Label
std::string GenLabel::getBeginWhileLabel() {
    std::string s = "_beg_while_";
    s += std::to_string(s_whileLabel.top());
    return s;
}

// Return Begin While Label
std::string GenLabel::getEndWhileLabel() {
    std::string s = "_end_while_";
    s += std::to_string(s_whileLabel.top());
    return s;
}

// Return Print Message Label
std::string GenLabel::getPrintMessageLabel() {
    std::string s = "_print_message_";
    s += std::to_string(labelNum);
    return s;
}