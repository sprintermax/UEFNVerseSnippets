Hexadecimal<public> := module{
    using. MathFeatures
    using. StringProcessing

    UpperCaseHexAlphabet<public> : string = "0123456789ABCDEF"
    LowerCaseHexAlphabet<public> : string = "0123456789abcdef"

    ReverseHexTable<public> : [char]int = map{
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9,
        'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15,
        'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15
    }

    # Converts a single byte (0-255) to its two-character hexadecimal representation
    # By default uses uppercase letters, but can use lowercase if wanted (for ex in MD5 Hashes)
    # Fails if the input is outside the byte range
    EncodeByteToHex<public>(Byte:int, ?LowerCase:logic=false)<computes><decides>:string = {
        HexAlphabet := LowerCase? and LowerCaseHexAlphabet or UpperCaseHexAlphabet
        
        HighNibble := HexAlphabet[Quotient[Byte, 16]]
        LowNibble := HexAlphabet[Mod[Byte, 16]]

        return "{HighNibble}{LowNibble}"
    }

    # Converts a single char to its two-character hexadecimal representation
    EncodeCharToHex<public>(Character:char)<computes>:string = {
        ByteValue := CharToInt(Character)
        
        return EncodeByteToHex[ByteValue] or Err("Unreachable")
    }

    # Converts a string to its hexadecimal string representation
    EncodeStringToHex<public>(String:string)<computes>:string = {
        HexBytes := for (Character : String) {
            EncodeCharToHex(Character)
        }
        Concatenate(HexBytes)
    }

    # Converts an integer to its hexadecimal string representation
    # Fails if the input integer is negative
    EncodeIntToHex<public>(Value:int)<decides><transacts>:string = {
        Value >= 0

        var ResultHex : string = ""
        var Current : int = Value

        loop {
            Current > 0 or (break)
            set ResultHex = EncodeByteToHex[Mod[Current, 256]] + ResultHex or Err("Unreachable")
            set Current = Quotient[Current, 256] or Err("Unreachable")
        }

        if (ResultHex.Length = 0). set ResultHex = "00"

        ResultHex
    }

    # Converts a hexadecimal string into its respective byte array
    # Fails if the input string has an odd length or contains invalid hexadecimal characters
    DecodeHexToByteArray<public>(HexString:string)<computes><decides><reads>:[]int = {
        HexLength := HexString.Length

        Mod[HexLength, 2] = 0

        ByteArray := for (Index := 0..(Truncate(HexLength / 2)) - 1) {
            HighChar := HexString[Index * 2]
            LowChar := HexString[(Index * 2) + 1]

            HighValue := ReverseHexTable[HighChar]
            LowValue := ReverseHexTable[LowChar]

            (HighValue * 16) + LowValue
        }
    }

    # Decodes a hexadecimal string into its normal byte string representation
    # Fails if the input string has an odd length or contains invalid hexadecimal characters
    DecodeHexToString<public>(HexString:string)<decides><transacts>:string = {
        for (Byte : DecodeHexToByteArray[HexString]) {
            IntToChar[Byte]
        }
    }

    # Decodes a hexadecimal string into its integer representation
    # Fails if the input string has an odd length or contains invalid hexadecimal characters
    DecodeHexToInt<public>(HexString:string)<decides><transacts>:int = {
        var Result : int = 0
        for (Byte : DecodeHexToByteArray[HexString]) {
            set Result = (Result * 256) + Byte
        }

        Result
    }
}