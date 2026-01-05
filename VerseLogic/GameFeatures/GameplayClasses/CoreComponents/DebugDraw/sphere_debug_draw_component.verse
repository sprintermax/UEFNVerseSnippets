using. /Verse.org/Colors
using. /Verse.org/Simulation
using. /Verse.org/SpatialMath

using. CommonAssets.Particles.DebugDraw

sphere_debug_draw_component<public> := class<internal><final>(debug_draw_component) {

    ParticleSystemType<private> : subtype(NS_DebugDraw_Sphere) = NS_DebugDraw_Sphere

    @editable
    var<private> Center<public><final> : vector3 = vector3{}
    @editable
    var<private> Radius<public><final> : float = 50.0
    @editable
    var<private> NumSegments<public><final> : int = 1

    SetCenter<public><final>(NewCenter:vector3):void = {
        option { set ParticleSystemType[_ParticleSystem?].Center = NewCenter }
        set Center = NewCenter
    }

    SetRadius<public><final>(NewRadius:float):void = {
        option { set ParticleSystemType[_ParticleSystem?].Radius = NewRadius }
        set Radius = NewRadius
    }

    SetNumSegments<public><final>(NewNumSegments:int):void = {
        option { set ParticleSystemType[_ParticleSystem?].NumSegments = NewNumSegments }
        set NumSegments = NewNumSegments
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
                NS_DebugDraw_Sphere{
                    Entity := Entity

                    Enabled := true
                    AutoPlay := true

                    Color := Color
                    Thickness := Thickness
                    Duration := Duration

                    Center := Center
                    Radius := Radius
                    NumSegments := NumSegments
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