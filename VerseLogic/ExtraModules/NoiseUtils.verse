using. MathFeatures

# Example usage:
# GenerateNoiseGrid()<suspends>:void = {
#     DebugDraw := debug_draw{}

#     NoiseScale := 0.1

#     for (X := -100..100, Y := -100..100) {
#         if (Mod[Y, 100] = 0). Sleep(0.0)

#         Result1 := PerlinNoise(X * NoiseScale, Y * NoiseScale, ?Seed := 13) * 100.0
#         Result2 := PerlinNoise(X * NoiseScale * 0.5, Y * NoiseScale * 0.5, ?Seed := 18) * 400.0
#         Result3 := PerlinNoise(X * NoiseScale * 0.1, Y * NoiseScale * 0.1, ?Seed := 39) * 2000

#         DebugDraw.DrawPoint(
#             Vector3(X * 100.0, Y * 100.0, 2000 + Result1 + Result2 + Result3),
#             ?Color := NamedColors.Blue,
#             ?Thickness := 10.0,
#             ?DrawDurationPolicy := debug_draw_duration_policy.Persistent
#         )
#     }
# }

NoiseUtils<public> := module {

    RandomGradient<internal>(X:int, Y:int, Seed:int)<computes><reads>:tuple(float, float) = {
        Angle := Sin(X * 374761.0 + Y * 65929.0) * 43758.5453 * if (Result := SeedRandom(Seed) <> 0.0). Result * 100.0 else 1.0 
        (Cos(Angle), Sin(Angle))
    }

    RandomGradient<internal>(X:int, Y:int, Z:int, Seed:int)<computes><reads>:tuple(float, float, float) = {
        Angle1 := Sin(X * 374761.0 + Y * 65929.0 + Z * 937162.0) * 43758.5453 * if (Result := SeedRandom(Seed) <> 0.0). Result * 100.0 else 1.0 
        Angle2 := Sin(X * 52147.0 + Y * 78311.0 + Z * 19349663.0) * 31245.233 * if (Result := SeedRandom(Seed) <> 0.0). Result * 100.0 else 1.0 
        (Cos(Angle1) * Sin(Angle2), Sin(Angle1) * Sin(Angle2), Cos(Angle2))
    }

    DotGridGradient<internal>(IX:int, IY:int, X:float, Y:float, Seed:int)<computes><reads>:float = {
        DX := X - IX
        DY := Y - IY
        Gradient := RandomGradient(IX, IY, Seed)
        DX * Gradient(0) + DY * Gradient(1)
    }

    DotGridGradient<internal>(IX:int, IY:int, IZ:int, X:float, Y:float, Z:float, Seed:int)<computes><reads>:float = {
        DX := X - IX
        DY := Y - IY
        DZ := Z - IZ
        Gradient := RandomGradient(IX, IY, IZ, Seed)
        DX * Gradient(0) + DY * Gradient(1) + DZ * Gradient(2)
    }

    # Fade function for Perlin Noise, which smooths the start and end of the interpolation for continuity
    SmoothLerp<internal>(T:float)<computes><reads>:float = {
        Pow(T, 3.0) * (T * (T * 6.0 - 15.0) + 10.0)
    }

    # Supposedly faster lerp algorithm than the built-in Verse Lerp function (WIP Test with profiler)
    FastLerp<public>(A:float, B:float, T:float)<computes>:float = {
        A + T * (B - A)
    }
    
    PerlinNoise<public>(X:float, Y:float, ?Seed:int=1)<computes><reads>:float = {
        if (not (X.IsFinite[] or Y.IsFinite[])). return 0.0

        X0 := Floor[X] or Err("Unreachable")
        Y0 := Floor[Y] or Err("Unreachable")

        X1 := X0 + 1
        Y1 := Y0 + 1

        SX := SmoothLerp(X - X0)
        SY := SmoothLerp(Y - Y0)

        N0 := DotGridGradient(X0, Y0, X, Y, Seed)
        N1 := DotGridGradient(X1, Y0, X, Y, Seed)
        IX0 := FastLerp(N0, N1, SX)

        N2 := DotGridGradient(X0, Y1, X, Y, Seed)
        N3 := DotGridGradient(X1, Y1, X, Y, Seed)
        IX1 := FastLerp(N2, N3, SX)

        FastLerp(IX0, IX1, SY) + 1.0 / 2.0
    }

    PerlinNoise<public>(X:float, Y:float, Z:float, ?Seed:int=1)<computes><reads>:float = {
        if (not (X.IsFinite[] or Y.IsFinite[] or Z.IsFinite[])). return 0.0
        
        X0 := Floor[X] or Err("Unreachable")
        Y0 := Floor[Y] or Err("Unreachable")
        Z0 := Floor[Z] or Err("Unreachable")

        X1 := X0 + 1
        Y1 := Y0 + 1
        Z1 := Z0 + 1

        SX := SmoothLerp(X - X0)
        SY := SmoothLerp(Y - Y0)
        SZ := SmoothLerp(Z - Z0)

        N0 := DotGridGradient(X0, Y0, Z0, X, Y, Z, Seed)
        N1 := DotGridGradient(X1, Y0, Z0, X, Y, Z, Seed)
        IX0 := FastLerp(N0, N1, SX)

        N2 := DotGridGradient(X0, Y1, Z0, X, Y, Z, Seed)
        N3 := DotGridGradient(X1, Y1, Z0, X, Y, Z, Seed)
        IX1 := FastLerp(N2, N3, SX)

        IY0 := FastLerp(IX0, IX1, SY)

        N4 := DotGridGradient(X0, Y0, Z1, X, Y, Z, Seed)
        N5 := DotGridGradient(X1, Y0, Z1, X, Y, Z, Seed)
        IX2 := FastLerp(N4, N5, SX)

        N6 := DotGridGradient(X0, Y1, Z1, X, Y, Z, Seed)
        N7 := DotGridGradient(X1, Y1, Z1, X, Y, Z, Seed)
        IX3 := FastLerp(N6, N7, SX)

        IY1 := FastLerp(IX2, IX3, SY)

        FastLerp(IY0, IY1, SZ) + 1.0 / 2.0
    }
}
