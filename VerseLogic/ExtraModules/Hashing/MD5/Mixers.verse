using. BitMath

# These four auxiliary functions mix the bits in different ways.
# Each function takes three 32-bit values and produces one 32-bit result.
# They are used in the four rounds of the MD5 algorithm.

# Round 1 function: F(X, Y, Z) = (X & Y) | ((~X) & Z)
FunctionF<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseOr(BitwiseAnd(X, Y), BitwiseAnd(BitwiseNot(X), Z))
}

# Round 2 function: G(X, Y, Z) = (X & Z) | (Y & (~Z))
FunctionG<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseOr(BitwiseAnd(X, Z), BitwiseAnd(Y, BitwiseNot(Z)))
}

# Round 3 function: H(X, Y, Z) = X ^ Y ^ Z
FunctionH<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseXor(BitwiseXor(X, Y), Z)
}

# Round 4 function: I(X, Y, Z) = Y ^ (X | (~Z))
FunctionI<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseXor(Y, BitwiseOr(X, BitwiseNot(Z)))
}