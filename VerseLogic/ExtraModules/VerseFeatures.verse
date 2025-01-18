using { /UnrealEngine.com/Temporary/UI }

VerseFeatures<public> := module {

    ### Logic Utils

    Success<public>()<computes><decides>:void = true? # true? crashes compiler
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
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:type).Keys<public>()<computes>:[]keytype = {
        for (CurrentKey->Unused : Input). CurrentKey
    }

    # Returns an array with all values of the map
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:type).Values<public>()<computes>:[]valuetype = {
        for (CurrentValue : Input). CurrentValue
    }

    # Returns a map without the map element that Key matches the Key provided
    # If Strict is set to true, will force a fail when key does not exist on the map
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:type).RemoveByKey<public>(KeyToRemove: keytype, ?Strict:logic=false)<transacts><decides>:[keytype]valuetype = {
        if (Strict?). Input[KeyToRemove]

        var TempMap:[keytype]valuetype = map{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentKey <> KeyToRemove
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns a map without all map elements that Key matches the Keys provided
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:type).RemoveByKeys<public>(KeysToRemove: []keytype)<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = Input
        for (KeyToRemove : KeysToRemove) {
            ResultMap := TempMap.RemoveByKey[KeyToRemove, ?Strict := false] # Strict default value is already false on the function definition and due to that is not a required argument, but if not mentioned again here, for some reason it crashes the server
            set TempMap = ResultMap
        }
        TempMap
    }

    # Returns a map with only the elements that Key matches the Keys provided
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:type).FilterByKeys<public>(Keys: []keytype)<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = map{}
        for (
            CurrentKey->CurrentValue:Input
            KeyToCompare : Keys
            CurrentKey = KeyToCompare
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns the first map Key where the associated Value matches the provided Value
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:subtype(comparable)).FindKeyByValue<public>(Value: valuetype)<transacts><decides>:keytype = {
        var MaybeKey:?keytype = false
        for (
            CurrentKey->CurrentValue:Input
            not MaybeKey?
            CurrentValue = Value
        ). set MaybeKey = option{CurrentKey}
        MaybeKey?
    }

    # Returns all map Keys where the associated Value matches the provided Value
    # If Strict is set to true, will force a fail when none of the values exist on the map
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:subtype(comparable)).FindKeysByValue<public>(Value: valuetype, ?Strict:logic=false)<transacts><decides>:[]keytype = {
        var KeysFound:[]keytype = array{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentValue = Value
        ). set KeysFound += array{CurrentKey}

        KeysFound.Length <> 0 or not Strict?

        KeysFound
    }

    # return a map with only the elements that Value matches the Values provided
    # If Strict is set to true, will force a fail when none of the values exist on the map
    (Input:[keytype]valuetype where keytype:subtype(comparable), valuetype:subtype(comparable)).FilterByValues<public>(Values: []valuetype, ?Strict:logic=false)<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = map{}
        for (
            CurrentKey->CurrentValue:Input
            ValueToCompare : Values
            CurrentValue = ValueToCompare
        ). set TempMap[CurrentKey] = CurrentValue

        TempMap.Length <> 0 or not Strict?

        TempMap
    }

    # UNTESTED
    # Returns the first map Key where the Value succeeds the provided comparer function
    # (Input:[keytype]valuetype).FindKeyByValueData<public>(Value: valuetype where keytype:subtype(comparable), valuetype:subtype(comparable))<transacts><decides>:keytype = {
    #     var MaybeKey:?keytype = false
    #     for (
    #         CurrentKey->CurrentValue:Input
    #         not MaybeKey?
    #         CurrentValue = Value
    #     ). set MaybeKey = option{CurrentKey}
    #     MaybeKey?
    # }

    # Returns all map Keys where the Value succeeds the provided comparer function
    # (Input:[keytype]valuetype).FindKeysByValueData<public>(Value: valuetype where keytype:subtype(comparable), valuetype:subtype(comparable))<transacts>:[]keytype = {
    #     var KeysFound:[]keytype = array{}
    #     for (
    #         CurrentKey->CurrentValue:Input
    #         CurrentValue = Value
    #     ). set KeysFound += array{CurrentKey}
    #     KeysFound
    # }



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

    (Input:[]t where t:type).QuickSort<public>(Comparer : type{_(:t, :t)<computes> : int}, ?IsAscending : logic = true)<computes> : []t = {
        if (Input.Length > 1, Pivot := Input[Floor(Input.Length/2)]) {
            
            Left := for (Element : Input, Comparer(Element, Pivot) < 0) { Element }
            Middle := for (Element : Input, Comparer(Element, Pivot) = 0) { Element }
            Right := for (Element : Input, Comparer(Element, Pivot) > 0) { Element }

            if (IsAscending?). Left.QuickSort(Comparer, ?IsAscending := IsAscending) + Middle + Right.QuickSort(Comparer, ?IsAscending := IsAscending)
            else. Right.QuickSort(Comparer, ?IsAscending := IsAscending) + Middle + Left.QuickSort(Comparer, ?IsAscending := IsAscending)

        } else { Input }
    }

    SortIntDefaultComparer<public>(A:int, B:int)<computes> : int = {
        if (A < B). -1
        else if (A > B). 1
        else 0
    }

    SortFloatDefaultComparer<public>(A:float, B:float)<computes> : int = {
        if (A < B). -1
        else if (A > B). 1
        else 0
    }

    

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

        for (Index->Char : String.Reverse()) {
            if (Index <> Length - 1 or not IsNegative?) {
                CurrentDigit := CharToIntMap[Char]
                set IntegerNumber += CurrentDigit * Int[Pow(10.0, Index * 1.0)]
            }
        }

        if (IsNegative?). IntegerNumber * -1 else. IntegerNumber
    }
}