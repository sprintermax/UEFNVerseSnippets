using. /Fortnite.com/Devices
using. /Verse.org/Simulation

using. BitMath

SHA1_SHA1_ComputeSHA1Hash_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<SHA1.SHA1.ComputeSHA1Hash(:string)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Input String>, <Expected SHA1 Hash>)
    TestCases<private> : []tuple(string, string) = array{
        # 1. Empty String (Crucial for padding logic)
        ("", "da39a3ee5e6b4b0d3255bfef95601890afd80709")

        # 2. Single Characters
        ("a", "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8")
        ("z", "395df8f7c51f007019cb30201c49e884b46b92fa")

        # # 3. Short Strings
        ("abc", "a9993e364706816aba3e25717850c26c9cd0d89d")
        ("hello", "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d")
        ("message digest", "c12252ceda8be8994d5fa0290a47231c1d16aae3")

        # # 4. Longer Strings (For multi-block processing)
        ("abcdefghijklmnopqrstuvwxyz", "32d10c7b8cf96570ca04ce37f2a19d84240d3a89")
        ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "761c457bf73b14d27e9e9265c46f4b4dda11f940")
        
        # # 5. Numerical/Symbolic Strings
        ("12345678901234567890123456789012345678901234567890123456789012345678901234567890", "50abf5706a150990a08b2c5ea40fa0e585554732")
        ("!@#$%^&*()", "bf24d65c9bb05b9b814a966940bcfa50767c8a8d")

        # # 6. Fox Test
        ("The quick brown fox jumps over the lazy dog", "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12")
        ("The quick brown fox jumps over the lazy dog.", "408d94384216f890ff7a0c3528e8bed1e0b01621")
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
            X := 0..1 # Just 1 (2 Iterations) because SHA1 is slow and triggers verse timeout
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
            Input := TestCase(0)
            Expected := TestCase(1)

            Received := ComputeSHA1HashString(Input)

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