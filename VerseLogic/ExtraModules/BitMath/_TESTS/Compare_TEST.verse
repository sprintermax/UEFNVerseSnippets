using. /Fortnite.com/Devices
using. /Verse.org/Simulation

BitMath_Compare_BitwiseBaseHandler_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Compare.BitwiseBaseHandler(:int,:int,:type\{_(:int,:int)<computes><decides>:void\})>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<ValueA>, <ValueB>, <Operation>, <Expected Result>)
    TestCases<private> : []tuple(int, int, type{_(:int, :int)<transacts>:int}, int) = array{
        # Group 1: AND Operations
        (7, 3, BitwiseAnd, 3)           # 0111 & 0011 = 0011 (3)
        (8, 4, BitwiseAnd, 0)           # 1000 & 0100 = 0000 (0)
        (-1, 5, BitwiseAnd, 5)          # All 1s & 0101 = 0101 (5)
        (-1, -1, BitwiseAnd, -1)        # All 1s & All 1s = -1
        (-8, 7, BitwiseAnd, 0)          # 1000 & 0111 = 0000
        (-8, -1, BitwiseAnd, -8)        # 1000 & 1111 = 1000
        (2147483647, 1, BitwiseAnd, 1)  # Max 32-bit & 1
        (0, 255, BitwiseAnd, 0)         # 0 & Anything = 0

        # Group 2: OR Operations
        (1, 2, BitwiseOr, 3)            # 01 | 10 = 11 (3)
        (8, 4, BitwiseOr, 12)           # 1000 | 0100 = 1100 (12)
        (-1, 0, BitwiseOr, -1)          # -1 | 0 = -1
        (-2, 1, BitwiseOr, -1)          # 1110 | 0001 = 1111 (-1)
        (-8, 7, BitwiseOr, -1)          # 1000 | 0111 = 1111 (-1)
        (-9, 1, BitwiseOr, -9)          # 10111 | 00001 = 10111 (-9)
        (1024, 2048, BitwiseOr, 3072)
        (0, 0, BitwiseOr, 0)

        # Group 3: XOR Operations
        (3, 5, BitwiseXor, 6)       # 011 ^ 101 = 110 (6)
        (7, 7, BitwiseXor, 0)       # Same values = 0
        (-1, 0, BitwiseXor, -1)     # -1 ^ 0 = -1
        (-1, -1, BitwiseXor, 0)     # -1 ^ -1 = 0
        (1, -2, BitwiseXor, -1)     # 01 ^ 10 = 11 (-1)
        (-8, 8, BitwiseXor, -16)    # 11000 ^ 01000 = 10000 (-16)
        (15, 1, BitwiseXor, 14)
        (1234, 4321, BitwiseXor, 5171)

        # Group 4: NAND Operations (NOT AND)
        (1, 1, BitwiseNand, -2)     # 01 NAND 01 = 10 (-2)
        (0, 7, BitwiseNand, -1)     # 0 NAND 7 = -1
        (-1, -1, BitwiseNand, 0)    # -1 NAND -1 = 0
        (8, 4, BitwiseNand, -1)     # 1000 NAND 0100 = 1111 (-1)
        (2, 2, BitwiseNand, -3)     # 010 NAND 010 = 101 (-3)

        # Group 5: NOR Operations (NOT OR)
        (0, 0, BitwiseNor, -1)  # 0 NOR 0 = -1
        (1, 2, BitwiseNor, -4)  # (01 | 10) = 011 -> NOT 011 = 100 (-4)
        (-1, 0, BitwiseNor, 0)  # -1 NOR 0 = 0
        (-1, -1, BitwiseNor, 0) # -1 NOR -1 = 0
        (4, 8, BitwiseNor, -13)

        # Group 6: XNOR Operations (Equal Bits)
        (7, 7, BitwiseXnor, -1) # 7 XNOR 7 = -1 (All bits match)
        (0, -1, BitwiseXnor, 0) # 0 XNOR -1 = 0 (No bits match)
        (3, 5, BitwiseXnor, -7) # 3 (011) XNOR 5 (101) = 001 (Needs 4 bits for sign)
        (1, 2, BitwiseXnor, -4) # 01 XNOR 10 = 00 (In 3 bits: 001 XNOR 010 = 100 (-4))

        # Group 7: Boundary & Large Value Stress Tests
        (2147483647, -2147483648, BitwiseAnd, 0)
        (2147483647, -2147483648, BitwiseOr, -1)
        (2147483647, -2147483648, BitwiseXor, -1)
        (10000000000, 0, BitwiseOr, 10000000000)
        (-10000000000, -1, BitwiseAnd, -10000000000)

        # Group 8: Power of Two Specifics
        (16, 1, BitwiseOr, 17)
        (16, 16, BitwiseAnd, 16)
        (16, 16, BitwiseXor, 0)
        (-16, -16, BitwiseAnd, -16)
        (-16, 16, BitwiseAnd, 16)

        # Group 9: Mixed Bit-Width Alignment
        (1, 1024, BitwiseOr, 1025)      # 2-bit vs 12-bit
        (-1, 1024, BitwiseAnd, 1024)    # 1-bit vs 12-bit
        (127, -128, BitwiseAnd, 0)      # 01111111 & 10000000 = 0
        (127, -128, BitwiseOr, -1)      # 01111111 | 10000000 = 11111111 (-1)

        # Group 10: Edge Cases
        (0, -1, BitwiseAnd, 0)
        (0, -1, BitwiseOr, -1)
        (0, -1, BitwiseXor, -1)
        (-1, -1, BitwiseXor, 0)
        (2, -2, BitwiseAnd, 2)  # 010 & 10 = 010 (2)
        (2, -2, BitwiseOr, -2)  # 010 | 10 = 10 (-2)
        (4, -4, BitwiseAnd, 4)  # 0100 & 100 = 0100 (4)
        (4, -4, BitwiseOr, -4)  # 0100 | 100 = 100 (-4)
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
            Operation := TestCase(2)
            Expected := TestCase(3)

            Received := Operation(ValueA, ValueB)

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

BitMath_Compare_BitwiseNot_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Compare.BitwiseNot(:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Expected Result>)
    TestCases<private> : []tuple(int, int) = array{
        # Group 1: Basics
        (0, -1)     # Width 1: NOT 0 is 1. FromPositive(1, 1) is -1.
        (-1, 0)     # Width 1: NOT 1 is 0. FromPositive(0, 1) is 0.
        (1, -2)     # Width 2: NOT 01 is 10. FromPositive(2, 2) is -2.
        (-2, 1)     # Width 2: NOT 10 is 01. FromPositive(1, 2) is 1.

        # Group 2: Positive Integers
        (2, -3)     # Width 3: NOT 010 is 101. FromPositive(5, 3) is -3.
        (3, -4)     # Width 3: NOT 011 is 100. FromPositive(4, 3) is -4.
        (4, -5)     # Width 4: NOT 0100 is 1011. FromPositive(11, 4) is -5.
        (7, -8)     # Width 4: NOT 0111 is 1000. FromPositive(8, 4) is -8.
        (8, -9)     # Width 5: NOT 01000 is 10111. FromPositive(23, 5) is -9.
        (15, -16)   # Width 5: NOT 01111 is 10000. FromPositive(16, 5) is -16.

        # Group 3: Negative Integers
        (-3, 2)     # Width 3: NOT 101 is 010 (2).
        (-4, 3)     # Width 3: NOT 100 is 011 (3).
        (-8, 7)     # Width 4: NOT 1000 is 0111 (7).
        (-9, 8)     # Width 5: NOT 10111 is 01000 (8).
        (-16, 15)   # Width 5: NOT 10000 is 01111 (15).

        # Group 4: Larger Widths
        (127, -128)                 # 8-bit
        (-128, 127)                 # 8-bit
        (32767, -32768)             # 16-bit
        (-32768, 32767)             # 16-bit
        (2147483647, -2147483648)   # 32-bit
        (-2147483648, 2147483647)   # 32-bit

        # Group 5: Arbitrary/Large Values
        (10000000000, -10000000001) # 35-bit
        (-10000000000, 9999999999)  # 35-bit
        (123456789, -123456790)
        
        # Group 6: The Pattern Test
        # In Two's Complement, NOT x is always equal to -(x + 1)
        (5, -6)     # -(5 + 1)
        (-6, 5)     # -(-6 + 1) = -(-5)
        (42, -43)
        (-100, 99)
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

            Received := BitwiseNot(Value)

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

BitMath_Compare_BitwiseNot2_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<BitMath.Compare.BitwiseNot2(:int,:int)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Value>, <Bit Width>, <Expected Result>)
    TestCases<private> : []tuple(int, int, ?int) = array{
        # Group 1: The Basics
        (0, 1, option{1})   # 1-bit: ~0 = 1
        (1, 1, option{0})   # 1-bit: ~1 = 0
        (0, 8, option{255}) # 8-bit: ~0 = 255 (11111111)
        (255, 8, option{0}) # 8-bit: ~255 = 0
        (1, 2, option{2})   # 2-bit: ~01 = 10 (2)
        (2, 2, option{1})   # 2-bit: ~10 = 01 (1)

        # Group 2: 4-Bit and 8-Bit Patterns
        (10, 4, option{5})      # 4-bit: ~1010 = 0101 (5)
        (5, 4, option{10})      # 4-bit: ~0101 = 1010 (10)
        (1, 4, option{14})      # 4-bit: ~0001 = 1110 (14)
        (127, 8, option{128})   # 8-bit: ~01111111 = 10000000 (128)
        (170, 8, option{85})    # 8-bit: ~10101010 = 01010101 (85)

        # Group 3: 16-Bit and 32-Bit Boundaries
        (0, 16, option{65535})                  # 2^16 - 1
        (32768, 16, option{32767})              # ~1000... = 0111...
        (0, 32, option{4294967295})             # 2^32 - 1
        (2147483648, 32, option{2147483647})    # Sign bit flip

        # Group 4: Large Widths (Beyond 32-bit)
        (0, 40, option{1099511627775})          # 2^40 - 1
        (1099511627775, 40, option{0})
        (123456789, 40, option{1099388170986})  # (2^40 - 1) - 123456789
        # (0, 640, option{18446744073709551615})   # 2^64 - 1
        
        # Group 5: Strategic Offsets
        (15, 5, option{16}) # 5-bit: ~01111 = 10000 (16)
        (16, 5, option{15}) # 5-bit: ~10000 = 01111 (15)
        (31, 6, option{32}) # 6-bit: ~011111 = 100000 (32)
        (32, 6, option{31}) # 6-bit: ~100000 = 011111 (31)
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
        var FailedResults : [int]?int = map{}

        for (Index->TestCase : TestCases) {
            Value := TestCase(0)
            BitWidth := TestCase(1)
            Expected := TestCase(2)

            Received := option{BitwiseNot[Value, BitWidth]}

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