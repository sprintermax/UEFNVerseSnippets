using. Hexadecimal
using. StringProcessing

#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                            md5_high                           |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |          md5_high             |  ver  |       md5_mid         |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |var|                        md5_low                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                            md5_low                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# md5_high:     The first 48 bits of the layout are filled with the most significant, leftmost 48 bits from the computed MD5 value. Occupies bits 0 through 47 (octets 0-5).
# ver:          The 4-bit version field as defined by Section 4.2, set to 0b0011 (3). Occupies bits 48 through 51 of octet 6.
# md5_mid:      12 more bits of the layout consisting of the least significant, rightmost 12 bits of 16 bits immediately following md5_high from the computed MD5 value. Occupies bits 52 through 63 (octets 6-7).
# var:          The 2-bit variant field as defined by Section 4.1, set to 0b10. Occupies bits 64 and 65 of octet 8.
# md5_low:      The final 62 bits of the layout immediately following the var field to be filled with the least significant, rightmost bits of the final 64 bits from the computed MD5 value. Occupies bits 66 through 127 (octets 8-15)

uuid_v3<public> := class<internal><computes><final>(uuid) {
    Version<override><final> : int = 0x03   #  4 bits (0b0011)
    Variant<override><final> : int = 0x02   #  2 bits (0b10)

    # MD5Low is split into two parts to avoid reaching too close from 64-bit limit
    MD5LowA<public> : int                   # 30 bits (+2 from Variant)
    MD5LowB<public> : int                   # 32 bits
    MD5Mid<public> : int                    # 12 bits (+4 from Version)
    MD5High<public> : int                   # 48 bits

    (uuid:)ToString<override>()<computes><reads>:string = {
        VersionMD5Mid := Version * 0x1000 + MD5Mid
        VariantMD5LowA := Variant * 0x40000000 + MD5LowA

        HexMD5High := EncodeIntToHex[MD5High] or Err("Unreachablea")
        HexVersionMD5Mid := EncodeIntToHex[VersionMD5Mid] or Err("Unreachableb")
        HexVariantMD5LowA := EncodeIntToHex[VariantMD5LowA] or Err("Unreachablec")
        HexMD5LowB := EncodeIntToHex[MD5LowB] or Err("Unreachabled")
        
        PadHexMD5High := PadLeft(HexMD5High, 12, '0')
        PaddedHexMD5HighPartA := PadHexMD5High.Slice[0, 8] or Err("Unreachablee")
        PaddedHexMD5HighPartB := PadHexMD5High.Slice[8, 12] or Err("Unreachablef")
        PadHexVersionMD5Mid := PadLeft(HexVersionMD5Mid, 4, '0')
        PadHexVariantMD5LowA := PadLeft(HexVariantMD5LowA, 8, '0')
        PadHexMD5LowB := PadLeft(HexMD5LowB, 8, '0')
        PadHexVariantMD5Low := PadHexVariantMD5LowA + PadHexMD5LowB
        PaddedHexVariantMD5Low := PadHexVariantMD5Low.Slice[0, 4] or Err("Unreachableg")
        PaddedHexMD5Low := PadHexVariantMD5Low.Slice[4, 16] or Err("Unreachableh")

        "{PaddedHexMD5HighPartA}-{PaddedHexMD5HighPartB}-{PadHexVersionMD5Mid}-{PaddedHexVariantMD5Low}-{PaddedHexMD5Low}"
    }
}

NewV3<public><constructor>(MD5String:string)<decides><transacts> := uuid_v3{
    let{
        # Ensures the provided MD5 string is exactly 32 characters long
        _Guard_Length := MD5String.Length = 32

        MD5High := MD5String.Slice[0, 12] or Err("Unreachable")
        MD5Mid := MD5String.Slice[12, 16] or Err("Unreachable")
        MD5LowA := MD5String.Slice[16, 24] or Err("Unreachable")
        MD5LowB := MD5String.Slice[24, 32] or Err("Unreachable")

        IntMD5High := DecodeHexToInt[MD5High]
        IntMD5Mid := DecodeHexToInt[MD5Mid]
        IntMD5LowA := DecodeHexToInt[MD5LowA]
        IntMD5LowB := DecodeHexToInt[MD5LowB]
    }

    MD5LowA := Mod[IntMD5LowA, 0x40000000] or Err("Unreachable")
    MD5LowB := IntMD5LowB
    MD5Mid := Mod[IntMD5Mid, 0x1000] or Err("Unreachable")
    MD5High := IntMD5High
}

CompileV3<public><constructor>(UUIDString:string)<decides><transacts> := uuid_v3{
    let {
        # Trims out existing hyphens from the UUID string
        CleanHex := for (Character : UUIDString, Character <> '-') { Character }

        # Ensures the cleaned hex string is exactly 32 characters long
        _Guard_Length := CleanHex.Length = 32

        # Extract each individual part of the UUID
        MD5High := CleanHex.Slice[0, 12] or Err("Unreachable")
        VersionMD5Mid := CleanHex.Slice[12, 16] or Err("Unreachable")
        VariantMD5LowA := CleanHex.Slice[16, 24] or Err("Unreachable")
        MD5LowB := CleanHex.Slice[24, 32] or Err("Unreachable")

        # Convert each hex part into its integer representation
        IntMD5High := DecodeHexToInt[MD5High]
        IntVersionMD5Mid := DecodeHexToInt[VersionMD5Mid]
        IntVariantMD5LowA := DecodeHexToInt[VariantMD5LowA]
        IntMD5LowB := DecodeHexToInt[MD5LowB]

        # Extract and validate the version field
        Version := Quotient[IntVersionMD5Mid, 0x1000] or Err("Unreachable")
        _Guard_Version := Version = 3

        # Extract and validate the variant field
        Variant := Quotient[IntVariantMD5LowA, 0x40000000] or Err("Unreachable")
        _Guard_Variant := Variant = 2

        # Extract the actual MD5 parts by removing version and variant bits
        IntMD5Mid := Mod[IntVersionMD5Mid, 0x1000] or Err("Unreachable")
        IntMD5LowA := Mod[IntVariantMD5LowA, 0x40000000] or Err("Unreachable")
    }

    MD5LowA := IntMD5LowA
    MD5LowB := IntMD5LowB
    MD5Mid := IntMD5Mid
    MD5High := IntMD5High
}