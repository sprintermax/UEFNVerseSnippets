# This file may contain untested stuff, that may not have correct or expected behavior

using. /UnrealEngine.com/Temporary/SpatialMath
using. /Verse.org/Random

using. MathFeatures
using. UnrealEngineFeatures
using. VerseFeatures

RandomTests<public> := module {

    Binary<public> := module {

        # binary_int32<public> := struct<concrete> {
        #     BitArray<public> : []logic = for (X := 0..31) { false }
        # }

        # binary_float32<public> := struct<concrete> {
        #     BitArray<public> : []logic = for (X := 0..31) { false }
        # }






































        ##################


        binary_int<public> := struct<concrete> {
            NegativeBit<public> : char = '0'
            BitArray<public> : []char = array{}
        }

        BitwiseAnd<public>(InputA : int, InputB : int)<transacts> : int = {
            return BinaryToInt(binary_int{
                BitArray := BitwiseAnd(IntToBinary(InputA).BitArray, IntToBinary(InputB).BitArray)
            })
        }

        BitwiseOr<public>(InputA : int, InputB : int)<transacts> : int = {
            return BinaryToInt(binary_int{
                BitArray := BitwiseOr(IntToBinary(InputA).BitArray, IntToBinary(InputB).BitArray)
            })
        }

        BitwiseXor<public>(InputA : int, InputB : int)<transacts> : int = {
            return BinaryToInt(binary_int{
                BitArray := BitwiseXor(IntToBinary(InputA).BitArray, IntToBinary(InputB).BitArray)
            })
        }

        BitwiseNot<public>(Input : int)<transacts> : int = {
            return BinaryToInt(binary_int{
                BitArray := BitwiseNot(IntToBinary(Input).BitArray)
            })
        }

        BitwiseAnd<public>(InputA : []char, InputB : []char)<transacts> : []char = {
            Result := for (Index := 0..Max(InputA.Length, InputB.Length)-1) {
                if (InputA.Reverse()[Index] = '1' and InputB.Reverse()[Index] = '1') {
                    '1'
                } else {
                    '0'
                }
            }

            return Result.Reverse()
        }

        BitwiseOr<public>(InputA : []char, InputB : []char)<transacts> : []char = {
            Result := for (Index := 0..Max(InputA.Length, InputB.Length)-1) {
                if (InputA.Reverse()[Index] = '1' or InputB.Reverse()[Index] = '1') {
                    '1'
                } else {
                    '0'
                }
            }

            return Result.Reverse()
        }

        BitwiseXor<public>(InputA : []char, InputB : []char)<transacts> : []char = {
            Result := for (Index := 0..Max(InputA.Length, InputB.Length)-1) {
                if ((InputA.Reverse()[Index] = '1' and (InputB.Reverse()[Index] = '0' or not InputB.Reverse()[Index])) or ((InputA.Reverse()[Index] = '0' or not InputA.Reverse()[Index]) and InputB.Reverse()[Index] = '1')) {
                    '1'
                } else {
                    '0'
                }
            }

            return Result.Reverse()
        }

        BitwiseNot<public>(Input : []char)<transacts> : []char = {
            Result := for (Index := 0..Input.Length-1) {
                if (Input[Index] = '0') {
                    '1'
                } else {
                    '0'
                }
            }

            return Result
        }

        LeftShift<public>(Input : int, Bits : int)<transacts><decides> : int = { # <<
            Int[Input * Pow(2.0, Bits * 1.0)]
        }

        RightShift<public>(Input : int, Bits : int)<transacts><decides> : int = { # >>
            Int[Input / Pow(2.0, Bits * 1.0)]
        }

        LeftShift<public>(Input : []char, Bits : int)<transacts> : []char = { # <<
            var BitArray : []char = Input

            for (X := 0..Bits-1) {
                set BitArray = BitArray + array{'0'}
            }

            BitArray
        }

        RightShift<public>(Input : []char, Bits : int)<transacts> : []char = { # >>
            var BitArray : []char = Input

            for (X := 0..Bits-1) {
                if (Val := BitArray.RemoveElement[BitArray.Length-1]). set BitArray = array{'0'} + Val
            }

            BitArray
        }

        UnclampedRightShift<public>(Input : []char, Bits : int)<transacts> : []char = { # <<
            var BitArray : []char = Input

            for (X := 0..Bits-1) {
                if (Val := array{BitArray[0]} + BitArray). set BitArray = Val
            }

            BitArray
        }

        ClampedLeftShift<public>(Input : []char, Bits : int)<transacts> : []char = { # <<
            var BitArray : []char = Input

            for (X := 0..Bits-1) {
                if (Val := BitArray.RemoveElement[0] + array{'0'}). set BitArray = Val
            }

            BitArray
        }

        ClampedCarriedRightShift<public>(Input : []char, Bits : int)<transacts> : []char = { # >>
            var BitArray : []char = Input

            for (X := 0..Bits-1) {
                if (Val := array{BitArray[0]} + BitArray.RemoveElement[BitArray.Length-1]). set BitArray = Val
            }

            BitArray
        }

        BinaryToInt<public>(Input : binary_int)<transacts> : int = {
            var Result : int = 0
            for (Index->Char : Input.BitArray.Reverse()) {
                if (Val := CharToIntMap[Char] * Int[Pow(2.0, Index*1.0)]). set Result += Val
            }

            if (Input.NegativeBit = '1') {
                set Result *= -1
            }
            
            return Result
        }

        IntToBinary<public>(Input:int)<transacts> : binary_int = {
            var n : int = if (Input < 0) { Input * -1 } else { Input }
            var a : int = 0
            var i : int = 0
            loop {
                if (n <= 0) {
                    break
                }

                if (
                    q := Int[n / 2.0]
                    r := Mod[n, 2]
                    set a += Int[Pow(10.0, i * 1.0)] * r) {
                    set n = q
                    set i += 1
                }
            }
            
            binary_int{
                NegativeBit := if (Input < 0) { '1' } else { '0' }
                BitArray := for (Char : "{a}") { Char }
            }
        }
    }

    
    (RandomTests:)NoiseUtils<public> := module {

        PerlinPermutations<public> : []int = array{ 151,160,137,91,90,15,
            131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
            190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
            88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
            77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
            102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
            135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
            5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
            223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
            129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
            251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
            49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
            138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
        }

        Gradients3<public> : []vector3 = array{ vector3{X:=1.0,Y:=1.0,Z:=0.0}, vector3{X:=-1.0,Y:=1.0,Z:=0.0}, vector3{X:=1.0,Y:=-1.0,Z:=0.0}, vector3{X:=-1.0,Y:=-1.0,Z:=0.0},
            vector3{X:=1.0,Y:=0.0,Z:=1.0}, vector3{X:=-1.0,Y:=0.0,Z:=1.0}, vector3{X:=1.0,Y:=0.0,Z:=-1.0}, vector3{X:=-1.0,Y:=0.0,Z:=-1.0},
            vector3{X:=0.0,Y:=1.0,Z:=1.0}, vector3{X:=0.0,Y:=-1.0,Z:=1.0}, vector3{X:=0.0,Y:=1.0,Z:=-1.0}, vector3{X:=0.0,Y:=-1.0,Z:=-1.0}
        }

        Dot<public>(G : vector2, X : float, Y : float)<transacts> : float = {
            return G.X * X + G.Y * Y
        }
        
        Dot<public>(G : vector3, X : float, Y : float, Z : float)<transacts> : float = {
            return G.X * X + G.Y * Y + G.Z * Z
        }        

        SimplexNoise_Octave<public> := class(){
            NUMBEROFSWAPS : int = 400

            var p<private> : []int = for (X := 0..PerlinPermutations.Length). 0
            var perm<private> : []int = for (X := 1..512). 0
            var permMod12<private> : []int = for (X := 1..512). 0

            var F2 : float = 0.0
            var G2 : float = 0.0
            F3 : float = 1.0/3.0
            G3 : float = 1.0/6.0
            var F4 : float = 0.0
            var G4 : float = 0.0

            block {
                set p = PerlinPermutations

                set F2 = 0.5*(Sqrt(3.0)-1.0)
                set G2 = (3.0-Sqrt(3.0))/6.0
                set F4 = (Sqrt(5.0)-1.0)/4.0
                set G4 = (5.0-Sqrt(5.0))/20.0

                for (i:=0..NUMBEROFSWAPS-1) {
                    swapFrom := GetRandomInt(0, p.Length-1)
                    swapTo := GetRandomInt(0, p.Length-1)

                    var temp : int = 0
                    if (tempVal := p[swapFrom]) { set temp = tempVal }

                    if(Val := p[swapTo], set p[swapFrom] = Val) {}
                    if(Val := p[swapFrom], set p[swapTo] = Val) {}
                }

                for (i:=0..511) {
                    if (Val := Binary.BitwiseAnd(i, 255), set perm[i] = Val) {}
                    if (Val := Mod[perm[i], 12], set permMod12[i] = Val) {}
                }
            }

            Noise<public>(xin : float, yin : float)<transacts><decides> : float = {
                var n0 : float = 0.0
                var n1 : float = 0.0
                var n2 : float = 0.0

                s := (xin + yin) * F2
                
                i : int = Floor[xin+s]
                j : int = Floor[yin+s]

                t : int = Int[(i+j)*G2]

                X0 : float = (i - t) * 1.0
                Y0 : float = (j - t) * 1.0
                x0 : float = xin - X0
                y0 : float = yin - Y0

                var i1 : int = 0
                var j1 : int = 0

                if (x0>y0) {
                    set i1 = 1
                    set j1 = 0
                } else {
                    set i1 = 0
                    set j1 = 1
                }

                x1 : float = x0 - i1 + G2
                y1 : float = y0 - j1 + G2
                x2 : float = x0 - 1.0 + 2.0 * G2
                y2 : float = y0 - 1.0 + 2.0 * G2

                ii : int = Binary.BitwiseAnd(i, 255)
                jj : int = Binary.BitwiseAnd(j, 255)
                gi0 : int = permMod12[ii+perm[jj]]
                gi1 : int = permMod12[ii+i1+perm[jj+j1]]
                gi2 : int = permMod12[ii+1+perm[jj+1]]

                var t0 : float = 0.5 - x0 * x0 - y0 * y0
                if (t0 < 0.0) {
                    set n0 = 0.0
                } else {
                    set t0 *= t0
                    if (DotResult := Dot(Gradients3[gi0].ToVector2(), x0, y0)). set n0 = t0 * t0 * DotResult
                }

                var t1 : float = 0.5 - x1 * x1 + y1 * y1
                if (t1 < 0.0) {
                    set n1 = 0.0
                } else {
                    set t1 *= t1
                    if (DotResult := Dot(Gradients3[gi1].ToVector2(), x1, y1)). set n1 = t1 * t1 * DotResult
                }

                var t2 : float = 0.5 - x2 * x2 + y2 * y2
                if (t2 < 0.0) {
                    set n2 = 0.0
                } else {
                    set t2 *= t2
                    if (DotResult := Dot(Gradients3[gi2].ToVector2(), x2, y2)). set n2 = t2 * t2 * DotResult
                }

                70 * (n0 + n1 + n2)
            }

        }

    }

}