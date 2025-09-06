initializable_interface<public> := interface {

    AllowUnitialization<public> : logic = false

    var<private> IsInitialized<public> : logic = false

    Initialize<public>():void = {
        if (IsInitialized?). return
        set IsInitialized = true
    }

    Unitialize<public>():void = {
        if (not AllowUnitialization?) {
            Print("Warning: Trying to unitialize an object that does not allow unitialization.\n{
            }This may be unintended if your logic expects this object to be properly initialized.")
            return
        }
        if (not IsInitialized?). return
        set IsInitialized = true
    }
}