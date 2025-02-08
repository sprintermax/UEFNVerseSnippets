using. /UnrealEngine.com/Temporary
using. /UnrealEngine.com/Temporary/UI

VerseFeatures<public> := module {

    ### Logic Utils

    Success<public>()<computes><decides>:void = true?
    Failure<public>()<computes><decides>:void = false?

    (VerseFeatures:)ToString<public>(Input:logic)<computes>:string = {
        if (Input?) { "true" } else { "false" }
    }
    
    (Logic:logic).Invert<public>()<computes>:logic = if (Logic?) { false } else { true }

    prefix'-'<public>(Logic:logic)<computes>:logic = Logic.Invert()



    ### Message Utils
    
    JoinMessages<public><localizes>(First:message, Second:message)<computes>:message = "{First}{Second}"

    operator'+'<public><localizes>(First:message, Second:message)<computes>:message = "{First}{Second}"



    ### Map Operations
    
    # Returns an array with all keys of the map
    (Input:[k]v where k:subtype(comparable), v:type).Keys<public>()<computes>:[]k = {
        for (CurrentKey->Unused : Input). CurrentKey
    }

    # Returns an array with all values of the map
    (Input:[k]v where k:subtype(comparable), v:type).Values<public>()<computes>:[]v = {
        for (CurrentValue : Input). CurrentValue
    }

    # Returns a map without the map element that Key matches the Key provided
    # If Strict is set to true, will force a fail when key does not exist on the map
    (Input:[k]v).RemoveByKey<public>(KeyToRemove:k, (?Strict:logic=false) where k:subtype(comparable), v:type)<transacts><decides>:[k]v = {
        if (Strict?). Input[KeyToRemove]

        var TempMap:[k]v = map{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentKey <> KeyToRemove
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns a map without all map elements that Key matches the Keys provided
    (Input:[k]v).RemoveByKeys<public>(KeysToRemove:[]k where k:subtype(comparable), v:type)<transacts><decides>:[k]v = {
        var TempMap:[k]v = Input
        for (KeyToRemove : KeysToRemove) {
            ResultMap := TempMap.RemoveByKey[KeyToRemove, ?Strict := false] # Strict default value is already false on the function definition and due to that is not a required argument, but if not mentioned again here, for some reason it crashes the server
            set TempMap = ResultMap
        }
        TempMap
    }

    # Returns a map with only the elements that Key matches the Keys provided
    (Input:[k]v).FilterByKeys<public>(Keys:[]k where k:subtype(comparable), v:type)<transacts><decides>:[k]v = {
        var TempMap:[k]v = map{}
        for (
            CurrentKey->CurrentValue:Input
            KeyToCompare : Keys
            CurrentKey = KeyToCompare
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns the first map Key where the associated Value matches the provided Value
    (Input:[k]v).FindKeyByValue<public>(Value:v where k:subtype(comparable), v:subtype(comparable))<transacts><decides>:k = {
        var MaybeKey:?k = false
        for (
            CurrentKey->CurrentValue:Input
            not MaybeKey?
            CurrentValue = Value
        ). set MaybeKey = option{CurrentKey}
        MaybeKey?
    }

    # Returns all map Keys where the associated Value matches the provided Value
    # If Strict is set to true, will force a fail when none of the values exist on the map
    (Input:[k]v).FindKeysByValue<public>(Value:v, (?Strict:logic=false) where k:subtype(comparable), v:subtype(comparable))<transacts><decides>:[]k = {
        KeysFound := for (
            CurrentKey->CurrentValue:Input
            CurrentValue = Value
        ). CurrentKey

        KeysFound.Length > 0 or not Strict?

        KeysFound
    }

    # return a map with only the elements that Value matches the Values provided
    # If Strict is set to true, will force a fail when none of the values exist on the map
    (Input:[k]v).FilterByValues<public>(Values:[]v, (?Strict:logic=false) where k:subtype(comparable), v:subtype(comparable))<transacts><decides>:[k]v = {
        var TempMap:[k]v = map{}
        NewMap := for (
            CurrentKey->CurrentValue:Input
            ValueToCompare : Values
            CurrentValue = ValueToCompare
        ). set TempMap[CurrentKey] = CurrentValue

        TempMap.Length > 0 or not Strict?

        TempMap
    }

    # UNTESTED
    # Returns the first map Key where the Value succeeds the provided condition function
    (Input:[k]v).FindKeyByValueData<public>(Condition:type{_(:v)<transacts><decides>:void} where k:subtype(comparable), v:subtype(any))<transacts><decides>:k = {
        var MaybeKey:?k = false
        for (
            CurrentKey->CurrentValue:Input
            not MaybeKey?
            Condition[CurrentValue]
        ). set MaybeKey = option{CurrentKey}
        MaybeKey?
    }

    # Returns all map Keys where the Value succeeds the provided condition function
    # If Strict is set to true, will force a fail when no compatible values exist on the map
    (Input:[k]v).FindKeysByValueData<public>(Condition:type{_(:v)<transacts><decides>:void}<#, (?Strict:logic=false)#> where k:subtype(comparable), v:subtype(any))<transacts><decides>:[]k = {
        KeysFound := for (
            CurrentKey->CurrentValue:Input
            Condition[CurrentValue]
        ). CurrentKey
        
        <#KeysFound.Length > 0 or not Strict?#>

        KeysFound
    }



    ### Array Operations

    (Input:[]t where t:type).Reverse<public>()<computes>:[]t = {
        LastIndex := Input.Length - 1
        for (
            CurrentIndex->Unused : Input
            Element := Input[LastIndex - CurrentIndex]
        ). Element
    }

    NormalizeIndex<public>(Length:int, Index:int)<decides><computes>:int = {
        Length >= 1

        NormalizedRange := Mod[Index, Length]

        NormalizedIndex := if (NormalizedRange < 0). Length + NormalizedRange
        else. NormalizedRange
    }

    (Input:[]t where t:type).At<public>(Index:int)<decides><computes>:t = {
        Input[NormalizeIndex[Input.Length, Index]]
    }

    (Input:generator(t) where t:type).AsArray<public>()<computes>:[]t = {
        for (Element : Input). Element
    }



    ### Sorting Operations

    (Input:[]t where t:type).MergeSort<public>(Less:type{_(:t, :t)<decides><transacts>:void})<transacts>:[]t = {
        Length := Input.Length

        if (
            Length > 1
            Pivot := Floor(Length/2)
            LeftPart := Input.Slice[0, Pivot]
            RightPart := Input.Slice[Pivot]
        ) {
            
            LeftSorted := LeftPart.MergeSort(Less)
            RightSorted := RightPart.MergeSort(Less)

            var LeftIndex : int = 0
            var RightIndex : int = 0
            var MergedArray : []t = array{}

            loop {
                if (LeftElement := LeftSorted[LeftIndex], RightElement := RightSorted[RightIndex]) {

                    if (Less[LeftElement, RightElement]) {
                        set MergedArray += array{LeftElement}
                        set LeftIndex += 1
                    } else {
                        set MergedArray += array{RightElement}
                        set RightIndex += 1
                    }

                } else {

                    if (LeftIndex >= LeftSorted.Length) {
                        option{set MergedArray += RightSorted.Slice[RightIndex]}
                    } else {
                        option{set MergedArray += LeftSorted.Slice[LeftIndex]}
                    }

                    break
                }
            }

            MergedArray

        } else { Input }
    }

    SortIntAscending<public>(Left:int, Right:int)<decides><computes>:void = {
        Left < Right
    }

    SortIntDescending<public>(Left:int, Right:int)<decides><computes>:void = {
        Left > Right
    }

    SortFloatAscending<public>(Left:float, Right:float)<decides><computes>:void = {
        Left < Right
    }

    SortFloatDescending<public>(Left:float, Right:float)<decides><computes>:void = {
        Left > Right
    }


    # OBSOLETE NEEDS REWORK
    # (Input:[]t where t:type).Sort<public>(Comparer:type{_(:t, :t)<computes>:int}, ?IsAscending:logic = true)<computes>:[]t = {
    #     if (Input.Length > 1, Pivot := Input[Floor(Input.Length/2)]) {
            
    #         Left := for (Element : Input, Comparer(Element, Pivot) < 0) { Element }
    #         Middle := for (Element : Input, Comparer(Element, Pivot) = 0) { Element }
    #         Right := for (Element : Input, Comparer(Element, Pivot) > 0) { Element }

    #         if (IsAscending?). Left.Sort(Comparer, ?IsAscending := IsAscending) + Middle + Right.Sort(Comparer, ?IsAscending := IsAscending)
    #         else. Right.Sort(Comparer, ?IsAscending := IsAscending) + Middle + Left.Sort(Comparer, ?IsAscending := IsAscending)

    #     } else { Input }
    # }

    # SortIntDefaultComparer<public>(A:int, B:int)<computes>:int = {
    #     if (A < B). -1
    #     else if (A > B). 1
    #     else 0
    # }

    # SortFloatDefaultComparer<public>(A:float, B:float)<computes>:int = {
    #     if (A < B). -1
    #     else if (A > B). 1
    #     else 0
    # }



    ### Containers

    # Generic container class that can be used for FIFO, LIFO, and other common types of array data storage
    Container<public>(t:type) := class<computes> {
        Elements<public> :[]t = array{}
		
        Size<public>()<computes>:int = Elements.Length
        IsEmpty<public>()<decides><computes>:void = Elements.Length = 0

        AddFirst<public>(Element:t)<computes>:Container(t) = Container(t){ Elements := array{Element} + Elements }
        AddLast<public>(Element:t)<computes>:Container(t) = Container(t){ Elements := Elements + array{Element} }

        # Get the value at an specific index
        # Fails if not able to find a value on the provided index
        # If Strict is set to False (Default), out of bound indexes will be normalized to array bounds
        # If Strict is set to true, out of bound indexes will not be normalized and will cause a fail
        GetAt<public>(Index:int, ?Strict:logic=false)<decides><computes>:tuple(Container(t), t) = {
            TargetIndex := if (Strict?). Index else. NormalizeIndex[Elements.Length, Index]
            (Container(t){ Elements := Elements.RemoveElement[TargetIndex] }, Elements[TargetIndex])
        }

        GetFirst<public>()<decides><computes>:tuple(Container(t), t) = (Container(t){ Elements := Elements.RemoveElement[0] }, Elements[0])
        GetLast<public>()<decides><computes>:tuple(Container(t), t) = (Container(t){ Elements := Elements.RemoveElement[Elements.Length - 1] }, Elements[Elements.Length - 1])

        (local:)SortBy<public>(Less:type {_(:t, :t)<computes><decides>:void})<computes>:Container(t) = {
            Container(t){ Elements := SortBy(Elements, Less) }
        }

        # Aliases
        Push<public>(Element:t)<computes>:Container(t) = AddLast(Element)
        Pop<public>()<computes><decides>:tuple(Container(t), t) = GetLast[]
    }

    ### String Utils

    CharToIntMap<public>:[char]int = map{
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4,
        '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9
    }

    # Tries to convert a numeric string to integer
    # Fails if the string is empty or not a valid integer number
    StringToInt<public>(String:string)<transacts><decides>:int = {
        String.Length > 0
        
        var IntegerNumber:int = 0

        IsNegative := if (String[0] = '-') { true } else { false }

        for (Index->Char : String) {
            if (Index > 0 or not IsNegative?) {
                CurrentDigit := CharToIntMap[Char]
                set IntegerNumber = IntegerNumber * 10 + CurrentDigit
            }
        }

        if (IsNegative?). IntegerNumber * -1 else. IntegerNumber
    }

    # WIP - Untested
    # Tries to convert a numeric string to float (Including Inf and NaN values)
    # Fails if the string is empty or not a valid float number
    # If Strict is set to true, will force a fail if the resulting value is Inf or NaN
    StringToFloat<public>(String:string, ?Strict:logic=false)<transacts><decides>:float = {
        String.Length > 0

        var FloatNumber:float = 0.0
        var IsFractionPart:logic = false
        var FractionDivider:float = 1.0

        IsNegative := if (String[0] = '-') { true } else { false }

        if (String = "-Inf" or String = "Inf") {
            not Strict?
            set FloatNumber = Inf
        } else if (String = "NaN") {
            not Strict?
            set FloatNumber = NaN
        } else {
            for (Index->Char : String) {
                if (Index > 0 or not IsNegative?) {
                    if (Char = '.') {
                        set IsFractionPart = true
                    } else {

                        CurrentDigit := CharToIntMap[Char]

                        if (IsFractionPart?) {
                            set FractionDivider *= 10.0
                            set FloatNumber += CurrentDigit * 1.0 / FractionDivider
                        } else {
                            set FloatNumber = FloatNumber * 10.0 + CurrentDigit * 1.0
                        }
                    }
                }
            }
        }

        if (IsNegative?). FloatNumber * -1.0 else. FloatNumber
    }
}