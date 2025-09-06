using. /Fortnite.com/Devices
using. /Verse.org/Simulation/Tags

GameplayTags<public> := module {

    # Debug Tags
    VTAG_DebugObject<public> := class(tag){}

    # Base Logic Tags
    VTAG_CreativeObject<public> := class(VTAG_DebugObject){}
    VTAG_CreativeProp<public> := class(VTAG_CreativeObject){}
    VTAG_FortniteDevice<public> := class(VTAG_CreativeObject){}
    VTAG_VerseDevice<public> := class(VTAG_CreativeObject){}

    # Base Creative Devices
    VTAG_AccoladeDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_BarrierDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_BillboardDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_ButtonDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_ChannelDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_CinematicSequenceDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_HUDMessageDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_InputTriggerDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_MutatorZoneDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_PlayerReferenceDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_PlayerSpawnerDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_PopUpDialogDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_RoundSettingsDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_SkyDiveVolumeDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_SwitchDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_TeleporterDevice<public> := class(VTAG_FortniteDevice){}
    VTAG_TriggerDevice<public> := class(VTAG_FortniteDevice){}
}