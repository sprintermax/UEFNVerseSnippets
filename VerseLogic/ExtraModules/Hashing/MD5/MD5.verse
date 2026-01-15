using. /UnrealEngine.com/Temporary/Diagnostics

using. BitMath
using. Encoding.Hexadecimal
using. MathFeatures
using. StringProcessing
using. VerseFeatures

# MD5 (Message Digest Algorithm 5)
#
# A cryptographic hash function that produces a 128-bit (16-byte) hash value.
# Developed by Ronald Rivest in 1991. Now considered cryptographically broken,
# but still widely used for checksums and non-security purposes.

md5_scoped<internal> := scoped { MD5 }

# Creates a new MD5 digest object for incremental hashing.
# Useful when you want to hash data in multiple chunks
NewDigest<public><constructor>()<computes><allocates> := digest_md5{}

# Maintains the state of an ongoing MD5 hash computation.
# Allows incremental hashing of data in multiple chunks.
digest_md5<public> := class<internal><concrete><computes><allocates><final>(digest) {

    # The four 32-bit state registers that hold the evolving hash value
    # Initially set to magic constants, modified by each block processed
    var<private> DigestStates<private>:[]int = array{
        _MD5Constants.InitialStateA
        _MD5Constants.InitialStateB
        _MD5Constants.InitialStateC
        _MD5Constants.InitialStateD
    }

    # Temporary buffer to accumulate bytes until having a complete 64-byte block
    # MD5 processes data in 512-bit (64-byte) chunks
    var<private> BlockBuffer<private>:[]int = array{}
    
    # Number of bytes currently in the incomplete block buffer (0-63)
    # When this reaches 64, we process the block and reset to 0
    var<private> BytesInBuffer<private>:int = 0
    
    # Total number of bytes that have been fed into the hash so far
    # Used in the final padding step to encode message length
    var<private> TotalBytesProcessed<private>:int = 0

    # Internal flag indicating if the digest is locked (finalized)
    var<private> IsLockedInternal<private> : logic = false

    # Check if no data has been processed yet
    IsEmpty<override>()<computes><decides><reads>:void = Self.TotalBytesProcessed = 0

    # Succeeds if the digest is currently locked, preventing further writes
    # (Can be unlocked later by calling Reset())
    IsLocked<override>()<computes><decides><reads>:void = Self.IsLockedInternal

    # Get the block size used by the hash function in bytes
    GetBlockSize<override>()<computes><reads>:int = _MD5Constants.BlockSize

    # Get the size of the final hash output in bytes
    GetHashSize<override>()<computes><reads>:int = _MD5Constants.HashSize

    # Reset the digest to initial state (for reusing the same object)
    Reset<override>()<transacts>:void = {
        set Self.DigestStates = array{
            _MD5Constants.InitialStateA
            _MD5Constants.InitialStateB
            _MD5Constants.InitialStateC
            _MD5Constants.InitialStateD
        }
        set Self.BlockBuffer = array{}
        set Self.BytesInBuffer = 0
        set Self.TotalBytesProcessed = 0
        set Self.IsLockedInternal = false
    }

    # Processes a single 64-byte (512-bit) block through the MD5 algorithm.
    # This is the core of MD5 - 64 operations in 4 rounds of 16 operations each.
    ProcessBlock<private>(Block:[]int)<transacts>:void = {
        # STEP 1: Parse block into 16 x 32-bit words (little-endian)
        #
        # MD5 interprets the 64 bytes as 16 little-endian 32-bit integers
        # Little-endian: least significant byte first
        # Example: bytes [0x12, 0x34, 0x56, 0x78] -> word 0x78563412
        var MessageWords:[]int = array{}
        for (
            WordIndex := 0..15
            ByteOffset := WordIndex * 4
            Byte0 := Block[ByteOffset + 0]  # Least significant byte
            Byte1 := Block[ByteOffset + 1]
            Byte2 := Block[ByteOffset + 2]
            Byte3 := Block[ByteOffset + 3]  # Most significant byte
        ) {
            # Combine 4 bytes into a 32-bit word (little-endian)
            # Word = Byte0 + (Byte1 * 256) + (Byte2 * 65536) + (Byte3 * 16777216)
            Word := Byte0 + (Byte1 * 256) + (Byte2 * 65536) + (Byte3 * 16777216)
            set MessageWords += array{Mod[Word, _MathConstants.Max32BitUInt]} or Err("Unreachable")
        }

        # STEP 2: Initialize working variables with current state
        var WorkingStates : []int = Self.DigestStates

        # STEP 3: Execute 64 operations in 4 rounds
        #
        # Each round uses a different function (F, G, H, or I) and processes
        # the message words in a different order for thorough mixing.

        # ROUND 1: Operations 0-15 using function F
        set WorkingStates = ExecuteRound(WorkingStates, 0, FunctionF, MessageWords, _MD5Constants.RotationAmountsRound1)
        # ROUND 2: Operations 16-31 using function G
        set WorkingStates = ExecuteRound(WorkingStates, 16, FunctionG, MessageWords, _MD5Constants.RotationAmountsRound2, ?MessageWordIndices := option{_MD5Constants.MessageWordIndicesRound2})
        # ROUND 3: Operations 32-47 using function H
        set WorkingStates = ExecuteRound(WorkingStates, 32, FunctionH, MessageWords, _MD5Constants.RotationAmountsRound3, ?MessageWordIndices := option{_MD5Constants.MessageWordIndicesRound3})
        # ROUND 4: Operations 48-63 using function I
        set WorkingStates = ExecuteRound(WorkingStates, 48, FunctionI, MessageWords, _MD5Constants.RotationAmountsRound4, ?MessageWordIndices := option{_MD5Constants.MessageWordIndicesRound4})

        # STEP 4: Add working variables back to state (with wraparound)
        # This ensures the hash accumulates information from all blocks
        set Self.DigestStates = for (Index := 0..3) {
            Mod[Self.DigestStates[Index] + WorkingStates[Index], _MathConstants.Max32BitUInt] or Err("Unreachable")
        }
    }

    # Util function to execute one round of 16 MD5 operations.
    # Applies the specified mixer function and handles round-specific details.
    ExecuteRound<private>(
        CurrentStates:[]int,
        IndexOffset:int,
        MixerFunction:type{_(:int, :int, :int)<transacts>:int},
        MessageWords:[]int,
        RotationAmounts:[]int,
        ?MessageWordIndices:?[]int = false
    )<transacts>:[]int = {
        var WorkingStates : []int = CurrentStates

        for (OperationIndex := 0..15) {
            GlobalIndex := IndexOffset + OperationIndex
            MessageWordIndex := MessageWordIndices?[OperationIndex] or OperationIndex
            
            FunctionResult := MixerFunction(WorkingStates[1], WorkingStates[2], WorkingStates[3]) or Err("Unreachable")
            Sum := Mod[WorkingStates[0] + FunctionResult + MessageWords[MessageWordIndex] + _MD5Constants.SineTable[GlobalIndex], _MathConstants.Max32BitUInt] or Err("Unreachable")
            Rotated := LeftRotate(Sum, RotationAmounts.At[OperationIndex], ?BitCount := option{32}) or Err("Unreachable")
            NewB := Mod[WorkingStates[1] + Rotated, _MathConstants.Max32BitUInt] or Err("Unreachable")

            set WorkingStates = array{
                WorkingStates[3] or Err("Unreachable")
                NewB
                WorkingStates[1] or Err("Unreachable")
                WorkingStates[2] or Err("Unreachable")
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
            SpaceInBuffer := _MD5Constants.BlockSize - Self.BytesInBuffer
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
            if (Self.BytesInBuffer = _MD5Constants.BlockSize) {
                ProcessBlock(Self.BlockBuffer)
                set Self.BlockBuffer = array{}
                set Self.BytesInBuffer = 0
            }
        }

        # Process any complete 64-byte blocks directly from remaining data
        loop {
            RemainingData.Length >= _MD5Constants.BlockSize or (break)

            CompleteBlock := RemainingData.Slice[0, _MD5Constants.BlockSize] or Err("Unreachable")
            ProcessBlock(CompleteBlock)
            set RemainingData = RemainingData.Slice[_MD5Constants.BlockSize] or Err("Unreachable")
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
    # the final 128-bit (16-byte) hash value as a raw byte array.
    # Fails if the digest is Locked
    Finalize<override>()<decides><transacts>:[]int = {
        not Self.IsLockedInternal?
        defer {
            set Self.IsLockedInternal = true
        }

        # STEP 1: Create padding
        #
        # MD5 padding format:
        # 1. Append a single '1' bit (0x80 byte)
        # 2. Append '0' bits until length ≡ 448 (mod 512) bits ≡ 56 (mod 64) bytes
        # 3. Append original message length as 64-bit little-endian integer

        # Calculate how many bytes we need to reach 56 bytes (mod 64)
        # This leaves 8 bytes for the length field
        BytesInLastBlock := Mod[Self.BytesInBuffer, _MD5Constants.BlockSize] or Err("Unreachable")
        PaddingZeroCount := if (BytesInLastBlock < 56) {
            56 - BytesInLastBlock - 1  # -1 for the 0x80 byte
        } else {
            (64 + 56) - BytesInLastBlock - 1
        }

        # Build padding: [0x80, 0x00, 0x00, ..., length_low_32bits, length_high_32bits]
        var PaddingBytes:[]int = array{0x80}  # Append '1' bit (as 0x80 byte = 128 decimal)
        for (Index := 0..PaddingZeroCount - 1) {
            set PaddingBytes += array{0}
        }

        # Append message length in bits as 64-bit little-endian integer
        MessageLengthInBits := Self.TotalBytesProcessed * 8
        
        # Split into low 32 bits and high 32 bits
        LengthLow32 := Mod[MessageLengthInBits, _MathConstants.Max32BitUInt] or Err("Unreachable")
        LengthHigh32 := Mod[Quotient[MessageLengthInBits, _MathConstants.Max32BitUInt + 1], _MathConstants.Max32BitUInt] or Err("Unreachable")

        # Encode as 8 bytes (little-endian)
        for (RawByteIndex := 0..7) {
            ByteIndex := Mod[RawByteIndex, 4] or Err("Unreachable")
            Length32 := RawByteIndex < 4 and LengthLow32 or LengthHigh32

            Divisor := PowerOfTwo[ByteIndex * 8] or Err("Unreachable")

            ByteValue := Mod[Quotient[Length32, Divisor], _MathConstants.Max32BitUInt] or Err("Unreachable")
            set PaddingBytes += array{Mod[ByteValue, 256]} or Err("Unreachable")
        }

        # Process the padding
        Write[PaddingBytes] or Err("Unreachable")

        # STEP 2: Convert final state to hex string (little-endian byte order)
        var HashBytes:[]int = array{}

        # Extract each state variable as 4 bytes (little-endian)
        for (State : Self.DigestStates) {
            for (ByteIndex := 0..3) {
                
                Divisor := PowerOfTwo[ByteIndex * 8] or Err("Unreachable")
                
                ByteValue := Mod[Quotient[State, Divisor], _MathConstants.Max32BitUInt] or Err("Unreachable")
                set HashBytes += array{Mod[ByteValue, 256]} or Err("Unreachable")
            }
        }

        HashBytes
    }
}

# Computes the MD5 hash for a given input byte array.
# Fails if InputBytes contain invalid byte values
ComputeMD5Hash<public>(InputBytes:[]int)<decides><transacts>:[]int = {
    # Create a new MD5 digest for hashing the input
    HashDigest := NewDigest()

    # Feed the raw bytes into the MD5 digest
    HashDigest.Write[InputBytes]

    # Finalize the hash and get the resulting MD5
    HashDigest.Finalize[] or Err("Unreachable")
}