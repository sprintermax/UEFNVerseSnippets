using. /Fortnite.com/Devices
using. /Verse.org/Simulation

owningagent_interface<public> := interface {

    var _OwningAgent<private> : ?agent = false

    RegisterOwner<public>(Agent:agent):void = {
        set _OwningAgent = option{Agent}
    }

    UnregisterOwner<public>():void = {
        set _OwningAgent = false
    }

    GetOwningAgent<public>()<transacts><decides>:agent = {
        _OwningAgent?
    }
}