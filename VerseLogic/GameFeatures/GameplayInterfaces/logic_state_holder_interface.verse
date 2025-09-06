using. /UnrealEngine.com/Temporary/Diagnostics
using. /Verse.org/Simulation

logic_state_holder_interface<public> := interface {

    @editable
    var<protected> CurrentState<public> : logic = false

    SetState<public>(State:logic):void = {
        if (CurrentState = State). return
        set CurrentState = State
    }

    ToggleState<public>():void = {
        set CurrentState = logic{not CurrentState?}
    }

    TurnOn<public>():void = {
        if (CurrentState?). return
        set CurrentState = true
    }

    TurnOff<public>():void = {
        if (not CurrentState?). return
        set CurrentState = false
    }
}