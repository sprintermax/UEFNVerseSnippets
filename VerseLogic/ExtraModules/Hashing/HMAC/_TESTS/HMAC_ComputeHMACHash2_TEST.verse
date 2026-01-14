using. /Fortnite.com/Devices
using. /Verse.org/Simulation

using. BitMath

HMAC_HMAC_ComputeHMACHash2_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<HMAC.HMAC.ComputeHMACHash2(:string)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Input Key>, <Input String> <Expected HMAC SHA1 Hash>)
    TestCases<private> : []tuple(string, string, string) = array{
        # Common Test Cases
        ("Jefe", "what do ya want for nothing?", "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79")
        ("key", "The quick brown fox jumps over the lazy dog", "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9")
        ("The cat is looking at something", "This is some cool information that will be hashed for testing purposes.", "a655c5eae3ae03b654586a11fc207551f0385ca7")
        # Empty Key and Message
        ("", "", "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d")
        # Empty Key
        ("", "Test", "2440c41268d23719f0e0d0fa3514819a5e30d0aa")
        # Empty Message
        ("Key", "", "e5aaeae4c3010aa2bef0ba1e67cd67bf818ac7ff")
        # Key longer than block size
        ("LongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKey", "Message", "a7400edb5d3a4166b010ebb92a1a4a58ed430131")
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
            X := 0..0 # Just 0 (1 Iterations) because HMAC/SHA1 is slow and triggers verse timeout
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
            InputKey := TestCase(0)
            InputString := TestCase(1)
            Expected := TestCase(2)

            Received := ComputeHMACHashString(InputKey, InputString, SHA1.digest_sha1)

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