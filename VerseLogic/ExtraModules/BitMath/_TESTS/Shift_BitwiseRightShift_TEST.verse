using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Shift_BitwiseRightShift_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Shift.BitwiseRightShift(:int,:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Positions>, <Expected Result>)
    TestCases<private> : []tuple(int, int, int) = array{
        # Group 1: Positive Values (Simple Division)
        (1, 1, 0)           # 1 >> 1 = 0
        (10, 1, 5)          # 10 / 2 = 5
        (15, 2, 3)          # 15 / 4 = 3.75 -> 3
        (1024, 10, 1)       # 2^10 >> 10 = 1
        (1234567, 10, 1205) # 1234567 / 1024 = 1205.6 -> 1205

        # Group 2: Negative Values (The Floor Test)
        (-1, 1, -1)             # -1 >> 1 = -1 (Sign preserved)
        # (-1, 100, -1)           # -1 remains -1 forever
        (-2, 1, -1)             # 1...1110 >> 1 = 1...1111 (-1)
        (-5, 1, -3)             # -5 / 2 = -2.5 -> -3
        (-15, 2, -4)            # -15 / 4 = -3.75 -> -4
        (-16, 2, -4)            # -16 / 4 = -4.0 -> -4
        (-1234567, 10, -1206)   # -1205.6 -> -1206

        # Group 3: Non-Power of Two Values
        (7, 2, 1)       # 7 (111) >> 2 = 1 (001)
        (-7, 2, -2)     # -7 (1...1001) >> 2 = 1...1110 (-2)
        (123, 3, 15)    # 123 / 8 = 15
        (-123, 3, -16)  # -123 / 8 = -15.375 -> -16

        # Group 4: Edge Cases
        (0, 5, 0)               # 0 remains 0
        (127, 4, 7)             # Max 7-bit pos >> 4
        (-128, 4, -8)           # Min 8-bit neg >> 4
        (2147483647, 31, 0)     # Max 31-bit pos shifted out
        (-2147483648, 31, -1)   # Min 32-bit neg becomes -1

        # Group 5: Large Values (Precision Stress)
        (9223372036854775807, 62, 1)
        (-9223372036854775808, 62, -2)

        # Group 6: Negative Position (Reverse to Left Shift)
        (1, -1, 2)              # 1 << 1
        (-1, -1, -2)            # -1 << 1
        (3, -2, 12)             # 3 << 2
        (-3, -2, -12)           # -3 << 2
        (1024, -10, 1048576)    # 1024 << 10
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
            Expected := TestCase(2)

            Received := BitwiseRightShift(Value, Positions)

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