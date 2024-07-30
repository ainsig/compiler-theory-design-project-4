// CMSC 430 Compiler Theory and Design
// Project 4 Skeleton
// UMGC CITE
// Summer 2023

// This file contains type definitions and the function
// prototypes for the type checking functions


typedef char* CharPtr;

enum Types {MISMATCH, INT_TYPE, CHAR_TYPE, REAL_TYPE, HEX_TYPE, LIST_TYPE, NONE};



void checkAssignment(Types lValue, Types rValue, string message);
Types checkWhen(Types true_, Types false_);
Types checkSwitch(Types case_, Types when, Types other);
Types checkCases(Types left, Types right);
Types checkArithmetic(Types left, Types right);
Types checkListElements(vector<Types>& elements, Types listType);
void checkListSubscript(Types subscriptType);
void checkRelationalTypes(Types left, Types right);
void checkExponentiation(Types base, Types exponent);
void checkNegation(Types value);
void checkRemainderOperator(Types left, Types right);
void checkIfElseTypes(Types ifType, Types elseType);
void checkFoldListType(Types listType);
void checkFunctionReturn(Types returnType, Types bodyType);



