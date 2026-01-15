using. /Fortnite.com/Devices
using. /Verse.org/Simulation

using. BitMath
using. Encoding.Hexadecimal
using. StringProcessing

MD5_MD5_ComputeMD5Hash_TEST<internal> := class<internal><concrete><final>(creative_device) {
    TestName<private> : string = "<MD5.MD5.ComputeMD5Hash(:string)>"

    GetLogPrefix<private>(Prefix:string, ?IsBenchmark:logic=false, ?IsProfile:logic=false)<computes>:string = {
        LogType := if (IsBenchmark?) { 
            # Verse places "VerseProfile:" automatically when running `profile{}`
            if (IsProfile?) { "" } else { "VerseProfile: " }
        } else { "VerseTest: " }

        "{LogType}{Prefix}{Prefix.Length > 0 and " " or ""}{TestName}"
    }

    # Array of tuple(<Input String>, <Expected MD5 Hash>)
    TestCases<private> : []tuple(string, string) = array{
        # 1. Empty String (Crucial for padding logic)
        ("", "d41d8cd98f00b204e9800998ecf8427e")

        # 2. Single Characters
        ("a", "0cc175b9c0f1b6a831c399e269772661")
        ("z", "fbade9e36a3f36d3d676c1b808451dd7")

        # # 3. Short Strings
        ("abc", "900150983cd24fb0d6963f7d28e17f72")
        ("hello", "5d41402abc4b2a76b9719d911017c592")
        ("message digest", "f96b697d7cb7938d525a2f31aaf161d0")

        # # 4. Longer Strings (For multi-block processing)
        ("abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b")
        ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "d174ab98d277d9f5a5611c2c9f419d9f")
        
        # # 5. Numerical/Symbolic Strings
        ("12345678901234567890123456789012345678901234567890123456789012345678901234567890", "57edf4a22be3c955ac49da2e2107b67a")
        ("!@#$%^&*()", "05b28d17a7b6e7024b6e5d8cc43a8bf7")

        # # 6. Fox Test
        ("The quick brown fox jumps over the lazy dog", "9e107d9d372bb6826bd81d3542a419d6")
        ("The quick brown fox jumps over the lazy dog.", "e4d909c290d0fb1ca068ffaddf22cbd0")
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
            X := 0..3 # Just 3 (8 Iterations) because MD5 is slow and triggers verse timeout
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

            Received := EncodeByteArrayToHex[ComputeMD5Hash[StringToByteArray(Input)], ?LowerCase := true] or Err("Unreachable")

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