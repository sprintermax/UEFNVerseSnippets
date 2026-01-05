using. /Verse.org/Colors
using. /Verse.org/SpatialMath

using. CommonAssets.Particles.DebugDraw

point_debug_draw_component<public> := class<internal><final>(debug_draw_component) {

    ParticleSystemType<private> : subtype(NS_DebugDraw_Point) = NS_DebugDraw_Point

    SetColor<override><final>(NewColor:color):void = {
        option { set ParticleSystemType[_ParticleSystem?].Color = NewColor }
        (super:)SetColor(NewColor)
    }

    SetThickness<override><final>(NewThickness:float):void = {
        option { set ParticleSystemType[_ParticleSystem?].Thickness = NewThickness }
        (super:)SetThickness(NewThickness)
    }

    SetDuration<override><final>(NewDuration:float):void = {
        option { set ParticleSystemType[_ParticleSystem?].Duration = NewDuration }
        (super:)SetDuration(NewDuration)
    }

    OnAddedToScene<override><final>():void = {
        option {
            not _ParticleSystem?
            set _ParticleSystem = option {
                NS_DebugDraw_Point{
                    Entity := Entity

                    Enabled := true
                    AutoPlay := true

                    Color := Color
                    Thickness := Thickness
                    Duration := Duration
                }
            }
        }
        (super:)OnAddedToScene()
    }

    # OnBeginSimulation<override>():void = {}

    # OnSimulate<override>()<suspends>:void = {}

    # OnEndSimulation<override>():void = {}

    # OnRemovingFromScene<override>():void = {}
}