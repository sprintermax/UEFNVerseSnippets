using. /Verse.org/Random

using. BitMath
using. DateTime

#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                           time_low                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |           time_mid            |  ver  |       time_high       |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |var|         clock_seq         |             node              |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                              node                             |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# time_low:     The least significant 32 bits of the 60-bit starting timestamp. Occupies bits 0 through 31 (octets 0-3).
# time_mid:     The middle 16 bits of the 60-bit starting timestamp. Occupies bits 32 through 47 (octets 4-5).
# ver:          The 4-bit version field as defined by Section 4.2, set to 0b0001 (1). Occupies bits 48 through 51 of octet 6.
# time_high:    The least significant 12 bits from the 60-bit starting timestamp. Occupies bits 52 through 63 (octets 6-7).
# var:          The 2-bit variant field as defined by Section 4.1, set to 0b10. Occupies bits 64 and 65 of octet 8.
# clock_seq:    The 14 bits containing the clock sequence. Occupies bits 66 through 79 (octets 8-9).
# node:         48-bit spatially unique identifier. Occupies bits 80 through 127 (octets 10-15). The node field consists of an IEEE 802 MAC address, usually the host address or a randomly derived value per Sections 6.9 and 6.10.

uuid_v1<public> := class<internal><computes><final>(uuid) {
    Version<override><final> : int = 0x01   #  4 bits (0b0001)
    Variant<override><final> : int = 0x02   #  2 bits (0b10)

    TimeLow<public> : int                   # 32 bits
    TimeMid<public> : int                   # 16 bits
    TimeHigh<public> : int                  # 12 bits
    
    ClockSeq<public> : int                  # 14 bits
    Node<public> : int                      # 48 bits
}

NewV1<public><constructor>()<transacts> := uuid_v1{
    let {
        GeneratorData := GetUUIDGeneratorData()
        _Unused := GeneratorData.Update()

        UnixSeconds := GeneratorData.LastTimestamp
        GregorianSeconds := UnixToGregorian(UnixSeconds)
        HundredNanoseconds := SecondsToHundredNanoseconds[GregorianSeconds] or Err("Unreachable")
    }

    # Extract least significant 32 bits (bits 0-31)
    TimeLow := BitwiseAnd(HundredNanoseconds, 0xFFFFFFFF)
    # Extract middle 16 bits (bits 32-47)
    TimeMid := BitwiseAnd(BitwiseRightShift(HundredNanoseconds, 32), 0xFFFF)
    # Extract most significant 12 bits (bits 48-59)
    TimeHigh := BitwiseAnd(BitwiseRightShift(HundredNanoseconds, 48), 0xFFF)

    ClockSeq := GeneratorData.ClockSequence
    Node := (
        RandomRaw := GetRandomInt(0, 0x3A7183E601999) # Random 48-bit number
        WithMulticast := RandomRaw + 0x10000000000 - Mod[RandomRaw, 20000000000] # Set multicast bit (least significant bit of first byte) to 1
        Mod[WithMulticast, 0x1000000000000] # Ensure it's 48 bits
    ) or Err("Unreachable")
}