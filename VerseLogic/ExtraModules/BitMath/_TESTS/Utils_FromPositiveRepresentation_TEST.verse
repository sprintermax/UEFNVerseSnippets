using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Utils_FromPositiveRepresentation_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Utils.FromPositiveRepresentation(:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <BitWidth>, <Expected Signed Representation>)
    TestCases<private> : []tuple(int, int, ?int) = array{
        # Group 1: The Basics (0 and -1)
        (0, 1, option{0})       # 0 is always 0
        (0, 8, option{0})       # 0 is always 0 regardless of width
        (1, 1, option{-1})      # 1-bit '1' is interpreted as -1
        (3, 2, option{-1})      # 2-bit '11' is interpreted as -1
        (255, 8, option{-1})    # 8-bit '11111111' is -1
        (65535, 16, option{-1})

        # Group 2: Positive Numbers (Should never change)
        (7, 4, option{7})   # Exact width
        (7, 8, option{7})   # Oversized width
        (127, 8, option{127})
        (127, 32, option{127})
        (240, 16, option{240})
        (380, 23, option{380})
        (2147483647, 32, option{2147483647})

        # Group 3: Negative Powers of Two (Exact Width)
        (2, 2, option{-2})
        (4, 3, option{-4})
        (8, 4, option{-8})
        (128, 8, option{-128})
        (32768, 16, option{-32768})

        # Group 4: Negative Numbers (Oversized Width / Sign Extension)
        (14, 4, option{-2})
        (252, 8, option{-4})
        (248, 8, option{-8})
        (9, 4, option{-7})
        (249, 8, option{-7})

        # Group 5: 8-Bit Boundaries
        (128, 8, option{-128})
        (129, 8, option{-127})
        (192, 8, option{-64})
        (254, 8, option{-2})

        # Group 6: 16-Bit Boundaries
        (32768, 16, option{-32768})
        (32769, 16, option{-32767})
        (65535, 16, option{-1})
        (32767, 16, option{32767})

        # Group 7: 32-Bit Boundaries
        (2147483648, 32, option{-2147483648})
        (2147483649, 32, option{-2147483647})
        (4294967295, 32, option{-1})
        (2147483647, 32, option{2147483647})

        # Group 8: Arbitrary/Random Widths
        (22, 5, option{-10})
        (54, 6, option{-10})
        (78, 7, option{-50})
        (924, 10, option{-100})
        (3096, 12, option{-1000})

        # Group 9: Large Values (Beyond 32-bit)
        (4294967296, 33, option{-4294967296})
        (24359738368, 35, option{-10000000000})
        (1099511627775, 40, option{-1})

        # Group 10: Special Tricky Cases
        (5, 3, option{-3})
        (13, 4, option{-3})
        (11, 4, option{-5})
        (10, 4, option{-6})
        (15, 5, option{15})
        (16, 5, option{-16})
        (17, 5, option{-15})
        (32, 6, option{-32})
        (33, 6, option{-31})
        (64, 7, option{-64})

        # Group 11: 64-Bit Boundaries (The "Double" Precision Limit)
        # (14728617310, 64, option{14728617310})                  # Fits in lower half, stays positive
        # (18446744073709551615, 64, option{-1})                  # Max Unsigned 64-bit
        # (9223372036854775808, 64, option{-9223372036854775808}) # Min Signed 64-bit as Unsigned
        # (9223372036854775807, 64, option{9223372036854775807})  # Max Signed 64-bit

        # Group 12: Oversized 64-Bit Widths (Sign Extension)
        # (18446744073709551611, 64, option{-5})
        # (18446744073709550592, 64, option{-1024})

        # Group 13: Beyond 64-Bit (True Arbitrary Precision)
        # (340282366920938463463374607431768211455, 128, option{-1})
        # (340282366920938463463374607431768211454, 128, option{-2})

        # Group 14: Other Values and Strategic Bit Patterns
        (274877906943, 38, option{-1})
        (100, 38, option{100})
        (274877906844, 38, option{-100})
        (2199023255551, 41, option{-1})
        (2199023255552, 42, option{-2199023255552})
        (1099511627776, 41, option{-1099511627776})
        (950285035, 30, option{-123456789})
        (1099388170987, 40, option{-123456789})
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

            Received := option{FromPositiveRepresentation[Value, BitWidth]}

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