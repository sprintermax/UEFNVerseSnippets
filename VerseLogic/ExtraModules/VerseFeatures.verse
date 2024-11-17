using { /UnrealEngine.com/Temporary/UI }

VerseFeatures<public> := module {

    ### Logic utils

    Success<public>()<transacts><decides>:void = {} # true? crashes compiler
    Failure<public>()<transacts><decides>:void = false?

    (Input:logic).ToString<public>()<computes>:string = {
        if (Input?) { "true" } else { "false" }
    }
    
    (Logic:logic).Invert<public>()<computes>:logic = if (Logic?) { false } else { true }

    prefix'-'<public>(Logic:logic)<computes>:logic = Logic.Invert()



    ### Message Utils
    
    JoinMessages<public><localizes>(First:message, Second:message)<computes>:message = "{First}{Second}"

    operator'+'<public><localizes>(First:message, Second:message)<computes>:message = "{First}{Second}"



    ### Map Operations

    # Returns a map without the map element that Key matches the Key provided
    (Input:[keytype]valuetype).DeleteByKey<public>(KeyToDelete: keytype where keytype:subtype(comparable), valuetype:type)<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = map{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentKey <> KeyToDelete
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns a map without all map elements that Key matches the Keys provided
    (Input:[keytype]valuetype).DeleteByKeys<public>(KeysToDelete: []keytype where keytype:subtype(comparable), valuetype:type)<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = Input
        for (KeyToDelete : KeysToDelete) {
            ResultMap := TempMap.DeleteByKey[KeyToDelete]
            set TempMap = ResultMap
        }
        TempMap
    }

    # Returns a map with only the elements that Key matches the Keys provided
    (Input:[keytype]valuetype).FilterByKeys<public>(Keys: []keytype where keytype:subtype(comparable), valuetype:subtype(comparable))<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = map{}
        for (
            CurrentKey->CurrentValue:Input
            KeyToCompare : Keys
            CurrentKey = KeyToCompare
        ). set TempMap[CurrentKey] = CurrentValue
        TempMap
    }

    # Returns the first map Key where the associated Value matches the provided Value
    (Input:[keytype]valuetype).FindKeyByValue<public>(Value: valuetype where keytype:subtype(comparable), valuetype:subtype(comparable))<transacts><decides>:keytype = {
        var MaybeKey:?keytype = false
        for (
            CurrentKey->CurrentValue:Input
            not MaybeKey?
            CurrentValue = Value
        ). set MaybeKey = option{CurrentKey}
        MaybeKey?
    }

    # Returns all map Keys where the associated Value matches the provided Value
    (Input:[keytype]valuetype).FindKeysByValue<public>(Value: valuetype where keytype:subtype(comparable), valuetype:subtype(comparable))<transacts>:[]keytype = {
        var KeysFound:[]keytype = array{}
        for (
            CurrentKey->CurrentValue:Input
            CurrentValue = Value
        ). set KeysFound += array{CurrentKey}
        KeysFound
    }

    # return a map with only the elements that Value matches the Values provided
    (Input:[keytype]valuetype).FilterByValues<public>(Values: []valuetype where keytype:subtype(comparable), valuetype:subtype(comparable))<transacts><decides>:[keytype]valuetype = {
        var TempMap:[keytype]valuetype = map{}
        for (
            CurrentKey->CurrentValue:Input
            ValueToCompare : Values
            CurrentValue = ValueToCompare
        ). set TempMap[CurrentKey] = CurrentValue
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
        for (Index->Unused:Input, Element := Input[Input.Length - 1 - Index]) { Element }
    }

    (Input:[]t where t:type).At<public>(Index:int)<decides><transacts>: t = {
        if (Index >= 0) { Input[Index] } else { Input[Input.Length + Index] }
    }



    ### Sorting Operations

    (Input:[]t where t : type).Sort<public>(Comparer : type{_(:t, :t)<computes> : int}, ?IsAscending : logic = true)<computes> : []t = {

        if (Input.Length > 1, Pivot := Input[Floor(Input.Length/2)]) {
            
            Left := for (Element : Input, Comparer(Element, Pivot) < 0) { Element }
            Middle := for (Element : Input, Comparer(Element, Pivot) = 0) { Element }
            Right := for (Element : Input, Comparer(Element, Pivot) > 0) { Element }

            if (IsAscending?). Left.Sort(Comparer, ?IsAscending := IsAscending) + Middle + Right.Sort(Comparer, ?IsAscending := IsAscending)
            else. Right.Sort(Comparer, ?IsAscending := IsAscending) + Middle + Left.Sort(Comparer, ?IsAscending := IsAscending)

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
        IsEmpty<public>()<decides><transacts>:void = Elements.Length = 0

        AddFirst<public>(Element:t)<computes>:Stack(t) = Stack(t){ Elements := array{Element} + Elements }
        AddLast<public>(Element:t)<computes>:Stack(t) = Stack(t){ Elements := Elements + array{Element} }

        GetAt<public>(Index:int)<decides><transacts>:tuple(Stack(t), t) = (Stack(t){ Elements := Elements.RemoveElement[Index] }, Elements[Index])

        GetFirst<public>()<decides><transacts>:tuple(Stack(t), t) = (Stack(t){ Elements := Elements.RemoveElement[0] }, Elements[0])
        GetLast<public>()<decides><transacts>:tuple(Stack(t), t) = (Stack(t){ Elements := Elements.RemoveElement[Elements.Length - 1] }, Elements[Elements.Length - 1])

        # Aliases
        Push<public>(Element:t)<computes>:Stack(t) = AddLast(Element)
        Pop<public>()<transacts><decides>:tuple(Stack(t), t) = GetLast[]
    }

    ### String Utils

    CharToIntMap<public>:[char]int = map{
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4,
        '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9
    }

    # WIP - REMEMBER TO CHECK IF NEGATIVE NUMBERS SUPPORT IS CORRECT
    StringToInt<public>(String:string)<transacts><decides>:int = {
        String.Length <> 0
        
        var IntegerNumber:int = 0

        ReversedString := String.Reverse()

        IsNegative := if (ReversedString[0] = '-'). true else. false

        for (Index->Char : String.Reverse()) {
            if (Index <> 0 or not IsNegative?) {
                CurrentDigit := CharToIntMap[Char]
                set IntegerNumber += CurrentDigit * Int[Pow(10.0, Index * 1.0)]
            }
        }

        if (IsNegative?). IntegerNumber * -1 else. IntegerNumber
    }
}