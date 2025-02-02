using. /Verse.org/Simulation

SessionPlayerData<public> := module {

    var SessionPlayerDataMap<public>:weak_map(session, [player]session_player_data) = map{}

    session_player_data<public> := class {
        PlayerBackRef<public>:player
        # Playspace:fort_playspace
        var GlobalSubscriptions<private>:[]cancelable = array{}

        RegisterSubscription<public>(Subscription:cancelable):void = {
            set GlobalSubscriptions += array{Subscription}
        }

        CancelAllSubscriptions<public>():void = {
            for (Subscription:GlobalSubscriptions) {
                Subscription.Cancel()
            }
            set GlobalSubscriptions = array{}
        }
    }

    (Session:session).InitializeSessionDataMap<internal>()<transacts><decides>:void = {
        if (not SessionPlayerDataMap[Session]) {
            set SessionPlayerDataMap[Session] = map{}
        }
    }

    (Session:session).GetAllPlayersData<public>()<transacts><decides>:[player]session_player_data = {
        Session.InitializeSessionDataMap[]
        SessionPlayerDataMap[Session]
    }

    (Player:player).SaveSessionData<public>(NewSessionPlayerData:session_player_data)<transacts><decides>:void = {
        CurrentSession := GetSession()
        CurrentSession.InitializeSessionDataMap[]

        Player.IsActive[]
        set SessionPlayerDataMap[CurrentSession][Player] = NewSessionPlayerData
    }

    (Player : player).HasSessionDataData<public>()<transacts><decides> : void = {
        CurrentSession := GetSession()
        
        Player.IsActive[]
        SessionPlayerDataMap[CurrentSession][Player]
    }

    (Player:player).GetSessionData<public>()<transacts><decides>:session_player_data = {
        CurrentSession := GetSession()
        CurrentSession.InitializeSessionDataMap[]

        Player.IsActive[]
        if (ExistingPlayerData := SessionPlayerDataMap[CurrentSession][Player]) {
            return ExistingPlayerData
        } else {
            NewPlayerData := session_player_data{
                PlayerBackRef := Player
            }
            Player.SaveSessionData[NewPlayerData]
            return NewPlayerData
        }
    }

    (Player:player).DeleteSessionData<public>()<transacts><decides>:void = {
        CurrentSession := GetSession()
        CurrentSession.InitializeSessionDataMap[]

        var TempSessionPlayerDataMap:[player]session_player_data = map{}
        for (
            StoredPlayer->StoredPlayerData:CurrentSession.GetAllPlayersData[]
            StoredPlayer <> Player
            StoredPlayer.IsActive[]
            set TempSessionPlayerDataMap[StoredPlayer] = StoredPlayerData
        ) {}

        set SessionPlayerDataMap[CurrentSession] = TempSessionPlayerDataMap
    }
}