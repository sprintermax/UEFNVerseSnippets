using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Shift_BitwiseLeftShift_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Shift.BitwiseLeftShift(:int,:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Positions>, <Expected Result>)
    TestCases<private> : []tuple(int, int, int) = array{
        # Group 1: Basic Examples
        (1, 0, 1)       # Shift by 0
        (1, 1, 2)       # 01 -> 10
        (1, 2, 4)       # 01 -> 100
        (1, 10, 1024)   # 2^10
        (0, 5, 0)       # 0 shifted is still 0
        (-1, 1, -2)     # 1...11 -> 1...10
        (-1, 8, -256)   # -1 << 8

        # Group 2: Positive Random/Arbitrary Values
        (3, 2, 12)      # 3 (11) << 2 = 12 (1100)
        (5, 3, 40)      # 5 (101) << 3 = 40 (101000)
        (7, 1, 14)      # 7 (111) << 1 = 14 (1110)
        (10, 4, 160)    # 10 * 16
        (123, 2, 492)   # 123 * 4
        (1025, 1, 2050)
        
        # Group 3: Negative Random/Arbitrary Values
        (-3, 2, -12)    # -3 * 4
        (-5, 3, -40)    # -5 * 8
        (-7, 1, -14)    # -7 * 2
        (-10, 4, -160)  # -10 * 16
        (-123, 3, -984) # -123 * 8

        # Group 4: Large Shifts & Precision Stress
        # (Verify about using floating-point precision on Pow operation)
        (1, 31, 2147483648)                 # 32-bit boundary
        # (1, 63, 9223372036854775808)        # 64-bit boundary
        # (-1, 63, -9223372036854775808)
        # (123456789, 20, 129453825032192)    # Random large shift
        
        # Group 5: Edge Cases & Patterns
        (127, 1, 254)   # Max 7-bit pos << 1
        (-128, 1, -256)     # Min 8-bit neg << 1
        (32767, 1, 65534)   # Max 15-bit pos << 1
        (-32768, 1, -65536)

        # Group 6: Negative Position (Reverse to Right Shift)
        (-1, -10, -1)   # -1 shifted right any amount is always -1
        (3, -1, 1)      # 3 (11) >> 1 = 1 (01)
        (-3, -1, -2)    # -3 (1...1101) >> 1 = (1...1110) = -2
        (123, -3, 15)   # 123 / 8 = 15.375 -> 15
        (1024, -10, 1)  # 1024 >> 10
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

            Received := BitwiseLeftShift(Value, Positions)

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