using. /UnrealEngine.com/Temporary/UI

VerseFeatures<public> := module {

    ### Logic Utils

    Success<public>()<computes><decides>:void = true?
    Failure<public>()<computes><decides>:void = false?

    PrintAndFail<public>(Message:string)<transacts><decides>:void = {
        Print(Message)
        Failure[]
    }

    PrintAndFail<public>(Message:string, Value:t where t :subtype(any))<transacts><decides>:t = {
        Print(Message)
        Failure[]
        Err("Unreachable")
    }

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
    (Input:[k]v where k:subtype(comparable), v:type).RemoveByKey<public>(KeyToRemove: k, ?Strict:logic=false)<transacts><decides>:[k]v = {
        if (Strict?). Input[KeyToRemove]

        var TempMap:[k]v = map{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentKey <> KeyToRemove
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns a map without all map elements that Key matches the Keys provided
    (Input:[k]v where k:subtype(comparable), v:type).RemoveByKeys<public>(KeysToRemove: []k)<transacts><decides>:[k]v = {
        var TempMap:[k]v = Input
        for (KeyToRemove : KeysToRemove) {
            ResultMap := TempMap.RemoveByKey[KeyToRemove, ?Strict := false] # Strict default value is already false on the function definition and due to that is not a required argument, but if not mentioned again here, for some reason it crashes the server
            set TempMap = ResultMap
        }
        TempMap
    }

    # Returns a map with only the elements that Key matches the Keys provided
    (Input:[k]v where k:subtype(comparable), v:type).FilterByKeys<public>(Keys: []k)<transacts><decides>:[k]v = {
        var TempMap:[k]v = map{}
        for (
            CurrentKey->CurrentValue:Input
            KeyToCompare : Keys
            CurrentKey = KeyToCompare
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns the first map Key where the associated Value matches the provided Value
    (Input:[k]v where k:subtype(comparable), v:subtype(comparable)).FindKeyByValue<public>(Value: v)<transacts><decides>:k = {
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
    (Input:[k]v where k:subtype(comparable), v:subtype(comparable)).FindKeysByValue<public>(Value: v, ?Strict:logic=false)<transacts><decides>:[]k = {
        var KeysFound:[]k = array{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentValue = Value
        ). set KeysFound += array{CurrentKey}

        KeysFound.Length <> 0 or not Strict?

        KeysFound
    }

    # return a map with only the elements that Value matches the Values provided
    # If Strict is set to true, will force a fail when none of the values exist on the map
    (Input:[k]v where k:subtype(comparable), v:subtype(comparable)).FilterByValues<public>(Values: []v, ?Strict:logic=false)<transacts><decides>:[k]v = {
        var TempMap:[k]v = map{}
        for (
            CurrentKey->CurrentValue:Input
            ValueToCompare : Values
            CurrentValue = ValueToCompare
        ). set TempMap[CurrentKey] = CurrentValue

        TempMap.Length <> 0 or not Strict?

        TempMap
    }

    # Returns the first map Key where the Value succeeds the provided condition function
    (Input:[k]v where k:subtype(comparable), v:subtype(any)).FindKeyByValueData<public>(Condition:type{_(:v)<transacts><decides>:void})<transacts><decides>:k = {
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
    (Input:[k]v where k:subtype(comparable), v:subtype(any)).FindKeysByValueData<public>(Condition:type{_(:v)<transacts><decides>:void}<#, ?Strict:logic=false#>)<transacts><decides>:[]k = {
        var KeysFound:[]k = array{}
        for (
            CurrentKey->CurrentValue:Input
            Condition[CurrentValue]
        ). set KeysFound += array{CurrentKey}
        
        <#KeysFound.Length <> 0 or not Strict?#>

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

    (Input:[]t where t:type).At<public>(Index:int)<decides><computes>: t = {
        Length := Input.Length

        Length >= 1

        NormalizedRange := Mod[Index, Length]

        NormalizedIndex := if (NormalizedRange < 0). Length + NormalizedRange
        else. NormalizedRange

        Input[NormalizedIndex]
    }

    (Input:generator(t) where t:type).AsArray<public>()<computes>:[]t = {
        for (Element : Input). Element
    }



    ### Sorting Operations

    (Input:[]t where t:type).MergeSort<public>(Less : type{_(:t, :t)<decides><transacts>:void})<transacts> : []t = {
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

    SortIntAscending<public>(Left:int, Right:int)<decides><transacts>:void = {
        Left < Right
    }

    SortIntDescending<public>(Left:int, Right:int)<decides><transacts>:void = {
        Left > Right
    }

    SortFloatAscending<public>(Left:float, Right:float)<decides><transacts>:void = {
        Left < Right
    }

    SortFloatDescending<public>(Left:float, Right:float)<decides><transacts>:void = {
        Left > Right
    }


    # OBSOLETE NEEDS REWORK
    # (Input:[]t where t:type).Sort<public>(Comparer : type{_(:t, :t)<computes> : int}, ?IsAscending : logic = true)<computes> : []t = {
    #     if (Input.Length > 1, Pivot := Input[Floor(Input.Length/2)]) {
            
    #         Left := for (Element : Input, Comparer(Element, Pivot) < 0) { Element }
    #         Middle := for (Element : Input, Comparer(Element, Pivot) = 0) { Element }
    #         Right := for (Element : Input, Comparer(Element, Pivot) > 0) { Element }

    #         if (IsAscending?). Left.Sort(Comparer, ?IsAscending := IsAscending) + Middle + Right.Sort(Comparer, ?IsAscending := IsAscending)
    #         else. Right.Sort(Comparer, ?IsAscending := IsAscending) + Middle + Left.Sort(Comparer, ?IsAscending := IsAscending)

    #     } else { Input }
    # }

    # SortIntDefaultComparer<public>(A:int, B:int)<computes> : int = {
    #     if (A < B). -1
    #     else if (A > B). 1
    #     else 0
    # }

    # SortFloatDefaultComparer<public>(A:float, B:float)<computes> : int = {
    #     if (A < B). -1
    #     else if (A > B). 1
    #     else 0
    # }



    ### Containers

    Stack<public>(t:type) := class<computes> {
        Elements<public> :[]t = array{}
		
        Size<public>()<computes>:int = Elements.Length
        IsEmpty<public>()<decides><computes>:void = Elements.Length = 0

        AddFirst<public>(Element:t)<computes>:Stack(t) = Stack(t){ Elements := array{Element} + Elements }
        AddLast<public>(Element:t)<computes>:Stack(t) = Stack(t){ Elements := Elements + array{Element} }

        GetAt<public>(Index:int)<decides><computes>:tuple(Stack(t), t) = (Stack(t){ Elements := Elements.RemoveElement[Index] }, Elements[Index])

        GetFirst<public>()<decides><computes>:tuple(Stack(t), t) = (Stack(t){ Elements := Elements.RemoveElement[0] }, Elements[0])
        GetLast<public>()<decides><computes>:tuple(Stack(t), t) = (Stack(t){ Elements := Elements.RemoveElement[Elements.Length - 1] }, Elements[Elements.Length - 1])

        # Aliases
        Push<public>(Element:t)<computes>:Stack(t) = AddLast(Element)
        Pop<public>()<computes><decides>:tuple(Stack(t), t) = GetLast[]
    }

    ### String Utils

    CharToIntMap<public>:[char]int = map{
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4,
        '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9
    }

    StringToInt<public>(String:string)<transacts><decides>:int = {
        Length := String.Length
        Length <> 0
        
        var IntegerNumber:int = 0

        ReversedString := String.Reverse()

        IsNegative := if (String[0] = '-') { true } else { false }

        for (Index->Char : ReversedString) {
            if (Index <> Length - 1 or not IsNegative?) {
                CurrentDigit := CharToIntMap[Char]
                set IntegerNumber += CurrentDigit * Int[Pow(10.0, Index * 1.0)]
            }
        }

        if (IsNegative?). IntegerNumber * -1 else. IntegerNumber
    }
}