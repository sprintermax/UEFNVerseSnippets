# https://www.rfc-editor.org/rfc/rfc9562.html

using. /Verse.org/Random
using. /Verse.org/Simulation

using. DateTime

var<internal> UUIDGeneratorData<internal> : weak_map(session, uuid_generator_data) = map{}

uuid_generator_data<internal> := class<internal><computes><allocates> {
    var<private> LastTimestamp<internal> : float
    var<private> ClockSequence<internal> : int

    Update<internal>()<transacts>:void = {
        UnixSeconds := GetSecondsSinceEpoch()
        GregorianSeconds := UnixToGregorian(UnixSeconds)
        HundredNanoseconds := SecondsToHundredNanoseconds[GregorianSeconds] or Err("Unreachable")

        if (UnixSeconds <= Self.LastTimestamp) {
            set Self.ClockSequence = Mod[Self.ClockSequence + 1, 0x4000] or Err("Unreachable")
        }

        set Self.LastTimestamp = UnixSeconds
    }
}

GetUUIDGeneratorData<internal>()<transacts>:uuid_generator_data = {
    Session := GetSession()
    UUIDGeneratorData[Session] or (
        set UUIDGeneratorData[Session] = uuid_generator_data{
            LastTimestamp := GetSecondsSinceEpoch()
            ClockSequence := Mod[GetRandomInt(0, 0x4000), 0x4000] or Err("Unreachable")
        }
    ) or Err("Unreachable")
}

uuid<public> := class<internal><abstract><computes> {
    Version<public> : int
    Variant<public> : int

    (uuid:)ToString<public>()<computes><reads>:string
}

ToString<public>((local:)UUID:uuid)<computes><reads>:string = (local:)UUID.ToString()