_MD5Constants<internal> := module {
    # The size of the final MD5 hash in bytes.
    HashSize<md5_scoped> : int = 16 # 128 bits
    # The size of each processing block in bytes.
    BlockSize<md5_scoped> : int = 64 # 512 bits

    # Initial hash state values (defined by MD5 specification)
    # These are carefully chosen "magic" constants
    InitialStateA<md5_scoped> : int = 0x67452301  # 1732584193
    InitialStateB<md5_scoped> : int = 0xEFCDAB89  # 4023233417
    InitialStateC<md5_scoped> : int = 0x98BADCFE  # 2562383102
    InitialStateD<md5_scoped> : int = 0x10325476  # 271733878

    # Precomputed constants derived from the MD5 Spec sine function.
    # Formula: `for (X := 0..63) { Floor[2^32 * Abs(Sin(X + 1))] }`
    # These ensure good avalanche effect in the hash function.
    SineTable<md5_scoped>: []int = array{
        # Round 1 (operations 0-15)
        0xD76AA478, 0xE8C7B756, 0x242070DB, 0xC1BDCEEE,
        0xF57C0FAF, 0x4787C62A, 0xA8304613, 0xFD469501,
        0x698098D8, 0x8B44F7AF, 0xFFFF5BB1, 0x895CD7BE,
        0x6B901122, 0xFD987193, 0xA679438E, 0x49B40821,
        # Round 2 (operations 16-31)
        0xF61E2562, 0xC040B340, 0x265E5A51, 0xE9B6C7AA,
        0xD62F105D, 0x02441453, 0xD8A1E681, 0xE7D3FBC8,
        0x21E1CDE6, 0xC33707D6, 0xF4D50D87, 0x455A14ED,
        0xA9E3E905, 0xFCEFA3F8, 0x676F02D9, 0x8D2A4C8A,
        # Round 3 (operations 32-47)
        0xFFFA3942, 0x8771F681, 0x6D9D6122, 0xFDE5380C,
        0xA4BEEA44, 0x4BDECFA9, 0xF6BB4B60, 0xBEBFBC70,
        0x289B7EC6, 0xEAA127FA, 0xD4EF3085, 0x04881D05,
        0xD9D4D039, 0xE6DB99E5, 0x1FA27CF8, 0xC4AC5665,
        # Round 4 (operations 48-63)
        0xF4292244, 0x432AFF97, 0xAB9423A7, 0xFC93A039,
        0x655B59C3, 0x8F0CCC92, 0xFFEFF47D, 0x85845DD1,
        0x6FA87E4F, 0xFE2CE6E0, 0xA3014314, 0x4E0811A1,
        0xF7537E82, 0xBD3AF235, 0x2AD7D2BB, 0xEB86D391
    }

    # Left rotation amounts per operation for round 1: 7, 12, 17, 22 (repeating)
    RotationAmountsRound1<md5_scoped> : []int = array{7, 12, 17, 22}

    # Message word access pattern for Round 2
    MessageWordIndicesRound2<md5_scoped> : []int = array{1, 6, 11, 0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12}
    # Left rotation amounts per operation for round 2: 5, 9, 14, 20 (repeating)
    RotationAmountsRound2<md5_scoped> : []int = array{5, 9, 14, 20}

    # Message word access pattern for Round 3
    MessageWordIndicesRound3<md5_scoped> : []int = array{5, 8, 11, 14, 1, 4, 7, 10, 13, 0, 3, 6, 9, 12, 15, 2}
    # Left rotation amounts per operation for round 3: 4, 11, 16, 23 (repeating)
    RotationAmountsRound3<md5_scoped> : []int = array{4, 11, 16, 23}

    # Message word access pattern for Round 4
    MessageWordIndicesRound4<md5_scoped> : []int = array{0, 7, 14, 5, 12, 3, 10, 1, 8, 15, 6, 13, 4, 11, 2, 9}
    # Left rotation amounts per operation for Round 4: 6, 10, 15, 21 (repeating)
    RotationAmountsRound4<md5_scoped> : []int = array{6, 10, 15, 21}
}