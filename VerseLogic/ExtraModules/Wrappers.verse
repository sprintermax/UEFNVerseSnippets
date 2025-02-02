using. /UnrealEngine.com/Temporary/UI
using. /Verse.org/Simulation

Wrappers<public> := module {

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