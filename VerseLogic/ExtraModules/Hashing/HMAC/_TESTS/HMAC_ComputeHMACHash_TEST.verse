using. /Fortnite.com/Devices
using. /Verse.org/Simulation

using. BitMath
using. Encoding.Hexadecimal
using. StringProcessing

HMAC_HMAC_ComputeHMACHash_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<HMAC.HMAC.ComputeHMACHash(:string)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Input Key>, <Input String> <Expected HMAC MD5 Hash>)
    TestCases<private> : []tuple(string, string, string) = array{
        # Common Test Cases
        ("Jefe", "what do ya want for nothing?", "750c783e6ab0b503eaa86e310a5db738")
        ("key", "The quick brown fox jumps over the lazy dog", "80070713463e7749b90c2dc24911e275")
        ("The cat is looking at something", "This is some cool information that will be hashed for testing purposes.", "d0630324bffd539af792345c7ce72cf9")
        # Empty Key and Message
        ("", "", "74e6f7298a9c2d168935f58c001bad88")
        # Empty Key
        ("", "Test", "4145127510db1967342c1fad3e81e4c4")
        # Empty Message
        ("Key", "", "8301611c8c027ed84cf7e30020dbd121")
        # Key longer than block size
        ("LongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKeyLongKey", "Message", "89a72db1e21cadb9a37a27a88faff9f0")
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
            X := 0..1 # Just 1 (2 Iterations) because HMAC/MD5 is slow and triggers verse timeout
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

            Received := EncodeByteArrayToHex[ComputeHMACHash[StringToByteArray(InputKey), StringToByteArray(InputString), MD5.digest_md5], ?LowerCase := true] or Err("Unreachable")

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