using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Utils_ToPositiveRepresentation_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Utils.ToPositiveRepresentation(:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <BitWidth>, <Expected Unsigned Representation>)
    TestCases<private> : []tuple(int, int, ?int) = array{
        # Group 1: The Basics (0 and -1)
        (0, 10, option{0})       # 0 is always 0
        (0, 60, option{0})       # 0 is always 0 regardless of width
        (-1, 1, option{1})       # -1 in 1-bit is '1'
        (-1, 2, option{3})       # -1 in 2-bit is '11' (3)
        (-1, 8, option{255})     # -1 in 8-bit is '11111111' (255)
        (-1, 16, option{65535})  # -1 in 16-bit is 65535

        # Group 2: Positive Numbers (Should never change)
        (7, 4, option{7})    # Exact width
        (7, 8, option{7})    # Oversized width
        (127, 8, option{127})
        (127, 32, option{127})
        (240, 16, option{240})
        (380, 23, option{380})
        (2147483647, 32, option{2147483647})

        # Group 3: Negative Powers of Two (Exact Width)
        (-2, 2, option{2})       # -2 in 2-bit (10) -> 2
        (-4, 3, option{4})       # -4 in 3-bit (100) -> 4
        (-8, 4, option{8})       # -8 in 4-bit (1000) -> 8
        (-128, 8, option{128})   # -128 in 8-bit (10000000) -> 128
        (-32768, 16, option{32768})

        # Group 4: Negative Numbers (Oversized Width / Sign Extension)
        # (This tests if the "infinite leading 1s" are captured correctly)
        (-2, 4, option{14})      # -2 in 4-bit (1110) -> 14
        (-4, 8, option{252})     # -4 in 8-bit (11111100) -> 252
        (-8, 8, option{248})     # -8 in 8-bit (11111000) -> 248
        (-7, 4, option{9})       # -7 in 4-bit (1001) -> 9
        (-7, 8, option{249})     # -7 in 8-bit (11111001) -> 249

        # Group 5: 8-Bit Boundaries
        (-128, 8, option{128})   # Min 8-bit
        (-127, 8, option{129})
        (-64, 8, option{192})
        (-2, 8, option{254})

        # Group 6: 16-Bit Boundaries
        (-32768, 16, option{32768})
        (-32767, 16, option{32769})
        (-1, 16, option{65535})
        (32767, 16, option{32767})

        # Group 7: 32-Bit Boundaries
        (-2147483648, 32, option{2147483648})
        (-2147483647, 32, option{2147483649})
        (-1, 32, option{4294967295})
        (2147483647, 32, option{2147483647})

        # Group 8: Arbitrary/Random Widths
        (-10, 5, option{22})     # -10 (10110) -> 22
        (-10, 6, option{54})     # -10 (110110) -> 54
        (-50, 7, option{78})     # -50 (1001110) -> 78
        (-100, 10, option{924})
        (-1000, 12, option{3096})

        # Group 9: Large Values (Beyond 32-bit)
        (-4294967296, 33, option{4294967296})
        (-10000000000, 35, option{24359738368}) # 2^35 - 10,000,000,000
        (-1, 40, option{1099511627775})         # 2^40 - 1

        # Group 10: Special Tricky Cases
        (-3, 3, option{5})       # -3 (101) -> 5
        (-3, 4, option{13})      # -3 (1101) -> 13
        (-5, 4, option{11})      # -5 (1011) -> 11
        (-6, 4, option{10})      # -6 (1010) -> 10
        (15, 5, option{15})
        (-16, 5, option{16})
        (-15, 5, option{17})     # -15 (10001) -> 17
        (-32, 6, option{32})
        (-31, 6, option{33})     # -31 (100001) -> 33
        (-64, 7, option{64})

        # Group 11: 64-Bit Boundaries (The "Double" Precision Limit)
        # (14728617310, 64, option{14728617310})                   # Fits in lower half, stays positive
        # (9223372036854775807, 64, option{9223372036854775807})   # Max Signed 64-bit

        # Group 12: Other Values and Strategic Bit Patterns
        (-1, 38, option{274877906943})               # 2^38 - 1
        (100, 38, option{100})                       # Positive stays same
        (-100, 38, option{274877906844})             # 2^38 - 100
        (-1, 41, option{2199023255551})              # 2^41 - 1
        (-2199023255552, 42, option{2199023255552})  # Min 42-bit value in 42-bit width
        (-1099511627776, 40, option{0})              # (2^40, should wrap to 0 if truncated)
        (-1099511627776, 41, option{1099511627776})  # -2^40 in 41-bit
        (-123456789, 30, option{950285035})
        (-123456789, 40, option{1099388170987})
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
            # 0..7 = (1, 2, 4, 8, 16, 32, 640, option{128}) Iterations
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
        var FailedResults : [int]?int = map{}

        for (Index->TestCase : TestCases) {
            Value := TestCase(0)
            BitWidth := TestCase(1)
            Expected := TestCase(2)

            Received := option{ToPositiveRepresentation[Value, BitWidth]}

            if (not IsBenchmark?) {
                if (Expected = Received) {
                    Print("{GetLogPrefix("✅")}: Test #{Index + 1}: PASS!")
                } else {
                    ExpectedString := "{Expected?}" or "false"
                    ReceivedString := "{Received?}" or "false"
                    Print("{GetLogPrefix("❌")}: Test #{Index + 1}: FAIL! (Expected: \"{ExpectedString}\", Received: \"{ReceivedString}\")")
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