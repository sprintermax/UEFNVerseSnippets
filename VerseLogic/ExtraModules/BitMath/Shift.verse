# Simulates an Left Shift
# Left Shift is always both Arithmetic and Logical, no distinction needed
# Equivalent to << Positions
BitwiseLeftShift<public>(Value:int, Positions:int)<computes><reads>:int = {
    if (Positions = 0). return Value
    if (Positions < 0). return BitwiseRightShift(Value, -Positions)

    # Calculate the multiplier as 2 raised to the number of positions
    Multiplier := PowerOfTwo[Positions] or Err("Unreachable")

    return Value * Multiplier
}

# Simulates an Arithmetic Right Shift
# It preserves the sign bit for negative numbers
# Equivalent to >> Positions
BitwiseRightShift<public>(Value:int, Positions:int)<computes><reads>:int = {
    if (Positions = 0). return Value
    if (Positions < 0). return BitwiseLeftShift(Value, -Positions)

    # # Calculate the divisor as 2 raised to the number of positions
    Divisor := PowerOfTwo[Positions] or Err("Unreachable")

    return Quotient[Value, Divisor] or Err("Unreachable")

    # if (Value >= 0). return Quotient[Value, Divisor] or Err("Unreachable")

    # # For negative values, use floor division to preserve the sign
    # return Floor(Value / Divisor) or Err("Unreachable")
}

# Simulates a Logical Right Shift
# It fills the leftmost bits with zeros regardless of the sign
# Equivalent to >>> Positions
BitwiseLogicalRightShift<public>(Value:int, Positions:int)<transacts>:int = {
    if (Positions = 0). return Value
    if (Positions < 0). return BitwiseLeftShift(Value, -Positions)
    
    # For positive values, logical and arithmetic right shifts are the same
    if (Value >= 0). return BitwiseRightShift(Value, Positions)

    # For negative values, use standard 8-bit width unless larger is needed
    BitWidth := Abs(Value) < 128 and 8 or GetBitWidth(Value)

    # Ensure the values is represented as positive for the operation
    UnsignedValue := ToPositiveRepresentation[Value, BitWidth] or Err("Unreachable")

    # Calculate the divisor as 2 raised to the number of positions
    Divisor := PowerOfTwo[Positions] or Err("Unreachable")

    return Quotient[UnsignedValue, Divisor] or Err("Unreachable")
}

# Performs a left circular rotation on bits
# Optional explicit bit count is required for some specific usages
# such as crypto algorithms (Like MD5 that uses 32-bit rotations)
# If not provided or negative, the function will auto-calculate the minimum needed bits.
LeftRotate<public>(Value:int, Positions:int, ?BitCount:?int = false)<computes><reads>:int = {
    if (Value = 0). return 0
    
    # 1. Determine bit width
    BitWidth := BitCount? >= 0 or GetBitWidth(Value)
    if (BitWidth = 0). return Value
    
    # 2. Normalize rotation and handle the 0-case early
    Rotation := Mod[Positions, BitWidth] or Err("Unreachable")
    if (Rotation = 0). return Value

    # 3. Get the Unsigned pattern
    UnsignedValue := ToPositiveRepresentation[Value, BitWidth] or Err("Unreachable")
    
    # 4. Arithmetic Rotation logic
    # We need 2^Rotation and 2^Width
    ShiftMultiplier := PowerOfTwo[Rotation] or Err("Unreachable")
    FullBoundary := PowerOfTwo[BitWidth] or Err("Unreachable")
    
    # Left part: Shift left and mask out bits that exceed BitWidth
    # Right part: Shift right to grab the bits that overflowed
    # RightShiftDivisor is FullBoundary / ShiftMultiplier
    LeftPart := Mod[UnsignedValue * ShiftMultiplier, FullBoundary] or Err("Unreachable")
    RightPart := Quotient[UnsignedValue, Quotient[FullBoundary, ShiftMultiplier]] or Err("Unreachable")
    
    # 5. Combine and return to signed
    return FromPositiveRepresentation[LeftPart + RightPart, BitWidth] or Err("Unreachable")
}

# (Old Approach - Slower)
# LeftRotate<public>(Value:int, Positions:int, ?BitCount:?int = false)<transacts>:int = {
#     # Optimization for Zero value
#     if (Value = 0). return 0
    
#     # Determine bit width: explicit or auto-calculated
#     BitWidth := BitCount? or GetBitWidth(Value)

#     if (BitWidth = 0). return Value
    
#     # Ensure value is represented as positive for the operation
#     UnsignedValue := ToPositiveRepresentation(Value, BitWidth)
    
#     # Normalize rotation amount to be within bit width
#     NormalizedRotation := Mod[Positions, BitWidth] or Err("Unreachable")
    
#     # If rotation is 0, return original value
#     if (NormalizedRotation = 0). return Value

#     # Calculate the modulus as 2 raised to the bit width
#     var Modulus : int = 1
#     for (Index := 0..BitWidth - 1) {
#         set Modulus *= 2
#     }

#     # WIP: Compare Performance with Pow function Instead of Loop
#     # Modulus := PowerOfTwo[BitWidth] or Err("Unreachable")
    
#     # Calculate 2^NormalizedRotation for left shift
#     var LeftShiftMultiplier : int = 1
#     for (Index := 0..NormalizedRotation - 1) {
#         set LeftShiftMultiplier *= 2
#     }

#     # WIP: Compare Performance with Pow function Instead of Loop
#     # LeftShiftMultiplier := PowerOfTwo[NormalizedRotation] or Err("Unreachable")
    
#     # Calculate 2^(BitWidth - NormalizedRotation) for right shift
#     var RightShiftDivisor : int = 1
#     for (Index := 0..(BitWidth - NormalizedRotation) - 1) {
#         set RightShiftDivisor *= 2
#     }

#     # WIP: Compare Performance with Pow function Instead of Loop
#     # RightShiftDivisor := PowerOfTwo[BitWidth - NormalizedRotation] or Err("Unreachable")
    
#     # Left part: shift left by rotation amount
#     LeftPart := Mod[UnsignedValue * LeftShiftMultiplier, Modulus] or Err("Unreachable")
    
#     # Right part: bits that wrapped around
#     RightPart := Quotient[UnsignedValue, RightShiftDivisor] or Err("Unreachable")
    
#     # Combine both parts
#     Result := Mod[LeftPart + RightPart, Modulus] or Err("Unreachable")
    
#     # Convert back to signed representation if needed
#     return FromPositiveRepresentation(Result, BitWidth)
# }


# Performs a right circular rotation on bits
# Right Rotation is just Left Rotation by -Positions
# Optional explicit bit count is required for some specific usages
# such as crypto algorithms (Like MD5 that uses 32-bit rotations)
# If not provided or negative, the function will auto-calculate the minimum needed bits.
RightRotate<public>(Value:int, Positions:int, ?BitCount:?int = false)<computes><reads>:int = {
    return LeftRotate(Value, -Positions, ?BitCount := BitCount)
}

# (Old Approach - Slower)
# Performs a right circular rotation on bits
# Optional explicit bit width. If not provided, auto-calculates minimum needed bits.
# RightRotate<public>(Value:int, Positions:int, ?BitCount:?int = false)<transacts>:int = {
#     if (Value = 0). return 0
    
#     # Determine bit width: explicit or auto-calculated
#     BitWidth := BitCount? or GetBitWidth(Value)

#     if (BitWidth = 0). return Value
    
#     return LeftRotate(Value, BitWidth - Mod[Positions, BitWidth], ?BitCount := BitCount) or Err("Unreachable")
# }

# Aliases for operator style usage (can't be like `operator'&'` due to verse limitations)
_'<<'(Value:int, Positions:int)<transacts>:void = BitwiseLeftShift(Value, Positions)
_'>>'(Value:int, Positions:int)<transacts>:void = BitwiseRightShift(Value, Positions)
_'>>>'(Value:int, Positions:int)<transacts>:void = BitwiseLogicalRightShift(Value, Positions)
(Value:int)._'<<'<public>(Positions:int)<transacts>:int = BitwiseLeftShift(Value, Positions)
(Value:int)._'>>'<public>(Positions:int)<transacts>:int = BitwiseRightShift(Value, Positions)
(Value:int)._'>>>'<public>(Positions:int)<transacts>:int = BitwiseLogicalRightShift(Value, Positions)