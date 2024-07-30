#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"


void checkAssignment(Types lValue, Types rValue, string message) {
    if ((lValue == INT_TYPE && rValue == INT_TYPE) ||
        (lValue == REAL_TYPE && rValue == REAL_TYPE) ||
        (lValue == CHAR_TYPE && rValue == CHAR_TYPE) ||
        (lValue == INT_TYPE && rValue == HEX_TYPE)) {
        return;
    }
    if (lValue == INT_TYPE && rValue == REAL_TYPE) {
        appendError(GENERAL_SEMANTIC, "Illegal Narrowing Variable Initialization");
    } else if (lValue != MISMATCH && rValue != MISMATCH && lValue != rValue) {
        appendError(GENERAL_SEMANTIC, "Type Mismatch on " + message);
    }
}

void checkFunctionReturn(Types returnType, Types bodyType) {
    if (returnType == INT_TYPE && bodyType == REAL_TYPE) {
        appendError(GENERAL_SEMANTIC, "Illegal Narrowing Function Return");
    }
}

Types checkWhen(Types true_, Types false_) {
    if (true_ == MISMATCH || false_ == MISMATCH)
        return MISMATCH;
    if (true_ != false_)
        appendError(GENERAL_SEMANTIC, "When Types Mismatch ");
    return true_;
}

Types checkSwitch(Types case_, Types when, Types other) {
    if (case_ != INT_TYPE)
        appendError(GENERAL_SEMANTIC, "Switch Expression Not Integer");
    return checkCases(when, other);
}

Types checkCases(Types left, Types right) {
    if (left == MISMATCH || right == MISMATCH)
        return MISMATCH;
    if (left == NONE || left == right)
        return right;
    appendError(GENERAL_SEMANTIC, "Case Types Mismatch");
    return MISMATCH;
}

Types checkArithmetic(Types left, Types right) {
    if (left == MISMATCH || right == MISMATCH)
        return MISMATCH;
    if (left == INT_TYPE && right == INT_TYPE)
        return INT_TYPE;
    if (left == REAL_TYPE && right == REAL_TYPE)
        return REAL_TYPE;
    if ((left == INT_TYPE && right == REAL_TYPE) || (left == REAL_TYPE && right == INT_TYPE))
        return REAL_TYPE;
    appendError(GENERAL_SEMANTIC, "Integer or Real Type Required");
    return MISMATCH;
}

Types checkListElements(vector<Types>& elements, Types listType) {
    for (Types type : elements) {
        if (type != listType) {
            appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
            return MISMATCH;
        }
    }
    return listType;
}

void checkListTypeConsistency(Types declaredType, Types elementType) {
    if (declaredType != elementType) {
        appendError(GENERAL_SEMANTIC, "Declared list type does not match element type");
    }
}

void checkListSubscript(Types subscriptType) {
    if (subscriptType != INT_TYPE) {
        appendError(GENERAL_SEMANTIC, "List Subscript Must Be Integer");
    }
}

void checkRelationalTypes(Types left, Types right) {
    if (left == CHAR_TYPE && (right == INT_TYPE || right == REAL_TYPE || right == HEX_TYPE)) {
        appendError(GENERAL_SEMANTIC, "Character Literals Cannot be Compared to Numeric Expressions");
    } else if (right == CHAR_TYPE && (left == INT_TYPE || left == REAL_TYPE || left == HEX_TYPE)) {
        appendError(GENERAL_SEMANTIC, "Character Literals Cannot be Compared to Numeric Expressions");
    }
}

void checkExponentiation(Types base, Types exponent) {
    if ((base != INT_TYPE && base != REAL_TYPE) || (exponent != INT_TYPE && exponent != REAL_TYPE)) {
        appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types");
    }
}

void checkNegation(Types value) {
    if (value != INT_TYPE && value != REAL_TYPE) {
        appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types");
    }
}

void checkRemainderOperator(Types left, Types right) {
    if (left != INT_TYPE || right != INT_TYPE) {
        appendError(GENERAL_SEMANTIC, "Remainder Operator Requires Integer Operands");
    }
}

void checkIfElseTypes(Types ifType, Types elseType) {
    if (ifType != elseType && ifType != MISMATCH && elseType != MISMATCH) {
        appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
    }
}

void checkFoldListType(Types listType) {
    if (listType != INT_TYPE && listType != REAL_TYPE) {
        appendError(GENERAL_SEMANTIC, "Fold Requires A Numeric List");
    }
}





