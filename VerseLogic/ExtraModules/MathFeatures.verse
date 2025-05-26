using. /UnrealEngine.com/Temporary/SpatialMath
using. /Verse.org/Random

using. UnrealEngineFeatures

MathFeatures<public> := module {
    operator'+'<public>(I:int, F:float)<computes>:float = I * 1.0 + F
    operator'+'<public>(F:float, I:int)<computes>:float = F + I * 1.0
    operator'-'<public>(I:int, F:float)<computes>:float = I * 1.0 - F
    operator'-'<public>(F:float, I:int)<computes>:float = F - I * 1.0
    operator'/'<public>(I:int, F:float)<computes>:float = I * 1.0 / F
    operator'/'<public>(F:float, I:int)<computes>:float = F / (I * 1.0)

    # Disabled because compiler shows as reserved identifiers
    # operator'>'<public>(I:int, F:float)<computes><decides>:int = I > F
    # operator'>'<public>(F:float, I:int)<computes><decides>:float = F > I
    # operator'<'<public>(I:int, F:float)<computes><decides>:int = I < F
    # operator'<'<public>(F:float, I:int)<computes><decides>:float = F < I

    # operator'>='<public>(I:int, F:float)<computes><decides>:int = I >= F
    # operator'>='<public>(F:float, I:int)<computes><decides>:float = F >= I
    # operator'<='<public>(I:int, F:float)<computes><decides>:int = I <= F
    # operator'<='<public>(F:float, I:int)<computes><decides>:float = F <= I

    # operator'>='<public>(I:int, F:float)<computes><decides>:int = I >= F
    # operator'>='<public>(F:float, I:int)<computes><decides>:float = F >= I
    # operator'<='<public>(I:int, F:float)<computes><decides>:int = I <= F
    # operator'<='<public>(F:float, I:int)<computes><decides>:float = F <= I

    # operator'<>'<public>(I:int, F:float)<computes><decides>:int = { I * 1.0 <> F; I }
    # operator'<>'<public>(F:float, I:int)<computes><decides>:float = { F <> I * 1.0 }

    # operator'='<public>(I:int, F:float)<computes><decides>:int = { I * 1.0 = F; I }
    # operator'='<public>(F:float, I:int)<computes><decides>:float = { F = I * 1.0 }

    zero_to_one_float<public> := type{_X:float where 0.0 <= _X, _X <= 1.0}

    RemapValueRange<public>(FromLow:float, FromHigh:float, ToLow:float, ToHigh:float, Value:float)<computes>:float = {
        return ToLow + (Value - FromLow) * (ToHigh - ToLow) / (FromHigh - FromLow)
    }

    (Value:int).ToFloat<public>()<computes>:float = Value * 1.0

    RoundDecimals<public>(Input:float, Decimals:int)<computes><decides><reads>:float = {
        Factor := Pow(10.0, Decimals * 1.0)
        
        Rounded := Round[Input * Factor]
        return (Rounded * 1.0) / Factor
    }

    FloorDecimals<public>(Input:float, Decimals:int)<computes><decides><reads>:float = {
        Factor := Pow(10.0, Decimals * 1.0)

        Rounded := Floor[Input * Factor]
        return (Rounded * 1.0) / Factor
    }

    CeilDecimals<public>(Input:float, Decimals:int)<computes><decides><reads>:float = {
        Factor := Pow(10.0, Decimals * 1.0)
        
        Rounded := Ceil[Input * Factor]
        return (Rounded * 1.0) / Factor
    }

    TruncateFloatToString<public>(Input:float, Decimals:int)<computes><decides><reads>:[]char = {
        String := ToString(Input)

        DotIndex := String.Find['.']
        StopIndex := if (Decimals > 0) { Min(DotIndex+Decimals+1,String.Length) } else { DotIndex }

        return String.Slice[0, StopIndex]
    }

    ### RNGs

    # Simple deterministic RNG, return between 0.0 (inclusive) and 1.0 (exclusive)
    SeedRandom<public>(Seed:int)<computes><reads>:float = {
        X := Sin(Seed * 1.0) * 10000.0
        X - Floor[X] * 1.0 or 0.0
    }

    # Shuffle an array of elements using a seed to make it deterministic
    (InputArray:[]t).Shuffle<public>(Seed:int where t:type)<transacts>:[]t = {
        var ShuffledArray : []t = InputArray
        var _Seed : int = Seed

        Length := ShuffledArray.Length
        
        for (X := 0..Length - 1) {

            I := Length - X
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
    # A more complete RNG class with more useful features
    seedable_rng := class {
        var State<private> : int = -1
        var<private> Iteration<public> : int = 0
        Multiplier<private> : int = 1664525
        Increment<private> : int = 1013904223
        Modulo<private> : int = Constants.Max32BitInt

        # Setup, Reset or Change the RNG state
        Init<public>(Seed:int)<transacts>:void = {
            set State = Seed
            set Iteration = 0
        }

        # Jumps to the next state
        NextState<public>()<transacts>:void = {
            set State = Mod[Multiplier * State + Increment, Modulo] or Err("Unreachable")
            set Iteration += 1
        }

        # Jumps the current state a specific amount of times
        Jump<public>(Count:int)<transacts>:void = {
            for (X := 0..Count - 1) {
                NextState()
            }
        }

        # Returns random float from 0.0 (inclusive) to 1.0 (exclusive)
        NextFloat<public>()<transacts>:float = {
            NextState()
            State * 1.0 / Modulo
        }

        # Returns random float from ValueMin (inclusive) to ValueMax (exclusive)
        NextFloatRange<public>(ValueMin:float, ValueMax:float)<transacts>:float = {
            ValueMin + (NextFloat() * (ValueMax - ValueMin))
        }

        # Returns random int # WIP TEST
        NextInt<public>()<transacts>:int = {
            NextState()
            State
        }

        # Returns random int from ValueMin (inclusive) to ValueMax (inclusive) # WIP TEST
        NextIntRange<public>(ValueMin:int, ValueMax:int)<transacts>:int = {
            ValueMin + Mod[NextInt(), (ValueMax - ValueMin + 1)] or 0
        }
    }

    # Makes an array of possible choices that can be used on GetRandomByWeights[]
    # Array of Elements and Weights are supposed to have the same length
    # If Strict is set to false (Default), will auto assign weight of 0 to exceding elements
    # If Strict is set to true, will force a fail if array lengths don't match.
    (Elements:[]t).AssignChoiceWeights<public>(Weights:[]int, (?Strict:logic = false) where t:type)<transacts><decides>:[]tuple(t, int) = {
        Elements.Length = Weights.Length or not Strict?

        Choices := for (
            Index->Element : Elements
            Weight := Weights[Index] or 0
        ). (Element, Weight)
    }

    # Returns a random element by considering priority weight over others (ChoiceData, Weight)
    # Elements with weight of 0 or negative values will never be selected
    GetRandomByWeights<public>(Choices:[]tuple(t, int) where t:type)<transacts><decides>:t = {
        var TotalWeight : int = 0

        for (Choice : Choices). set TotalWeight += Max(0, Choice(1))

        var AccumulatedWeight : int = 0
        var MaybeSelectedChoice : ?t = false

        for (ChoiceIndex->Choice : Shuffle(Choices), not MaybeSelectedChoice?) {
            set AccumulatedWeight += Max(0, Choice(1))
            if (GetRandomInt(0, TotalWeight) < AccumulatedWeight) {
                set MaybeSelectedChoice = option{Choice(0)}
            }
        }

        MaybeSelectedChoice?
    }

    # Used to calculate how many times a cycle happened, and how much progress is left to the next cycle
    # Returns (Current Cycle Index, Progress to Next Index)
    GetIterationIndex<public>(TotalProgress:float, StepSize:float)<computes><reads>:tuple(int,float) = {
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
        # Min64BitFloat<public>()<transacts>float = Pow(2.0, -1022.0)
        # Max64BitFloat<public>()<transacts>:float = (1.0 + (Pow(2.0, 52.0) - 1.0) / Pow(2.0, 52.0)) * Pow(2.0, 1023.0)
        HalfPi<public>:float = PiFloat / 2.0
    }

    # Get a random int between Min32BitInt and Max32BitInt
    GetRandomInt<public>():int = GetRandomInt(Constants.Min32BitInt, Constants.Max32BitInt)

    # Get a random float between Min32BitInt and Max32BitInt
    # Verse has 64bit floats, but I avoid using that full range due to some issues explained above
    GetRandomFloat<public>():float = GetRandomFloat(Constants.Min32BitInt * 1.0, Constants.Max32BitInt * 1.0)

    EasingFunctions<public> := module {

        # Easing modes for interpolation of values
        # https://easings.net/
        # https://easingwizard.com/
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

        # All easing functions expect input values between 0.0 and 1.0
        # Some functions may work with values outside that range, but it is not
        # guaranteed, they may not work as expected and give weird results
        (EasingMode:easing_mode).Evaluate<public>(Value:float)<computes><reads>:float = {
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

        EaseInSine<public>(Value:float)<computes><reads>:float = {
            1 - Cos((Value * PiFloat) / 2)
        }
        EaseOutSine<public>(Value:float)<computes><reads>:float = {
            Sin((Value * PiFloat) / 2)
        }
        EaseInOutSine<public>(Value:float)<computes><reads>:float = {
            -(Cos(PiFloat * Value) - 1) / 2
        }
        
        EaseInQuad<public>(Value:float)<computes>:float = {
            Value * Value
        }
        EaseOutQuad<public>(Value:float)<computes>:float = {
            1- (1 - Value) * (1 - Value)
        }
        EaseInOutQuad<public>(Value:float)<computes><reads>:float = {
            if (Value < 0.5) {
                2 * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 2.0) / 2
            }
        }

        EaseInCubic<public>(Value:float)<computes>:float = {
            Value * Value * Value
        }
        EaseOutCubic<public>(Value:float)<computes><reads>:float = {
            1 - Pow(1 - Value, 3.0)
        }
        EaseInOutCubic<public>(Value:float)<computes><reads>:float = {
            if (Value < 0.5) {
                4 * Value * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 3.0) / 2
            }
        }

        EaseInQuart<public>(Value:float)<computes>:float = {
            Value * Value * Value * Value
        }
        EaseOutQuart<public>(Value:float)<computes><reads>:float = {
            1 - Pow(1 - Value, 4.0)
        }
        EaseInOutQuart<public>(Value:float)<computes><reads>:float = {
            if (Value < 0.5) {
                8 * Value * Value * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 4.0) / 2
            }
        }

        EaseInQuint<public>(Value:float)<computes>:float = {
            Value * Value * Value * Value * Value
        }
        EaseOutQuint<public>(Value:float)<computes><reads>:float = {
            1 - Pow(1 - Value, 5.0)
        }
        EaseInOutQuint<public>(Value:float)<computes><reads>:float = {
            if (Value < 0.5) {
                16 * Value * Value * Value * Value * Value
            } else {
                1 - Pow(-2 * Value + 2, 5.0) / 2
            }
        }

        EaseInExpo<public>(Value:float)<computes><reads>:float = {
            if (Value = 0.0) {
                0.0
            } else {
                Pow(2.0, 10 * Value - 10)
            }
        }
        EaseOutExpo<public>(Value:float)<computes><reads>:float = {
            if (Value = 1.0) {
                1.0
            } else {
                1 - Pow(2.0, -10 * Value)
            }
        }
        EaseInOutExpo<public>(Value:float)<computes><reads>:float = {
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

        EaseInCirc<public>(Value:float)<computes><reads>:float = {
            1 - Sqrt(1 - Pow(Value, 2.0))
        }
        EaseOutCirc<public>(Value:float)<computes><reads>:float = {
            Sqrt(1 - Pow(Value - 1, 2.0))
        }
        EaseInOutCirc<public>(Value:float)<computes><reads>:float = {
            if (Value < 0.5) {
                (1 - Sqrt(1 - Pow(2 * Value, 2.0))) / 2
            } else {
                (Sqrt( 1 - Pow(-2 * Value + 2, 2.0)) + 1) / 2
            }
        }

        EaseInBack<public>(Value:float)<computes>:float = {
            Constant := 1.70158
            Constant2 := Constant + 1

            Constant2 * Value * Value * Value - Constant * Value * Value
        }
        EaseOutBack<public>(Value:float)<computes><reads>:float = {
            Constant := 1.70158
            Constant2 := Constant + 1

            1 + Constant2 * Pow(Value -1, 3.0) + Constant * Pow(Value - 1, 2.0)
        }
        EaseInOutBack<public>(Value:float)<computes><reads>:float = {
            Constant := 1.70158
            Constant2 := Constant + 1.525

            if (Value < 0.5) {
                (Pow(2 * Value, 2.0) * ((Constant2 + 1) * 2 * Value - Constant2)) / 2
            } else {
                (Pow(2 * Value - 2, 2.0) * ((Constant2 + 1) * (Value * 2 - 2) + Constant2) + 2) / 2
            }
        }
        
        EaseInElastic<public>(Value:float)<computes><reads>:float = {
            Constant := (2 * PiFloat) / 3

            if (Value = 0.0) {
                0.0
            } else if (Value = 1.0) {
                1.0
            } else {
                -Pow(2.0, 10 * Value - 10) * Sin((Value * 10 - 10.75) * Constant)
            }
        }
        EaseOutElastic<public>(Value:float)<computes><reads>:float = {
            Constant := (2 * PiFloat) / 3

            if (Value = 0.0) {
                0.0
            } else if (Value = 1.0) {
                1.0
            } else {
                Pow(2.0, -10 * Value) * Sin((Value * 10 - 0.75) * Constant) + 1
            }
        }
        EaseInOutElastic<public>(Value:float)<computes><reads>:float = {
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
        
        EaseInBounce<public>(Value:float)<computes>:float = {
            1 - EaseOutBounce(1 - Value)
        }
        EaseOutBounce<public>(Value:float)<computes>:float = {
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
        EaseInOutBounce<public>(Value:float)<computes>:float = {
            if (Value < 0.5) {
                (1 - EaseOutBounce(1 - 2 * Value)) / 2
            } else {
                ( 1 + EaseOutBounce(2 * Value - 1)) / 2
            }
        }
    }

    # Rotate a point in 3D space around an anchor point on a specific axis
    (Point:vector3).RotateAroundAnchor<public>(Anchor:vector3, Axis:vector3, AngleRadians:float)<transacts>:vector3 = {
        MakeRotation(Axis, AngleRadians).RotateVector(Point - Anchor) + Anchor
    }

    # Rotate a point in 2D space around an anchor point
    (Point:vector2).RotateAroundAnchor<public>(Anchor:vector2, AngleRadians:float)<transacts>:vector2 = {
        Anchor3 := Anchor.ToVector3()
        (MakeRotation(vector3{Z := 1.0}, AngleRadians).RotateVector(Point.ToVector3() - Anchor3) + Anchor3).ToVector2()
    }
}