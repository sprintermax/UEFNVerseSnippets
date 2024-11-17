using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }

Wrappers<public> := module {

    wrapper_agent(DataType : type) := class() {
        ExtraData : DataType
        OutputFunc : tuple(agent, DataType) -> void
        InputFunc(Args : agent):void = OutputFunc(Args, ExtraData)
    }

    (Listenable : listenable(agent)).SubscribeAgent<public>(OutputFunc : tuple(agent, DataType)->void, ExtraData : DataType where DataType:type) : cancelable = {
        Wrapper := wrapper_agent(DataType){ExtraData := ExtraData, OutputFunc := OutputFunc}
        Listenable.Subscribe(Wrapper.InputFunc)
    }

    wrapper_optagent(DataType : type) := class() {
        ExtraData : DataType
        OutputFunc : tuple(?agent, DataType) -> void
        InputFunc(Args : ?agent):void = OutputFunc(Args, ExtraData)
    }

    (Listenable : listenable(?agent)).SubscribeOptAgent<public>(OutputFunc : tuple(?agent, DataType)->void, ExtraData : DataType where DataType:type) : cancelable = {
        Wrapper := wrapper_optagent(DataType){ExtraData := ExtraData, OutputFunc := OutputFunc}
        Listenable.Subscribe(Wrapper.InputFunc)
    }

    wrapper_widget_message(t:type) := class {
        ExtraData:t;
        OutputFunc:tuple(widget_message, t) -> void
        InputFunc(WidgetMessage:widget_message):void = OutputFunc(WidgetMessage, ExtraData)
    }

    (Listenable:listenable(widget_message)).Subscribe<public>(OutputFunc:tuple(widget_message, t)->void, ExtraData:t where t:type):cancelable = {
        Listenable.Subscribe(wrapper_widget_message(t){ExtraData := ExtraData, OutputFunc := OutputFunc}.InputFunc)
    }
}