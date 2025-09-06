using. /Verse.org/Simulation

activatable_interface<public> := interface {

    @editable
    ActivationDelay<public> : ?type{_X : float where _X >= 0.0, _X <= 0.3} = false

    ActivateEvent<protected> : event()
    CancelActivationEvent<protected> : event()

    Activate<public>()<suspends>:void = {
        race {
            CancelActivationEvent.Await()
            block {
                Sleep(ActivationDelay? or -1.0)
                ActivateEvent.Signal()
            }
        }
    }

    AwaitActivation<public>()<suspends>:void = {
        ActivateEvent.Await()
    }
}