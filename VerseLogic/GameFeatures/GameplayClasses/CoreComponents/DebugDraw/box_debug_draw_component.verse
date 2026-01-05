using. /Verse.org/Colors
using. /Verse.org/Simulation
using. /Verse.org/SpatialMath

using. CommonAssets.Particles.DebugDraw

box_debug_draw_component<public> := class<internal><final>(debug_draw_component) {

    ParticleSystemType<private> : subtype(NS_DebugDraw_Box) = NS_DebugDraw_Box

    @editable
    var<private> Center<public><final> : vector3 = vector3{}
    @editable
    var<private> Rotation<public><final> : rotation = rotation{}
    @editable
    var<private> Extent<public><final> : vector3 = vector3{}

    SetCenter<public><final>(NewCenter:vector3):void = {
        option { set ParticleSystemType[_ParticleSystem?].Center = NewCenter }
        set Center = NewCenter
    }

    SetRotation<public><final>(NewRotation:rotation):void = {
        # option { set ParticleSystemType[_ParticleSystem?].Rotation = NewRotation }
        option { set ParticleSystemType[_ParticleSystem?].RotationAxis = Rotation.GetAxis() }
        option { set ParticleSystemType[_ParticleSystem?].RotationAngle = Rotation.GetAngleRadians() }
        set Rotation = NewRotation
    }

    SetExtent<public><final>(NewExtent:vector3):void = {
        option { set ParticleSystemType[_ParticleSystem?].Extent = NewExtent }
        set Extent = NewExtent
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
                NS_DebugDraw_Box{
                    Entity := Entity

                    Enabled := true
                    AutoPlay := true

                    Color := Color
                    Thickness := Thickness
                    Duration := Duration

                    Center := Center
                    # Rotation := Rotation
                    RotationAxis := Rotation.GetAxis()
                    RotationAngle := Rotation.GetAngleRadians()
                    Extent := Extent
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