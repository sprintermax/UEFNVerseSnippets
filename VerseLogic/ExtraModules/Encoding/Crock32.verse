# TODO TEST FUNCTIONALITY

Crock32<public> := module {
    using. BitMath
    using. StringProcessing

    # Crock32 Character Set (Does not include confusing characters like I, L, O, and U)
    Crock32Alphabet<public> : string = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

    Encode<public>(Value:int)<decides><transacts>:string = {
        var _Value : int = Value
        var _Result : ?string = false

        option{
            Value = 0
            set _Result = option{"0"}
        }? or option{
            loop {
                _Value > 0 or (break)
                Remainder := Mod[_Value, 32] or Err("Unreachable")
                set _Value = Floor(_Value / 32) or Err("Unreachable")
                set _Result = option{"{Crock32Alphabet[Remainder]}{_Result?}" or Err("Unreachable")}
            }
        }

        _Result?
    }

    Decode<public>(String:string)<decides><transacts>:int = {
        var _Result : ?int = false

        for (Character : Normalize[String]) {
            CharIndex := Crock32Alphabet.Find[Character]
            set _Result = option{_Result? * 32 + CharIndex}
        }

        _Result?
    }

    
    # Normalizes the given Crock32 string by replacing aliased characters
    # with their correct counterparts and converts all letters to uppercase.
    # 
    # Fails if the string contains invalid Crock32 characters.
    Normalize<public>(String:string)<decides><transacts>:string = {
        for (Character : String, Character <> '-') {
            array{'O', 'o'}.Find[Character] and '0' or
            array{'L', 'l', 'I', 'i'}.Find[Character] and '1' or (
                CharacterCode := CharToInt(Character)

                option{
                    digit_characters_range[CharacterCode]
                    Character
                }? or option{
                    ascii_characters_range[CharacterCode]
                    option{
                        uppercase_characters_range[CharacterCode]
                        Character
                    }? or option{
                        lowercase_characters_range[CharacterCode]
                        UpperCaseOffset := CharacterCode - 32
                        uppercase_characters_range[UpperCaseOffset]
                        IntToChar[UpperCaseOffset]
                    }?
                }?
            )
        }
    }

    # WIP CONFIRM IF WORKS THE SAME WAY AS THE CROCK32 MODULE, IF NOT DELETE IT
    Crock32Encoding<public>()<computes>:Base32.encoding = Base32.NewEncoding[Crock32.Crock32Alphabet] or Err("Unreachable")
}