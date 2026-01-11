using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Utils_GetBitWidth_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Utils.GetBitWidth(:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }
        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Expected Bit Width>)
    TestCases<private> : []tuple(int, int) = array{
        (0, 1) #        0 Base case
        (1, 2) #       01
        (-1, 1) #       1 (or 2 if the system forces a padding bit)
        (2, 3) #      010
        (-2, 2) #      10
        (3, 3) #      011
        (-3, 3) #     101
        (4, 4) #     0100
        (-4, 3) #     100
        (7, 4) #     0111
        (-8, 4) #    1000
        (8, 5) #    01000
        (-9, 5) #   10111
        (15, 5)
        (-16, 5)
        (16, 6)
        (31, 6)
        (-32, 6)
        (32, 7)
        (63, 7)
        (-64, 7)
        (64, 8)
        (127, 8) #  Max Signed 8-bit
        (-128, 8) # Min Signed 8-bit
        (128, 9)
        (255, 9)
        (-256, 9)
        (256, 10)
        (1023, 11)
        (-1024, 11)
        (1024, 12)
        (32767, 16) #   Max Signed 16-bit
        (-32768, 16) #  Min Signed 16-bit
        (32768, 17)
        (65535, 17)
        (-65536, 17)
        (8388607, 24) #  Max Signed 24-bit
        (-8388608, 24) # Min Signed 24-bit
        (8388608, 25)
        (2147483647, 32) #      Max Signed 32-bit
        (-2147483648, 32) #     Min Signed 32-bit
        (2147483648, 33) #      Exceeds 32-bit by +1
        (-2147483649, 33) #     Exceeds 32-bit by -1
        (4294967295, 33)
        (-4294967296, 33)
        (4294967296, 34)
        (10000000000, 35) #     Positive 10 Billion
        (-10000000000, 35) #    Negative 10 Billion

        # (9223372036854775807, 64) #   Max Signed 64-bit
        # (-9223372036854775808, 64) #  Min Signed 64-bit
        # (9223372036854775808, 65) #   Exceeds 64-bit
        # (12345678901234567890, 65) #  Positive Arbitrary Large
        # (-12345678901234567890, 65) # Negative Arbitrary Large
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
            Expected := TestCase(1)

            Received := GetBitWidth(Value)

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