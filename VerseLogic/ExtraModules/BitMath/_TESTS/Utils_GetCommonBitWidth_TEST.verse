using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Utils_GetCommonBitWidth_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Utils.GetCommonBitWidth(:int,:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }
        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<ValueA>, <ValueB>, <Expected Common Bit Width>)
    TestCases<private> : []tuple(int, int, int) = array{
        # Group 1: Identity & Small Constants
        (0, 0, 1)   # Both 1-bit
        (0, -1, 1)  # Both 1-bit
        (-1, -1, 1) # Both 1-bit
        (1, 0, 2)   # 1 needs 2 bits (01) 0 needs 1. Max is 2.
        (1, 1, 2)   # Both 2-bit (01)

        # Group 2: Different Widths (Positive)
        (1, 7, 4)       # 1 (2-bit) vs 7 (4-bit) -> 4
        (8, 2, 5)       # 8 (5-bit) vs 2 (3-bit) -> 5
        (127, 255, 9)   # 127 (8-bit) vs 255 (9-bit) -> 9

        # Group 3: Different Widths (Negative)
        (-1, -8, 4)     # -1 (1-bit) vs -8 (4-bit) -> 4
        (-2, -4, 3)     # -2 (2-bit) vs -4 (3-bit) -> 3
        (-128, -1, 8)   # -128 (8-bit) vs -1 (1-bit) -> 8

        # Group 4: Mixed Signs (The Alignment Stress Test)
        (7, -8, 4)      # 7 (4-bit: 0111) vs -8 (4-bit: 1000) -> 4
        (1, -2, 2)      # 1 (2-bit: 01) vs -2 (2-bit: 10) -> 2
        (15, -1, 5)     # 15 (5-bit: 01111) vs -1 (1-bit: 1) -> 5
        (-16, 15, 5)    # -16 (5-bit: 10000) vs 15 (5-bit: 01111) -> 5
        (-17, 1, 6)     # -17 (6-bit) vs 1 (2-bit) -> 6

        # Group 5: Power of Two Boundaries
        (16, 16, 6)     # 16 needs 6 bits (010000)
        (-16, -16, 5)   # -16 needs 5 bits (10000)
        (16, -16, 6)    # Mixed: Max(6, 5) -> 6

        # Group 6: Large Values
        (2147483647, 0, 32)             # Max 32-bit positive
        (-2147483648, 1, 32)            # Min 32-bit negative vs 2-bit positive -> 32
        (4294967296, -1, 34)            # 2^32 (34-bit) vs -1 (1-bit) -> 34
        (10000000000, -10000000000, 35) # 35-bit range
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
            ValueA := TestCase(0)
            ValueB := TestCase(1)
            Expected := TestCase(2)

            Received := GetCommonBitWidth(ValueA, ValueB)

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