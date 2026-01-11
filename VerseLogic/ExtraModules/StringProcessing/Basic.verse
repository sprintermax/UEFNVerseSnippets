using. VerseFeatures

(String:string).StartsWith<public>(Prefix:string)<computes><decides>:void = {
    String.Slice[0, Prefix.Length] = Prefix
}

(String:string).EndsWith<public>(Suffix:string)<computes><decides>:void = {
    String.Slice[String.Length - Suffix.Length] = Suffix
}

(String:string).CutPrefix<public>(Prefix:string)<computes><decides>:string = {
    String.StartsWith[Prefix]
    String.Slice[Prefix.Length]
}

(String:string).CutSuffix<public>(Suffix:string)<computes><decides>:string = {
    String.EndsWith[Suffix]
    String.Slice[0, String.Length - Suffix.Length]
}

# Converts a character to its corresponding Unicode code point (bytes 0-255)
CharToInt<public>(Character:char)<computes>:int = {
    UTF8CodeUnits[Character] or Err("Unreachable")
}

# Converts an Unicode code point (bytes 0-255) to its corresponding character
# Fails if the input is outside the byte range
IntToChar<public>(CharacterCode:int)<decides><transacts>:char = {
    UTF8CodeUnits.FindKeyByValue[CharacterCode]
}

PadLeft<public>(String:string, TargetLength:int, PadCharacter:char)<computes>:string = {
    NeededCharacters := TargetLength - String.Length 

    PaddingString := for (X := 0..NeededCharacters - 1) { PadCharacter }

    PaddingString + String
}

PadRight<public>(String:string, TargetLength:int, PadCharacter:char)<computes>:string = {
    NeededCharacters := TargetLength - String.Length 

    PaddingString := for (X := 0..NeededCharacters - 1) { PadCharacter }

    String + PaddingString
}

# Supposed to be '.Find()', using '.Locate()' due to verse limitations
# NOTE: Disabled since verse does not support return in failable contexts (keeping here for future reference)
# (String:string).Locate<public>(SubString:string)<computes><decides>:int = {
#     StringLength := String.Length
#     SubStringLength := SubString.Length

#     # If substring is empty, return 0
#     if (SubStringLength = 0). return 0
#     # If substring is a single char, try to return the index of first occurence or fail
#     if (SubStringLength = 1). return String.Find[SubString[0]]
#     # If substring is equal or shorter than string continue, otherwise fail
#     SubStringLength <= StringLength
#     # If substring is same as string, return 0
#     if (SubStringLength = StringLength, SubString = String). return 0

#     # brute-force search (Not Optimized)
#     for (
#         MainIndex->_Unused : String
#         SubIndex->SubChar : SubString
#         String[MainIndex + SubIndex] = SubChar
#         SubIndex + 1 = SubStringLength
#     ). return MainIndex

#     # substring not found in string, so force a fail
#     Failure[]
# }

# Supposed to be '.Find()', using '.Locate()' due to verse limitations
(String:string).Locate<public>(SubString:string)<decides><transacts>:int = {
    var _Position : ?int = false

    StringLength := String.Length
    SubStringLength := SubString.Length

    # Handle special cases first for optimization purposes
    option{
        # If substring is empty, result should be 0
        SubStringLength = 0
        set _Position = option{0}
    }? or option {
        # If substring is a single char, result should be its first occurence if found
        SubStringLength = 1
        Position := String.Find[SubString[0]]
        set _Position = option{Position}
    }

    option{
        # Don't need to run the full search if we already have a result
        not _Position?
        # Only run full search if substring is equal or shorter than string
        SubStringLength <= StringLength

        option{
            # If substring and string are equal, result should be 0
            SubStringLength = StringLength
            SubString = String
            set _Position = option{0}
        }? or option{
            # brute-force search (Not Optimized)
            for (
                MainIndex->_Unused : String
                SubIndex->SubChar : SubString
                String[MainIndex + SubIndex] = SubChar
                SubIndex + 1 = SubStringLength
            ). set _Position = option{MainIndex}
        }
    }

    # If this fails, means that substring was not found in string
    _Position?
}


<#>
    TODO (FOR SPLIT/SLICE FUNCTIONS):
    - CHECK BEHAVIOR (IF SHOULD CUT OR NOT SEPARATOR ON THE RESULT)
    - CONFIRM IF NAMINGS ARE ACCURATE AND DESCRIPTIVE ENOUGH


(String:string).SplitAt<public>(Separator:char)<computes><decides>:tuple(string, string) = {

    SeparatorPosition := String.Find[Separator]
    
    Before := String.Slice[0, SeparatorPosition]
    After := String.Slice[SeparatorPosition + 1] # .Slice[SeparatorPosition, String.Length]

    return (Before, After)
}

(String:string).Split<public>(Separator:char)<transacts>:[]string = {

    var Results : []string = array{}
    var After : string = String

    loop {
        Result := After.SplitAt[Separator] or (break)
        set Results += array{Result(0)}
        set After = Result(1)
    }

    return Results + array{After}
}

# Should be same as the one above but written differently (must confirm behavior)
# TODO: Compare benchmarks between both implementations
(String:string).Split2<public>(Separator:char)<transacts>:[]string = {
    var ResultingStrings : []string = array{}

    var CurrentSubString : string = ""
    for (Character : String) {
        option {
            Character = Separator
            CurrentSubString <> ""
            set ResultingStrings += array{CurrentSubString}
            set CurrentSubString = ""
        }? or (
            set CurrentSubString += "{Character}"
        )
    }

    option {
        CurrentSubString <> ""
        set ResultingStrings += array{CurrentSubString}
    }

    ResultingStrings
}

# Supposed to be <computes>, but being <transacts> due to limitation on .Find[] function
(String:string).SplitAt<public>(Separator:string)<decides><transacts>:tuple(string, string) = {

    SeparatorPosition := String.Locate[Separator] # WIP - Check if native "Find[]" works
    
    Before := String.Slice[0, SeparatorPosition]
    After := String.Slice[SeparatorPosition + 1] # .Slice[SeparatorPosition, String.Length]

    return (Before, After)
}

(String:string).Split<public>(Separator:string)<transacts>:[]string = {

    var Results : []string = array{}
    var After : string = String

    loop {
        Result := After.SplitAt[Separator] or (break)
        set Results += array{Result(0)}
        set After = Result(1)
    }

    return Results + array{After}
}

# NOTE: Needs to be qualified due to verse wrongly conflicting with other functions
(StringProcessing:)Concatenate<public>(Strings:[]string, Separator:string)<computes>:string = {
    Concatenate(for (Index->String : Strings) {
        option{
            Index + 1 < Strings.Length
            String + Separator
        }? or String
    })
}


# Abusing JSON Module for optimized approach since we don't have native functionality
_UE_JSON<internal> := import(/UnrealEngine.com/JSON)

ParseInt<public>(String:string)<decides><transacts>:int = {
    _UE_JSON.Parse[String].AsInt[]
}

ParseFloat<public>(String:string)<decides><transacts>:float = {
    _UE_JSON.Parse[String].AsFloat[]
}

# Range Validation (TEMP)

IsCharacterRange<public>(CharacterCode:int, ExpectedCharacterRange:type{_(:int)<computes><decides>:any})<computes><decides>:int = {
    ExpectedCharacterRange[CharacterCode]
    CharacterCode
}

IsCharacterRange<public>(Character:char, ExpectedCharacterRange:type{_(:int)<computes><decides>:any})<computes><decides>:char = {
    IsCharacterRange[CharToInt(Character), ExpectedCharacterRange]
    Character
}

IsCharacterRangeAny<public>(CharacterCode:int, ExpectedCharacterRanges:[]type{_(:int)<computes><decides>:any})<computes><decides>:int = {
    MatchedRanges := for (
        ExpectedCharacterRange : ExpectedCharacterRanges
        IsCharacterRange[CharacterCode, ExpectedCharacterRange]
    ){}
    MatchedRanges.Length > 0
    CharacterCode
}

IsCharacterRangeAll<public>(CharacterCode:int, ExpectedCharacterRanges:[]type{_(:int)<computes><decides>:any})<computes><decides>:int = {
    for (ExpectedCharacterRange : ExpectedCharacterRanges){
        IsCharacterRange[CharacterCode, ExpectedCharacterRange]
    }
    CharacterCode
}

IsCharacterRangeAny<public>(Character:char, ExpectedCharacterRanges:[]type{_(:int)<computes><decides>:any})<computes><decides>:char = {
    IsCharacterRangeAny[CharToInt(Character), ExpectedCharacterRanges]
    Character
}

IsCharacterRangeAll<public>(Character:char, ExpectedCharacterRanges:[]type{_(:int)<computes><decides>:any})<computes><decides>:char = {
    IsCharacterRangeAll[CharToInt(Character), ExpectedCharacterRanges]
    Character
}