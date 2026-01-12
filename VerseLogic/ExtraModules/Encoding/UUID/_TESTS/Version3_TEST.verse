using. /Fortnite.com/Devices
using. /Verse.org/Simulation

using. BitMath
using. VerseFeatures

UUID_Version3_NewV3_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<UUID.Version3.NewV3()>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<MD5String>, <Expected UUID Result>)
    TestCases<private> : []tuple(string, ?string) = array{
        ("00000000000000000000000000000000", option{"00000000-0000-3000-8000-000000000000"})
        ("ffffffffffffffffffffffffffffffff", option{"FFFFFFFF-FFFF-3FFF-BFFF-FFFFFFFFFFFF"})
        ("b6e3ad37b676011d2bab1455d33593fd", option{"B6E3AD37-B676-311D-ABAB-1455D33593FD"})
        ("2477375c7bf0c5408c3fe13fadeec8e8", option{"2477375C-7BF0-3540-8C3F-E13FADEEC8E8"})
        ("e91d43803cd3ca291f0872a074917719", option{"E91D4380-3CD3-3A29-9F08-72A074917719"})
        ("8844221e8c4076548d3a478dc857c454", option{"8844221E-8C40-3654-8D3A-478DC857C454"})
        ("f18ec9222cf31971b99b4e7444ba64f3", option{"F18EC922-2CF3-3971-B99B-4E7444BA64F3"})
        ("d5a863d9f62e63d7b979596d4060d231", option{"D5A863D9-F62E-33D7-B979-596D4060D231"})
        ("91f3d2090d6250e63c4784d888f45b9f", option{"91F3D209-0D62-30E6-BC47-84D888F45B9F"})
        ("14902fb3193c164d3401faed5f1652a7", option{"14902FB3-193C-364D-B401-FAED5F1652A7"})
        ("ee23683c962d2d4b030017fa18cfc17a", option{"EE23683C-962D-3D4B-8300-17FA18CFC17A"})
        ("4db29932a4a9ee6e843315a4d1b0eb50", option{"4DB29932-A4A9-3E6E-8433-15A4D1B0EB50"})
        ("f00e5928ee47b7e7d829c03ab35bd269", option{"F00E5928-EE47-37E7-9829-C03AB35BD269"})
        ("e20d2e5c199a12a2b7b55c62d6add90c", option{"E20D2E5C-199A-32A2-B7B5-5C62D6ADD90C"})
        ("g0000000000000000000000000000000", false)         # Fail: 'g'
        ("000000000000000000000000000z0000", false)         # Fail: 'z'
        ("0000000000q000000000000000000000", false)         # Fail: 'q'
        ("00000000000000k00000000000000000", false)         # Fail: 'k'
        ("00000000000000000s00000000000000", false)         # Fail: 's'
        ("8ea14e7d-1431-f7da-c576-a186d01f15b6", false)     # Fail: With Hyphens
        ("751521a3.0bae.b078.9384.4e64687dcaf0", false)     # Fail: With Dots
        (" d81b97caa7ee4ce58b53457854e0fe4f", false)        # Fail: Leading space
        ("eeb585e4f61dd1ad310459cd87b59591 ", false)        # Fail: Trailing space
        ("6d4873cf6259ab48e badc8c2941a8b02", false)        # Fail: Space inside
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
            Value := TestCase(0)
            Expected := TestCase(1)

            Received := option{NewV3[Value]}

            if (not IsBenchmark?) {
                if (Expected = option{Received?.ToString()}) {
                    Print("{GetLogPrefix("✅")}: Test #{Index + 1}: PASS!")
                } else {
                    ExpectedString := "{Expected?}" or "false"
                    ReceivedString := "{Received?.ToString()}" or "false"
                    Print("{GetLogPrefix("❌")}: Test #{Index + 1}: FAIL! (Expected: \"{ExpectedString}\", Received: \"{ReceivedString}\")")
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

UUID_Version3_CompileV3_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<UUID.Version3.CompileV3(:string)>"

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
        ("2e668a30-eea2-31f0-8fda-98f11aafdbae", true)      # Valid Standard (Variant 8 = 1000)
        ("2E668A30-EEA2-31F0-9FDA-98F11AAFDBAE", true)      # Valid Uppercase (Variant 9 = 1001)
        ("2e668a30-eea2-31f0-afda-98f11aafdbae", true)      # (Variant A = 1010)
        ("2e668a30-eea2-31f0-bfda-98f11aafdbae", true)      # (Variant B = 1011)

        # Group 2: Structural Failures
        ("gxe68a30-eea2-31f0-afda-98f11aafdbae", false)     # Invalid Hex Character ('g')
        ("2e668a30-eea2-31f0-afda-98f11aafdb", false)       # Too Short (Missing last bytes)
        ("2e668a30-eea2-31f0-afda-98f11aafdbaeff", false)   # Too Long (Extra bytes)
        ("", false)                                         # Empty String
        #
        # 2.1 These bellow are valid only if the parser is not strict about the UUID spec
        # (My Verse parser accepts only the no-hyphens from this list)
        ("2e668a30eea231f0afda98f11aafdbae", true)                  # No-Hyphens
        ("urn:uuid:2e668a30-eea2-31f0-8fda-98f11aafdbae", false)    # URN Prefix
        ("\{2e668a30-eea2-31f0-bfda-98f11aafdbae\}", false)         # With Brackets
        ("2e668a30 eea2 31f0 afda 98f11aafdbae", false)             # With Spaces
        ("2e668a30.eea2.31f0.8fda.98f11aafdbae", false)             # With Dots
        
        # Group 3: Version Validation (Must be '3')
        # The version is the first digit of the 3rd group (xxxx-Vxxx-...)
        ("2e668a30-eea2-01f0-afda-98f11aafdbae", false)     # Fail: Version 0 (Nil/Invalid)
        ("2e668a30-eea2-11f0-afda-98f11aafdbae", false)     # Fail: Version 1 (Time Based)
        ("2e668a30-eea2-21f0-afda-98f11aafdbae", false)     # Fail: Version 2 (DCE Security)
        ("2e668a30-eea2-41f0-afda-98f11aafdbae", false)     # Fail: Version 4 (Random)
        ("2e668a30-eea2-51f0-afda-98f11aafdbae", false)     # Fail: Version 5 (SHA1 Name)

        # Group 4: Variant Validation (Must be 8, 9, A, or B)
        # The variant is the first digit of the 4th group
        # Valid Binary: 10xx (8, 9, A, B)
        #
        # Low Range Failures (0xxx - 0111) -> NCS Compat
        ("2e668a30-eea2-31f0-0fda-98f11aafdbae", false)     # Fail: Variant 0
        ("2e668a30-eea2-31f0-7fda-98f11aafdbae", false)     # Fail: Variant 7 (0111)
        #
        # High Range Failures (11xx) -> Microsoft / Future
        ("2e668a30-eea2-31f0-cfda-98f11aafdbae", false)     # Fail: Variant C (1100 - Microsoft)
        ("2e668a30-eea2-31f0-dfda-98f11aafdbae", false)     # Fail: Variant D (1101)
        ("2e668a30-eea2-31f0-efda-98f11aafdbae", false)     # Fail: Variant E (1110 - Future)
        ("2e668a30-eea2-31f0-ffda-98f11aafdbae", false)     # Fail: Variant F (1111)

        # Group 5: Special Sentinels (RFC 9562)
        # These are valid UUID formats generally, but invalid for Version 3
        #
        # Nil UUID (All bits set to 0)
        ("00000000-0000-0000-0000-000000000000", false)     # Fail: Version 0 and Variant 0
        # Max UUID (All bits set to 1)
        ("FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF", false)     # Fail: Version F and Variant F

        # Group 6: Invalid Characters (Non-Hex)
        # Any character outside 0-9, a-f, A-F must fail the parser.
        #
        # 6.1 boundary Letters (g-z)
        ("g0000000-0000-31f0-8000-000000000000", false)     # Fail: 'g'
        ("00000000-0000-31f0-8000-00000000000z", false)     # Fail: 'z'
        ("00000000-0000-31f0-8000-000q00000000", false)     # Fail: 'q'
        #
        # 6.2 Common Visual Typos (O vs 0, l vs 1)
        ("0000O000-0000-31f0-8000-000000000000", false)     # Fail: Capital 'O' instead of Zero
        ("00000000-0000-31f0-80l0-000000000000", false)     # Fail: Lowercase 'l' instead of One
        ("00000000-0I00-31f0-8000-000000000000", false)     # Fail: Capital 'I' instead of One
        #
        # 6.3 Symbols and Punctuation
        ("2e668a30-eea2-31f0-8fda-98f11#afdbae", false)     # Fail: '#'
        ("2e668a30-eea2-31f0-8fd$-98f11aafdbae", false)     # Fail: '$'
        ("2e668a30-&ea2-31f0-8fda-98f11aafdbae", false)     # Fail: '&'
        #
        # 6.4 Whitespace Checks
        (" 2e668a30-eea2-31f0-8fda-98f11aafdbae", false)    # Fail: Leading space
        ("2e668a30-eea2-31f0-8fda-98f11aafdbae ", false)    # Fail: Trailing space
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

            Received := option{CompileV3[UUIDString]}

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