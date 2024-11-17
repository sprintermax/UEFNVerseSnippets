using { /UnrealEngine.com/Temporary/SpatialMath }

using { MathFeatures }

HexagonMath<public> := module {

    hex_coord<public> := struct<computes>{
        Q<public>:int = 0
        R<public>:int = 0
        S<public>:int = 0
    }

    HexDirectionVectors<public>:[]hex_coord = array{
        hex_coord{Q := 1, R := 0, S := -1}, hex_coord{Q := 1, R := -1, S := 0}, hex_coord{Q := 0, R := -1, S := +1},
        hex_coord{Q := -1, R := 0, S := 1}, hex_coord{Q := -1, R := 1, S := 0}, hex_coord{Q := 0, R := 1, S := -1}
    }

    HexAddPos<public>(HexCoord:hex_coord, DirectionVector:hex_coord)<transacts>:hex_coord = {
        hex_coord{
            Q := HexCoord.Q + DirectionVector.Q
            R := HexCoord.R + DirectionVector.R
            S := HexCoord.S + DirectionVector.S
        }
    }

    HexNeighbour<public>(HexPos:hex_coord, Direction:int)<transacts><decides>:hex_coord = {
        DirectionVector := HexDirectionVectors[Direction]
        HexAddPos(HexPos, DirectionVector)
    }

    HexScale<public>(HexCoord:hex_coord, Factor:int)<transacts>:hex_coord = {
        hex_coord{
            Q := HexCoord.Q * Factor
            R := HexCoord.R * Factor
            S := HexCoord.S * Factor
        }
    }

    HexRing<public>(CenterHexPos:hex_coord, Radius:int)<transacts>:[]hex_coord = {
        if(Radius = 0). return array{CenterHexPos}

        var ResultHexArray:[]hex_coord = array{}

        var CurrentHex:hex_coord = hex_coord{}
        if (InitialHexDirectionVector := HexDirectionVectors[4]) {
            set CurrentHex = HexAddPos(CenterHexPos, HexScale(InitialHexDirectionVector, Radius))
        }

        for (
            I := 0..5
            J := 0..Radius - 1
        ) {
            if (NextHex := HexNeighbour[CurrentHex, I]) {
                set ResultHexArray += array{CurrentHex}
                set CurrentHex = NextHex
            }
        }

        ResultHexArray
    }

    HexSpiral<public>(CenterHexPos:hex_coord, StartRadius:int, EndRadius:int)<transacts>:[]hex_coord = {
        var ResultHexArray:[]hex_coord = array{}

        for (K := StartRadius..EndRadius) {
            set ResultHexArray += HexRing(CenterHexPos, K)
        }

        ResultHexArray
    }

    # 2.0 * PiFloat / 3.0 = 120 Degrees
    HexCoordToVector2Pos<public>(HexCoord:hex_coord, RotationAngle:float, ?IsDegrees : logic = false):vector2 = {
        AngleQ := 2.0 * PiFloat / 3.0 + if (IsDegrees?). DegreesToRadians(RotationAngle) else. RotationAngle
        AngleR := 0.0 + if (IsDegrees?). DegreesToRadians(RotationAngle) else. RotationAngle
        AngleS := 2.0 * PiFloat / 3.0 * 2.0 + if (IsDegrees?). DegreesToRadians(RotationAngle) else. RotationAngle

        QVector := vector2{
            X := HexCoord.Q * Cos(AngleQ)
            Y := HexCoord.Q * Sin(AngleQ)
        }
        RVector := vector2{
            X := HexCoord.R * Cos(AngleR)
            Y := HexCoord.R * Sin(AngleR)
        }
        SVector := vector2{
            X := HexCoord.S * Cos(AngleS)
            Y := HexCoord.S * Sin(AngleS)
        }

        QVector + RVector + SVector
    }
    

    Vector2PosToHexCoord<public>(Position:vector2, HexSize : float, RotationAngle:float, ?IsDegrees : logic = false)<transacts>:hex_coord = {
        
        RotatedVector := Position.RotateAroundAnchor(vector2{}, if (IsDegrees?). DegreesToRadians(RotationAngle) else. RotationAngle)
    
        Q := (RotatedVector.X * (2.0/3.0)) / HexSize
        R := ((-RotatedVector.X / 3.0) + (Sqrt(3.0) / 3.0) * RotatedVector.Y) / HexSize
        S := -Q -R

        var RoundedQ : int = Round[Q] or 0
        var RoundedR : int = Round[R] or 0
        var RoundedS : int = Round[S] or 0

        DiffQ := Abs(RoundedQ - Q)
        DiffR := Abs(RoundedR - R)
        DiffS := Abs(RoundedS - S)

        if (DiffQ > DiffR and DiffQ > DiffS) {
            set RoundedQ = -RoundedR - RoundedS
        } else if (DiffR > DiffS) {
            set RoundedR = -RoundedQ - RoundedS
        } else. set RoundedS = -RoundedQ - RoundedR

        hex_coord{ # For some reason the Q and R values needs to be flippled to work
            Q := RoundedR
            R := RoundedQ
            S := RoundedS
        }
    }

    HexCoordToGrid2D<public>(HexCoord:hex_coord)<transacts>:vector2i = {
        vector2i{
            X := HexCoord.Q + (HexCoord.R - Floor((Mod[Abs(HexCoord.R), 2] or 0) / 2) or 0)
            Y := HexCoord.R
        }
    }

    Grid2DToHexCoord<public>(GridCoord:vector2i)<transacts>:hex_coord = {
        hex_coord{
            Q := GridCoord.X - (GridCoord.Y - Floor((Mod[Abs(GridCoord.Y), 2] or 0) / 2) or 0)
            R := GridCoord.Y
            S := -GridCoord.X - GridCoord.Y
        }
    }
}