using. /Verse.org/Random

using. BitMath
using. DateTime
using. Hexadecimal
using. StringProcessing

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

    # If true the node was randomly generated, else it's MAC address based
    IsRandomNode<public> : logic

    (uuid:)ToString<override>()<transacts>:string = {
        VersionTimeHigh := Version * 0x1000 + TimeHigh
        VariantClockSeq := Variant * 0x4000 + ClockSeq

        HexTimeLow := EncodeIntToHex[TimeLow] or Err("Unreachable")
        HexTimeMid := EncodeIntToHex[TimeMid] or Err("Unreachable")
        HexVersionTimeHigh := EncodeIntToHex[VersionTimeHigh] or Err("Unreachable")
        HexVariantClockSeq := EncodeIntToHex[VariantClockSeq] or Err("Unreachable")
        HexNode := EncodeIntToHex[Node] or Err("Unreachable")

        PadHexTimeLow := PadLeft(HexTimeLow, 8, '0')
        PadHexTimeMid := PadLeft(HexTimeMid, 4, '0')
        PadHexVersionTimeHigh := PadLeft(HexVersionTimeHigh, 4, '0')
        PadHexVariantClockSeq := PadLeft(HexVariantClockSeq, 4, '0')
        PadHexNode := PadLeft(HexNode, 12, '0')

        "{PadHexTimeLow}-{PadHexTimeMid}-{PadHexVersionTimeHigh}-{PadHexVariantClockSeq}-{PadHexNode}"
    }
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
    # TimeLow := BitwiseAnd(HundredNanoseconds, 0xFFFFFFFF)
    TimeLow := Mod[HundredNanoseconds, 0x100000000] or Err("Unreachable")
    # Extract middle 16 bits (bits 32-47)
    # TimeMid := BitwiseAnd(BitwiseRightShift(HundredNanoseconds, 32), 0xFFFF)
    TimeMid := Mod[Quotient[HundredNanoseconds, 0x100000000], 0x10000] or Err("Unreachable")
    # Extract most significant 12 bits (bits 48-59)
    # TimeHigh := BitwiseAnd(BitwiseRightShift(HundredNanoseconds, 48), 0xFFF)
    TimeHigh := Mod[Quotient[HundredNanoseconds, 0x1000000000000], 0x1000] or Err("Unreachable")

    ClockSeq := GeneratorData.ClockSequence
    Node := (
        # Get a random 48-bit number
        RandomRaw := GetRandomInt(0, 0xFFFFFFFFFFFF)

        # Get the multicast bit value (least significant bit of first byte octet)
        MulticastBit := Mod[Quotient[RandomRaw, 0x10000000000], 2] or Err("Unreachable")

        # If multicast bit is 0, set it to 1 to indicate random node ID
        MulticastBit = 0 and RandomRaw + 0x10000000000 or RandomRaw
    )

    IsRandomNode := true
}

CompileV1<public><constructor>(UUIDString:string)<decides><transacts> := uuid_v1{
    let {
        # Trims out existing hyphens from the UUID string
        CleanHex := for (Character : UUIDString, Character <> '-') { Character }

        # Ensures the cleaned hex string is exactly 32 characters long
        _Guard_Length := CleanHex.Length = 32

        # Extract each individual part of the UUID
        TimeLow := CleanHex.Slice[0, 8] or Err("Unreachable")           # 8 Chars
        TimeMid := CleanHex.Slice[8, 12] or Err("Unreachable")          # 4 Chars
        VersionTimeHigh := CleanHex.Slice[12, 16] or Err("Unreachable") # 4 Chars
        VariantClockSeq := CleanHex.Slice[16, 20] or Err("Unreachable") # 4 Chars
        Node := CleanHex.Slice[20, 32] or Err("Unreachable")            # 12 Chars

        # Convert each hex part into its integer representation
        IntTimeLow := DecodeHexToInt[TimeLow]
        IntTimeMid := DecodeHexToInt[TimeMid]
        IntVersionTimeHigh := DecodeHexToInt[VersionTimeHigh]
        IntVariantClockSeq := DecodeHexToInt[VariantClockSeq]
        IntNode := DecodeHexToInt[Node]

        # Extract and validate the version field
        Version := Quotient[IntVersionTimeHigh, 0x1000] or Err("Unreachable")
        _Guard_Version := Version = 1

        # Extract and validate the variant field
        Variant := Quotient[IntVariantClockSeq, 0x4000] or Err("Unreachable")
        _Guard_Variant := Variant = 2

        # Extract the actual time and clock sequence values
        IntTimeHigh := Mod[IntVersionTimeHigh, 0x1000] or Err("Unreachable")
        IntClockSeq := Mod[IntVariantClockSeq, 0x4000] or Err("Unreachable")

        # Determine if the node is random based on the multicast bit
        MulticastBit := Quotient[IntNode, 0x10000000000] or Err("Unreachable")
        IsRandomNode := logic{Mod[MulticastBit, 2] = 1}
    }

    TimeLow := IntTimeLow
    TimeMid := IntTimeMid
    TimeHigh := IntTimeHigh
    ClockSeq := IntClockSeq
    Node := IntNode
    IsRandomNode := IsRandomNode
}