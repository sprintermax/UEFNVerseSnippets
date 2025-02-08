using. /Verse.org/Colors
using. /Verse.org/Simulation
using. /UnrealEngine.com/Temporary/Diagnostics

using. VerseFeatures

# I don't use this anymore, made for testing but daily usage of this on projects were not good enough.
DebugFeatures<public> := module {

    PrintAndFail<public>(Message:string, ?Duration:float=2.0, ?Color:color=NamedColors.White)<transacts><decides>:void = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        Failure[]
    }

    PrintAndFail<public>(Message:message, ?Duration:float=2.0, ?Color:color=NamedColors.White)<transacts><decides>:void = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        Failure[]
    }

    PrintAndFail<public>(Message:diagnostic, ?Duration:float=2.0, ?Color:color=NamedColors.White)<transacts><decides>:void = {
        Print(Message, ?Duration := Duration, ?Color := Color)
        Failure[]
    }

    PrintAndFail<public>(Message:diagnostic, Value:t, (?Duration:float=2.0), (?Color:color=NamedColors.White) where t:subtype(any))<transacts><decides>:t = {
        PrintAndFail[Message, ?Duration := Duration, ?Color := Color]
        Err("Unreachable")
    }

    PrintAndFail<public>(Message:string, Value:t, (?Duration:float=2.0), (?Color:color=NamedColors.White) where t:subtype(any))<transacts><decides>:t = {
        PrintAndFail[Message, ?Duration := Duration, ?Color := Color]
        Err("Unreachable")
    }

    PrintAndFail<public>(Message:message, Value:t, (?Duration:float=2.0), (?Color:color=NamedColors.White) where t:subtype(any))<transacts><decides>:t = {
        PrintAndFail[Message, ?Duration := Duration, ?Color := Color]
        Err("Unreachable")
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

        # Arbitrary template for logging messages with default or custom values
        Log<public>(Text:string, ?LogVariant:log_variant = log_variant.LogInformation):void = {
            case (LogVariant) {
                log_variant.LogInformation => Print(Text, ?Duration := 2.0, ?Color := NamedColors.White)
                log_variant.LogSuccess => Print(Text, ?Duration:= 3.0, ?Color := NamedColors.Green)
                log_variant.LogCosmetic => Print(Text, ?Duration := 5.0, ?Color := NamedColors.SkyBlue)
                log_variant.LogWarning => Print(Text, ?Duration:= 7.5, ?Color := NamedColors.Yellow)
                log_variant.LogError => Print(Text, ?Duration:= 10.0, ?Color := NamedColors.Red)
            }
        }

        # Log templates
        Log_Information<public>(Text:string):void = Log(Text, ?LogVariant := log_variant.LogInformation)
        Log_OperationSuccess<public>(Text:string):void = Log(Text, ?LogVariant := log_variant.LogSuccess)
        Log_CosmeticWarning<public>(Text:string):void = Log(Text, ?LogVariant := log_variant.LogCosmetic)
        Log_ConfigurationWarning<public>(Text:string):void = Log(Text, ?LogVariant := log_variant.LogWarning)
        Log_CriticalError<public>(Text:string):void = Log(Text, ?LogVariant := log_variant.LogError)
    }

    prefixable_message_logger<public> := interface() {
        GetLogPrefix<public><localizes>():string
    }

    (PrefixableLogger:prefixable_message_logger).Log<public>(Text:string, ?LogVariant:Logger.log_variant = Logger.log_variant.LogInformation):void = Logger.Log(Msg_Debug_Prefix_Custom_Start + PrefixableLogger.GetLogPrefix() + Msg_Debug_Prefix_Custom_End + Text, ?LogVariant := LogVariant)
    (PrefixableLogger:prefixable_message_logger).Log_Information<public>(Text:string):void = Logger.Log_Information(Msg_Debug_Prefix_Custom_Start + PrefixableLogger.GetLogPrefix() + Msg_Debug_Prefix_Custom_End + Text)
    (PrefixableLogger:prefixable_message_logger).Log_OperationSuccess<public>(Text:string):void = Logger.Log_OperationSuccess(Msg_Debug_Prefix_Custom_Start + PrefixableLogger.GetLogPrefix() + Msg_Debug_Prefix_Custom_End + Text)
    (PrefixableLogger:prefixable_message_logger).Log_CosmeticWarning<public>(Text:string):void = Logger.Log_CosmeticWarning(Msg_Debug_Prefix_Custom_Start + PrefixableLogger.GetLogPrefix() + Msg_Debug_Prefix_Custom_End + Text)
    (PrefixableLogger:prefixable_message_logger).Log_ConfigurationWarning<public>(Text:string):void = Logger.Log_ConfigurationWarning(Msg_Debug_Prefix_Custom_Start + PrefixableLogger.GetLogPrefix() + Msg_Debug_Prefix_Custom_End + Text)
    (PrefixableLogger:prefixable_message_logger).Log_CriticalError<public>(Text:string):void = Logger.Log_CriticalError(Msg_Debug_Prefix_Custom_Start + PrefixableLogger.GetLogPrefix() + Msg_Debug_Prefix_Custom_End + Text)
    

    
    ### Debug messages

    # Common Debug prefixes
    Msg_Debug_Prefix_Custom_Start<public>:string = "["
    Msg_Debug_Prefix_Custom_End<public>:string = "] "

    Msg_Debug_Prefix_Common_Error<public>:string = "[ERROR]"
    Msg_Debug_Prefix_Common_Warn<public>:string = "[WARN]"
    Msg_Debug_Prefix_Common_Info<public>:string = "[INFO]"
    Msg_Debug_Prefix_Common_Done<public>:string = "[DONE]"

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