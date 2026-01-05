using. /Fortnite.com/Devices
using. /UnrealEngine.com/Temporary/Diagnostics
using. /UnrealEngine.com/Temporary/SpatialMath
using. /Verse.org/Colors
using. /Verse.org/Simulation

using. ExtraModules.MathFeatures
using. ExtraModules.NoiseUtils
using. ExtraModules.UnrealEngineFeatures

# Simple device made to test and play with perlin noise algorythms
noise_tests_device<internal> := class<final>(creative_device) {

    DebugDraw : debug_draw = debug_draw{}

    @editable
    UseProp : logic = false

    @editable
    Prop : creative_prop_asset = DefaultCreativePropAsset

    OnBegin<override>()<suspends>:void = {

        # for (
        #     XOffset := -1..1, YOffset := -1..1,
        #     (XOffset = 0 and YOffset <> 0) or
        #     (XOffset <> 0, YOffset = 0)
        # ) {
        #     Print("{XOffset} | {YOffset}")
        # }

        var HeightDifferenceCount : int = 0

        for (X := -100..100, Y := -100..100) {
            if (Mod[Y, 50] = 0). Sleep(0.0)

            TargetHeight := 2000 + GetNoiseValue(X * 1.0, Y * 1.0)
            TargetHeightGridSnapped := GridSnap[TargetHeight, 100] or Err("Unreachable")

            FinalPos := Vector3(X * 100.0, Y * 100.0, TargetHeightGridSnapped * 1.0)

            if (UseProp?) {
                SpawnProp(Prop, FinalPos, IdentityRotation()) # Actual Block
                # SpawnProp(Prop, FinalPos - Vector3(0.0, 0.0, -100.0), IdentityRotation()) # 1 Bellow Block
                # SpawnProp(Prop, FinalPos - Vector3(0.0, 0.0, -200.0), IdentityRotation()) # 2 Bellow Block
                # SpawnProp(Prop, FinalPos - Vector3(0.0, 0.0, -300.0), IdentityRotation()) # 3 Bellow Block

                for (
                    XOffset := -1..1, YOffset := -1..1,
                    (XOffset = 0 and YOffset <> 0) or (XOffset <> 0, YOffset = 0),
                    NeighbourTargetHeight := 2000 + GetNoiseValue(X + XOffset * 1.0, Y + YOffset * 1.0),
                    NeighbourTargetHeightGridSnapped := GridSnap[NeighbourTargetHeight, 100] or Err("Unreachable"),
                    NeighbourHeightDistance := Floor((TargetHeightGridSnapped - NeighbourTargetHeightGridSnapped) / 100),
                    NeighbourHeightDistance > 1
                ) {
                    # set HeightDifferenceCount += 1
                    # Print("{HeightDifferenceCount} --- {XOffset} | {YOffset} --- {TargetHeightGridSnapped} | {NeighbourTargetHeightGridSnapped}")
                    for (FillBlockOffset := 1..NeighbourHeightDistance - 1) {
                        SpawnProp(Prop, FinalPos + Vector3(0.0, 0.0, -100.0 * FillBlockOffset), IdentityRotation())
                    }
                }
            } else DebugDraw.DrawPoint(
                FinalPos,
                ?Color := NamedColors.Blue,
                ?Thickness := 10.0,
                ?DrawDurationPolicy := debug_draw_duration_policy.Persistent
            )
        }
    }

    GetNoiseValue<public>(X:float, Y:float)<transacts>:float = {
        NoiseScale := 0.025 # 0.1

        Result1 := PerlinNoise(X * NoiseScale, Y * NoiseScale, ?Seed := 13) * 100.0
        Result2 := PerlinNoise(X * NoiseScale * 0.5, Y * NoiseScale * 0.5, ?Seed := 18) * 200.0
        Result3 := PerlinNoise(X * NoiseScale * 0.1, Y * NoiseScale * 0.1, ?Seed := 39) * 1500 # 1500.0

        TargetHeight := (Result1 + Result2 + Result3) * 3.0
    }

    GridSnap<public>(Value:float, GridSize:int)<computes><reads><decides>:int = {
        RoundedValue := Round[Value]
        Remainder := Mod[RoundedValue, GridSize]
        if (Remainder > Floor(GridSize / 2)) {
            RoundedValue - Remainder + GridSize
        } else. RoundedValue - Remainder
    }
}