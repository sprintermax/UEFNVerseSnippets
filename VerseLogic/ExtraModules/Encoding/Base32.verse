# TODO TEST FUNCTIONALITY

Base32<public> := module {
    using. BitMath
    using. MathFeatures
    using. StringProcessing
    using. VerseFeatures

    StdAlphabet<public> : string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    HexAlphabet<public> : string = "0123456789ABCDEFGHIJKLMNOPQRSTUV"

    StdPadding<public> : char = '='

    NewEncoding<public><constructor>(
        Encoder:string,
        ?PadCharacter:?char = option{StdPadding}
    )<computes><decides> := encoding{
        block {
            Encoder.Length = 32
            if (_PadCharacter := PadCharacter?) {
                not array{'\r', '\n'}.Find[_PadCharacter]
                not Encoder.Find[_PadCharacter]
            }
        }

        CharacterSet := Encoder
        _PadCharacter := PadCharacter
    }

    encoding<public> := class<internal><computes> {
        CharacterSet<public> : string
        _PadCharacter<public> : ?char

        Encode<public>(Source:string)<transacts>:string = {
            SourceLength := Source.Length
            if (SourceLength = 0). return ""

            var Result : string = ""

            Shifts := array{35, 30, 25, 20, 15, 10, 5, 0}
            CompleteBlocks := SourceLength - Mod[SourceLength, 5] or Err("Unreachable")
            
            var SourceIndex : int = 0
            loop {
                SourceIndex < CompleteBlocks or (break)

                var Bits : int = 0
                for (X := 0..4) {
                    set Bits = (Bits * 256) + CharToInt(Source[SourceIndex + X]) or Err("Unreachable")
                }

                for (Shift : Shifts) {
                    set Result += array{CharacterSet[BitwiseAnd(BitwiseRightShift(Bits, Shift), 0x1F)]} or Err("Unreachable")
                }

                set SourceIndex += 5
            }

            RemainingBytes := SourceLength - SourceIndex

            if (RemainingBytes = 0). return Result

            block {
                var Bits : int = 0
                for (X := 0..RemainingBytes - 1) {
                    set Bits = (Bits * 256) + CharToInt(Source[SourceIndex + X]) or Err("Unreachable")
                }

                set Bits = BitwiseLeftShift(Bits, (5 - RemainingBytes) * 8)

                OutputCount := array{2, 4, 5, 7}[RemainingBytes - 1] or Err("Unreachable")

                for (X := 0..OutputCount - 1) {
                    Shift := 35 - (X * 5)
                    set Result += array{CharacterSet[BitwiseAnd(BitwiseRightShift(Bits, Shift), 0x1F)]} or Err("Unreachable")
                }

                if (PadCharacter := Self._PadCharacter?) {
                    for (X := OutputCount..7) {
                        set Result += array{PadCharacter}
                    }
                }
            }

            Result
        }

        Decode<public>(Source:string)<decides><transacts>:string = {
            var CleanSource : string = ""
            loop {
                for (
                    Character : Source
                    not array{'\r', '\n'}.Find[Character]
                ) {
                    if (Self._PadCharacter? = Character). break
                    set CleanSource += array{Character}
                }
                break
            }

            # NormalizedSource := Normalize[CleanSource]
            # set CleanSource = NormalizedSource

            SourceLength := CleanSource.Length

            var Result : string = ""


            if (SourceLength > 0) {
                var SourceIndex : int = 0

                var DecodeError : logic = false
                loop {
                    SourceIndex + 8 <= CleanSource.Length or (break)
                    
                    var Bits : int = 0
                    for (X := 0..7) {
                        Index := CharacterSet.Find[CleanSource[SourceIndex + X]] or Err("Unreachable")
                        set Bits = BitwiseOr(BitwiseLeftShift(Bits, 5), Index)
                    }
                    
                    for (X := 0..4) {
                        Shift := 32 - (X * 8)
                        set Result += array{IntToChar[BitwiseAnd(BitwiseRightShift(Bits, Shift), 0xFF)]} or (set DecodeError = true; break)
                    }
                    
                    set SourceIndex += 8
                }
                not DecodeError?

                RemainingBytes := SourceLength - SourceIndex

                if (RemainingBytes >= 2) {
                    var Bits : int = 0
                    for (X := 0..RemainingBytes - 1) {
                        Index := CharacterSet.Find[CleanSource[SourceIndex + X]]
                        set Bits = BitwiseOr(BitwiseLeftShift(Bits, 5), Index)
                    }

                    set Bits = BitwiseLeftShift(Bits, (8 - RemainingBytes) * 5)

                    # Determine how many bytes to extract based on remaining Base32 characters
                    ByteCount := map{2 => 1, 4 => 2, 5 => 3, 7 => 4}[RemainingBytes] or Err("Unreachable")

                    for (X := 0..ByteCount - 1) {
                        Shift := 32 - (X * 8)
                        set Result += array{IntToChar[BitwiseAnd(BitwiseRightShift(Bits, Shift), 0xFF)]} or Err("Unreachable")
                    }
                }
            }

            Result
        }
    }

    
    # Normalizes the given Base32 string by converting all 
    # letters to uppercase.
    # 
    # Fails if the string contains invalid Base32 characters.
    Normalize<public>(String:string)<decides><transacts>:string = {
        for (Character : String) {
            CharacterCode := CharToInt(Character)

            option{
                digit_characters_range[CharacterCode]
                Character
            }? or option{
                hexadecimal_characters_range[CharacterCode]
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
        }
    }

    StdEncoding<public>()<computes>:encoding = NewEncoding[StdAlphabet] or Err("Unreachable")
    HexEncoding<public>()<computes>:encoding = NewEncoding[HexAlphabet] or Err("Unreachable")
}