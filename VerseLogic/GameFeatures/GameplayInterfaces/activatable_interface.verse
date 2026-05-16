using. /Verse.org/Simulation

activatable_interface<public> := interface<public> {

    @editable
    ActivationDelay<public> : ?type{_X : float where _X >= 0.0, _X <= 0.3} = false

    ActivateEvent<public> : event()
    CancelActivationEvent<public> : event()

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