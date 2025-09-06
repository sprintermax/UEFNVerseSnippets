using. /Fortnite.com/Game
using. /Verse.org/Concurrency
using. /Verse.org/SceneGraph
using. /Verse.org/Simulation

<#> For details and usage example, check this post on Epic Forums:
    https://dev.epicgames.com/community/snippets/558p/fortnite-fort-round-gameplay-interface-for-scene-graph-components
fort_round_simulate_interface<public> := interface {

    var<private> FortRoundManagerSubscriptions<private> : []cancelable = array{}

    var<private> _CancelFortRoundGameplayEvent<private> : ?event() = false
    var<private> _FortRoundGameplayHandlerTask<private> : ?task(void) = false

    var<private> IsFortRoundSimulating<public><final> : logic = false
    var<private> _FortRoundStartEvent<private> : ?event() = false
    var<private> _FortRoundEndEvent<private> : ?event() = false

    IsFortRoundGameplayActive<public><final>()<computes><decides><reads>:void = _FortRoundGameplayHandlerTask?

    <#> Start listening to Fort Round Events. Calling this before OnAddedToScene will silently fail.
        If Fort Round is already running, will trigger the FortRoundSimulate callbacks immediately.
    StartFortRoundGameplay<public><final>():void = {
        SelfComponent := if (_SelfComponent := component[Self]). _SelfComponent else. return
        if (not SelfComponent.IsInScene[]). return
        if (IsFortRoundSimulating?). OnFortRoundStartInternal()
        if (IsFortRoundGameplayActive[]). return
        if (FortRoundManager := SelfComponent.Entity.GetFortRoundManager[]) {
            InitializeEventsInternal()

            # Keeping the Round Subscriptions cached so they do not get garbage collected 
            set FortRoundManagerSubscriptions = array{
                FortRoundManager.SubscribeRoundStarted(OnFortRoundStartInternal)
                FortRoundManager.SubscribeRoundEnded(OnFortRoundEndInternal)
            }

            # Keeping the Task cached so it does not get garbage collected
            FortRoundGameplayHandlerTask := spawn { FortRoundGameplayHandler() }
            set _FortRoundGameplayHandlerTask = option{FortRoundGameplayHandlerTask}
        }
    }

    <#> Cancel the running FortRoundSimulate tasks, and stops listening for future Fort Round Events.
        Can be used during OnEndSimulation to stop the Fort Round Behavior when the component is removed from scene.
    StopFortRoundGameplay<public><final>():void = {
        for (FortRoundManagerSubscription : FortRoundManagerSubscriptions) {
            FortRoundManagerSubscription.Cancel()
        }
        set FortRoundManagerSubscriptions = array{}

        set _FortRoundGameplayHandlerTask = false
        OnFortRoundEndInternal()
        if (CancelFortRoundGameplayEvent := _CancelFortRoundGameplayEvent?). CancelFortRoundGameplayEvent.Signal()
    }

    <#> Need to construct the events outside interface construction due to a bug
        where events created at interface initialization are acting as global.
    InitializeEventsInternal<private>()<transacts>:void = {
        if (not _CancelFortRoundGameplayEvent?). set _CancelFortRoundGameplayEvent = option{event(){}}
        if (not _FortRoundStartEvent?). set _FortRoundStartEvent = option{event(){}}
        if (not _FortRoundEndEvent?). set _FortRoundEndEvent = option{event(){}}
    }

    OnFortRoundStartInternal<private>():void = {
        if (IsFortRoundSimulating?). return
        set IsFortRoundSimulating = true
        if (FortRoundStartEvent := _FortRoundStartEvent?). FortRoundStartEvent.Signal()
    }
    OnFortRoundEndInternal<private>():void = {
        if (not IsFortRoundSimulating?). return
        set IsFortRoundSimulating = false
        if (FortRoundEndEvent := _FortRoundEndEvent?). FortRoundEndEvent.Signal()
    }

    FortRoundGameplayHandler<private>()<suspends>:void = {
        race {
            if (CancelFortRoundGameplayEvent := _CancelFortRoundGameplayEvent?). CancelFortRoundGameplayEvent.Await()
            FortRoundLifetimeHandler()
        }
    }

    FortRoundLifetimeHandler<private>()<suspends>:void = {
        loop {
            if (FortRoundStartEvent := _FortRoundStartEvent?). FortRoundStartEvent.Await()
            race {
                if (FortRoundEndEvent := _FortRoundEndEvent?). FortRoundEndEvent.Await() else. Sleep(Inf)
                (OnFortRoundBeginSimulation(); OnFortRoundSimulate(); Sleep(Inf))
            }
            OnFortRoundEndSimulation()
        }
    }

    AwaitFortRoundStart<public><final>()<suspends>:void = {
        if (IsFortRoundSimulating?). return 
        InitializeEventsInternal()
        if (FortRoundStartEvent := _FortRoundStartEvent?). FortRoundStartEvent.Await()
    }

    AwaitFortRoundEnd<public><final>()<suspends>:void = {
        InitializeEventsInternal()
        if (FortRoundEndEvent := _FortRoundEndEvent?). FortRoundEndEvent.Await()
    }

    OnFortRoundBeginSimulation<public>():void = {}

    OnFortRoundSimulate<public>()<suspends>:void = {}

    OnFortRoundEndSimulation<public>():void = {}
}