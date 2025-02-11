using. /Fortnite.com/Game
using. /UnrealEngine.com/Temporary/UI
using. /Verse.org/Simulation

Wrappers<public> := module {

    instant_callback_wrapper_delayed<internal>(PassThroughType:type)<computes> := class {
        Proxy(Payload:PassThroughType)<suspends>:void = Callback.Signal(Payload)
        Callback : event(PassThroughType) = event(PassThroughType){}
    }

    instant_callback_wrapper<internal>(PassThroughType:type)<computes> := class {
        Proxy(Payload:PassThroughType):void = Callback.Signal(Payload)
        Callback : event(PassThroughType) = event(PassThroughType){}
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

    wrapper_generic(PassThroughType:type, DataType:type)<computes> := class<computes> {
        ExtraData:DataType
        Callback:tuple(PassThroughType, DataType) -> void
        Proxy(Payload:PassThroughType):void = Callback(Payload, ExtraData)
    }
    
    (Subscribable:subscribable(PassThroughType) where PassThroughType:type).Subscribe<public>(Callback:tuple(PassThroughType, DataType) -> void, ExtraData:DataType where DataType:type)<transacts> : cancelable = {
        Wrapper := wrapper_generic(PassThroughType, DataType) {ExtraData := ExtraData, Callback := Callback}
        Subscribable.Subscribe(Wrapper.Proxy)
    }

    wrapper_agent(DataType : type)<computes> := class<computes> {
        ExtraData : DataType
        Callback : tuple(agent, DataType) -> void
        Proxy(Args : agent):void = Callback(Args, ExtraData)
    }

    (Listenable : listenable(agent)).SubscribeAgent<public>(Callback : tuple(agent, DataType)->void, ExtraData : DataType where DataType:type)<transacts> : cancelable = {
        Wrapper := wrapper_agent(DataType){ExtraData := ExtraData, Callback := Callback}
        Listenable.Subscribe(Wrapper.Proxy)
    }

    wrapper_optagent(DataType : type)<computes> := class<computes> {
        ExtraData : DataType
        Callback : tuple(?agent, DataType) -> void
        Proxy(Args : ?agent):void = Callback(Args, ExtraData)
    }

    (Listenable : listenable(?agent)).SubscribeOptAgent<public>(Callback : tuple(?agent, DataType)->void, ExtraData : DataType where DataType:type)<transacts> : cancelable = {
        Wrapper := wrapper_optagent(DataType){ExtraData := ExtraData, Callback := Callback}
        Listenable.Subscribe(Wrapper.Proxy)
    }

    wrapper_widget_message(t:type)<computes> := class<computes> {
        ExtraData:t;
        Callback:tuple(widget_message, t) -> void
        Proxy(WidgetMessage:widget_message):void = Callback(WidgetMessage, ExtraData)
    }

    (Listenable:listenable(widget_message)).SubscribeWidgetMessage<public>(Callback:tuple(widget_message, t)->void, ExtraData:t where t:type)<transacts> :cancelable = {
        Listenable.Subscribe(wrapper_widget_message(t){ExtraData := ExtraData, Callback := Callback}.Proxy)
    }
}