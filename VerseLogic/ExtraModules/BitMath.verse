using. MathFeatures

BitMath<public> := module {

    BitwiseAndCondition<internal>(A:int, B:int)<transacts><decides>:void = A = 1 and B = 1
    BitwiseOrCondition<internal>(A:int, B:int)<transacts><decides>:void = A = 1 or B = 1
    BitwiseXorCondition<internal>(A:int, B:int)<transacts><decides>:void = Mod[A + B, 2] = 1

    BitwiseBaseHandler<internal>(InputA:int, InputB:int, BitwiseCondition:type{_(:int, :int)<transacts><decides>:void})<transacts>:int = {

        MaxInt := Round[Pow(2.0, 32.0)] or Err("Unreachable")

        # Handles negative numbers
        var A : int = if (InputA < 0). MaxInt + InputA else InputA
        var B : int = if (InputB < 0). MaxInt + InputB else InputB

        var Result : int = 0
        var BitPosition : int = 1

        for (_Index := 0..31) {
            BitA := Mod[A, 2] or Err("Unreachable")
            BitB := Mod[B, 2] or Err("Unreachable")

            # Checks the bitwise condition
            if (BitwiseCondition[BitA, BitB]). set Result += BitPosition

            set BitPosition *= 2

            set A = Floor[A / 2.0] or Err("Unreachable")
            set B = Floor[B / 2.0] or Err("Unreachable")
        }
    
        # Convert back to signed if needed
        if (Result * 1.0 >= MaxInt / 2.0). Result - MaxInt else Result
        
    }

    BitwiseAnd<public>(InputA:int, InputB:int)<transacts>:int = {
        BitwiseBaseHandler(InputA, InputB, BitwiseAndCondition)
    }

    BitwiseOr<public>(InputA:int, InputB:int)<transacts>:int = {
        BitwiseBaseHandler(InputA, InputB, BitwiseOrCondition)
    }

    BitwiseXor<public>(InputA:int, InputB:int)<transacts>:int = {
        BitwiseBaseHandler(InputA, InputB, BitwiseXorCondition)
    }

    BitwiseNot<public>(InputX:int)<transacts>:int = {

        MaxInt := Round[Pow(2.0, 32.0)] or Err("Unreachable")

        # Handles negative numbers
        X := if (InputX < 0). MaxInt + InputX else InputX

        Result := (MaxInt - 1) - X

        # Convert back to signed if needed
        if (Result * 1.0 >= MaxInt / 2.0). Result - MaxInt else Result
    }

    LeftShift<public>(Input:int, Positions:int)<transacts>:int = { # <<
        Input * Round[Pow(2.0, Abs(Positions) * 1.0)] or Err("Unreachable")
    }

    # Arithmetic
    RightShift<public>(Input:int, Positions:int)<transacts>:int = { # >>
        Floor(Input / Round[Pow(2.0, Abs(Positions) * 1.0)]) or Err("Unreachable")
    }

    LogicalRightShift<public>(InputX:int, Positions:int)<transacts>:int = { # >>>

        # Handles negative numbers
        X := if (InputX < 0). Floor[InputX + Pow(2.0, 32.0)] or Err("Unreachable") else InputX

        Floor(X / Round[Pow(2.0, Abs(Positions) * 1.0)]) or Err("Unreachable")
    }
}