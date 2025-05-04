using. /Verse.org/Simulation

using. VerseFeatures

SessionPlayerData<public> := module {

    var SessionPlayerDataMap<public>:weak_map(session, [agent]session_player_data) = map{}

    session_player_data<public> := class {
        PlayerBackRef<public>:agent
        # Playspace:fort_playspace
        var GlobalSubscriptions<private>:[]cancelable = array{}

        # Stats
        var<private> Score<public>:int = 0

        RegisterSubscription<public>(Subscription:cancelable):void = {
            set GlobalSubscriptions += array{Subscription}
        }

        CancelAllSubscriptions<public>():void = {
            for (Subscription:GlobalSubscriptions) {
                Subscription.Cancel()
            }
            set GlobalSubscriptions = array{}
        }

        IsRealPlayer<public>()<transacts><decides>:void = player[PlayerBackRef]
    }

    (Session:session).InitializeSessionDataMap<internal>()<transacts><decides>:void = {
        if (not SessionPlayerDataMap[Session]) {
            set SessionPlayerDataMap[Session] = map{}
        }
    }

    (Session:session).GetAllPlayersData<public>()<transacts><decides>:[agent]session_player_data = {
        Session.InitializeSessionDataMap[]
        SessionPlayerDataMap[Session]
    }

    (Player:agent).SetSessionData<public>(NewSessionPlayerData:session_player_data)<transacts><decides>:void = {
        CurrentSession := GetSession()
        CurrentSession.InitializeSessionDataMap[]

        # Player.IsActive[]
        Player.IsValid[]
        set SessionPlayerDataMap[CurrentSession][Player] = NewSessionPlayerData
    }

    (Player:agent).HasSessionDataData<public>()<transacts><decides> : void = {
        CurrentSession := GetSession()
        
        # Player.IsActive[]
        Player.IsValid[]
        SessionPlayerDataMap[CurrentSession][Player]
    }

    (Player:agent).GetSessionData<public>()<transacts><decides>:session_player_data = {
        CurrentSession := GetSession()
        CurrentSession.InitializeSessionDataMap[]

        # Player.IsActive[]
        Player.IsValid[]
        if (ExistingPlayerData := SessionPlayerDataMap[CurrentSession][Player]) {
            return ExistingPlayerData
        } else {
            NewPlayerData := if (RealPlayer := player[Player]) {
                if (PPlayerData := RealPlayer.GetPersistableData[]) {
                    session_player_data{
                        PlayerBackRef := Player
                        Score := PPlayerData.Score
                    }
                } else {
                    Print("Failed to get persistable data for player, initializing default session data")
                    session_player_data{
                        PlayerBackRef := Player
                        Score := 0
                    }
                }
            } else {
                session_player_data{
                    PlayerBackRef := Player
                    Score := GetRandomInt(0, 100) # Example populating random data for Test Players or other Agents
                }
            }
            Player.SaveSessionData[NewPlayerData]
            return NewPlayerData
        }
    }

    (Player:agent).DeleteSessionData<public>()<transacts><decides>:void = {
        CurrentSession := GetSession()
        CurrentSession.InitializeSessionDataMap[]

        var TempSessionPlayerDataMap:[agent]session_player_data = map{}
        for (
            StoredPlayer->StoredPlayerData:CurrentSession.GetAllPlayersData[]
            StoredPlayer <> Player
            # StoredPlayer.IsActive[]
            StoredPlayer.IsValid[]
            set TempSessionPlayerDataMap[StoredPlayer] = StoredPlayerData
        ) {}

        set SessionPlayerDataMap[CurrentSession] = TempSessionPlayerDataMap
    }
}