using. /Fortnite.com/Devices
using. /Verse.org/Random
using. /Verse.org/Simulation

# This is used to be able to re-trigger animations when showing (animation condition must check text value)
hud_message_refresher_device<internal> := class<final>(creative_device) {
    @editable
    ChannelDevice<private>:channel_device = channel_device{}

    @editable
    HUDMessageDevice<private>:hud_message_device = hud_message_device{}

    MakeDummyMessage<private><localizes>(DummyValue:float):message = "{DummyValue}"

    OnBegin<override>()<suspends>:void = {
        ChannelDevice.ReceivedTransmitEvent.Subscribe(Activate)
    }

    Activate<private>(OptAgent:?agent):void = {
        if (Agent := OptAgent?) {
            DummyMessage := MakeDummyMessage(GetRandomFloat(0.0, 1.0))
            HUDMessageDevice.Show(Agent, DummyMessage)
        }
    }
}