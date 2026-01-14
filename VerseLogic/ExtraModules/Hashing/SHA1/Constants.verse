_SHA1Constants<internal> := module {
    # The size of the final SHA-1 hash in bytes.
    HashSize<sha1_scoped> : int = 20 # 160 bits
    # The size of each processing block in bytes.
    BlockSize<sha1_scoped> : int = 64 # 512 bits

    # Initial hash state values (defined by SHA-1 specification)
    # These are carefully chosen "magic" constants
    InitialStateA<sha1_scoped> : int = 0x67452301 # 1732584193
    InitialStateB<sha1_scoped> : int = 0xEFCDAB89 # 4023233417
    InitialStateC<sha1_scoped> : int = 0x98BADCFE # 2562383102
    InitialStateD<sha1_scoped> : int = 0x10325476 # 271733878
    InitialStateE<sha1_scoped> : int = 0xC3D2E1F0 # 3285377520

    # Precomputed constants for each round of SHA-1
    K1<sha1_scoped> : int = 0x5A827999 # Round 1 (operations 0-19)
    K2<sha1_scoped> : int = 0x6ED9EBA1 # Round 2 (operations 20-39)
    K3<sha1_scoped> : int = 0x8F1BBCDC # Round 3 (operations 40-59)
    K4<sha1_scoped> : int = 0xCA62C1D6 # Round 4 (operations 60-79)
}