using. /Fortnite.com/Game
using. /Verse.org/Concurrency
using. /Verse.org/SceneGraph
using. /Verse.org/Simulation

physics_tick_events_interface<public> := interface {

    var<private> PhysicsTickEventsSubscriptions<private> : []cancelable = array{}

    var<private> IsPhysicsTickEventsActive<public><final> : logic = false
    var<private> _OnPrePhysicsEvent<private> : ?event(float) = false
    var<private> _OnPostPhysicsEvent<private> : ?event(float) = false

    StartPhysicsTickEvents<public><final>(TickEvents:tick_events):void = {
        if (IsPhysicsTickEventsActive?). return

        InitializeEventsInternal()

        set PhysicsTickEventsSubscriptions = array{
            TickEvents.PrePhysics.Subscribe(OnPrePhysicsInternal)
            TickEvents.PostPhysics.Subscribe(OnPostPhysicsInternal)
        }

        set IsPhysicsTickEventsActive = true
    }

    <#> Cancel the running FortRoundSimulate tasks, and stops listening for future Fort Round Events.
        Can be used during OnEndSimulation to stop the Fort Round Behavior when the component is removed from scene.
    StopPhysicsTickEvents<public><final>():void = {
        for (PhysicsTickEventsSubscription : PhysicsTickEventsSubscriptions) {
            PhysicsTickEventsSubscription.Cancel()
        }
        set PhysicsTickEventsSubscriptions = array{}

        set IsPhysicsTickEventsActive = false
    }
    
    InitializeEventsInternal<private>()<transacts>:void = {
        if (not _OnPrePhysicsEvent?). set _OnPrePhysicsEvent = option{event(float){}}
        if (not _OnPostPhysicsEvent?). set _OnPostPhysicsEvent = option{event(float){}}
    }

    AwaitPrePhysics<public><final>()<suspends>:float = {
        InitializeEventsInternal()
        if (OnPrePhysicsEvent := _OnPrePhysicsEvent?). OnPrePhysicsEvent.Await() else. Err("Unreachable")
    }

    AwaitPostPhysics<public><final>()<suspends>:float = {
        InitializeEventsInternal()
        if (OnPostPhysicsEvent := _OnPostPhysicsEvent?). OnPostPhysicsEvent.Await() else. Err("Unreachable")
    }

    OnPrePhysicsInternal<private>(DeltaTime:float):void = {
        if (OnPrePhysicsEvent := _OnPrePhysicsEvent?). OnPrePhysicsEvent.Signal(DeltaTime)
        OnPrePhysics(DeltaTime)
    }

    OnPostPhysicsInternal<private>(DeltaTime:float):void = {
        if (OnPostPhysicsEvent := _OnPostPhysicsEvent?). OnPostPhysicsEvent.Signal(DeltaTime)
        OnPostPhysics(DeltaTime)
    }

    OnPrePhysics<public>(DeltaTime:float):void = {}
    OnPostPhysics<public>(DeltaTime:float):void = {}
}