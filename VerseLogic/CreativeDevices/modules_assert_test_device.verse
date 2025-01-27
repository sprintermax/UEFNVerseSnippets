using. /Fortnite.com/Devices
using. /Verse.org/Colors
using. /Verse.org/Random
using. /Verse.org/Simulation

using. ExtraModules.DebugFeatures
using. ExtraModules.VerseFeatures

dummy_class := class<unique>{
    A:int
    B:int
}

AGreaterOrEqualsThanThree(Value:dummy_class)<transacts><decides>:void = {
    Value.A >= 2
}
BGreaterThanFifty(Value:dummy_class)<transacts><decides>:void = {
    Value.B >= 50
}
BGreaterThanA(Value:dummy_class)<transacts><decides>:void = {
    Value.B > Value.A
}
AEqualsToB(Value:dummy_class)<transacts><decides>:void = {
    Value.A = Value.B
}

modules_assert_test_device<internal> := class<final>(creative_device) {

    var TestID : string = ""
    var Passed : int = 0
    var Failed : int = 0

    Assert(Message:string):void = {
        set TestID = Message
    }

    Pass()<transacts>:void = {
        Print("Test Passed: {TestID}", ?Color := NamedColors.Green)
        set Passed += 1
    }
    Fail()<transacts>:void = {
        Print("Test Failed: {TestID}", ?Color := NamedColors.Red)
        set Failed += 1
    }

    OnBegin<override>()<suspends>:void = {

        AssertVerseFeatures()

        Logger.Log_CosmeticWarning("Tests Completed - Results:\nPassed: {Passed} | Failed: {Failed} | Total: {Passed + Failed}")
    }

    AssertVerseFeatures()<suspends>:void = {
        Logger.Log_CosmeticWarning("Asserting VerseFeatures Module")

        ### Logic Utils

        Assert("IF Condition Should Always Success")
        if (Success[]). Pass()
        else. Fail()

        Assert("IF Condition Should Always Fail")
        if (Failure[]). Fail()
        else. Pass()

        Assert("'true' Logic to String should be 'true'")
        if (ToString(true) = "true"). Pass()
        else. Fail()

        Assert("'false' Logic to String should be 'false'")
        if (ToString(false) = "false"). Pass()
        else. Fail()

        Assert("'false' Logic inverted should be 'true'")
        if (false.Invert() = true). Pass()
        else. Fail()

        Assert("'true' Logic inverted should be 'false'")
        if (true.Invert() = false). Pass()
        else. Fail()

        ### Message Utils

        ### Map Operations
        Sleep(0.0)

        EmptyMap : [comparable]any= map{}
        ABC123Map := map{
            "A" => 1
            "B" => 2
            "C" => 3
        }
        DEF345Map := map{
            "D" => 3
            "E" => 4
            "F" => 5
        }

        MapForCompare := map{
            "A" => dummy_class{A := 1, B := 2}
            "B" => dummy_class{A := 2, B := 3}
            "C" => dummy_class{A := 4, B := 3}
            "D" => dummy_class{A := 6, B := 5}
            "E" => dummy_class{A := 7, B := 7}
        }

        Assert("Should silently pass when trying to delete inexistent key from map")
        if (ABC123Map.RemoveByKey["D"]). Pass()
        else. Fail()

        Assert("Should fail when trying to delete inexistent key from map with strict mode")
        if (ABC123Map.RemoveByKey["D", ?Strict := true]). Fail()
        else. Pass()

        Assert("Should return a map without element matching deleted key")
        if (ABC123Map.RemoveByKey["B"] = map{
            "A" => 1
            "C" => 3
        }). Pass()
        else. Fail()

        Assert("Should silently pass when trying to delete inexistent keys from map")
        if (ABC123Map.RemoveByKeys["D", "E"]). Pass()
        else. Fail()
        
        Assert("Should return a map without elements matching deleted keys")
        if (ABC123Map.RemoveByKeys["A", "C"] = map{
            "B" => 2
        }). Pass()
        else. Fail()

        Assert("Should return a map with only elements matching specified keys")
        if (ABC123Map.FilterByKeys["A", "C"] = map{
            "A" => 1
            "C" => 3
        }). Pass()
        else. Fail()

        Assert("Should fail if no key found where the associated value matches specified value")
        if (ABC123Map.FindKeyByValue[4]). Fail()
        else. Pass()

        Assert("Should return the first key where the associated value matches specified value")
        if (ABC123Map.FindKeyByValue[3] = "C"). Pass()
        else. Fail()

        Assert("Should silently pass with an empty array when no keys found where the associated values matches specified value")
        if (ABC123Map.FindKeysByValue[4]). Pass()
        else. Fail()

        Assert("Should fail due to no keys found where the associated values matches specified value with strict mode")
        if (ABC123Map.FindKeysByValue[4, ?Strict := true]). Fail()
        else. Pass()

        Assert("Should return an array with all keys where the associated values matches specified value")
        if (ConcatenateMaps(ABC123Map, DEF345Map).FindKeysByValue[3] = array{"C", "D"}). Pass()
        else. Fail()

        Assert("Should silently pass with an empty map when no values matches specified value")
        if (ABC123Map.FilterByValues[array{4}]). Pass()
        else. Fail()

        Assert("Should fail due to no values found that matches specified value with strict mode")
        if (ABC123Map.FilterByValues[array{4}, ?Strict := true]). Fail()
        else. Pass()

        Assert("Should return a map with all elements where associated values matches specified value")
        if (ConcatenateMaps(ABC123Map, DEF345Map).FilterByValues[array{3}] = map{
            "C" => 3
            "D" => 3
        }). Pass()
        else. Fail()

        # Assert("Should fail due to no elements that matches comparer function")
        # if (MapForCompare.FindKeyByValueData[BGreaterThanFifty]). Fail()
        # else. Pass()

        # Assert("Should return map with first element that matches comparer function")
        # if (MapForCompare.FindKeyByValueData[AGreaterOrEqualsThanThree] = map{
        #     "C" => dummy_class{A := 4, B := 3}
        # }). Pass()
        # else. Fail()
        
        # Assert("Should silently pass with an empty map when no elements matches specified comparer function")
        # if (MapForCompare.FindKeysByValueData[BGreaterThanFifty]). Pass()
        # else. Fail()

        # Assert("Should fail due to no elements matches specified comparer function with strict mode")
        # if (MapForCompare.FindKeysByValueData[BGreaterThanFifty, ?Strict := true]). Fail()
        # else. Pass()

        # Assert("Should return map with only the elements that matches specified comparer function")
        # if (MapForCompare.FindKeysByValueData[AGreaterOrEqualsThanThree] = map{
        #     "C" => dummy_class{A := 4, B := 3}
        #     "D" => dummy_class{A := 6, B := 5}
        #     "E" => dummy_class{A := 7, B := 7}
        # }). Pass()
        # else. Fail()

        ### Array Operations
        Sleep(0.0)

        EmptyArray := array{}
        Test123Array := array{1, 2, 3}
        Test826Array := array{8, 2, 6}

        Assert("Test123Array reversed should be 'array\{3, 2, 1\}'")
        if (Test123Array.Reverse() = array{3, 2, 1}). Pass()
        else. Fail()

        Assert("Accessing empty array at any index should fail")
        if (EmptyArray.At[0]). Fail()
        else. Pass()

        Assert("Accessing array at in range positive index should return 3")
        if (Test123Array.At[2] = 3). Pass()
        else. Fail()

        Assert("Accessing array at in range negative index should return 2")
        if (Test123Array.At[-2] = 2). Pass()
        else. Fail()

        Assert("Accessing array at out of range positive index should return 2")
        if (Test123Array.At[7] = 2). Pass()
        else. Fail()

        Assert("Accessing array at out of range negative index should return 3")
        if (Test123Array.At[-7] = 3). Pass()
        else. Fail()

        ### Sorting Operations

        Assert("Ascending sort of Test826Array should be 'array\{2, 6, 8\}'")
        if (Test826Array.MergeSort(SortIntAscending) = array{2, 6, 8}). Pass()
        else. Fail()

        Assert("Descending sort of Test826Array should be 'array\{8, 6, 2\}'")
        if (Test826Array.MergeSort(SortIntDescending) = array{8, 6, 2}). Pass()
        else. Fail()

        ### Containers

        ### String Utils
        Sleep(0.0)

        Assert("String should be converted to positive integer 381")
        if (StringToInt["381"] = 381). Pass()
        else. Fail()

        Assert("String should be converted to negative integer -248")
        if (StringToInt["-248"] = -248). Pass()
        else. Fail()

        Assert("Empty string should fail conversion to integer")
        if (StringToInt[""]). Fail()
        else. Pass()

        Assert("Float String should fail conversion to integer")
        if (StringToInt["1.0256"]). Fail()
        else. Pass()

        Assert("Non-numeric String should fail conversion to integer")
        if (StringToInt["Hello World"]). Fail()
        else. Pass()
        
    }
}