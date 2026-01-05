using. /Verse.org/Colors
using. /Verse.org/SceneGraph
using. /Verse.org/Simulation
using. /Verse.org/SpatialMath

debug_draw_channel<public> := class<concrete><unique><final> {
    var<private> DrawInstances<private><final> : []debug_draw_component = array{}

    AddInstance<internal><final>(InstanceToAdd:debug_draw_component)<transacts>:void = {
        option {
            not DrawInstances.Find[InstanceToAdd]
            set DrawInstances += array{InstanceToAdd}
        }
    }

    RemoveInstance<internal><final>(InstanceToRemove:debug_draw_component)<transacts>:void = {
        option {
            InstanceIndex := DrawInstances.Find[InstanceToRemove]
            NewDrawInstances := DrawInstances.RemoveElement[InstanceIndex]
            set DrawInstances = NewDrawInstances
        }
    }

    Show<public><final>():void = {
        for (DrawInstance : DrawInstances) {
            DrawInstance.Show()
        }
    }
    Hide<public><final>():void = {
        for (DrawInstance : DrawInstances) {
            DrawInstance.Hide()
        }
    }
    Clear<public><final>():void = {
        for (DrawInstance : DrawInstances) {
            DrawInstance.SetChannel(false)
            DrawInstance.Clear()
        }
    }
}

debug_draw_component<public> := class<internal><abstract><final_super>(component) {

    Entity<override><final> : entity = entity{}

    var<protected> _ParticleSystem<internal> : ?particle_system_component = false

    var<protected> Channel<private><final> : ?debug_draw_channel = false
    
    @editable
    var<protected> Color<public><final> : color = MakeColorFromHex("#FF0000")
    @editable
    var<protected> Thickness<public><final> : float = 1.0
    @editable
    var<protected> Duration<public><final> : float = Inf

    IsShown<public><final>()<decides><transacts>:void = {
        IsInScene[] and _ParticleSystem?.IsEnabled[]
    }

    SetColor<public>(NewColor:color):void = {
        set Color = NewColor
    }

    SetThickness<public>(NewThickness:float):void = {
        set Thickness = NewThickness
    }

    SetDuration<public>(NewDuration:float):void = {
        set Duration = NewDuration
        if (IsShown[]). Show()
    }

    GetChannel<public><final>()<computes><reads><decides>:debug_draw_channel = Channel?
    SetChannel<public><final>(NewChannel:?debug_draw_channel)<transacts>:void = {
        if (NewChannel = Channel). return

        option { Channel?.RemoveInstance(Self) }
        option { NewChannel?.AddInstance(Self) }

        set Channel = NewChannel
    }

    Show<public><final>(ParentEntity:entity):void = {
        ParentEntity.AddEntities(array{Entity})
        Show()
    }

    Show<public><final>():void = {
        ShowParticleEvent.Signal()
    }
    Hide<public><final>():void = {
        HideParticleEvent.Signal()
    }
    Clear<public><final>():void = {
        Hide()
        Entity.RemoveFromParent()
    }

    ShowParticleEvent<private><final> : event() = event(){}
    HideParticleEvent<private><final> : event() = event(){}

    OnAddedToScene<override>():void = {
        ParticleSystem := _ParticleSystem? or (return)
        Entity.AddComponents(array{ParticleSystem})
    }

    # OnBeginSimulation<override>():void = {}

    OnSimulate<override>()<suspends>:void = {
        ParticleSystem := _ParticleSystem? or (return)
        loop {
            ParticleSystem.Enable()
            race {
                HideParticleEvent.Await()
                loop {
                    Timeout := race {
                        (ShowParticleEvent.Await(); false)
                        (Sleep(Duration); true)
                    }
                    if (Timeout?). break
                }
            }
            ParticleSystem.Disable()
            ShowParticleEvent.Await()
        }
    }

    # OnEndSimulation<override>():void = {}

    # OnRemovingFromScene<override>():void = {}
}