# Determines the minimum bit width needed to represent the given integer value
GetBitWidth<public>(Value:int)<computes><reads>:int = {
    # Optimization for Zero values
    if (Value = 0). return 1
    
    # Special case for -1, which requires 2 bits (0b11) in signed representation
    if (Value = -1). return 2

    AbsValue := Abs(Value)

    # +1 for positive numbers to account for the sign bit
    CorrectedAbsValue := Value < 0 and AbsValue or AbsValue + 1

    # Calculate the bit width using logarithm base 2
    return Ceil[Log(2.0, CorrectedAbsValue * 1.0)] + 1 or Err("Unreachable")
}

# Determines the minimum bit width needed to represent both numbers
GetBitWidth<public>(A:int, B:int)<computes><reads>:int = {
    # Early return optimization for Zero values
    if (A = 0 and B = 0). return 1

    # If one is zero, just calculate for the other
    if (A = 0). return GetBitWidth(B)
    if (B = 0). return GetBitWidth(A)

    # Calculate bit width needed for each number individually
    WidthA := GetBitWidth(A)
    WidthB := GetBitWidth(B)

    # Return the maximum of the two
    return Max(WidthA, WidthB)
}

# Succeeds if the given integer value is a power of two
IsPowerOfTwo<public>(Value:int)<decides><transacts>:void = {
    # Zero and negative numbers are not powers of two
    Value > 0

    var Result : logic = false

    var Temp : int = Value
    loop {
        if (Temp <= 1) {
            # Successfully reduced to 1, so it's a power of two
            set Result = true
            break
        }
        # If is not divisible by 2, then is not a power of two
        if (Mod[Temp, 2] <> 0). break
        set Temp = Quotient[Temp, 2] or Err("Unreachable")
    }

    Result?
}

# Converts the given signed integer to its positive representation based on the specified bit width
ToPositiveRepresentation<internal>(Value:int, BitWidth:int)<computes><reads>:int = {
    # If the value is already positive, does not need to convert
    if (Value >= 0). return Value

    # for negative values, compute the two's complement positive representation
    MaxValue := Int[Pow(2.0, BitWidth * 1.0)] or Err("Unreachable")

    # adding the negative value to the max value gives the positive representation
    return MaxValue + Value
}

# Converts the given unsigned integer back to its signed integer representation based on the specified bit width
FromPositiveRepresentation<internal>(Value:int, BitWidth:int)<computes><reads>:int = {
    MaxValue := Int[Pow(2.0, BitWidth * 1.0)] or Err("Unreachable")

    HalfMax := Quotient[MaxValue, 2] or Err("Unreachable")

    # If the value is in the upper half, it represents a negative number in two's complement
    if (Value >= HalfMax). return Value - MaxValue

    return Value
}