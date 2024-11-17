# https://dev.epicgames.com/documentation/en-us/uefn/using-persistable-data-in-verse
# https://dev.epicgames.com/documentation/en-us/uefn/persistent-player-statistics-in-unreal-editor-for-fortnite

using { /Verse.org/Simulation }

PersistablePlayerData<public> := module {

    var PersistablePlayerDataMap<public>:weak_map(player, persistable_player_data) = map{}

    persistable_player_data<public> := class<final><persistable> {
        # Versioning
        PersistentDataVersion<public>:int = 0 # Last Played Version of Persistable Data
        LastViewedPatchVersion<public>:int = 0 # Last Patch Notes Seen
        
        # Global Stats
    }

    (Player:player).MakePersistableData<public><constructor>(Source:persistable_player_data)<transacts> := persistable_player_data {
        PersistentDataVersion := Source.PersistentDataVersion
        LastViewedPatchVersion := Source.LastViewedPatchVersion

    }

    (Player:player).SavePersistableData<public>(NewPersistablePlayerData:persistable_player_data)<transacts><decides>:void = {
        Player.IsActive[]
        set PersistablePlayerDataMap[Player] = NewPersistablePlayerData
    }

    (Player : player).HasPersistableData<public>()<transacts><decides> : void = {
        Player.IsActive[]
        PersistablePlayerDataMap[Player]
    }

    (Player:player).GetPersistableData<public>()<transacts><decides>:persistable_player_data = {
        Player.IsActive[]
        if (ExistingPlayerData := PersistablePlayerDataMap[Player]) {
            return ExistingPlayerData
        } else {
            NewPlayerData := persistable_player_data{}
            Player.SavePersistableData[NewPlayerData]
            return NewPlayerData
        }
    }

    (Player:player).DeletePersistableData<public>()<transacts><decides>:void = {
        Player.IsActive[]
        NewPlayerData := persistable_player_data{}
        Player.SavePersistableData[NewPlayerData]
    }
}