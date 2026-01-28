using. /Fortnite.com/Game
using. /UnrealEngine.com/Temporary/UI
using. /Verse.org/Concurrency
using. /Verse.org/Simulation

Wrappers<public> := module {

    instant_callback_wrapper_delayed<internal>(PassThroughType:type)<computes> := class {
        Proxy<internal>(Payload:PassThroughType)<suspends>:void = Callback.Signal(Payload)
        Callback<internal>:event(PassThroughType) = event(PassThroughType){}
    }

    instant_callback_wrapper<internal>(PassThroughType:type)<computes> := class {
        Proxy<internal>(Payload:PassThroughType):void = Callback.Signal(Payload)
        Callback<internal>:event(PassThroughType) = event(PassThroughType){}
    }

    wrapper_empty<internal>(PassThroughType:type)<computes> := class<computes> {
        Proxy(Payload:PassThroughType):any = spawn { Callback() }
        Callback:type{_()<suspends>:any}
    }

    wrapper_basic<internal>(PassThroughType:type, DataType:type)<computes> := class<computes> {
        Proxy(Payload:PassThroughType):any = spawn { Callback(ExtraData) }
        Callback:type{_(:DataType)<suspends>:any}
        ExtraData:DataType
    }

    wrapper_generic<internal>(PassThroughType:type, DataType:type)<computes> := class<computes> {
        Proxy(Payload:PassThroughType):any = spawn { Callback(Payload, ExtraData) }
        Callback:type{_(:PassThroughType, :DataType)<suspends>:any}
        ExtraData:DataType
    }

    (Awaitable:awaitable(t)).Await<public>(MaxTimeout:float where t:type)<suspends>:?t = {
        race {
            (EventData := Awaitable.Await(); option{EventData})
            (Sleep(MaxTimeout); false)
        }
    }

    (Awaitable:awaitable(t)).AwaitFor<public>((Query:t, ?MaxTimeout:float=Inf) where t:subtype(comparable))<suspends>:logic = {
        race {
            (loop {
                EventData := Awaitable.Await()
                if (EventData = Query). break
            }; true)
            (Sleep(MaxTimeout); false)
        }
    }
        
    (RoundManager:fort_round_manager).AwaitRoundStart<public>()<suspends>:void = {
        Wrapper := instant_callback_wrapper_delayed(void){}
        race {
            Wrapper.Callback.Await()
            block {
                RoundManager.SubscribeRoundStarted(Wrapper.Proxy)
                Sleep(Inf)
            }
        }
    }

    (RoundManager:fort_round_manager).AwaitRoundEnd<public>()<suspends>:void = {
        Wrapper := instant_callback_wrapper(void){}
        race {
            Wrapper.Callback.Await()
            block {
                RoundManager.SubscribeRoundEnded(Wrapper.Proxy)
                Sleep(Inf)
            }
        }
    }
    
    (Subscribable:subscribable(PassThroughType)).Subscribe<public>(Callback:type{_(:PassThroughType, :DataType)<suspends>:any}, Payload:DataType where PassThroughType:type, DataType:type)<transacts> : cancelable = {
        Wrapper := wrapper_generic(PassThroughType, DataType) {Callback := Callback, ExtraData := Payload}
        Subscribable.Subscribe(Wrapper.Proxy)
    }

    (Subscribable:subscribable(PassThroughType)).Invoke<public>((Callback:type{_()<suspends>:any}) where PassThroughType:type)<transacts> : cancelable = {
        Wrapper := wrapper_empty(PassThroughType) {Callback := Callback}
        Subscribable.Subscribe(Wrapper.Proxy)
    }

    (Subscribable:subscribable(PassThroughType)).InvokeArgs<public>(Callback:type{_(:DataType)<suspends>:any}, Payload:DataType where PassThroughType:type, DataType:type)<transacts> : cancelable = {
        Wrapper := wrapper_basic(PassThroughType, DataType) {Callback := Callback, ExtraData := Payload}
        Subscribable.Subscribe(Wrapper.Proxy)
    }

    # Not using built-in 'subscribable()' and 'cancelable()' interfaces because of current verse limitations
    subscription_task<public>(t:type)<computes> := class<internal> {
        Callback<internal>:type{_(:t):void}
        Proxy<internal>:event(t)

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

        Listen<internal>():subscription_task(t) = {
            spawn. TaskHandler()
            Self
        }
    }

    subscribable_event<public>(t:type)<computes> := class(
        awaitable(t),
        signalable(t)
    ) {
        EmitEvent<private> : event(t) = event(t){}

        (subscribable_event:)Subscribe<public>(Callback:type{_(:t):void}):subscription_task(t) = {
            subscription_task(t) {
                Callback := Callback
                Proxy := EmitEvent
            }.Listen()
        }

        Signal<override>(Payload:t):void = {
            EmitEvent.Signal(Payload)
        }

        Await<override>()<suspends>:t = {
            EmitEvent.Await()
        }
    }

    # The methods bellow should be obsolete with the new parametric version above
    # (Listenable : listenable(agent)).SubscribeAgent<public>(Callback : type{_(:agent, :DataType):void}, ExtraData : DataType where DataType:type)<transacts> : cancelable = {
    #     Wrapper := wrapper_generic(agent, DataType){ExtraData := ExtraData, Callback := Callback}
    #     Listenable.Subscribe(Wrapper.Proxy)
    # }

    # (Listenable : listenable(?agent)).SubscribeOptAgent<public>(Callback : type{_(:?agent, :DataType):void}, ExtraData : DataType where DataType:type)<transacts> : cancelable = {
    #     Wrapper := wrapper_generic(?agent, DataType){ExtraData := ExtraData, Callback := Callback}
    #     Listenable.Subscribe(Wrapper.Proxy)
    # }

    # (Listenable:listenable(widget_message)).SubscribeWidgetMessage<public>(Callback:type{_(:widget_message, :DataType):void}, ExtraData:DataType where DataType:type)<transacts> :cancelable = {
    #     Listenable.Subscribe(wrapper_generic(widget_message, DataType){ExtraData := ExtraData, Callback := Callback}.Proxy)
    # }
}