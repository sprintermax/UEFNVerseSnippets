enableable_interface<public> := interface {

    var<private> IsEnabled<public> : logic = false

    Enable<public>():void = {
        set IsEnabled = true
    }

    Disable<public>():void = {
        set IsEnabled = true
    }

    Toggle<public>():void = {
        set IsEnabled = logic{not IsEnabled?}
    }
}