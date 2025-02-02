using. /Fortnite.com/Devices
using. /UnrealEngine.com/Temporary/SpatialMath
using. /Verse.org/Colors
using. /Verse.org/Random
using. /Verse.org/Simulation

using. ExtraModules.BitMath
using. ExtraModules.DebugFeatures
using. ExtraModules.TextLocalization
using. ExtraModules.UnrealEngineFeatures
using. ExtraModules.VerseFeatures

dummy_class := class<unique>{
    A:int
    B:int
}

AGreaterOrEqualsThanThree<internal>(Value:dummy_class)<transacts><decides>:void = Value.A >= 3
BGreaterThanFifty<internal>(Value:dummy_class)<transacts><decides>:void = Value.B >= 50
BGreaterThanA<internal>(Value:dummy_class)<transacts><decides>:void = Value.B > Value.A
AEqualsToB<internal>(Value:dummy_class)<transacts><decides>:void = Value.A = Value.B

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
        Sleep(1.0)
        AssertUnrealEngineFeatures()
        Sleep(1.0)
        AssertTextLocalization()
        Sleep(1.0)
        AssertBitMath()

        Logger.Log_CosmeticWarning("Tests Completed - Results:\nPassed: {Passed} | Failed: {Failed} | Total: {Passed + Failed}")
    }

    ABC123Map : [string]int = map{
        "A" => 1
        "B" => 2
        "C" => 3
    }
    DEF345Map : [string]int = map{
        "D" => 3
        "E" => 4
        "F" => 5
    }

    MapForCompare : [string]dummy_class = map{
        "A" => dummy_class{A := 1, B := 2}
        "B" => dummy_class{A := 2, B := 3}
        "C" => dummy_class{A := 4, B := 3}
        "D" => dummy_class{A := 6, B := 5}
        "E" => dummy_class{A := 7, B := 7}
    }

    Test123Array : []int = array{1, 2, 3}
    Test826Array : []int = array{8, 2, 6}

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

        Assert("Should silently pass when trying to delete inexistent key from map")
        if (ABC123Map.RemoveByKey["D"] = ABC123Map). Pass()
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
        if (ABC123Map.RemoveByKeys["D", "E"] = ABC123Map). Pass()
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
        if (ABC123Map.FindKeysByValue[4] = array{}). Pass()
        else. Fail()

        Assert("Should fail due to no keys found where the associated values matches specified value with strict mode")
        if (ABC123Map.FindKeysByValue[4, ?Strict := true]). Fail()
        else. Pass()

        Assert("Should return an array with all keys where the associated values matches specified value")
        if (ConcatenateMaps(ABC123Map, DEF345Map).FindKeysByValue[3] = array{"C", "D"}). Pass()
        else. Fail()

        Assert("Should silently pass with an empty map when no values matches specified value")
        if (ABC123Map.FilterByValues[array{4}] = map{}). Pass()
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

        Assert("Should fail due to no elements that matches comparer function")
        if (MapForCompare.FindKeyByValueData[BGreaterThanFifty]). Fail()
        else. Pass()

        Assert("Should return the key of first element that matches comparer function")
        if (MapForCompare.FindKeyByValueData[AGreaterOrEqualsThanThree] = "C"). Pass()
        else. Fail()
        
        Assert("Should silently pass with an empty array when no elements matches specified comparer function")
        if (MapForCompare.FindKeysByValueData[BGreaterThanFifty] = array{}). Pass()
        else. Fail()

        # TEST DISABLED DUE TO A BUG IN THE VERSE COMPILER RELATED TO OPTIONAL NAMED PARAMETERS
        # Assert("Should fail due to no elements matches specified comparer function with strict mode")
        # if (MapForCompare.FindKeysByValueData[BGreaterThanFifty, ?Strict := true]). Fail()
        # else. Pass()

        Assert("Should return map with only the key of elements that matches specified comparer function")
        if (MapForCompare.FindKeysByValueData[AGreaterOrEqualsThanThree] = array{"C", "D", "E"}). Pass()
        else. Fail()

        ### Array Operations
        Sleep(0.0)

        Assert("Test123Array reversed should be 'array\{3, 2, 1\}'")
        if (Test123Array.Reverse() = array{3, 2, 1}). Pass()
        else. Fail()

        Assert("Accessing empty array at any index should fail")
        if (array{}.At[0]). Fail()
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

    AssertUnrealEngineFeatures()<suspends>:void = {
        Logger.Log_CosmeticWarning("Asserting UnrealEngineFeatures Module")

        Assert("Should fail when trying to get position of a bezier curve with an empty array using DeCasteljau algorithm")
        if (BezierCurves.DeCasteljau_3DV2[array{}, 0.5]). Fail()
        else. Pass()

        Assert("Should return first index of the input array if its length is 1 using DeCasteljau algorithm")
        if (BezierCurves.DeCasteljau_3DV2[array{Vector3(1.2, 1.3, 1.4)}, 0.5] = Vector3(1.2, 1.3, 1.4)). Pass()
        else. Fail()

        Assert("Should return midpoint of the input array of 2 bezier curve points using DeCasteljau algorithm")
        if (BezierCurves.DeCasteljau_3DV2[array{
            Vector3(0.0, 0.0, 0.0)
            Vector3(1.0, 1.0, 1.0)
        }, 0.5] = Vector3(0.5, 0.5, 0.5)). Pass()
        else. Fail()

        Assert("Should return midpoint of the input array of multiple bezier curve points using DeCasteljau algorithm")
        if (BezierCurves.DeCasteljau_3DV2[array{
            Vector3(0.0, 0.0, 0.0)
            Vector3(1.0, 1.0, 1.0)
            Vector3(1.0, 1.0, -1.0)
        }, 0.5] = Vector3(0.75, 0.75, 0.25)). Pass()
        else. Fail()

    }

    AssertTextLocalization()<suspends>:void = {
        Logger.Log_CosmeticWarning("Asserting TextLocalization Module")

        TimeSeconds := 12345.678

        PositiveTime := Loc_Time_ClockFormat(TimeSeconds)
        PositiveTimeMiliseconds := Loc_Time_ClockFormat(TimeSeconds, ?DisplayMiliseconds := true)
        NegativeTime := Loc_Time_ClockFormat(-TimeSeconds)
        NegativeTimeMiliseconds := Loc_Time_ClockFormat(-TimeSeconds, ?DisplayMiliseconds := true)

        Assert("Positive Time of 12345.678 should be '03:25:45'")
        if (PositiveTime = "03:25:45"). Pass()
        else. Fail()

        Assert("Positive Time with miliseconds of 12345.678 should be '03:25:45.678'")
        if (PositiveTimeMiliseconds = "03:25:45.678"). Pass()
        else. Fail()

        Assert("Negative Time of 12345.678 should be '-03:25:45'")
        if (NegativeTime = "-03:25:45"). Pass()
        else. Fail()

        Assert("Negative Time with miliseconds of 12345.678 should be '-03:25:45.678'")
        if (NegativeTimeMiliseconds = "-03:25:45.678"). Pass()
        else. Fail()

    }

    AssertBitMath()<suspends>:void = {
        Logger.Log_CosmeticWarning("Asserting BitMath Module")

        Assert("Bitwise And operations must provides expected values")
        if (
            BitwiseAnd(5, 3) = 1
            BitwiseAnd(14530, 84573912) = 14528
            BitwiseAnd(-14530, -84512) = -96992
            BitwiseAnd(-5, -2) = -6
            BitwiseAnd(-5, 7) = 3
        ). Pass()
        else. Fail()

        Assert("Bitwise Or operations must provide expected values")
        if (
            BitwiseOr(5, 3) = 7
            BitwiseOr(14530, 84573912) = 84573914
            BitwiseOr(-14530, -84512) = -2050
            BitwiseOr(-5, -2) = -1
            BitwiseOr(-5, 7) = -1
        ). Pass()
        else. Fail()

        Assert("Bitwise Xor operations must provide expected values")
        if (
            BitwiseXor(5, 3) = 6
            BitwiseXor(14530, 84573912) = 84559386
            BitwiseXor(-14530, -84512) = 94942
            BitwiseXor(-5, -2) = 5
            BitwiseXor(-5, 7) = -4
        ). Pass()
        else. Fail()

        Assert("Bitwise Not operations must provide expected values")
        if (
            BitwiseNot(5) = -6
            BitwiseNot(14530) = -14531
            BitwiseNot(-14530) = 14529
            BitwiseNot(-5) = 4
            BitwiseNot(7) = -8
        ). Pass()
        else. Fail()

        Assert("Arithmetic left shift operations must provide expected values")
        if (
            LeftShift(5, 2) = 20
            LeftShift(-5, 2) = -20
            LeftShift(14530, 3) = 116240
            LeftShift(-14530, 6) = -929920
            LeftShift(-14530, -2) = -58120
        ). Pass()
        else. Fail()

        Assert("Right shift operations must provide expected values")
        if (
            RightShift(5, 2) = 1
            RightShift(-5, 2) = -2
            RightShift(14530, 3) = 1816
            RightShift(-14530, 6) = -228
            RightShift(-14530, -2) = -3633
        ). Pass()
        else. Fail()

        Assert("Logical Right shift operations must provide expected values")
        if (
            LogicalRightShift(5, 2) = 1
            LogicalRightShift(-5, 2) = 1073741822
            LogicalRightShift(14530, 3) = 1816
            LogicalRightShift(-14530, 6) = 67108636
            LogicalRightShift(-14530, -2) = 1073738191
        ). Pass()
        else. Fail()
    }
}