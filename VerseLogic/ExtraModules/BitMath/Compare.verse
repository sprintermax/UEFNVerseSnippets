# This is a internal handler for bitwise comparison operations to avoid code duplication
BitwiseBaseHandler<internal>(A:int, B:int, BitwiseCondition:type{_(:int, :int)<decides><transacts>:void})<transacts>:int = {
    # Get the minimum Bit Width needed to represent both Values
    BitWidth := GetBitWidth(A, B)

    # Ensure both values are represented as positives for the operation
    var UnsignedA : int = ToPositiveRepresentation(A, BitWidth)
    var UnsignedB : int = ToPositiveRepresentation(B, BitWidth)

    var Result : int = 0
    var BitPosition : int = 1

    loop {
        UnsignedA > 0 or UnsignedB > 0 or (break)

        BitA := Mod[UnsignedA, 2] or Err("Unreachable")
        BitB := Mod[UnsignedB, 2] or Err("Unreachable")

        # Compute the given Bitwise Condition for the current bit
        if (BitwiseCondition[BitA, BitB]) {
            set Result += BitPosition
        }

        set BitPosition *= 2
        set UnsignedA = Quotient[UnsignedA, 2] or Err("Unreachable")
        set UnsignedB = Quotient[UnsignedB, 2] or Err("Unreachable")
    }

    # Convert back to signed representation if needed
    return FromPositiveRepresentation(Result, BitWidth)
}

# Compares if both of the bits are 1
BitwiseAndCondition<internal>(A:int, B:int)<computes><decides>:void = {
    A = 1 and B = 1
}

# Compares if any of the bits are 1
BitwiseOrCondition<internal>(A:int, B:int)<computes><decides>:void = {
    A = 1 or B = 1
}

# Compares if only one of the bits is 1
BitwiseXorCondition<internal>(A:int, B:int)<computes><decides>:void = {
    A + B = 1
}

# Compares if the bit is 0
BitwiseNotCondition<internal>(Value:int)<computes><decides>:void = {
    Value = 0
}

# Compares if both the bits are not 2
BitwiseNandCondition<internal>(A:int, B:int)<computes><decides>:void = {
    A + B <> 2
}

# Compares if both the bits are 0
BitwiseNorCondition<internal>(A:int, B:int)<computes><decides>:void = {
    A + B = 0
}

# Compares if both bits are equal
BitwiseXnorCondition<internal>(A:int, B:int)<computes><decides>:void = {
    A = B
}

# Performs Bitwise AND operation between two integers
BitwiseAnd<public>(A:int, B:int)<transacts>:int = {
    # Early return optimization for Zero Values
    if (A = 0 or B = 0). return 0

    return BitwiseBaseHandler(A, B, BitwiseAndCondition)
}

# Performs Bitwise OR operation between two integers
BitwiseOr<public>(A:int, B:int)<transacts>:int = {
    # Early return optimization for Zero Values
    if (A = 0). return B
    if (B = 0). return A

    return BitwiseBaseHandler(A, B, BitwiseOrCondition)
}

# Performs Bitwise XOR operation between two integers
BitwiseXor<public>(A:int, B:int)<transacts>:int = {
    # Early return optimization for Zero and Equal Values
    if (A = B). return 0
    if (A = 0). return B
    if (B = 0). return A

    return BitwiseBaseHandler(A, B, BitwiseXorCondition)
}

# Performs Bitwise NOT operation on an integer
BitwiseNot<public>(Value:int)<transacts>:int = {
    # Get the minimum Bit Width needed to represent the Value
    BitWidth := GetBitWidth(Value)

    # Ensure the values is represented as positive for the operation
    var UnsignedValue : int = ToPositiveRepresentation(Value, BitWidth)

    var Result : int = 0
    var BitPosition : int = 1

    for (Index := 0..BitWidth - 1) {
        Bit := Mod[UnsignedValue, 2] or Err("Unreachable")

        # Compute the Bitwise OR Condition for the current bit
        if (BitwiseNotCondition[Bit]) {
            set Result += BitPosition
        }

        set BitPosition *= 2
        set UnsignedValue = Quotient[UnsignedValue, 2] or Err("Unreachable")
    }

    # Convert back to signed representation if needed
    return FromPositiveRepresentation(Result, BitWidth)
}

# Performs Bitwise NAND operation between two integers
BitwiseNand<public>(A:int, B:int)<transacts>:int = {
    return BitwiseBaseHandler(A, B, BitwiseNandCondition)
}

# Performs Bitwise NOR operation between two integers
BitwiseNor<public>(A:int, B:int)<transacts>:int = {
    # Early return optimization for Zero Values
    if (A = 0 and B = 0). return -1 # BitwiseNot(0)

    return BitwiseBaseHandler(A, B, BitwiseNorCondition)
}

# Performs Bitwise XNOR operation between two integers
BitwiseXnor<public>(A:int, B:int)<transacts>:int = {
    # Early return optimization for Equal Values
    if (A = B). return -1 # BitwiseNot(0)

    return BitwiseBaseHandler(A, B, BitwiseXnorCondition)
}