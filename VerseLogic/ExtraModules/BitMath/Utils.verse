# Determines the minimum bit width needed to represent the given integer value
# by using Two's Complement representation
# WARNING: Due to Logarithm limitations, this function may not work correctly
# for values larger than 2^63 (Close to or Above the 64 Bit Integer Limit)
GetBitWidth<public>(Value:int)<computes><reads>:int = {
    # Optimization for Zero and -1 values
    if (Value = 0 or Value = -1). return 1
    
    # For negative numbers, we measure the magnitude of (Value + 1)
    # This handles the two's complement asymmetry
    Target := Value < 0 and Abs(Value + 1) or Value

    # Int(Log2(Target)) + 1 gives magnitude bits. 
    # We add +1 again for the mandatory sign bit.
    Log2[Target] + 2 or Err("Unreachable")
}

# Determines the minimum bit width needed to represent both values safely
GetCommonBitWidth<public>(A:int, B:int)<computes><reads>:int = {
    # Optimization for Zero and -1 values
    if ((A = 0 or A = -1) and (B = 0 or B = -1)). return 1

    # If one is Zero or -1, just calculate for the other
    if (A = 0 or A = -1). return GetBitWidth(B)
    if (B = 0 or B = -1). return GetBitWidth(A)

    # Calculate bit width needed for each number individually
    WidthA := GetBitWidth(A)
    WidthB := GetBitWidth(B)

    # Return the maximum of the two
    Max(WidthA, WidthB)
}

# Succeeds if the given integer value is a power of two
IsPowerOfTwo<public>(Value:int)<computes><decides><reads>:void = {
    Value > 0

    # If it is a power of two, it MUST be 2 raised to (BitWidth - 2)
    # We subtract 2 because GetBitWidth includes the sign bit and uses 1-based counting
    Exponent := GetBitWidth(Value) - 2

    # Verify by reconstructon
    ReconstructedValue := PowerOfTwo[Exponent] or Err("Unreachable")

    Value = ReconstructedValue
}

# Computes the integer power of two for the given exponent
# Fails if the exponent is negative
PowerOfTwo<public>(Exponent:int)<computes><decides><reads>:int = {
    Exponent >= 0

    # Adding 0.5 ensures that values like 255.999999... rounds
    # up to 256 instead of truncating down to 255.
    Int[Pow(2.0, Exponent * 1.0) + 0.5] or Err("Unreachable")
}

# Computes the base-2 logarithm for a given integer
# Fails if the input zero or negative
Log2<public>(Value:int)<computes><decides><reads>:int = {
    Value > 0

    Int[Log(2.0, Value * 1.0)] or Err("Unreachable")
}

# Converts the given signed integer to its positive unsigned representation based on the specified bit width
# Fails if the given bit width is negative
ToPositiveRepresentation<internal>(Value:int, BitWidth:int)<computes><decides><reads>:int = {
    BitWidth >= 0

    # If the value is already positive, does not need to convert
    # Value >= 0 and Value or (
    #     # for negative values, compute the two's complement positive representation
    #     MaxValue := PowerOfTwo[BitWidth] or Err("Unreachable")

    #     # adding the negative value to the max value gives the positive representation
    #     MaxValue + Value
    # )

    Limit := PowerOfTwo[BitWidth] or Err("Unreachable")
    Result := Mod[Value, Limit] or Err("Unreachable")
    (Result < 0) + Limit or Result
}

# Converts the given unsigned integer back to its signed integer representation based on the specified bit width
# Fails if the given bit width is negative
FromPositiveRepresentation<internal>(Value:int, BitWidth:int)<computes><decides><reads>:int = {
    BitWidth >= 0

    MaxValue := PowerOfTwo[BitWidth] or Err("Unreachable")
    HalfMax := Quotient[MaxValue, 2] or Err("Unreachable")
    
    # If the value is in the upper half, it represents a negative number in two's complement
    Value >= HalfMax and Value - MaxValue or Value
}

# Succeeds if the bit at the specified position is set (1)
# Fails if the given position is negative
IsBitSet<public>(Value:int, Position:int)<computes><decides><reads>:void = {
    Position >= 0

    # Position 0 is the 1s place, Position 1 is the 2s place, etc.
    Divisor := PowerOfTwo[Position]
    
    # Shift the bit to the 1s place and check if it's odd
    BitValue := Mod[Floor(Value / Divisor), 2] or Err("Unreachable")

    BitValue = 1
}

# Internal function to write a specific bit with an option to skip bit check
# SkipBitCheck is to avoid redundant checks when already knowing it
# Fails if the given position is negative
WriteBitInternal<internal>(Value:int, Position:int, State:logic, SkipBitCheck:logic)<computes><decides><reads>:int = {
    Position >= 0

    not SkipBitCheck? and logic{IsBitSet[Value, Position]} = State and Value or (
        Modifier := PowerOfTwo[Position] or Err("Unreachable")
        Value + (State? and Modifier or -Modifier)
    )
}

# Writes a specific bit position to the given state
# Fails if the given position is negative
WriteBit<public>(Value:int, Position:int, State:logic)<computes><decides><reads>:int = {
    Position >= 0

    WriteBitInternal[Value, Position, State, false] or Err("Unreachable")
}

# Sets a specific bit position to 1
# Fails if the given position is negative
SetBit<public>(Value:int, Position:int)<computes><decides><reads>:int = {
    Position >= 0

    WriteBitInternal[Value, Position, true, false] or Err("Unreachable")
}

# Clears a specific bit position to 0
# Fails if the given position is negative
ClearBit<public>(Value:int, Position:int)<computes><decides><reads>:int = {
    Position >= 0

    WriteBitInternal[Value, Position, false, false] or Err("Unreachable")
}

# Flips the bit at the specified position (0 -> 1 or 1 -> 0)
# Fails if the given position is negative
ToggleBit<public>(Value:int, Position:int)<computes><decides><reads>:int = {
    Position >= 0

    # Gets the current bit state and flips it
    OppositeState := logic{not IsBitSet[Value, Position]}

    WriteBitInternal[Value, Position, OppositeState, true] or Err("Unreachable")
}