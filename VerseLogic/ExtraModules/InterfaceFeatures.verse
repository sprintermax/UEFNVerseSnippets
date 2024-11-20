using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }

InterfaceFeatures<public> := module {

    (Widget:widget).ForceRedraw<public>():void = {
        Widget.SetEnabled(false)
        Widget.SetEnabled(true)
    }

    (Canvas:canvas).AddWidgetAndForceRedraw<public>(Slot:canvas_slot) : void = {
        Canvas.AddWidget(Slot)
        Canvas.ForceRedraw()
    }

    (Canvas:canvas).RemoveWidgetAndForceRedraw<public>(Widget:widget) : void = {
        Canvas.RemoveWidget(Widget)
        Canvas.ForceRedraw()
    }

    operator'+'<public>(MarginA:margin, MarginB:margin)<transacts>:margin = margin{
        Left := MarginA.Left + MarginB.Left
        Top := MarginA.Top + MarginB.Top
        Right := MarginA.Right + MarginB.Right
        Bottom := MarginA.Bottom + MarginB.Bottom
    }

    operator'+'<public>(Margin:margin, Value:float)<transacts>:margin = margin{
        Left := Margin.Left + Value
        Top := Margin.Top + Value
        Right := Margin.Right + Value
        Bottom := Margin.Bottom + Value
    }

    operator'-'<public>(MarginA:margin, MarginB:margin)<transacts>:margin = margin{
        Left := MarginA.Left - MarginB.Left
        Top := MarginA.Top - MarginB.Top
        Right := MarginA.Right - MarginB.Right
        Bottom := MarginA.Bottom - MarginB.Bottom
    }

    operator'-'<public>(Margin:margin, Value:float)<transacts>:margin = margin{
        Left := Margin.Left - Value
        Top := Margin.Top - Value
        Right := Margin.Right - Value
        Bottom := Margin.Bottom - Value
    }
    
    operator'*'<public>(MarginA:margin, MarginB:margin)<transacts>:margin = margin{
        Left := MarginA.Left * MarginB.Left
        Top := MarginA.Top * MarginB.Top
        Right := MarginA.Right * MarginB.Right
        Bottom := MarginA.Bottom * MarginB.Bottom
    }

    operator'*'<public>(Margin:margin, Value:float)<transacts>:margin = margin{
        Left := Margin.Left * Value
        Top := Margin.Top * Value
        Right := Margin.Right * Value
        Bottom := Margin.Bottom * Value
    }

    operator'/'<public>(MarginA:margin, MarginB:margin)<transacts>:margin = margin{
        Left := MarginA.Left / MarginB.Left
        Top := MarginA.Top / MarginB.Top
        Right := MarginA.Right / MarginB.Right
        Bottom := MarginA.Bottom / MarginB.Bottom
    }

    operator'/'<public>(Margin:margin, Value:float)<transacts>:margin = margin{
        Left := Margin.Left / Value
        Top := Margin.Top / Value
        Right := Margin.Right / Value
        Bottom := Margin.Bottom / Value
    }

    AnchorPresets<public> := module {
        TopLeft<public>():anchors = anchors{
            Minimum := vector2{X := 0.0, Y := 0.0}
            Maximum := vector2{X := 0.0, Y := 0.0}
        }
        TopMiddle<public>():anchors = anchors{
            Minimum := vector2{X := 0.5, Y := 0.0}
            Maximum := vector2{X := 0.5, Y := 0.0}
        }
        TopRight<public>():anchors = anchors{
            Minimum := vector2{X := 1.0, Y := 0.0}
            Maximum := vector2{X := 1.0, Y := 0.0}
        }
        LeftMiddle<public>():anchors = anchors{
            Minimum := vector2{X := 0.0, Y := 0.5}
            Maximum := vector2{X := 0.0, Y := 0.5}
        }
        Center<public>():anchors = anchors{
            Minimum := vector2{X := 0.5, Y := 0.5}
            Maximum := vector2{X := 0.5, Y := 0.5}
        }
        RightMiddle<public>():anchors = anchors{
            Minimum := vector2{X := 1.0, Y := 0.5}
            Maximum := vector2{X := 1.0, Y := 0.5}
        }
        BottomLeft<public>():anchors = anchors{
            Minimum := vector2{X := 0.0, Y := 1.0}
            Maximum := vector2{X := 0.0, Y := 1.0}
        }
        BottomMiddle<public>():anchors = anchors{
            Minimum := vector2{X := 0.5, Y := 1.0}
            Maximum := vector2{X := 0.5, Y := 1.0}
        }
        BottomRight<public>():anchors = anchors{
            Minimum := vector2{X := 1.0, Y := 1.0}
            Maximum := vector2{X := 1.0, Y := 1.0}
        }

        Full<public>():anchors = anchors{
            Minimum := vector2{X := 0.0, Y := 0.0}
            Maximum := vector2{X := 1.0, Y := 1.0}
        }
        PointAt<public>(Position:vector2):anchors = anchors{
            Minimum := Position
            Maximum := Position
        }

        Custom<public>(MinX:float, MaxX:float, MinY:float, MaxY:float):anchors = anchors{
            Minimum := vector2{X := MinX, Y := MaxX}
            Maximum := vector2{X := MinY, Y := MaxY}
        }
    }

    AlignmentPresets<public> := module {
        TopLeft<public>:vector2 = vector2{X := 0.0, Y := 0.0 }
        TopMiddle<public>:vector2 = vector2{X := 0.5, Y := 0.0 }
        TopRight<public>:vector2 = vector2{X := 1.0, Y := 0.0 }
        LeftMiddle<public>:vector2 = vector2{X := 0.0, Y := 0.5 }
        Center<public>:vector2 = vector2{X := 0.5, Y := 0.5 }
        RightMiddle<public>:vector2 = vector2{X := 1.0, Y := 0.5 }
        BottomLeft<public>:vector2 = vector2{X := 0.0, Y := 1.0 }
        BottomMiddle<public>:vector2 = vector2{X := 0.5, Y := 1.0 }
        BottomRight<public>:vector2 = vector2{X := 1.0, Y := 1.0 }
    }

    MarginPresets<public> := module {
        NoMargin<public>()<transacts>:margin = margin{
            Left := 0.0
            Top := 0.0
            Right := 0.0
            Bottom := 0.0
        }
        SinglePixel<public>()<transacts>:margin = margin{
            Left := 1.0
            Top := 1.0
            Right := 1.0
            Bottom := 1.0
        }

        LTRB<public>(Left:float, Top:float, Right:float, Bottom:float)<transacts> : margin = margin{
            Left := Left
            Top := Top
            Right := Right
            Bottom := Bottom
        }
    }

    ContainerWithBorder<public>(
        Content:widget,
        ?ContentPadding:?margin = false,
        ?BorderSize:float = 3.0,
        ?BorderColor:color = NamedColors.White,
        ?BorderOpacity:type{_X:float where 0.0 <= _X, _X <= 1.0} = 0.25,
        ?BackgroundColor:color = NamedColors.Black,
        ?BackgroundOpacity:type{_X:float where 0.0 <= _X, _X <= 1.0} = 0.75
    ): overlay = {
        var OverlayElements:[]overlay_slot = array{}
            
        if (BorderSize > 0.0 and BorderOpacity > 0.0) {
            set OverlayElements += array{
                # Border Top
                overlay_slot{
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Top
                    Widget := color_block{
                        DefaultColor := BorderColor
                        DefaultOpacity := BorderOpacity
                        DefaultDesiredSize := vector2{
                            X := BorderSize
                            Y := BorderSize
                        }
                    }
                }
                # Border Bottom
                overlay_slot{
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Bottom
                    Widget := color_block{
                        DefaultColor := BorderColor
                        DefaultOpacity := BorderOpacity
                        DefaultDesiredSize := vector2{
                            X := BorderSize
                            Y := BorderSize
                        }
                    }
                }
                # Border Left
                overlay_slot{
                    Padding := margin{
                        Left := 0.0
                        Top := BorderSize
                        Right := 0.0
                        Bottom := BorderSize
                    }
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := color_block{
                        DefaultColor := BorderColor
                        DefaultOpacity := BorderOpacity
                        DefaultDesiredSize := vector2{
                            X := BorderSize
                            Y := BorderSize
                        }
                    }
                }
                # Border Right
                overlay_slot{
                    Padding := margin{
                        Left := 0.0
                        Top := BorderSize
                        Right := 0.0
                        Bottom := BorderSize
                    }
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := color_block{
                        DefaultColor := BorderColor
                        DefaultOpacity := BorderOpacity
                        DefaultDesiredSize := vector2{
                            X := BorderSize
                            Y := BorderSize
                        }
                    }
                }
            }
        }
        
        if (BackgroundOpacity > 0.0) {
            set OverlayElements += array{
                overlay_slot{
                    Padding := MarginPresets.SinglePixel() * BorderSize
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := color_block{
                        DefaultColor := BackgroundColor
                        DefaultOpacity := BackgroundOpacity
                    }
                }
            }
        }

        set OverlayElements += array{
            overlay_slot{
                Padding := ContentPadding? or MarginPresets.NoMargin()
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment := vertical_alignment.Center
                Widget := Content
            }
        }
        overlay{Slots := OverlayElements}
    }
}