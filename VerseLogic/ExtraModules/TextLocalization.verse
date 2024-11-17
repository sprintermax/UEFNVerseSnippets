using { /Verse.org/Simulation }

TextLocalization<public> := module {
    ### Generic conversion methods
    MessageFromAgent<public><localizes>(Agent:agent):message = "{Agent}"
    MessageFromPlayer<public><localizes>(Player:player):message = "{Player}"
    MessageFromString<public><localizes>(String:string):message = "{String}"
    MessageFromInt<public><localizes>(Value:int):message = "{Value}"
    MessageFromFloat<public><localizes>(Value:float):message = "{Value}"

    ### Common and Placeholder localization texts
    Loc_Common_EmptyMessage<public><localizes>:message = ""
    Loc_Common_SingleSpace<public><localizes>:message = " "
    Loc_Common_Unknown<public><localizes>:message = "Unknown"
    Loc_Common_Missing<public><localizes>:message = "Missing"
    Loc_Common_Unavailable<public><localizes>:message = "Unavailable"
    Loc_Common_Placeholder<public><localizes>:message = "Placeholder"
    Loc_Common_Placeholder_Short<public><localizes>:message = "[PH]"

    ### Generic localization Texts
    Loc_Common_Number_0<public><localizes> : message = "0"
    Loc_Common_Number_1<public><localizes> : message = "1"
    Loc_Common_Number_2<public><localizes> : message = "2"
    Loc_Common_Number_3<public><localizes> : message = "3"
    Loc_Common_Number_4<public><localizes> : message = "4"
    Loc_Common_Number_5<public><localizes> : message = "5"
    Loc_Common_Number_6<public><localizes> : message = "6"
    Loc_Common_Number_7<public><localizes> : message = "7"
    Loc_Common_Number_8<public><localizes> : message = "8"
    Loc_Common_Number_9<public><localizes> : message = "9"

    ### User Interface messages
    Loc_Action_Close<public><localizes>:message = "Close"
    Loc_Action_CloseMenu<public><localizes>:message = "Close Menu"
    Loc_Action_Back<public><localizes>:message = "Back"
    Loc_Action_Delete<public><localizes>:message = "Delete"
    Loc_Action_Clear<public><localizes>:message = "Clear"

    Loc_Action_Previous<public><localizes>:message = "Previous"
    Loc_Action_PreviousPage<public><localizes>:message = "Previous Page"
    Loc_Action_PreviousIcon<public><localizes>:message = "◀" # "◀️"
    Loc_Action_Next<public><localizes>:message = "Next"
    Loc_Action_NextPage<public><localizes>:message = "Next Page"
    Loc_Action_NextIcon<public><localizes>:message = "▶" # "▶️"

    Loc_PlayerStatistics_Title<public><localizes>:message = "Player Statistics"

    Loc_Achievements_Title<public><localizes>:message = "ACHIEVEMENTS"

    Loc_ItemShop_Title<public><localizes>:message = "COSMETICS SHOP"
    Loc_ItemShop_Daily_Title<public><localizes>:message = "DAILY COSMETICS SHOP"
    Loc_ItemShop_Daily_RefreshMessage<public><localizes>(ClockText:string):message = "New items in: {ClockText}"

    Loc_Price_Free<public><localizes>:message = "FREE"

    Loc_Info_Owned<public><localizes>:message = "OWNED"
    Loc_Info_AlreadyOwned<public><localizes>:message = "ALREADY OWNED"
    Loc_Info_Purchased<public><localizes>:message = "PURCHASED"
    Loc_Info_AlreadyPurchased<public><localizes>:message = "Already Purchased"
    Loc_Info_Equipped<public><localizes>:message = "EQUIPPED"
    Loc_Info_AlreadyEquipped<public><localizes>:message = "Already Equipped"

    Loc_Action_Get<public><localizes>:message = "Get"
    Loc_Action_Purchase<public><localizes>:message = "Purchase"
    Loc_Action_RedeemCode<public><localizes>:message = "Redeem Code"
    Loc_Action_Equip<public><localizes>:message = "Equip"
    Loc_Action_Unequip<public><localizes>:message = "Unequip"
    
    Loc_Voting_VoteCount<public>(Count:int):message = {
        if (Count = 1). Loc_Voting_VoteCount_Singular(Count)
        else. Loc_Voting_VoteCount_Plural(Count)
    }
    Loc_Voting_VoteCount_Singular<public><localizes>(Count:int):message = "{Count} VOTE"
    Loc_Voting_VoteCount_Plural<public><localizes>(Count:int):message = "{Count} VOTES"

    Loc_Voting_RemainingToVote<public>(Count:int):message = {
        if (Count = 1). Loc_Voting_RemainingToVote_Singular(Count)
        else. Loc_Voting_RemainingToVote_Plural(Count)
    }
    Loc_Voting_RemainingToVote_Singular<public><localizes>(Count:int):message = "{Count} PLAYER REMAINING TO VOTE"
    Loc_Voting_RemainingToVote_Plural<public><localizes>(Count:int):message = "{Count} PLAYERS REMAINING TO VOTE"

    Loc_Voting_Vote<public><localizes>:message = "VOTE"
    Loc_Voting_Voted<public><localizes>:message = "VOTED"

    Loc_Inventory_Title<public><localizes>:message = "MY INVENTORY"
    Loc_Inventory_NoItemAvailable<public><localizes>:message = "NO ITEM AVAILABLE"
    Loc_Inventory_NothingAvailable<public><localizes>:message = "NOTHING AVAILABLE"

    ### Currencies
    Loc_Currency_NotEnough<public><localizes>:message = "NOT ENOUGH"

    Loc_Currency_ExperiencePoints_Name<public><localizes>:message = "Experience Points"

    ### Date and Time
    Loc_Time_ClockFormat<public>(Seconds:float, ?DisplayMiliseconds:logic = false):string = {
        var TimeString : string = "??:??:??"
        if (
            ClampedSeconds := Abs(Floor[Seconds])
            TimeSeconds := Abs(Mod[ClampedSeconds, 60])
            TimeMinutesTotal := Abs(Floor(ClampedSeconds / 60))
            TimeMinutes := Abs(Mod[Floor(ClampedSeconds / 60), 60])
            TimeHours := Abs(Floor(TimeMinutesTotal / 60))
        ) {
            if (TimeHours >= 10). set TimeString = "{TimeHours}:"
            else. set TimeString = "0{TimeHours}:"

            if (TimeMinutes >= 10). set TimeString += "{TimeMinutes}:"
            else. set TimeString += "0{TimeMinutes}:"

            if (TimeSeconds >= 10). set TimeString += "{TimeSeconds}"
            else. set TimeString += "0{TimeSeconds}"

            if (DisplayMiliseconds?) {
                TimeMiliseconds := Floor[(Seconds - ClampedSeconds * 1.0) * 1000] or 0
                
                if (TimeMiliseconds >= 100). set TimeString += ".{TimeMiliseconds}"
                else if (TimeMiliseconds >= 10). set TimeString += ".0{TimeMiliseconds}"
                else. set TimeString += ".00{TimeMiliseconds}"
            }
        }
        
        TimeString
    }

    ### Debug translation messages

    # Common Debug prefixes
    Loc_Debug_Prefix_Custom_Start<public><localizes>:message = "["
    Loc_Debug_Prefix_Custom_End<public><localizes>:message = "] "

    Loc_Debug_Prefix_Common_Error<public><localizes>:message = "[ERROR]"
    Loc_Debug_Prefix_Common_Warn<public><localizes>:message = "[WARN]"
    Loc_Debug_Prefix_Common_Info<public><localizes>:message = "[INFO]"
    Loc_Debug_Prefix_Common_Done<public><localizes>:message = "[DONE]"

    # Common and non-specific error messages
    Loc_Debug_General_AgentNotFound<public><localizes>:message = "An Agent was expected but not found."
    Loc_Debug_General_PlayerNotFound<public><localizes>:message = "A Player was expected but not found."
    Loc_Debug_General_PlayerNotFound_FromAgent<public><localizes>(Agent:agent):message = "A Player was expected for {Agent} but not found."
    Loc_Debug_General_FortCharacterNotFound<public><localizes>:message = "A Fort Character was expected but not found."
    Loc_Debug_General_FortCharacterNotFound_FromAgent<public><localizes>(Agent:agent):message = "A Fort Character was expected for {Agent} but not found."
    Loc_Debug_General_PlayerUINotFound<public><localizes>(Player:player):message = "Player UI was expected for \"{Player}\" but not found."

    Loc_Debug_PersistablePlayerData_NotFound<public><localizes>(Player:player):message = "Persistable data for \"{Player}\" not found."
    Loc_Debug_PersistablePlayerData_GetFailed<public><localizes>(Player:player):message = "Failed to get persistable data for \"{Player}\"."
    Loc_Debug_PersistablePlayerData_SetFailed<public><localizes>(Player:player):message = "Failed to save persistable data for \"{Player}\"."
    Loc_Debug_PersistablePlayerData_SetSuccess<public><localizes>(Player:player):message = "Successfully saved persistable data for \"{Player}\"."

    Loc_Debug_SessionPlayerData_NotFound<public><localizes>(Player:player):message = "Session data for \"{Player}\" not found."
    Loc_Debug_SessionPlayerData_GetFailed<public><localizes>(Player:player):message = "Failed to get session data for \"{Player}\"."
    Loc_Debug_SessionPlayerData_SetFailed<public><localizes>(Player:player):message = "Failed to save session data for \"{Player}\"."
    Loc_Debug_SessionPlayerData_SetSuccess<public><localizes>(Player:player):message = "Successfully saved session data for \"{Player}\"."

    # Specific error messages
}