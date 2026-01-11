using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Shift_RightRotate_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Shift.RightRotate(:int,:int)>"

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
        (1, 1, false, -2)       # Width 2 (01). Right 1 -> 10 (-2 in 2-bit).
        (-1, 4, false, -1)      # Always -1
        (3, 1, false, -3)       # Width 3 (011). Right 1 -> 101 (-3 in 3-bit).
        (-4, 1, false, 2)       # Width 3 (100). Right 1 -> 010 (2).
        (-4, 2, false, 1)       # Width 3 (100). Right 2 -> 001 (1).
        (7, 2, false, -3)       # Width 4 (0111). Right 2 -> 1101 (-3 in 4-bit).
        (128, 1, false, 64)     # Width 9 (010000000). Right 1 -> 001000000 (64).
        (-128, 3, false, 16)    # Width 8 (10000000). Right 3 -> 00010000 (16).
        (170, 1, false, 85)     # Width 9 (010101010). Right 1 -> 001010101 (85).

        # Group 2: Fixed 8-Bit Width
        (1, 1, option{8}, -128)     # 00000001 -> 10000000 (-128)
        (1, 4, option{8}, 16)       # 00000001 -> 00010000 (Wraps: 2^4)
        (128, 1, option{8}, 64)     # 10000000 -> 01000000
        (-128, 1, option{8}, 64)    # 10000000 -> 01000000
        (170, 1, option{8}, 85)     # 10101010 -> 01010101
        (-1, 4, option{8}, -1)      # Stays all 1s

        # Group 3: Fixed 32-Bit Width
        (1, 31, option{32}, 2)                      # 0..01 Right 31 -> 0..010 (Wraps around)
        (-2147483648, 1, option{32}, 1073741824)
        (0, 10, option{32}, 0)
        (-1, 15, option{32}, -1)

        # Group 4: Multi-Rotation & Modulo Handling
        (1, 10, option{8}, 64)  # 10 mod 8 is 2. 00000001 Right 2 -> 01000000 (64).
        (5, 16, option{8}, 5)   # Identity

        # Group 5: Arbitrary/Large Values
        (123456789, 4, option{40}, 343605099729)    # Calculated 40-bit wrap
        # (-1, 1, option{64}, -1)
        
        # Group 6: Negative Positions (Should rotate Left)
        (1, -1, option{8}, 2)       # Right Rot -1 is Left Rot 1. 00000001 -> 00000010
        (47, -5, option{8}, -27)
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

            Received := RightRotate(Value, Positions, ?BitCount:=BitWidth)

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