using. /Verse.org/Colors
using. /Verse.org/Simulation
using. /Verse.org/SpatialMath

using. CommonAssets.Particles.DebugDraw

line_debug_draw_component<public> := class<internal><final>(debug_draw_component) {

    ParticleSystemType<private> : subtype(NS_DebugDraw_Line) = NS_DebugDraw_Line

    @editable
    var<private> Start<public><final> : vector3 = vector3{}
    @editable
    var<private> End<public><final> : vector3 = vector3{}

    SetStart<public><final>(NewStart:vector3):void = {
        option { set ParticleSystemType[_ParticleSystem?].Start = NewStart }
        set Start = NewStart
    }

    SetEnd<public><final>(NewEnd:vector3):void = {
        option { set ParticleSystemType[_ParticleSystem?].End = NewEnd }
        set End = NewEnd
    }

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
                NS_DebugDraw_Line{
                    Entity := Entity

                    Enabled := true
                    AutoPlay := true

                    Color := Color
                    Thickness := Thickness
                    Duration := Duration

                    Start := Start
                    End := End
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