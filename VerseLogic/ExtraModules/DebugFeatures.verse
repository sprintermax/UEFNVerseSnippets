using. /Verse.org/Colors
using. /Verse.org/Simulation
using. /UnrealEngine.com/Temporary/Diagnostics

using. VerseFeatures

# I don't use this anymore, made for testing but daily usage of this on projects were not good enough.
# I plan to make a better logger module in the future
DebugFeatures<public> := module {

    Print<public>(Message:string, ReturnValue:t, ?Duration:float=2.0, (?Color:color=NamedColors.White) where t:type)<transacts>:t = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        ReturnValue
    }

    Print<public>(Message:message, ReturnValue:t, ?Duration:float=2.0, (?Color:color=NamedColors.White) where t:type)<transacts>:t = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        ReturnValue
    }

    Print<public>(Message:diagnostic, ReturnValue:t, ?Duration:float=2.0, (?Color:color=NamedColors.White) where t:type)<transacts>:t = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        ReturnValue
    }

    PrintAndFail<public>(Message:string, ?Duration:float=2.0, ?Color:color=NamedColors.White)<decides><transacts>:false = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        Failure[]
    }

    PrintAndFail<public>(Message:message, ?Duration:float=2.0, ?Color:color=NamedColors.White)<decides><transacts>:false = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        Failure[]
    }

    PrintAndFail<public>(Message:diagnostic, ?Duration:float=2.0, ?Color:color=NamedColors.White)<decides><transacts>:false = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        Failure[]
    }

    # Logger := class(log){}

    Logger<public> := module {
        log_variant<public> := enum {
            LogInformation # generic information messages that happens over time, usually for testing purposes such as debugging values
            LogSuccess # messages for very important operations that succeeced, used for informative reasons like keeping track when it happens during the game
            LogCosmetic # warning messages that don't affect the gameplay, for example with visual/cosmetic only things, the gameplay should still works fine
            LogWarning # warning messages that can affect how the gameplay logic works, may or may not break the game depending on how it's used
            LogError # critical errors that will always break the game, in a perfect scenario you should never see this on a project ready to release
        }

        # Arbitrary template for logging messages
        (Logger:)Log<public>(Data:any, ReturnValue:t, (?LogVariant:log_variant=log_variant.LogInformation) where t:type)<transacts>:t = {
            case (LogVariant) {
                log_variant.LogInformation => Print(ToDiagnostic(Data), ReturnValue, ?Duration := 2.0, ?Color := NamedColors.White)
                log_variant.LogSuccess => Print(ToDiagnostic(Data), ReturnValue, ?Duration:= 3.0, ?Color := NamedColors.Green)
                log_variant.LogCosmetic => Print(ToDiagnostic(Data), ReturnValue, ?Duration := 5.0, ?Color := NamedColors.SkyBlue)
                log_variant.LogWarning => Print(ToDiagnostic(Data), ReturnValue, ?Duration:= 7.5, ?Color := NamedColors.Yellow)
                log_variant.LogError => Print(ToDiagnostic(Data), ReturnValue, ?Duration:= 10.0, ?Color := NamedColors.Red)
            }
        }

        Log<public>(Data:any, ?LogVariant:log_variant=log_variant.LogInformation)<transacts>:void = {
            Log(Data, void, ?LogVariant := LogVariant)
        }

        LogAndFail<public>(Data:any, ?LogVariant:log_variant=log_variant.LogInformation)<decides><transacts>:false = {
            Log(Data, void, ?LogVariant := LogVariant)
            Failure[]
        }
    }

    message_logger<public> := interface {
        LogPrefix<public> : string = ""

        Log<public>(Data:any, ?LogVariant:Logger.log_variant=Logger.log_variant.LogInformation)<transacts>:void = Logger.Log(LogPrefix + ToDiagnostic(Data), void, ?LogVariant := LogVariant)
        (message_logger:)Log<public>(Data:any, ReturnValue:t, (?LogVariant:Logger.log_variant=Logger.log_variant.LogInformation) where t:type)<transacts>:t = Logger.Log(LogPrefix + ToDiagnostic(Data), ReturnValue, ?LogVariant := LogVariant)
        LogAndFail<public>(Data:any, ?LogVariant:Logger.log_variant=Logger.log_variant.LogInformation)<decides><transacts>:false = Logger.LogAndFail[LogPrefix + ToDiagnostic(Data), ?LogVariant := LogVariant]

        Log_Information<public>(Data:any)<transacts>:void = Logger.Log(LogPrefix + ToDiagnostic(Data), void, ?LogVariant := Logger.log_variant.LogInformation)
        Log_OperationSuccess<public>(Data:any)<transacts>:void = Logger.Log(LogPrefix + ToDiagnostic(Data), void, ?LogVariant := Logger.log_variant.LogSuccess)
        Log_CosmeticWarning<public>(Data:any)<transacts>:void = Logger.Log(LogPrefix + ToDiagnostic(Data), void, ?LogVariant := Logger.log_variant.LogCosmetic)
        Log_ConfigurationWarning<public>(Data:any)<transacts>:void = Logger.Log(LogPrefix + ToDiagnostic(Data), void, ?LogVariant := Logger.log_variant.LogWarning)
        Log_CriticalError<public>(Data:any)<transacts>:void = Logger.Log(LogPrefix + ToDiagnostic(Data), void, ?LogVariant := Logger.log_variant.LogError)

        # LogCallback_Information<public>(Data:any, ReturnValue:t where t:type)<transacts>:t = Logger.Log(LogPrefix + ToDiagnostic(Data), ReturnValue, ?LogVariant := Logger.log_variant.LogInformation)
        # LogCallback_OperationSuccess<public>(Data:any, ReturnValue:t where t:type)<transacts>:t = Logger.Log(LogPrefix + ToDiagnostic(Data), ReturnValue, ?LogVariant := Logger.log_variant.LogSuccess)
        # LogCallback_CosmeticWarning<public>(Data:any, ReturnValue:t where t:type)<transacts>:t = Logger.Log(LogPrefix + ToDiagnostic(Data), ReturnValue, ?LogVariant := Logger.log_variant.LogCosmetic)
        # LogCallback_ConfigurationWarning<public>(Data:any, ReturnValue:t where t:type)<transacts>:t = Logger.Log(LogPrefix + ToDiagnostic(Data), ReturnValue, ?LogVariant := Logger.log_variant.LogWarning)
        # LogCallback_CriticalError<public>(Data:any, ReturnValue:t where t:type)<transacts>:t = Logger.Log(LogPrefix + ToDiagnostic(Data), ReturnValue, ?LogVariant := Logger.log_variant.LogError)

        LogAndFail_Information<public>(Data:any)<decides><transacts>:false = Logger.LogAndFail[LogPrefix + ToDiagnostic(Data), ?LogVariant := Logger.log_variant.LogInformation]
        LogAndFail_OperationSuccess<public>(Data:any)<decides><transacts>:false = Logger.LogAndFail[LogPrefix + ToDiagnostic(Data), ?LogVariant := Logger.log_variant.LogSuccess]
        LogAndFail_CosmeticWarning<public>(Data:any)<decides><transacts>:false = Logger.LogAndFail[LogPrefix + ToDiagnostic(Data), ?LogVariant := Logger.log_variant.LogCosmetic]
        LogAndFail_ConfigurationWarning<public>(Data:any)<decides><transacts>:false = Logger.LogAndFail[LogPrefix + ToDiagnostic(Data), ?LogVariant := Logger.log_variant.LogWarning]
        LogAndFail_CriticalError<public>(Data:any)<decides><transacts>:false = Logger.LogAndFail[LogPrefix + ToDiagnostic(Data), ?LogVariant := Logger.log_variant.LogError]
    }



    ### Debug messages

    # Common Debug prefixes
    Msg_Debug_Prefix_Custom_Start<public>:string = "["
    Msg_Debug_Prefix_Custom_End<public>:string = "] "

    Msg_Debug_Prefix_Common_Error<public>:string = "[ERROR] "
    Msg_Debug_Prefix_Common_Warn<public>:string = "[WARN] "
    Msg_Debug_Prefix_Common_Info<public>:string = "[INFO] "
    Msg_Debug_Prefix_Common_Done<public>:string = "[DONE] "

    # Common and non-specific error messages
    Msg_Debug_General_AgentNotFound<public>:string = "An Agent was expected but not found."
    Msg_Debug_General_PlayerNotFound<public>:string = "A Player was expected but not found."
    Msg_Debug_General_PlayerInactive<public>:string = "An Active player was expected but not found."
    Msg_Debug_General_FortCharacterNotFound<public>:string = "A Fort Character was expected but not found."
    Msg_Debug_General_FortCharacterInactive<public>:string = "An Active Fort Character was expected but not found."
    Msg_Debug_General_PlayerUINotFound<public>:string = "Player UI was expected but not found."
    
    Msg_Debug_PersistablePlayerData_NotFound<public>:string = "Persistable data not found."
    Msg_Debug_PersistablePlayerData_GetFailed<public>:string = "Failed to get persistable data."
    Msg_Debug_PersistablePlayerData_SetFailed<public>:string = "Failed to save persistable data."
    Msg_Debug_PersistablePlayerData_SetSuccess<public>:string = "Successfully saved persistable data."

    Msg_Debug_SessionPlayerData_NotFound<public>:string = "Session data not found."
    Msg_Debug_SessionPlayerData_GetFailed<public>:string = "Failed to get session data."
    Msg_Debug_SessionPlayerData_SetFailed<public>:string = "Failed to save session data."
    Msg_Debug_SessionPlayerData_SetSuccess<public>:string = "Successfully saved session data."

    # Specific error messages
    Msg_Debug_Dependencies_Optional_Generic<public>:string = "An optional device [...]"
    Msg_Debug_Dependencies_Required_Generic<public>:string = "A required device was not found."
}