# Converts Unix seconds (since January 1, 1970 UTC) to Gregorian seconds (since October 15, 1582)
UnixToGregorian<public>(UnixSeconds:float)<computes>:float = {
    return UnixSeconds + GregorianUnixOffset
}

# Converts Gregorian seconds (since October 15, 1582) to Unix seconds (since January 1, 1970 UTC)
GregorianToUnix<public>(GregorianSeconds:float)<computes>:float = {
    return GregorianSeconds - GregorianUnixOffset
}

# Converts Seconds float to Miliseconds int
# Fails if `not IsFinite[Seconds]`
SecondsToMiliseconds<public>(Seconds:float)<computes><decides><reads>:int = {
    return Int[Seconds * 1e3]
}

# Converts Seconds float to Nanoseconds int
# Fails if `not IsFinite[Seconds]`
SecondsToNanoseconds<public>(Seconds:float)<computes><decides><reads>:int = {
    return Int[Seconds * 1e9]
}

# Converts Seconds float to Hundred Nanoseconds int (100ns units)
# Fails if `not IsFinite[Seconds]`
SecondsToHundredNanoseconds<public>(Seconds:float)<computes><decides><reads>:int = {
    return Int[Seconds * 1e7]
}

# Converts Miliseconds int to Seconds float
MilisecondsToSeconds<public>(Miliseconds:int)<computes>:float = {
    return (Miliseconds * 1.0) / 1e3
}

# Converts Nanoseconds int to Seconds float
NanosecondsToSeconds<public>(Nanoseconds:int)<computes>:float = {
    return (Nanoseconds * 1.0) / 1e9
}

# Converts Hundred Nanoseconds int (100ns units) to Seconds float
HundredNanosecondsToSeconds<public>(HundredNanoseconds:int)<computes>:float = {
    return (HundredNanoseconds * 1.0) / 1e7
}