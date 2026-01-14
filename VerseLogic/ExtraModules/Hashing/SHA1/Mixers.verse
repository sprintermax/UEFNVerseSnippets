using. BitMath

# These four auxiliary functions mix the bits in different ways.
# Each function takes three 32-bit values and produces one 32-bit result.
# They are used in the four rounds of the SHA-1 algorithm.

# Choice(X, Y, Z) = (X & Y) ^ (~X & Z)
FunctionChoice<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseOr(BitwiseAnd(X, Y), BitwiseAnd(BitwiseNot(X), Z))
}

# Parity(X, Y, Z) = X ^ Y ^ Z
FunctionParity<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseXor(BitwiseXor(X, Y), Z)
}

# Majority(X, Y, Z) = (X & Y) | (X & Z) | (Y & Z)
FunctionMajority<internal>(X:int, Y:int, Z:int)<transacts>:int = {
    BitwiseOr(BitwiseOr(BitwiseAnd(X, Y), BitwiseAnd(X, Z)), BitwiseAnd(Y, Z))
}