using. /Verse.org/Random

using. MathFeatures
using. VerseFeatures

StringManipulation<public> := module {

    numeric_characters_range<public>(CharCode:int)<computes><decides>:int = CharCode >= 48 and CharCode <= 57
    octal_characters_range<public>(CharCode:int)<computes><decides>:int = CharCode >= 48 and CharCode <= 55
    hexadecimal_characters_range<public>(CharCode:int)<computes><decides>:int = {
        numeric_characters_range[CharCode] or
        CharCode >= 97 and CharCode <= 102
    }
    uppercase_alphabet_characters_range<public>(CharCode:int)<computes><decides>:int = CharCode >= 65 and CharCode <= 90
    lowercase_alphabet_characters_range<public>(CharCode:int)<computes><decides>:int = CharCode >= 97 and CharCode <= 122
    alphabet_characters_range<public>(CharCode:int)<computes><decides>: int = {
        uppercase_alphabet_characters_range[CharCode] or
        lowercase_alphabet_characters_range[CharCode]
    }
    uppercase_special_characters_range<public>(CharCode:int)<computes><decides>:int = {
        CharCode = 140 or
        CharCode = 159 or
        CharCode >= 192 and CharCode <= 214 or
        CharCode >= 216 and CharCode <= 222
    }
    lowercase_special_characters_range<public>(CharCode:int)<computes><decides>:int = {
        CharCode = 156 or
        CharCode >= 224 and CharCode <= 246 or
        CharCode >= 248 and CharCode <= 255
    }
    special_characters_range<public>(CharCode:int)<computes><decides>:int = {
        uppercase_special_characters_range[CharCode] or
        lowercase_special_characters_range[CharCode]
    }
    symbol_characters_range<public>(CharCode:int)<computes><decides>:int = {
        CharCode >= 33 and CharCode <= 47 or
        CharCode >= 58 and CharCode <= 64 or
        CharCode >= 91 and CharCode <= 96 or
        CharCode >= 123 and CharCode <= 126
    }

    # ASCII Tables based on Windows-1252 character set
    # https://www.ascii-code.com/
    ControlCharacters<public>:[string]int = map{
        "␀" =>  0, "␁" =>  1, "␂" =>  2, "␃" =>  3, "␄" =>  4, "␅" =>  5, "␆" =>  6, "␇" =>  7,
        "␈" =>  8, "␉" =>  9, "␊" => 10, "␋" => 11, "␌" => 12, "␍" => 13, "␎" => 14, "␏" => 15,
        "␐" => 16, "␑" => 17, "␒" => 18, "␓" => 19, "␔" => 20, "␕" => 21, "␖" => 22, "␗" => 23,
        "␘" => 24, "␙" => 25, "␚" => 26, "␛" => 27, "␜" => 28, "␝" => 29, "␞" => 30, "␟" => 31
    }

    PrintableCharacters<public>:[string]int = map{
        " " =>  32, "!" =>  33, "\"" =>  34,  "#" =>  35,  "$" =>  36,  "%" =>  37, "&" =>  38, "'" =>  39,
        "(" =>  40, ")" =>  41,  "*" =>  42,  "+" =>  43,  "," =>  44,  "-" =>  45, "." =>  46, "/" =>  47,
        "0" =>  48, "1" =>  49,  "2" =>  50,  "3" =>  51,  "4" =>  52,  "5" =>  53, "6" =>  54, "7" =>  55,
        "8" =>  56, "9" =>  57,  ":" =>  58,  ";" =>  59,  "<" =>  60,  "=" =>  61, ">" =>  62, "?" =>  63,
        "@" =>  64, "A" =>  65,  "B" =>  66,  "C" =>  67,  "D" =>  68,  "E" =>  69, "F" =>  70, "G" =>  71,
        "H" =>  72, "I" =>  73,  "J" =>  74,  "K" =>  75,  "L" =>  76,  "M" =>  77, "N" =>  78, "O" =>  79,
        "P" =>  80, "Q" =>  81,  "R" =>  82,  "S" =>  83,  "T" =>  84,  "U" =>  85, "V" =>  86, "W" =>  87,
        "X" =>  88, "Y" =>  89,  "Z" =>  90,  "[" =>  91, "\\" =>  92,  "]" =>  93, "^" =>  94, "_" =>  95,
        "`" =>  96, "a" =>  97,  "b" =>  98,  "c" =>  99,  "d" => 100,  "e" => 101, "f" => 102, "g" => 103,
        "h" => 104, "i" => 105,  "j" => 106,  "k" => 107,  "l" => 108,  "m" => 109, "n" => 110, "o" => 111,
        "p" => 112, "q" => 113,  "r" => 114,  "s" => 115,  "t" => 116,  "u" => 117, "v" => 118, "w" => 119,
        "x" => 120, "y" => 121,  "z" => 122, "\{" => 123,  "|" => 124, "\}" => 125, "~" => 126, "␡" => 127
    }

    ExtendedCharacters<public>:[string]int = map{
        "€" => 128, "‚" => 130, "ƒ" => 131, "„" => 132, "…" => 133, "†" => 134, "‡" => 135, "ˆ" => 136,
        "‰" => 137, "Š" => 138, "‹" => 139, "Œ" => 140, "Ž" => 142, "‘" => 145, "’" => 146, "“" => 147,
        "”" => 148, "•" => 149, "–" => 150, "—" => 151, "˜" => 152, "™" => 153, "š" => 154, "›" => 155,
        "œ" => 156, "ž" => 158, "Ÿ" => 159, "¡" => 161, "¢" => 162, "£" => 163, "¤" => 164, "¥" => 165,
        "¦" => 166, "§" => 167, "¨" => 168, "©" => 169, "ª" => 170, "«" => 171, "¬" => 172, "®" => 174,
        "¯" => 175, "°" => 176, "±" => 177, "²" => 178, "³" => 179, "´" => 180, "µ" => 181, "¶" => 182,
        "·" => 183, "¸" => 184, "¹" => 185, "º" => 186, "»" => 187, "¼" => 188, "½" => 189, "¾" => 190,
        "¿" => 191, "À" => 192, "Á" => 193, "Â" => 194, "Ã" => 195, "Ä" => 196, "Å" => 197, "Æ" => 198,
        "Ç" => 199, "È" => 200, "É" => 201, "Ê" => 202, "Ë" => 203, "Ì" => 204, "Í" => 205, "Î" => 206,
        "Ï" => 207, "Ð" => 208, "Ñ" => 209, "Ò" => 210, "Ó" => 211, "Ô" => 212, "Õ" => 213, "Ö" => 214,
        "×" => 215, "Ø" => 216, "Ù" => 217, "Ú" => 218, "Û" => 219, "Ü" => 220, "Ý" => 221, "Þ" => 222,
        "ß" => 223, "à" => 224, "á" => 225, "â" => 226, "ã" => 227, "ä" => 228, "å" => 229, "æ" => 230,
        "ç" => 231, "è" => 232, "é" => 233, "ê" => 234, "ë" => 235, "ì" => 236, "í" => 237, "î" => 238,
        "ï" => 239, "ð" => 240, "ñ" => 241, "ò" => 242, "ó" => 243, "ô" => 244, "õ" => 245, "ö" => 246,
        "÷" => 247, "ø" => 248, "ù" => 249, "ú" => 250, "û" => 251, "ü" => 252, "ý" => 253, "þ" => 254,
        "ÿ" => 255
    }

    ToUpperCase<public>(String:string, ?IgnoreSpecialChars:logic=false)<transacts>:string = {
        CaseSwapperHandler(
            String,
            lowercase_alphabet_characters_range,
            lowercase_special_characters_range,
            -32,
            map{ 156 => 140, 255 => 159 },
            ?IgnoreSpecialChars := IgnoreSpecialChars
        )
    }

    ToLowerCase<public>(String:string, ?IgnoreSpecialChars:logic=false)<transacts>:string = {
        CaseSwapperHandler(
            String,
            uppercase_alphabet_characters_range,
            uppercase_special_characters_range,
            32,
            map{ 140 => 156, 159 => 255 },
            ?IgnoreSpecialChars := IgnoreSpecialChars
        )
    }
    
    CaseSwapperHandler<internal>(
        String:string,
        AlphabetCharsCaseRange:type{_(CharCode:int)<computes><decides>:int},
        SpecialCharsCaseRange:type{_(CharCode:int)<computes><decides>:int},
        PrintableCharsDelta:int,
        ExtendedCharsSwapMap:[int]int,
        ?IgnoreSpecialChars:logic=false
    )<transacts>:string = {
        if (String.Length <= 0). return ""

        var ResultingString : string = ""

        for (Char : String) {
            CharString := "{Char}"

            NewCharString := if (CharCode := PrintableCharacters[CharString], AlphabetCharsCaseRange[CharCode]) {
                PrintableCharacters.FindKeyByValue[CharCode + PrintableCharsDelta] or Err("Unreachable")
            } else if (not IgnoreSpecialChars?, CharCode := ExtendedCharacters[CharString], SpecialCharsCaseRange[CharCode]) {
                SwappedCharCode := ExtendedCharsSwapMap[CharCode] or CharCode + PrintableCharsDelta
                ExtendedCharacters.FindKeyByValue[SwappedCharCode] or Err("Unreachable") 
            } else. CharString

            set ResultingString += NewCharString
        }

        ResultingString
    }

    GetRandomString<public>(Length:int, ?UseNumbers:logic=false, ?UseSymbols:logic=false, ?UseSpecialChars:logic=false)<transacts>:string = {
        if (Length <= 0). return ""

        var ResultingString : string = ""

        var ValidCharacters : []string = PrintableCharacters.FindKeysByValueData[alphabet_characters_range] or Err("Unreachable")
        
        if (UseNumbers?). set ValidCharacters += PrintableCharacters.FindKeysByValueData[numeric_characters_range] or Err("Unreachable")
        if (UseSymbols?). set ValidCharacters += PrintableCharacters.FindKeysByValueData[symbol_characters_range] or Err("Unreachable")
        if (UseSpecialChars?). set ValidCharacters += ExtendedCharacters.FindKeysByValueData[special_characters_range] or Err("Unreachable")
            
        ValidCharactersLength := ValidCharacters.Length
        
        var ShuffledValidCharacters : []string = Shuffle(ValidCharacters)

        var IterationIndex : int = 0
        loop {
            if (IterationIndex >= Abs(Length)). break
            
            CurrentIndex := Mod[IterationIndex, ValidCharactersLength] or Err("Unreachable")

            set ResultingString += ShuffledValidCharacters[CurrentIndex] or Err("Unreachable")

            if (CurrentIndex >= ValidCharactersLength - 1){
                set ShuffledValidCharacters = Shuffle(ValidCharacters)
            }

            set IterationIndex += 1
        }

        ResultingString
    }

    SimpleStringHash<public>(String:string)<transacts>:int = {
        if (String.Length <= 0). return 0

        var ResultingHash : int = 0

        for (Char : String) {
            CharString := "{Char}"
            CharCode := ControlCharacters[CharString] or PrintableCharacters[CharString] or ExtendedCharacters[CharString] or -1
            HashedChar := ResultingHash * 31 + CharCode
            set ResultingHash = Mod[HashedChar, Constants.Max32BitInt] or Err("Unreachable")
        }

        ResultingHash
    }

    GeneratePseudoUniqueID<public>(?SaltCount:int=16)<transacts>:int = {
        UniqueStringID := "{GetSecondsSinceEpoch()}{GetRandomString(SaltCount, ?UseNumbers:=true, ?UseSymbols:=true)}{GetRandomFloat(-1024.0, 1024.0)}"
        HashedString := SimpleStringHash(UniqueStringID)
    }
}