using. /Fortnite.com/Game
using. /Verse.org/Concurrency
using. /Verse.org/Simulation

Wrappers<public> := module {

    function_sync<public>(args_type:type, return_type:type)<converges> := type{_(:args_type):return_type}
    function_sync<public>(args_type:type, payload_type:type, return_type:type)<converges> := type{_(:args_type, :payload_type):return_type}
    function_async<public>(args_type:type, return_type:type)<converges> := type{_(:args_type)<suspends>:return_type}
    function_async<public>(args_type:type, payload_type:type, return_type:type)<converges> := type{_(:args_type, :payload_type)<suspends>:return_type}

    event_callback_wrapper<public>(passthrough_type:type)<converges> := class {
        Proxy<public>(Passthrough:passthrough_type):any = Callback.Signal(Passthrough)
        Callback<public>:event(passthrough_type) = event(passthrough_type){}
    }

    wrapper_empty<public>(return_type:type)<converges> := class<computes> {
        Proxy<public>(:any):task(return_type) = spawn. Callback()
        Callback<public>:function_async(tuple(), return_type)
    }

    wrapper_passthrough<public>(passthrough_type:type, return_type:type)<converges> := class<computes> {
        Proxy<public>(Passthrough:passthrough_type):task(return_type) = spawn. Callback(Passthrough)
        Callback<public>:function_async(passthrough_type, return_type)
    }

    wrapper_payload<public>(data_type:type, return_type:type)<converges> := class<computes> {
        Proxy(:any):task(return_type) = spawn. Callback(Payload)
        Callback<public>:function_async(data_type, return_type)
        Payload<public>:data_type
    }

    wrapper_args_payload<public>(passthrough_type:type, data_type:type, return_type:type)<converges> := class<computes> {
        Proxy<public>(Passthrough:passthrough_type):task(return_type) = spawn { Callback(Passthrough, Payload) }
        Callback<public>:function_async(passthrough_type, data_type, return_type)
        Payload<public>:data_type
    }

    # Allow <suspends>, invokes callback with original args
    (Subscribable:subscribable(passthrough_type)).SubscribeTo<public>(Callback:function_async(passthrough_type, return_type) where passthrough_type:type, return_type:type)<transacts> : cancelable = {
        Subscribable.(/Verse.org/Verse/subscribable:)Subscribe(wrapper_passthrough(passthrough_type, return_type){Callback := Callback}.Proxy)
    }

    # Allow <suspends>, invokes callback ignoring original args
    (Subscribable:subscribable(passthrough_type)).Invoke<public>(Callback:function_async(tuple(), return_type) where passthrough_type:type, return_type:type)<transacts> : cancelable = { # TEST function_empty?
        Subscribable.(/Verse.org/Verse/subscribable:)Subscribe(wrapper_empty(return_type){Callback := Callback}.Proxy)
    }

    # Allow <suspends>, invokes callback with original args + custom Payload
    (Subscribable:subscribable(passthrough_type)).SubscribeArgs<public>(Callback:function_async(passthrough_type, data_type, return_type), Payload:data_type where passthrough_type:type, data_type:type, return_type:type)<transacts> : cancelable = {
        Subscribable.(/Verse.org/Verse/subscribable:)Subscribe(wrapper_args_payload(passthrough_type, data_type, return_type){Callback := Callback, Payload := Payload}.Proxy)
    }

    # Allow <suspends>, invokes callback with custom Payload ignoring original args
    (Subscribable:subscribable(passthrough_type)).InvokeArgs<public>(Callback:function_async(data_type, return_type), Payload:data_type where passthrough_type:type, data_type:type, return_type:type)<transacts> : cancelable = {
        Subscribable.(/Verse.org/Verse/subscribable:)Subscribe(wrapper_payload(data_type, return_type){Callback := Callback, Payload := Payload}.Proxy)
    }

    # Made mainly for usage with 'fort_round_manager' (Scene Graph)
    # But not yet supported by verse :(
    (Handler:function_async(function_sync(passthrough_type, any), cancelable) where passthrough_type:type).Await<public>()<suspends>:void = {
        Wrapper := event_callback_wrapper(passthrough_type){}
        race {
            Wrapper.Callback.Await()
            block {
                Subscription := Handler(Wrapper.Proxy)
                defer. Subscription.Cancel()
                Sleep(Inf)
            }
        }
    }

    # Obsolete due to the above .Await()
    (RoundManager:fort_round_manager).AwaitRoundStart<public>()<suspends>:void = {
        Wrapper := event_callback_wrapper(tuple()){}
        race {
            Wrapper.Callback.Await()
            block {
                RoundManager.SubscribeRoundStarted(Wrapper.Proxy)
                Sleep(Inf)
            }
        }
    }

    (RoundManager:fort_round_manager).AwaitRoundEnd<public>()<suspends>:void = {
        Wrapper := event_callback_wrapper(tuple()){}
        race {
            Wrapper.Callback.Await()
            block {
                RoundManager.SubscribeRoundEnded(Wrapper.Proxy)
                Sleep(Inf)
            }
        }
    }

    # Not using built-in 'subscribable()' and 'cancelable()' interfaces because of current verse limitations
    subscription_task<public>(payload_type:type)<converges> := class<internal> {
        Callback<internal>:function_async(payload_type, void)
        Proxy<internal>:event(payload_type)

        CancelEvent<private> : event() = event(){}

        Cancel<public>():void = {
            CancelEvent.Signal()
        }

        TaskHandler<private>()<suspends>:void = {
            race {
                CancelEvent.Await()
                loop {
                    Payload := Proxy.Await()
                    Callback(Payload)
                }
            }
        }

        Listen<internal>():subscription_task(payload_type) = {
            spawn. TaskHandler()
            Self
        }
    }

    subscribable_event<public>(payload_type:type)<converges> := class(
        awaitable(payload_type),
        signalable(payload_type)
    ) {
        EmitEvent<private> : event(payload_type) = event(payload_type){}

        (subscribable_event:)Subscribe<public>(Callback:function_async(payload_type, void)):subscription_task(payload_type) = {
            subscription_task(payload_type) {
                Callback := Callback
                Proxy := EmitEvent
            }.Listen()
        }

        Signal<override>(Payload:payload_type):void = {
            EmitEvent.Signal(Payload)
        }

        Await<override>()<suspends>:payload_type = {
            EmitEvent.Await()
        }
    }
}