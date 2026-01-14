using. /UnrealEngine.com/Temporary/Diagnostics
using. /Verse.org/Simulation

# WIP: Development of this is paused due to lack of flexibility with computes and default logger class
# Wanted to make it all <computes>, to create a new log class it needs to be in a <transacts> context

default_log_channel<internal> := class(log_channel) {}
# Logger := log{Channel := default_log_channel}

(_Log:log).Panic<public>()<computes>:false = {
    Panic(?Logger:=option{_Log})
}

# `?__:void=void` is a trick to bypass verse compiler complaining about function ambiguity
(_Log:log).Panic<public>(Message:string, ?__:void=void)<computes>:false = {
    Panic(Message, ?Logger:=option{_Log})
}

Panic<public>(?Logger:?log=false)<computes>:false = {
    Panic("User raised a panic without providing a message.", ?Logger:=Logger)
}

# Logs a panic message and throws a runtime error to stop execution.
# If a logger is provided, it will log the panic message and stack trace.
Panic<public>(Message:string, ?Logger:?log=false)<computes>:false = {
    option{
        _Logger := Logger?
        _Logger.Print("🚨 PANIC: {Message}")
        _Logger.Print("Stack Trace Follows:")
        _Logger.PrintCallStack()
    }
    KnowMoreInfo := Logger? and "\nSee logs for aditional details." or ""
    Err("PANIC: {Message}{KnowMoreInfo}")
}

# Unsafe call, it expect to always succeed, or else will throw a runtime error.
#
# It was made for usage on places where the result is already known to always succeed, such
# as defining constants and avoiding patterns like `Something[] or Err("Unreachable")`
Must<public>(Function:type{_(:t)<decides><transacts>:t2}, Args:t where t:type, t2:type)<transacts>:t2 = {
    Function[Args] or Panic("A function call expected to always succeed has failed.")
}
Must<public>(Result:result(t, any) where t:type)<computes>:t = {
    Result.GetSuccess[] or Panic("A result unwrapping expected to always succeed has failed.")
}
Must<public>(Optional:?t where t:type)<computes>:t = {
    Optional? or Panic("An optional unwrapping expected to always succeed has failed.")
}