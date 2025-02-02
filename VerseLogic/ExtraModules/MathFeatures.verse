using. /UnrealEngine.com/Temporary/SpatialMath
using. /Verse.org/Random

using. UnrealEngineFeatures

MathFeatures<public> := module {
    operator'+'<public>(I:int, F:float)<transacts>:float = I * 1.0 + F
    operator'+'<public>(F:float, I:int)<transacts>:float = F + I * 1.0
    operator'-'<public>(I:int, F:float)<transacts>:float = I * 1.0 - F
    operator'-'<public>(F:float, I:int)<transacts>:float = F - I * 1.0
    operator'/'<public>(I:int, F:float)<transacts>:float = I * 1.0 / F
    operator'/'<public>(F:float, I:int)<transacts>:float = F / (I * 1.0)

    # Disabled because compiler shows as reserved identifiers
    # operator'>'<public>(I:int, F:float)<transacts><decides>:int = I > F
    # operator'>'<public>(F:float, I:int)<transacts><decides>:float = F > I
    # operator'<'<public>(I:int, F:float)<transacts><decides>:int = I < F
    # operator'<'<public>(F:float, I:int)<transacts><decides>:float = F < I

    # operator'<>'<public>(I:int, F:float)<transacts><decides>:int = { I * 1.0 <> F; I }
    # operator'<>'<public>(F:float, I:int)<transacts><decides>:float = { F <> I * 1.0 }

    # operator'='<public>(I:int, F:float)<transacts><decides>:int = { I * 1.0 = F; I }
    # operator'='<public>(F:float, I:int)<transacts><decides>:float = { F = I * 1.0 }

    zero_to_one_float<public> := type{_X:float where 0.0 <= _X, _X <= 1.0}

    RemapValueRange<public>(FromLow:float, FromHigh:float, ToLow:float, ToHigh:float, Value:float)<transacts>:float = {
        return ToLow + (Value - FromLow) * (ToHigh - ToLow) / (FromHigh - FromLow)
    }

    (Value:int).ToFloat<public>()<transacts>:float = Value * 1.0

    RoundDecimals<public>(Input:float, Decimals:int)<transacts><decides>:float = {
        Factor := Pow(10.0, Decimals * 1.0)
        
        Rounded := Round[Input * Factor]
        return (Rounded * 1.0) / Factor
    }

    FloorDecimals<public>(Input:float, Decimals:int)<transacts><decides>:float = {
        Factor := Pow(10.0, Decimals * 1.0)

        Rounded := Floor[Input * Factor]
        return (Rounded * 1.0) / Factor
    }

    CeilDecimals<public>(Input:float, Decimals:int)<transacts><decides>: float = {
        Factor := Pow(10.0, Decimals * 1.0)
        
        Rounded := Ceil[Input * Factor]
        return (Rounded * 1.0) / Factor
    }

    TruncateFloatToString<public>(Input:float, Decimals:int)<transacts><decides>:[]char = {
        var String:[]char = ToString(Input)

        DotIndex := String.Find['.']
        StopIndex := if (Decimals > 0) { Min(DotIndex+Decimals+1,String.Length) } else { DotIndex }

        return String.Slice[0, StopIndex]
    }

    ### RNGs

    SeedRandom<public>(Seed:int)<transacts>:float = {
        X := Sin(Seed * 1.0) * 10000.0
        X - Floor[X] * 1.0 or 0.0
    }

    (InputArray:[]t).Shuffle<public>(Seed:int where t : type)<transacts>: []t = {
        var ShuffledArray : []t = InputArray
        var _Seed : int = Seed
        
        for (X := 0..ShuffledArray.Length - 1) {

            I := ShuffledArray.Length - X
            J := Floor[SeedRandom(_Seed) * (I + 1)] or I

            option{
                PrevValue := ShuffledArray[I]
                SwapValue := ShuffledArray[J]
                set ShuffledArray[I] = SwapValue
                set ShuffledArray[J] = PrevValue
            }

            set _Seed = Mod[_Seed * 9301 + 49297, 233280] or _Seed
        }

        ShuffledArray
    }

    # Never needed to use this, should work but is untested
    seedable_rng := class {
        var<private> Seed<public> : int = -1
        Multiplier<public> : int = 1664525
        Increment<public> : int = 1013904223
        Modulo<public> : int = Constants.Max32BitInt

        Init(NewSeed:int)<transacts>: void = {
            set Seed = NewSeed
        }

        NextInt()<transacts> : int = {
            option {
                NewValue := Mod[Multiplier * Seed + Increment, Modulo]
                set Seed = NewValue
            }
            Seed
        }

        NextIntRange(ValueMin:int, ValueMax:int)<transacts> : int = {
            ValueMin + (Mod[NextInt(), (ValueMax - ValueMin + 1)]) or 0
        }
    }

    # Returns a random element by considering priority weight over others (Weight, ChoiceData)
    # (Untested with Negative and Zero weight values)
    GetRandomByWeights<public>(Choices:[]tuple(int, t) where t : type)<transacts><decides>:t = {
        var TotalWeight : int = 0

        for (Choice : Choices). set TotalWeight += Choice(0)

        var AccumulatedWeight : int = 0
        var MaybeSelectedChoice : ?t = false

        for (ChoiceIndex->Choice : Shuffle(Choices), not MaybeSelectedChoice?) {
            set AccumulatedWeight += Choice(0)
            if (GetRandomInt(0, TotalWeight) < AccumulatedWeight) {
                set MaybeSelectedChoice = option{Choice(1)}
            }
        }

        MaybeSelectedChoice?
    }

    # Returns (Current Index, Progress to Next Index)
    GetIterationIndex<public>(TotalProgress:float, StepSize:float)<transacts>:tuple(int,float) = {
        IterationIndex := Floor[TotalProgress / StepSize] or 0
        StepProgress := TotalProgress - IterationIndex * StepSize

        (IterationIndex, StepProgress)
    }

    <#
        Seems to be broken, the verse functions and creative devices are supposed to allow up to 32bit ints and 64bit floats, but
        it doesn't seem to support some ranges, completely breaking the result value by repeating the previous number or behaving
        completely weird with positive/negative signs and decimals. I avoid going over 32bit ints and floats values due to this.
    #>
    Constants<public> := module {
        Min32BitInt<public> : int = -2147483648 # Round[Pow(-2.0, 31.0)] or Err("Unreachable")
        Max32BitInt<public> : int = 2147483647 # Round[Pow(2.0, 31.0)] - 1 or Err("Unreachable")
        Min64BitInt<public> : int = -9223372036854775808 # Round[Pow(-2.0, 63.0)] or Err("Unreachable")
        Max64BitInt<public> : int = 9223372036854775807 # Round[Pow(2.0, 63.0)] - 1 or Err("Unreachable")
        # Min64BitFloat<public>()<transacts> : float = Pow(2.0, -1022.0)
        # Max64BitFloat<public>()<transacts> : float = (1.0 + (Pow(2.0, 52.0) - 1.0) / Pow(2.0, 52.0)) * Pow(2.0, 1023.0)
    }
    GetRandomInt<public>() : int = GetRandomInt(Constants.Min32BitInt, Constants.Max32BitInt)
    GetRandomFloat<public>() : float = GetRandomFloat(Constants.Min32BitInt * 1.0, Constants.Max32BitInt * 1.0)

    EasingFunctions<public> := module {

        easing_mode<public> := enum {
            Linear
            InSine
            OutSine
            InOutSine
            InQuad
            OutQuad
            InOutQuad
            InCubic
            OutCubic
            InOutCubic
            InQuart
            OutQuart
            InOutQuart
            InQuint
            OutQuint
            InOutQuint
            InExpo
            OutExpo
            InOutExpo
            InCirc
            OutCirc
            InOutCirc
            InBack
            OutBack
            InOutBack
            InElastic
            OutElastic
            InOutElastic
            InBounce
            OutBounce
            InOutBounce
        }

        (EasingMode:easing_mode).Evaluate<public>(Value:float):float = {
            case (EasingMode) {
                easing_mode.Linear => Value
                easing_mode.InSine => EaseInSine(Value)
                easing_mode.OutSine => EaseOutSine(Value)
                easing_mode.InOutSine => EaseInOutSine(Value)
                easing_mode.InQuad => EaseInQuad(Value)
                easing_mode.OutQuad => EaseOutQuad(Value)
                easing_mode.InOutQuad => EaseInOutQuad(Value)
                easing_mode.InCubic => EaseInCubic(Value)
                easing_mode.OutCubic => EaseOutCubic(Value)
                easing_mode.InOutCubic => EaseInOutCubic(Value)
                easing_mode.InQuart => EaseInQuart(Value)
                easing_mode.OutQuart => EaseOutQuart(Value)
                easing_mode.InOutQuart => EaseInOutQuart(Value)
                easing_mode.InQuint => EaseInQuint(Value)
                easing_mode.OutQuint => EaseOutQuint(Value)
                easing_mode.InOutQuint => EaseInOutQuint(Value)
                easing_mode.InExpo => EaseInExpo(Value)
                easing_mode.OutExpo => EaseOutExpo(Value)
                easing_mode.InOutExpo => EaseInOutExpo(Value)
                easing_mode.InCirc => EaseInCirc(Value)
                easing_mode.OutCirc => EaseOutCirc(Value)
                easing_mode.InOutCirc => EaseInOutCirc(Value)
                easing_mode.InBack => EaseInBack(Value)
                easing_mode.OutBack => EaseOutBack(Value)
                easing_mode.InOutBack => EaseInOutBack(Value)
                easing_mode.InElastic => EaseInElastic(Value)
                easing_mode.OutElastic => EaseOutElastic(Value)
                easing_mode.InOutElastic => EaseInOutElastic(Value)
                easing_mode.InBounce => EaseInBounce(Value)
                easing_mode.OutBounce => EaseOutBounce(Value)
                easing_mode.InOutBounce => EaseInOutBounce(Value)
            }
        }

        EaseInSine<public>(Value:float):float = {
            1 - Cos((Value * PiFloat) / 2)
        }
        EaseOutSine<public>(Value:float):float = {
            Sin((Value * PiFloat) / 2)
        }
        EaseInOutSine<public>(Value:float):float = {
            -(Cos(PiFloat * Value) - 1) / 2
        }
        
        EaseInQuad<public>(Value:float):float = {
            Value * Value
        }
        EaseOutQuad<public>(Value:float):float = {
            1- (1 - Value) * (1 - Value)
        }
        EaseInOutQuad<public>(Value:float):float = {
            if (Value < 0.5) {
                2 * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 2.0) / 2
            }
        }

        EaseInCubic<public>(Value:float):float = {
            Value * Value * Value
        }
        EaseOutCubic<public>(Value:float):float = {
            1 - Pow(1 - Value, 3.0)
        }
        EaseInOutCubic<public>(Value:float):float = {
            if (Value < 0.5) {
                4 * Value * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 3.0) / 2
            }
        }

        EaseInQuart<public>(Value:float):float = {
            Value * Value * Value * Value
        }
        EaseOutQuart<public>(Value:float):float = {
            1 - Pow(1 - Value, 4.0)
        }
        EaseInOutQuart<public>(Value:float):float = {
            if (Value < 0.5) {
                8 * Value * Value * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 4.0) / 2
            }
        }

        EaseInQuint<public>(Value:float):float = {
            Value * Value * Value * Value * Value
        }
        EaseOutQuint<public>(Value:float):float = {
            1 - Pow(1 - Value, 5.0)
        }
        EaseInOutQuint<public>(Value:float):float = {
            if (Value < 0.5) {
                16 * Value * Value * Value * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 5.0) / 2
            }
        }

        EaseInExpo<public>(Value:float):float = {
            if (Value = 0.0) {
                0.0
            } else {
                Pow(2.0, 10 * Value - 10)
            }
        }
        EaseOutExpo<public>(Value:float):float = {
            if (Value = 1.0) {
                1.0
            } else {
                1 - Pow(2.0, -10 * Value)
            }
        }
        EaseInOutExpo<public>(Value:float):float = {
            if (Value = 0.0) {
                0.0
            } else if (Value = 1.0) {
                1.0
            } else if (Value < 0.5) {
                Pow(2.0, 20 * Value - 10) / 2
            } else {
                (2 - Pow(2.0, -20 * Value + 10)) / 2
            }
        }

        EaseInCirc<public>(Value:float):float = {
            1 - Sqrt(1 - Pow(Value, 2.0))
        }
        EaseOutCirc<public>(Value:float):float = {
            Sqrt(1 - Pow(Value - 1, 2.0))
        }
        EaseInOutCirc<public>(Value:float):float = {
            if (Value < 0.5) {
                (1 - Sqrt(1 - Pow(2 * Value, 2.0))) / 2
            } else {
                (Sqrt( 1 - Pow(-2 * Value + 2, 2.0)) + 1) / 2
            }
        }

        EaseInBack<public>(Value:float):float = {
            Constant := 1.70158
            Constant2 := Constant + 1

            Constant2 * Value * Value * Value - Constant * Value * Value
        }
        EaseOutBack<public>(Value:float):float = {
            Constant := 1.70158
            Constant2 := Constant + 1

            1 + Constant2 * Pow(Value -1, 3.0) + Constant * Pow(Value - 1, 2.0)
        }
        EaseInOutBack<public>(Value:float):float = {
            Constant := 1.70158
            Constant2 := Constant + 1.525

            if (Value < 0.5) {
                (Pow(2 * Value, 2.0) * ((Constant2 + 1) * 2 * Value - Constant2)) / 2
            } else {
                (Pow(2 * Value - 2, 2.0) * ((Constant2 + 1) * (Value * 2 - 2) + Constant2) + 2) / 2
            }
        }
        
        EaseInElastic<public>(Value:float):float = {
            Constant := (2 * PiFloat) / 3

            if (Value = 0.0) {
                0.0
            } else if (Value = 1.0) {
                1.0
            } else {
                -Pow(2.0, 10 * Value - 10) * Sin((Value * 10 - 10.75) * Constant)
            }
        }
        EaseOutElastic<public>(Value:float):float = {
            Constant := (2 * PiFloat) / 3

            if (Value = 0.0) {
                0.0
            } else if (Value = 1.0) {
                1.0
            } else {
                Pow(2.0, -10 * Value) * Sin((Value * 10 - 0.75) * Constant) + 1
            }
        }
        EaseInOutElastic<public>(Value:float):float = {
            Constant := (2 * PiFloat) / 4.5

            if (Value = 0.0) {
                0.0
            } else if (Value = 1.0) {
                1.0
            } else if (Value < 0.5) {
                -Pow(2.0, 20 * Value - 10) * Sin((20 * Value - 11.125) * Constant) / 2
            } else {
                (Pow(2.0, -20 * Value + 10) * Sin((20 * Value - 11.125) * Constant)) / 2 + 1
            }
        }
        
        EaseInBounce<public>(Value:float):float = {
            1 - EaseOutBounce(1 - Value)
        }
        EaseOutBounce<public>(Value:float):float = {
            Constant1 := 7.5625
            Constant2 := 2.75

            if (Value < 1 / Constant2) {
                Constant1 * Value * Value
            } else if (Value < 2 / Constant2) {
                Constant1 * (Value - 1.5 / Constant2) * Value + 0.75
            } else if ( Value < 2.5 / Constant2) {
                Constant1 * (Value - 2.25 / Constant2) * Value + 0.9375
            } else {
                Constant1 * (Value - 2.625 / Constant2) * Value + 0.984375
            }
        }
        EaseInOutBounce<public>(Value:float):float = {
            if (Value < 0.5) {
                (1 - EaseOutBounce(1 - 2 * Value)) / 2
            } else {
                ( 1 + EaseOutBounce(2 * Value - 1)) / 2
            }
        }
    }

    # Obsolete, use RotateAroundAnchor methods instead
    # (Point:vector3).RotateAround<public>(Anchor:vector3, Axis:vector3, AngleRadians:float)<transacts> : vector3 = {
    #     TranslatedPoint := Point - Anchor
    #     TranslatedPoint.RotateAngleAxis(AngleRadians, Axis) + Anchor
    # }

    # (Pos:vector3).RotateAngleAxis<public>(AngleRadians:float, Axis:vector3)<transacts> : vector3 = {

    #     SinVal := Sin(AngleRadians)
    #     CosVal := Cos(AngleRadians)

    #     AxisXX := Pow(Axis.X, 2.0)
    #     AxisYY := Pow(Axis.Y, 2.0)
    #     AxisZZ := Pow(Axis.Z, 2.0)

    #     AxisXY := Axis.X * Axis.Y
    #     AxisYZ := Axis.Y * Axis.Z
    #     AxisZX := Axis.Z * Axis.X

    #     AxisXS := Axis.X * SinVal
    #     AxisYS := Axis.Y * SinVal
    #     AxisZS := Axis.Z * SinVal

    #     OMC := 1.0 - CosVal

    #     vector3{
    #         X := (OMC * AxisXX + CosVal) * Pos.X + (OMC * AxisXY - AxisZS) * Pos.Y + (OMC * AxisZX + AxisYS) * Pos.Z
    #         Y := (OMC * AxisXY + AxisZS) * Pos.X + (OMC * AxisYY + CosVal) * Pos.Y + (OMC * AxisYZ - AxisXS) * Pos.Z
    #         Z := (OMC * AxisZX - AxisYS) * Pos.X + (OMC * AxisYZ  + AxisXS) * Pos.Y + (OMC * AxisZZ + CosVal) * Pos.Z
    #     }
    # }

    (Point:vector3).RotateAroundAnchor<public>(Anchor:vector3, Axis:vector3, AngleRadians:float)<transacts> : vector3 = {
        MakeRotation(Axis, AngleRadians).RotateVector(Point - Anchor) + Anchor
    }

    (Point:vector2).RotateAroundAnchor<public>(Anchor:vector2, AngleRadians:float)<transacts> : vector2 = {
        (MakeRotation(vector3{Z := 1.0}, AngleRadians).RotateVector(Point.ToVector3() - Anchor.ToVector3()) + Anchor.ToVector3()).ToVector2()
    }
}