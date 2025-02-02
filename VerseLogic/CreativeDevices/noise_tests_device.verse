using. /Fortnite.com/Devices
using. /UnrealEngine.com/Temporary/Diagnostics
using. /UnrealEngine.com/Temporary/SpatialMath
using. /Verse.org/Colors
using. /Verse.org/Simulation

using. ExtraModules.MathFeatures
using. ExtraModules.NoiseUtils
using. ExtraModules.UnrealEngineFeatures

# Simple evice made to test and play with perlin noise algorythms
noise_tests_device<internal> := class<final>(creative_device) {

    DebugDraw : debug_draw = debug_draw{}

    @editable
    UseProp : logic = false

    @editable
    Prop : creative_prop_asset = DefaultCreativePropAsset

    OnBegin<override>()<suspends>:void = {

        NoiseScale := 0.1

        for (X := -100..100, Y := -100..100) {
            if (Mod[Y, 50] = 0). Sleep(0.0)

            Result1 := PerlinNoise(X * NoiseScale, Y * NoiseScale, ?Seed := 13) * 100.0
            Result2 := PerlinNoise(X * NoiseScale * 0.5, Y * NoiseScale * 0.5, ?Seed := 18) * 200.0
            Result3 := PerlinNoise(X * NoiseScale * 0.1, Y * NoiseScale * 0.1, ?Seed := 39) * 1500

            FinalPos := Vector3(X * 100.0, Y * 100.0, 2000 + (Result1 + Result2 + Result3) * 3.0)

            if (UseProp?) {
                SpawnProp(Prop, FinalPos, IdentityRotation())
            } else DebugDraw.DrawPoint(
                Vector3(X * 100.0, Y * 100.0, 2000 + (Result1 + Result2 + Result3) * 3.0),
                ?Color := NamedColors.Blue,
                ?Thickness := 10.0,
                ?DrawDurationPolicy := debug_draw_duration_policy.Persistent
            )
        }
    }
}