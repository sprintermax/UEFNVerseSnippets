using. /Fortnite.com/Devices
using. /Verse.org/Simulation

using. BitMath
using. VerseFeatures

UUID_Version1_NewV1_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<UUID.Version1.NewV1()>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # How many UUIDs to generate during the test
    TestCases<private> : int = 18

    OnBegin<override>()<suspends>:void = {
        Sleep(0.0)
        ExecuteTestCases()
        Sleep(1.0)
        RunBenchmark()
    }

    RunBenchmark<public>()<suspends>:void = {
        Print("{GetLogPrefix("🧪", ?IsBenchmark:=true)}: STARTING BENCHMARK FOR {TestCases} TESTS...")

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

    # NOTE: IMPOSSIBLE TO FAIL (TODO)
    ExecuteTestCases<public>(?IsBenchmark:logic=false):void = {

        if (not IsBenchmark?). Print("{GetLogPrefix("🚀")}: STARTING {TestCases} TESTS...")

        for (Index := 1..TestCases) {
            Received := NewV1()

            if (not IsBenchmark?) {
                Print("{GetLogPrefix("✅")}: Test #{Index + 1}: PASS! (\"{Received}\")")
            }
        }

        if (not IsBenchmark?) {
            Print("{GetLogPrefix("⭐")}: TESTS FINISHED! {TestCases}/{TestCases} TESTS PASSED.")
        }
    }
}

UUID_Version1_CompileV1_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<UUID.Version1.CompileV1(:string)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<UUIDString>, <Expected Compile Result>)
    TestCases<private> : []tuple(string, logic) = array{
        # Group 1: Happy Paths (Valid UUID v1)
        ("2e668a30-eea2-11f0-8fda-98f11aafdbae", true)      # Valid Standard (Variant 8 = 1000)
        ("2E668A30-EEA2-11F0-9FDA-98F11AAFDBAE", true)      # Valid Uppercase (Variant 9 = 1001)
        ("2e668a30-eea2-11f0-afda-98f11aafdbae", true)      # (Variant A = 1010)
        ("2e668a30-eea2-11f0-bfda-98f11aafdbae", true)      # (Variant B = 1011)

        # Group 2: Structural Failures
        ("gxe68a30-eea2-11f0-afda-98f11aafdbae", false)     # Invalid Hex Character ('g')
        ("2e668a30-eea2-11f0-afda-98f11aafdb", false)       # Too Short (Missing last bytes)
        ("2e668a30-eea2-11f0-afda-98f11aafdbaeff", false)   # Too Long (Extra bytes)
        ("", false)                                         # Empty String
        #
        # 2.1 These bellow are valid only if the parser is not strict about the UUID spec
        # (My Verse parser accepts only the no-hyphens from this list)
        ("2e668a30eea211f0afda98f11aafdbae", true)                  # No-Hyphens
        ("urn:uuid:2e668a30-eea2-11f0-8fda-98f11aafdbae", false)    # URN Prefix
        ("\{2e668a30-eea2-11f0-bfda-98f11aafdbae\}", false)         # With Brackets
        ("2e668a30 eea2 11f0 afda 98f11aafdbae", false)             # With Spaces
        ("2e668a30.eea2.11f0.8fda.98f11aafdbae", false)             # With Dots
        
        # Group 3: Version Validation (Must be '1')
        # The version is the first digit of the 3rd group (xxxx-Vxxx-...)
        ("2e668a30-eea2-01f0-afda-98f11aafdbae", false)     # Fail: Version 0 (Nil/Invalid)
        ("2e668a30-eea2-21f0-afda-98f11aafdbae", false)     # Fail: Version 2 (DCE Security)
        ("2e668a30-eea2-31f0-afda-98f11aafdbae", false)     # Fail: Version 3 (MD5 Name)
        ("2e668a30-eea2-41f0-afda-98f11aafdbae", false)     # Fail: Version 4 (Random)
        ("2e668a30-eea2-51f0-afda-98f11aafdbae", false)     # Fail: Version 5 (SHA1 Name)

        # Group 4: Variant Validation (Must be 8, 9, A, or B)
        # The variant is the first digit of the 4th group
        # Valid Binary: 10xx (8, 9, A, B)
        #
        # Low Range Failures (0xxx - 0111) -> NCS Compat
        ("2e668a30-eea2-11f0-0fda-98f11aafdbae", false)     # Fail: Variant 0
        ("2e668a30-eea2-11f0-7fda-98f11aafdbae", false)     # Fail: Variant 7 (0111)
        #
        # High Range Failures (11xx) -> Microsoft / Future
        ("2e668a30-eea2-11f0-cfda-98f11aafdbae", false)     # Fail: Variant C (1100 - Microsoft)
        ("2e668a30-eea2-11f0-dfda-98f11aafdbae", false)     # Fail: Variant D (1101)
        ("2e668a30-eea2-11f0-efda-98f11aafdbae", false)     # Fail: Variant E (1110 - Future)
        ("2e668a30-eea2-11f0-ffda-98f11aafdbae", false)     # Fail: Variant F (1111)

        # Group 5: Special Sentinels (RFC 9562)
        # These are valid UUID formats generally, but invalid for Version 1
        #
        # Nil UUID (All bits set to 0)
        ("00000000-0000-0000-0000-000000000000", false)     # Fail: Version 0 and Variant 0
        # Max UUID (All bits set to 1)
        ("FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF", false)     # Fail: Version F and Variant F

        # Group 6: Invalid Characters (Non-Hex)
        # Any character outside 0-9, a-f, A-F must fail the parser.
        #
        # 6.1 boundary Letters (g-z)
        ("g0000000-0000-11f0-8000-000000000000", false)     # Fail: 'g'
        ("00000000-0000-11f0-8000-00000000000z", false)     # Fail: 'z'
        ("00000000-0000-11f0-8000-000q00000000", false)     # Fail: 'q'
        #
        # 6.2 Common Visual Typos (O vs 0, l vs 1)
        ("0000O000-0000-11f0-8000-000000000000", false)     # Fail: Capital 'O' instead of Zero
        ("00000000-0000-11f0-80l0-000000000000", false)     # Fail: Lowercase 'l' instead of One
        ("00000000-0I00-11f0-8000-000000000000", false)     # Fail: Capital 'I' instead of One
        #
        # 6.3 Symbols and Punctuation
        ("2e668a30-eea2-11f0-8fda-98f11#afdbae", false)     # Fail: '#'
        ("2e668a30-eea2-11f0-8fd$-98f11aafdbae", false)     # Fail: '$'
        ("2e668a30-&ea2-11f0-8fda-98f11aafdbae", false)     # Fail: '&'
        #
        # 6.4 Whitespace Checks
        (" 2e668a30-eea2-11f0-8fda-98f11aafdbae", false)    # Fail: Leading space
        ("2e668a30-eea2-11f0-8fda-98f11aafdbae ", false)    # Fail: Trailing space
        ("2e668a30-eea2-11 f0-8fda-98f11aafdbae", false)    # Fail: Space inside
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
        var FailedResults : [int]string = map{}

        for (Index->TestCase : TestCases) {
            UUIDString := TestCase(0)
            Expected := TestCase(1)

            Received := option{CompileV1[UUIDString]}

            if (not IsBenchmark?) {
                if (Expected = logic{Received?}) {
                    Print("{GetLogPrefix("✅")}: Test #{Index + 1}: PASS!")
                } else {
                    ReceivedString := "{Received?.ToString()}" or "false"
                    Print("{GetLogPrefix("❌")}: Test #{Index + 1}: FAIL! (Expected: \"{Expected}\", Received: \"{ReceivedString}\")")
                    (set FailedResults[Index] = ReceivedString) or Err("Unreachable")
                }
            }
        }

        if (not IsBenchmark?) {
            ResultEmoji := if (FailedResults.Length = 0) { "⭐" } else { "⚠️" }
            Print("{GetLogPrefix(ResultEmoji)}: TESTS FINISHED! {TestCases.Length - FailedResults.Length}/{TestCases.Length} TESTS PASSED.")
        }
    }
}