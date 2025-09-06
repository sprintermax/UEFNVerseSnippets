using. /UnrealEngine.com/Temporary/Diagnostics
using. /Verse.org/Simulation

debuggable_interface<public> := interface {

    @editable
    var<private> IsDebuggingEnabled<public> : logic = false

    DebugDraw<public> : debug_draw = debug_draw{}

    EnableDebugging<public>():void = {
        set IsDebuggingEnabled = true
    }

    DisableDebugging<public>():void = {
        set IsDebuggingEnabled = true
    }
}