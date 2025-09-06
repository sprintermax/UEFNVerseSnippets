using. /UnrealEngine.com/Temporary/SpatialMath

UnrealEngineFeatures<public> := module {

    horizontal_direction<public> := enum{None, Left, Right}
    vertical_direction<public> := enum{None, Up, Down}

    Vector2<public>(Value:float)<computes>:vector2 = vector2{ X := Value, Y := Value }
    Vector2<public>(X:float, Y:float)<computes>:vector2 = vector2{ X := X, Y := Y }
    Vector2i<public>(Value:int)<computes>:vector2i = vector2i{ X := Value, Y := Value }
    Vector2i<public>(X:int, Y:int)<computes>:vector2i = vector2i{ X := X, Y := Y }

    Vector3<public>(Value:float)<computes>:vector3 = vector3{ X := Value, Y := Value, Z := Value }
    Vector3<public>(X:float, Y:float, Z:float)<computes>:vector3 = vector3{ X := X, Y := Y, Z := Z }
    Vector3i<public>(Value:int)<computes>:vector3i = vector3i{ X := Value, Y := Value, Z := Value }
    Vector3i<public>(X:int, Y:int, Z:int)<computes>:vector3i = vector3i{ X := X, Y := Y, Z := Z }

    Vector4<public>(Value:float)<computes>:vector4 = vector4{ X := Value, Y := Value, Z := Value, W := Value }
    Vector4<public>(X:float, Y:float, Z:float, W:float)<computes>:vector4 = vector4{ X := X, Y := Y, Z := Z, W := W }   
    Vector4i<public>(Value:int)<computes>:vector4i = vector4i{ X := Value, Y := Value, Z := Value, W := Value }
    Vector4i<public>(X:int, Y:int, Z:int, W:int)<computes>:vector4i = vector4i{ X := X, Y := Y, Z := Z, W := W }

    vector3i<public> := struct<computes>{
        X<public>:int = 0
        Y<public>:int = 0
        Z<public>:int = 0
    }
    vector4<public> := struct<computes>{
        X<public>:float = 0.0
        Y<public>:float = 0.0
        Z<public>:float = 0.0
        W<public>:float = 0.0
    }
    vector4i<public> := struct<computes>{
        X<public>:int = 0
        Y<public>:int = 0
        Z<public>:int = 0
        W<public>:int = 0
    }

    (Input:vector2).ToVector3<public>()<computes> : vector3 = vector3{ X := Input.X, Y := Input.Y }
    (Input:vector3).ToVector2<public>()<computes> : vector2 = vector2{ X := Input.X, Y := Input.Y }
    (Input:vector3).ToVector4<public>()<computes> : vector4 = vector4{ X := Input.X, Y := Input.Y, Z := Input.Z }
    (Input:vector4).ToVector3<public>()<computes> : vector3 = vector3{ X := Input.X, Y := Input.Y, Z := Input.Z }
    (Input:vector3i).ToVector3<public>()<computes> : vector3 = {
        return vector3{
            X := Input.X * 1.0
            Y := Input.Y * 1.0
            Z := Input.Z * 1.0
        }
    }
    (Input:vector4i).ToVector4<public>()<computes> : vector4 = {
        return vector4{
            X := Input.X * 1.0
            Y := Input.Y * 1.0
            Z := Input.Z * 1.0
            W := Input.W * 1.0
        }
    }

    BezierCurves<public> := module {

        QuadraticBezierPoint<public>(Start:vector2, Control:vector2, End:vector2, Alpha:float)<computes><reads>:vector2 = {
            ControlPoint := vector2{
                X := Control.X + (1.0 - Alpha) * (Start.X - Control.X) + Alpha * (End.X - Control.X)
                Y := Control.Y + (1.0 - Alpha) * (Start.Y - Control.Y) + Alpha * (End.Y - Control.Y)
            }

            # PointPosition := vector2{
            #     X := (1.0 - Alpha) * (1.0 - Alpha) * Control.X + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.X + Alpha * Alpha * End.X
            #     Y := (1.0 - Alpha) * (1.0 - Alpha) * Control.Y + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.Y + Alpha * Alpha * End.Y
            # }

            PointPosition := vector2{
                X := Pow((1.0 - Alpha), 2.0) * Control.X + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.X + Pow(Alpha, 2.0) * End.X
                Y := Pow((1.0 - Alpha), 2.0) * Control.Y + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.Y + Pow(Alpha, 2.0) * End.Y
            }
        }

        QuadraticBezierPoint<public>(Start:vector3, Control:vector3, End:vector3, Alpha:float)<computes><reads>:vector3 = {
            ControlPoint := vector3{
                X := Control.X + (1.0 - Alpha) * (Start.X - Control.X) + Alpha * (End.X - Control.X)
                Y := Control.Y + (1.0 - Alpha) * (Start.Y - Control.Y) + Alpha * (End.Y - Control.Y)
                Z := Control.Z + (1.0 - Alpha) * (Start.Z - Control.Z) + Alpha * (End.Z - Control.Z)
            }

            PointPosition := vector3{
                X := Pow((1.0 - Alpha), 2.0) * Control.X + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.X + Pow(Alpha, 2.0) * End.X
                Y := Pow((1.0 - Alpha), 2.0) * Control.Y + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.Y + Pow(Alpha, 2.0) * End.Y
                Z := Pow((1.0 - Alpha), 2.0) * Control.Z + 2.0 * (1.0 - Alpha) * Alpha * ControlPoint.Z + Pow(Alpha, 2.0) * End.Z
            }
        }

        # 3D Bezier

        bezier_3D<public> := class<computes> {
            Start<public>:vector3
            Mid<public>:vector3
            End<public>:vector3
        }

        EvaluatePoints_Bezier_3D<public>(Points:[]vector3, Position:float)<decides><transacts>:tuple(vector3, [][]bezier_3D) = {
            Evaluate_Bezier_3D[MakeBezierLines_3D(Points), Position]
        }

        Evaluate_Bezier_3D<public>(BezierLines:[]bezier_3D, Position:float)<decides><transacts>:tuple(vector3, [][]bezier_3D) = {
            var CurrentCurveLines : []bezier_3D = GetChildBezierLines_3D(BezierLines, Position)
            var PastBezierLines : [][]bezier_3D = array{ BezierLines, CurrentCurveLines }

            loop {
                if (CurrentCurveLines.Length <= 1). break
                set CurrentCurveLines = GetChildBezierLines_3D(CurrentCurveLines, Position)
                set PastBezierLines += array{CurrentCurveLines}
            }

            (CurrentCurveLines[0].Mid, PastBezierLines)
        }

        MakeBezierLines_3D<public>(Points:[]vector3)<computes>:[]bezier_3D = {
            for (Point : Points). bezier_3D{
                Start := Point
                End := Point
                Mid := Point
            }
        }

        GetChildBezierLines_3D<public>(Points:[]bezier_3D, Position:float)<computes>:[]bezier_3D = {
            for (
                Index := 0..Points.Length - 2
                PointA := Points[Index].Mid
                PointB := Points[Index + 1].Mid
            ) {
                bezier_3D{
                    Start := PointA
                    End := PointB
                    Mid := vector3{
                        X := PointA.X + ((PointB.X - PointA.X) * Position)
                        Y := PointA.Y + ((PointB.Y - PointA.Y) * Position)
                        Z := PointA.Z + ((PointB.Z - PointA.Z) * Position)
                    }
                }
            }
        }

        # 2D Bezier

        bezier_2D<public> := class<computes> {
            Start<public>:vector2
            Mid<public>:vector2
            End<public>:vector2
        }

        EvaluatePoints_Bezier_2D<public>(Points:[]vector2, Position:float)<decides><transacts>:tuple(vector2, [][]bezier_2D) = {
            Evaluate_Bezier_2D[MakeBezierLines_2D(Points), Position]
        }

        Evaluate_Bezier_2D<public>(BezierLines:[]bezier_2D, Position:float)<decides><transacts>:tuple(vector2, [][]bezier_2D) = {
            var CurrentCurveLines : []bezier_2D = GetChildBezierLines_2D(BezierLines, Position)
            var PastBezierLines : [][]bezier_2D = array{ BezierLines, CurrentCurveLines }

            loop {
                if (CurrentCurveLines.Length <= 1). break
                set CurrentCurveLines = GetChildBezierLines_2D(CurrentCurveLines, Position)
                set PastBezierLines += array{CurrentCurveLines}
            }

            (CurrentCurveLines[0].Mid, PastBezierLines)
        }

        MakeBezierLines_2D<public>(Points:[]vector2)<computes>:[]bezier_2D = {
            for (Point : Points). bezier_2D{
                Start := Point
                End := Point
                Mid := Point
            }
        }

        GetChildBezierLines_2D<public>(Points:[]bezier_2D, Position:float)<computes>:[]bezier_2D = {
            for (
                Index := 0..Points.Length - 2
                PointA := Points[Index].Mid
                PointB := Points[Index + 1].Mid
            ) {
                bezier_2D{
                    Start := PointA
                    End := PointB
                    Mid := vector2{
                        X := PointA.X + ((PointB.X - PointA.X) * Position)
                        Y := PointA.Y + ((PointB.Y - PointA.Y) * Position)
                    }
                }
            }
        }

        DeCasteljau_3DV2<public>(Points:[]vector3, Position:float)<decides><transacts>:vector3 = {
            var Midpoints : []vector3 = Points

            loop {
                if (Midpoints.Length <= 1). break

                set Midpoints = for (
                    Index := 0..Midpoints.Length - 2
                    PointA := Midpoints[Index]
                    PointB := Midpoints[Index + 1]
                ) {
                    vector3{
                        X := PointA.X + ((PointB.X - PointA.X) * Position)
                        Y := PointA.Y + ((PointB.Y - PointA.Y) * Position)
                        Z := PointA.Z + ((PointB.Z - PointA.Z) * Position)
                    }
                }
            }

            Midpoints[0]
        }
    }
}
