using. BitMath
using. Encoding.Hexadecimal
using. MathFeatures
using. StringProcessing

# SHA-1 (Secure Hash Algorithm 1)
#
# A cryptographic hash function that produces a 160-bit (20-byte) hash value.
# Designed by the NSA and published in 1995. Like MD5, it is considered 
# cryptographically broken against collision attacks, but remains widely used
# for checksums, Git commit hashes, and legacy systems.

sha1_scoped<internal> := scoped { SHA1 }

# Creates a new SHA-1 digest object for incremental hashing.
# Useful when you want to hash data in multiple chunks
NewDigest<public><constructor>()<computes><allocates> := digest_sha1{}

# Maintains the state of an ongoing SHA-1 hash computation.
# Allows incremental hashing of data in multiple chunks.
digest_sha1<public> := class<internal><concrete><computes><allocates><final>(digest) {

    # The five 32-bit state registers that hold the evolving hash value
    # Initially set to magic constants, these are modified by each block processed.
    var<private> DigestStates<private>:[]int = array{
        _SHA1Constants.InitialStateA
        _SHA1Constants.InitialStateB
        _SHA1Constants.InitialStateC
        _SHA1Constants.InitialStateD
        _SHA1Constants.InitialStateE
    }

    # Temporary buffer to accumulate bytes until having a complete 64-byte block
    # SHA-1 processes data in 512-bit (64-byte) chunks.
    var<private> BlockBuffer<private>:[]int = array{}
    
    # Number of bytes currently in the incomplete block buffer (0-63).
    # When this reaches 64, we process the block and reset to 0.
    var<private> BytesInBuffer<private>:int = 0
    
    # Total number of bytes that have been fed into the hash so far.
    # Used in the final padding step to encode message length.
    var<private> TotalBytesProcessed<private>:int = 0

    # Internal flag indicating if the digest is locked (finalized)
    var<private> IsLockedInternal<private> : logic = false

    # Check if no data has been processed yet
    IsEmpty<override>()<computes><decides><reads>:void = Self.TotalBytesProcessed = 0

    # Succeeds if the digest is currently locked, preventing further writes
    # (Can be unlocked later by calling Reset())
    IsLocked<override>()<computes><decides><reads>:void = Self.IsLockedInternal

    # Get the block size used by the hash function in bytes
    GetBlockSize<override>()<computes><reads>:int = _SHA1Constants.BlockSize

    # Get the size of the final hash output in bytes
    GetHashSize<override>()<computes><reads>:int = _SHA1Constants.HashSize

    # Reset the digest to initial state (for reusing the same object)
    Reset<override>()<transacts>:void = {
        set Self.DigestStates = array{
            _SHA1Constants.InitialStateA
            _SHA1Constants.InitialStateB
            _SHA1Constants.InitialStateC
            _SHA1Constants.InitialStateD
            _SHA1Constants.InitialStateE
        }
        set Self.BlockBuffer = array{}
        set Self.BytesInBuffer = 0
        set Self.TotalBytesProcessed = 0
        set Self.IsLockedInternal = false
    }

    # Processes a single 64-byte (512-bit) block through the SHA-1 algorithm.
    # This is the core of SHA-1, involving message expansion and 80 rounds of mixing.
    ProcessBlock<private>(Block:[]int)<transacts>:void = {
        # STEP 1: Parse block into 16 x 32-bit words (Big-Endian)
        #
        # SHA-1 interprets the 64 bytes as 16 Big-Endian 32-bit integers.
        # Big-Endian: Most significant byte first (opposite of MD5).
        # Example: bytes [0x12, 0x34, 0x56, 0x78] -> word 0x12345678
        var MessageWords:[]int = array{}
        for (
            WordIndex := 0..15
            ByteOffset := WordIndex * 4
            Byte0 := Block[ByteOffset + 0]  # Most significant byte
            Byte1 := Block[ByteOffset + 1]
            Byte2 := Block[ByteOffset + 2]
            Byte3 := Block[ByteOffset + 3]  # Least significant byte
        ) {
            # Combine 4 bytes into a 32-bit word (Big-Endian)
            Word := (Byte0 * 16777216) + (Byte1 * 65536) + (Byte2 * 256) + Byte3
            set MessageWords += array{Mod[Word, _MathConstants.Max32BitUInt]} or Err("Unreachable")
        }

        # STEP 2: Message Schedule Expansion
        # Extend the sixteen 32-bit words into eighty 32-bit words.
        # Formula: W[t] = S^1(W[t-3] XOR W[t-8] XOR W[t-14] XOR W[t-16])
        # This diffusion ensures changes in the input propagate to all future rounds.
        for (T := 16..79) {
            Term1 := MessageWords[T - 3] or Err("Unreachable")
            Term2 := MessageWords[T - 8] or Err("Unreachable")
            Term3 := MessageWords[T - 14] or Err("Unreachable")
            Term4 := MessageWords[T - 16] or Err("Unreachable")
            
            XorResult := BitwiseXor(BitwiseXor(BitwiseXor(Term1, Term2), Term3), Term4)
            Rotated := LeftRotate(XorResult, 1, ?BitCount := option{32})
            set MessageWords += array{Rotated}
        }

        # STEP 3: Initialize working variables with current state
        var WorkingStates : []int = Self.DigestStates

        # STEP 4: Main Loop (80 operations)
        # Split into 4 rounds of 20 operations each.
        #
        # Each round uses a different non-linear logical function and a specific constant K.

        # ROUND 1: Operations 0-19 using function Choice and Constant K1
        set WorkingStates = ExecuteRound(WorkingStates, 0, FunctionChoice, MessageWords, _SHA1Constants.K1)
        # ROUND 2: Operations 20-39 using function Parity and Constant K2
        set WorkingStates = ExecuteRound(WorkingStates, 20, FunctionParity, MessageWords, _SHA1Constants.K2)
        # ROUND 3: Operations 40-59 using function Majority and Constant K3
        set WorkingStates = ExecuteRound(WorkingStates, 40, FunctionMajority, MessageWords, _SHA1Constants.K3)
        # ROUND 4: Operations 60-79 using function Parity and Constant K4
        set WorkingStates = ExecuteRound(WorkingStates, 60, FunctionParity, MessageWords, _SHA1Constants.K4)

        # STEP 5: Add working variables back to state (with wraparound)
        # This ensures the hash accumulates information from all blocks processed so far.
        set Self.DigestStates = for (Index := 0..4) {
            Mod[Self.DigestStates[Index] + WorkingStates[Index], _MathConstants.Max32BitUInt] or Err("Unreachable")
        }
    }

    # Util function to execute one round of 20 SHA-1 operations
    # Applies the specified mixer function and the constant K.
    ExecuteRound<private>(
        CurrentStates:[]int,
        IndexOffset:int,
        MixerFunction:type{_(:int, :int, :int)<transacts>:int},
        MessageWords:[]int,
        KConstant:int
    )<transacts>:[]int = {
        var WorkingStates : []int = CurrentStates

        for (OperationIndex := 0..19) {
            GlobalIndex := IndexOffset + OperationIndex
            FunctionResult := MixerFunction(WorkingStates[1], WorkingStates[2], WorkingStates[3]) or Err("Unreachable")
            Rotated := LeftRotate(WorkingStates[0], 5, ?BitCount := option{32}) or Err("Unreachable")
            Word := MessageWords[GlobalIndex] or Err("Unreachable")
            NewA := Mod[Rotated + FunctionResult + WorkingStates[4] + Word + KConstant, _MathConstants.Max32BitUInt] or Err("Unreachable")

            set WorkingStates = array{
                NewA
                WorkingStates[0] or Err("Unreachable")
                LeftRotate(WorkingStates[1], 30, ?BitCount := option{32}) or Err("Unreachable")
                WorkingStates[2] or Err("Unreachable")
                WorkingStates[3] or Err("Unreachable")
            }
        }

        WorkingStates
    }

    # Add data to the hash computation. Data is buffered until we have
    # complete 64-byte blocks to process.
    # Fails if the digest is Locked or if BytesToWrite contains invalid byte values
    Write<override>(BytesToWrite:[]int)<decides><transacts>:void = {
        not Self.IsLockedInternal?

        var RemainingData : []int = for (Byte : BytesToWrite) {
            # We validate the byte values are in 0-255 range and fail otherwise
            Byte >= 0 and Byte <= 255
        }
        set Self.TotalBytesProcessed += RemainingData.Length

        # If buffer already has some data, try to fill it to 64 bytes
        if (Self.BytesInBuffer > 0) {
            SpaceInBuffer := _SHA1Constants.BlockSize - Self.BytesInBuffer
            BytesToCopy := RemainingData.Length < SpaceInBuffer or SpaceInBuffer
            
            # Copy bytes into buffer
            for (Index := 0..BytesToCopy - 1) {
                set Self.BlockBuffer += array{RemainingData[Index]} or Err("Unreachable")
            }
            set Self.BytesInBuffer += BytesToCopy
            
            # Remove copied bytes from remaining data
            if (RemainingData.Length > BytesToCopy) {
                set RemainingData = RemainingData.Slice[BytesToCopy] or Err("Unreachable")
            } else {
                set RemainingData = array{}
            }
            
            # If buffer is now full, process it
            if (Self.BytesInBuffer = _SHA1Constants.BlockSize) {
                ProcessBlock(Self.BlockBuffer)
                set Self.BlockBuffer = array{}
                set Self.BytesInBuffer = 0
            }
        }

        # Process any complete 64-byte blocks directly from remaining data
        loop {
            RemainingData.Length >= _SHA1Constants.BlockSize or (break)

            CompleteBlock := RemainingData.Slice[0, _SHA1Constants.BlockSize] or Err("Unreachable")
            ProcessBlock(CompleteBlock)
            set RemainingData = RemainingData.Slice[_SHA1Constants.BlockSize] or Err("Unreachable")
        }

        # Store any leftover bytes in the buffer
        if (RemainingData.Length > 0) {
            for (Byte : RemainingData) {
                set Self.BlockBuffer += array{Byte}
            }
            set Self.BytesInBuffer = RemainingData.Length
        }
    }

    # Complete the hash computation by applying paddings and returning
    # the final 160-bit (20-byte) hash value as a raw byte array.
    # Fails if the digest is Locked
    Finalize<override>()<decides><transacts>:[]int = {
        not Self.IsLockedInternal?
        defer {
            set Self.IsLockedInternal = true
        }

        # STEP 1: Create padding
        #
        # SHA-1 padding format:
        # 1. Append a single '1' bit (0x80 byte)
        # 2. Append '0' bits until length ≡ 448 (mod 512) bits ≡ 56 (mod 64) bytes
        # 3. Append original message length as 64-bit big-endian integer

        # Calculate how many bytes we need to reach 56 bytes (mod 64)
        # This leaves 8 bytes for the length field
        BytesInLastBlock := Mod[Self.BytesInBuffer, _SHA1Constants.BlockSize] or Err("Unreachable")
        PaddingZeroCount := if (BytesInLastBlock < 56) {
            56 - BytesInLastBlock - 1
        } else {
            (64 + 56) - BytesInLastBlock - 1
        }

        # Build padding: [0x80, 0x00, 0x00, ..., length_high, length_low]
        var PaddingBytes:[]int = array{0x80}
        for (Index := 0..PaddingZeroCount - 1) {
            set PaddingBytes += array{0}
        }

        # Append message length in bits as 64-bit big-endian integer
        MessageLengthInBits := Self.TotalBytesProcessed * 8

        # Split into low 32 bits and high 32 bits
        LengthHigh32 := Mod[Quotient[MessageLengthInBits, _MathConstants.Max32BitUInt + 1], _MathConstants.Max32BitUInt] or Err("Unreachable")
        LengthLow32 := Mod[MessageLengthInBits, _MathConstants.Max32BitUInt] or Err("Unreachable")

        # Write High 8 bytes first (big-endian)
        for (RawByteIndex := 0..3) {
            ByteIndex := 3 - RawByteIndex

            Divisor := PowerOfTwo[ByteIndex * 8] or Err("Unreachable")
            
            ByteValue := Mod[Quotient[LengthHigh32, Divisor], 256] or Err("Unreachable")
            set PaddingBytes += array{ByteValue}
        }

        # Write Low 8 bytes second (big-endian)
        for (RawByteIndex := 0..3) {
            ByteIndex := 3 - RawByteIndex

            Divisor := PowerOfTwo[ByteIndex * 8] or Err("Unreachable")

            ByteValue := Mod[Quotient[LengthLow32, Divisor], 256] or Err("Unreachable")
            set PaddingBytes += array{ByteValue}
        }

        # Process the padding
        Write[PaddingBytes] or Err("Unreachable")

        # STEP 2: Convert final state to hex string (big-endian)
        var HashBytes:[]int = array{}

        # Extract each state variable as 4 bytes (big-endian)
        for (State : Self.DigestStates) {
            for (RawByteIndex := 0..3) {
                ByteIndex := 3 - RawByteIndex

                Divisor := PowerOfTwo[ByteIndex * 8] or Err("Unreachable")

                ByteValue := Mod[Quotient[State, Divisor], 256] or Err("Unreachable")
                set HashBytes += array{ByteValue}
            }
        }

        HashBytes
    }
}

# Computes the SHA-1 hash for a given input byte array.
# Fails if InputBytes contain invalid byte values
ComputeSHA1Hash<public>(InputBytes:[]int)<decides><transacts>:[]int = {
    # Create a new SHA-1 digest for hashing the input
    HashDigest := NewDigest()

    # Feed the raw bytes into the SHA-1 digest
    HashDigest.Write[InputBytes]

    # Finalize the hash and get the resulting SHA-1
    HashDigest.Finalize[] or Err("Unreachable")
}