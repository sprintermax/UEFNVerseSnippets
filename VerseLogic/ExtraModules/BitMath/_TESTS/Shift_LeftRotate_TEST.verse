using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Shift_LeftRotate_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Shift.LeftRotate(:int,:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Positions>, <Fixed Bit Width>, <Expected Result>)
    TestCases<private> : []tuple(int, int, ?int, int) = array{
        # Group 1: Dynamic Width (BitCount = false)
        (1, 1, false, -2)   # Width 2 (01). Rotate 1 -> 10 (-2 in 2-bit).
        (-1, 4, false, -1)
        (3, 1, false, -2)   # Width 3 (011). Rotate 1 -> 110 (-2 in 3-bit).
        (-4, 1, false, 1)   # Width 3 (100). Rotate 1 -> 001 (1).
        (-4, 2, false, 2)
        (7, 2, false, -3)    # Width 4 (0111). Rotate 2 -> 1101 (-3 in 4-bit).
        (128, 1, false, -256)
        (-128, 3, false, 4)
        (170, 1, false, -172)

        # Group 2: Fixed 8-Bit Width
        (1, 1, option{8}, 2)    # 00000001 -> 00000010
        (1, 4, option{8}, 16)   # 00000001 -> 00010000
        (128, 1, option{8}, 1)  # 10000000 -> 00000001 (Sign bit wraps to bottom)
        (-128, 1, option{8}, 1) # Same as above
        (170, 1, option{8}, 85) # 10101010 -> 01010101
        (-1, 4, option{8}, -1)  # 11111111 rotated is still all 1s

        # Group 3: Fixed 32-Bit Width
        (1, 31, option{32}, -2147483648)    # Bit 0 moves to the Sign Bit
        (-2147483648, 1, option{32}, 1)     # Sign Bit wraps to Bit 0
        (0, 10, option{32}, 0)              # 0 stays 0
        (-1, 15, option{32}, -1)            # All 1s stays -1

        # Group 4: Multi-Rotation & Modulo Handling
        (1, 10, option{8}, 4)   # 10 rot 8 is 2. 00000001 << 2 = 4.
        (5, 16, option{8}, 5)   # 16 is multiple of 8, should be identity

        # Group 5: Arbitrary/Large Values
        (123456789, 4, option{40}, 1975308624)
        # (-1, 1, option{64}, -1)
        
        # Group 6: Negative Positions (Should rotate Right)
        (1, -1, option{8}, -128)    # Left Rot -1 is Right Rot 1. 00000001 -> 10000000 (-128)
        (47, -5, option{8}, 121)
    }

    OnBegin<override>()<suspends>:void = {
        Sleep(0.0)
        ExecuteTestCases()
        Sleep(1.0)
        RunBenchmark()
    }

    RunBenchmark<public>()<suspends>:void = {
        Print("{GetLogPrefix("🧪", ?IsBenchmark:=true)}: STARTING BENCHMARK FOR {TestCases.Length} TESTS...")

        for (
            # 0..7 = (1, 2, 4, 8, 16, 32, 64, 128) Iterations
            X := 0..7
            Iterations := PowerOfTwo[X] or Err("Unreachable")
        ) {
            Sleep(0.0)
            # 🔄 (Benchmark prints does not support emojis)
            profile("{GetLogPrefix("", ?IsBenchmark:=true, ?IsProfile:=true)}: Benchmark #{X + 1} ({Iterations} Iterations):") {
                for (Y := 1..Iterations) {
                    ExecuteTestCases(?IsBenchmark:=true)
                }
            }
        }

        TEMP_PH := "<unimplemented>"

        Print("{GetLogPrefix("📊", ?IsBenchmark:=true)}: BENCHMARK FINISHED! MIN: {TEMP_PH}, MAX: {TEMP_PH}, AVERAGE: {TEMP_PH}")
    }

    ExecuteTestCases<public>(?IsBenchmark:logic=false):void = {

        if (not IsBenchmark?). Print("{GetLogPrefix("🚀")}: STARTING {TestCases.Length} TESTS...")

        # Map of [<Case Index>]<Received>
        var FailedResults : [int]int = map{}

        for (Index->TestCase : TestCases) {
            Value := TestCase(0)
            Positions := TestCase(1)
            BitWidth := TestCase(2)
            Expected := TestCase(3)

            Received := LeftRotate(Value, Positions, ?BitCount:=BitWidth)

            if (not IsBenchmark?) {
                if (Expected = Received) {
                    Print("{GetLogPrefix("✅")}: Test #{Index + 1}: PASS!")
                } else {
                    Print("{GetLogPrefix("❌")}: Test #{Index + 1}: FAIL! (Expected: \"{Expected}\", Received: \"{Received}\")")
                    (set FailedResults[Index] = Received) or Err("Unreachable")
                }
            }
        }

        if (not IsBenchmark?) {
            ResultEmoji := if (FailedResults.Length = 0) { "⭐" } else { "⚠️" }
            Print("{GetLogPrefix(ResultEmoji)}: TESTS FINISHED! {TestCases.Length - FailedResults.Length}/{TestCases.Length} TESTS PASSED.")
        }
    }
}