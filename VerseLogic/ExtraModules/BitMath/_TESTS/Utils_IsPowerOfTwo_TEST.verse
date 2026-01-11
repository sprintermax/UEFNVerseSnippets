using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Utils_IsPowerOfTwo_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Utils.IsPowerOfTwo(:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Is Power Of Two>)
    TestCases<private> : []tuple(int, logic) = array{
        (0, false)
        (1, true)
        (-1, false)
        (2, true)
        (-2, false)
        (3, false)
        (-3, false)
        (4, true)
        (-4, false)
        (7, false)
        (-8, false)
        (8, true)
        (-9, false)
        (15, false)
        (-16, false)
        (16, true)
        (31, false)
        (-32, false)
        (32, true)
        (63, false)
        (-64, false)
        (64, true)
        (127, false) #  Max Signed 8-bit
        (-128, false) # Min Signed 8-bit
        (128, true)
        (255, false)
        (-256, false)
        (256, true)
        (1023, false)
        (-1024, false)
        (1024, true)
        (32767, false) #   Max Signed 16-bit
        (-32768, false) #  Min Signed 16-bit
        (32768, true)
        (65535, false)
        (-65536, false)
        (8388607, false) #  Max Signed 24-bit
        (-8388608, false) # Min Signed 24-bit
        (8388608, true)
        (2147483647, false) #   Max Signed 32-bit
        (-2147483648, false) #  Min Signed 32-bit
        (2147483648, true) #    Exceeds 32-bit by +1
        (-2147483649, false) #  Exceeds 32-bit by -1
        (4294967295, false)
        (-4294967296, false)
        (4294967296, true)
        (10000000000, false) #      Positive 10 Billion
        (-10000000000, false) #     Negative 10 Billion

        # (9223372036854775807, false) #    Max Signed 64-bit
        # (-9223372036854775808, false) #   Min Signed 64-bit
        # (9223372036854775808, false) #    Exceeds 64-bit
        # (12345678901234567890, false) #   Positive Arbitrary Large
        # (-12345678901234567890, false) #  Negative Arbitrary Large
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
        var FailedResults : [int]logic = map{}

        for (Index->TestCase : TestCases) {
            Value := TestCase(0)
            Expected := TestCase(1)

            Received := logic{IsPowerOfTwo[Value]}

            if (Expected = Received) {
                if (not IsBenchmark?). Print("{GetLogPrefix("✅")}: Test #{Index + 1}: PASS!")
            } else {
                ExpectedString := if (Expected?) { "true" } else { "false" }
                ReceivedString := if (Received?) { "true" } else { "false" }
                if (not IsBenchmark?). Print("{GetLogPrefix("❌")}: Test #{Index + 1}: FAIL! (Expected: \"{ExpectedString}\", Received: \"{ReceivedString}\")")
                (set FailedResults[Index] = Received) or Err("Unreachable")
            }
        }

        if (not IsBenchmark?) {
            ResultEmoji := if (FailedResults.Length = 0) { "⭐" } else { "⚠️" }
            Print("{GetLogPrefix(ResultEmoji)}: TESTS FINISHED! {TestCases.Length - FailedResults.Length}/{TestCases.Length} TESTS PASSED.")
        }
    }
}