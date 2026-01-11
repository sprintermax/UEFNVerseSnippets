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
digest_md5<public> := class<internal><concrete><computes><allocates><final> {

    # The four 32-bit state registers that hold the evolving hash value
    # Initially set to magic constants, modified by each block processed
    var<private> StateA<private>:int = _MD5Constants.InitialStateA
    var<private> StateB<private>:int = _MD5Constants.InitialStateB
    var<private> StateC<private>:int = _MD5Constants.InitialStateC
    var<private> StateD<private>:int = _MD5Constants.InitialStateD

    # Temporary buffer to accumulate bytes until having a complete 64-byte block
    # MD5 processes data in 512-bit (64-byte) chunks
    var<private> BlockBuffer<private>:[]int = array{}
    
    # Number of bytes currently in the incomplete block buffer (0-63)
    # When this reaches 64, we process the block and reset to 0
    var<private> BytesInBuffer<private>:int = 0
    
    # Total number of bytes that have been fed into the hash so far
    # Used in the final padding step to encode message length
    var<private> TotalBytesProcessed<private>:int = 0

    # Check if no data has been processed yet
    IsEmpty<public>()<computes><decides><reads>:void = Self.TotalBytesProcessed = 0

    # Reset the digest to initial state (for reusing the same object)
    Reset<public>()<transacts>:void = {
        set Self.StateA = _MD5Constants.InitialStateA
        set Self.StateB = _MD5Constants.InitialStateB
        set Self.StateC = _MD5Constants.InitialStateC
        set Self.StateD = _MD5Constants.InitialStateD
        set Self.BlockBuffer = array{}
        set Self.BytesInBuffer = 0
        set Self.TotalBytesProcessed = 0
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
        var CurrentState : []int = array{ Self.StateA, Self.StateB, Self.StateC, Self.StateD }

        # STEP 3: Execute 64 operations in 4 rounds
        #
        # Each round uses a different function (F, G, H, or I) and processes
        # the message words in a different order for thorough mixing.
        

        # ROUND 1: Operations 0-15 using function F
        Round1Result := ExecuteRound(CurrentState, 0, FunctionF, MessageWords, _MD5Constants.RotationAmountsRound1)
        # ROUND 2: Operations 16-31 using function G
        Round2Result := ExecuteRound(Round1Result, 16, FunctionG, MessageWords, _MD5Constants.RotationAmountsRound2, ?MessageWordIndices := option{_MD5Constants.MessageWordIndicesRound2})
        # ROUND 3: Operations 32-47 using function H
        Round3Result := ExecuteRound(Round2Result, 32, FunctionH, MessageWords, _MD5Constants.RotationAmountsRound3, ?MessageWordIndices := option{_MD5Constants.MessageWordIndicesRound3})
        # ROUND 4: Operations 48-63 using function I
        Round4Result := ExecuteRound(Round3Result, 48, FunctionI, MessageWords, _MD5Constants.RotationAmountsRound4, ?MessageWordIndices := option{_MD5Constants.MessageWordIndicesRound4})


        # STEP 4: Add working variables back to state (with wraparound)
        # This ensures the hash accumulates information from all blocks
        set Self.StateA = Mod[Self.StateA + Round4Result[0], _MathConstants.Max32BitUInt] or Err("Unreachable")
        set Self.StateB = Mod[Self.StateB + Round4Result[1], _MathConstants.Max32BitUInt] or Err("Unreachable")
        set Self.StateC = Mod[Self.StateC + Round4Result[2], _MathConstants.Max32BitUInt] or Err("Unreachable")
        set Self.StateD = Mod[Self.StateD + Round4Result[3], _MathConstants.Max32BitUInt] or Err("Unreachable")
    }

    # Util function to execute one round of 16 MD5 operations.
    # Applies the specified mixer function and handles round-specific details.
    ExecuteRound<private>(
        CurrentState:[]int,
        GlobalIndexOffset:int,
        MixerFunction:type{_(:int, :int, :int)<transacts>:int},
        MessageWords:[]int,
        RotationAmounts:[]int,
        ?MessageWordIndices:?[]int = false
    )<transacts>:[]int = {
        var WorkingA:int = CurrentState[0] or Err("Unreachable")
        var WorkingB:int = CurrentState[1] or Err("Unreachable")
        var WorkingC:int = CurrentState[2] or Err("Unreachable")
        var WorkingD:int = CurrentState[3] or Err("Unreachable")

        for (OperationIndex := 0..15) {
            GlobalIndex := GlobalIndexOffset + OperationIndex
            MessageWordIndex := MessageWordIndices?[OperationIndex] or OperationIndex
            
            FunctionResult := MixerFunction(WorkingB, WorkingC, WorkingD)
            Sum := Mod[WorkingA + FunctionResult + MessageWords[MessageWordIndex] + _MD5Constants.SineTable[GlobalIndex], _MathConstants.Max32BitUInt] or Err("Unreachable")
            Rotated := LeftRotate(Sum, RotationAmounts.At[OperationIndex], ?BitCount := option{32}) or Err("Unreachable")
            NewA := Mod[WorkingB + Rotated, _MathConstants.Max32BitUInt] or Err("Unreachable")

            set WorkingA = WorkingD
            set WorkingD = WorkingC
            set WorkingC = WorkingB
            set WorkingB = NewA
        }

        return array{WorkingA, WorkingB, WorkingC, WorkingD}
    }

    # Add the input string to the hash computation.
    WriteString<public>(Input:string)<transacts>:void = {
        ByteArray := for (Character : Input) {
            CharToInt(Character)
        }

        Self.WriteRawBytes(ByteArray)
    }

    # Add data to the hash computation. Data is buffered until we have
    # complete 64-byte blocks to process.
    WriteRawBytes<public>(Bytes:[]int)<transacts>:void = {
        var RemainingData : []int = Bytes
        set Self.TotalBytesProcessed += Bytes.Length

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

    # Complete the hash computation by applying MD5 padding and returning
    # the final 128-bit (16-byte) hash value as a hex string.
    Finalize<public>()<transacts>:string = {
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
        # Message length in bits = TotalBytesProcessed * 8
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
        WriteRawBytes(PaddingBytes)

        # STEP 2: Convert final state to hex string (little-endian byte order)
        var HashBytes:[]int = array{}

        # Extract each state variable as 4 bytes (little-endian)
        for (State : array{Self.StateA, Self.StateB, Self.StateC, Self.StateD}) {
            for (ByteIndex := 0..3) {
                
                Divisor := PowerOfTwo[ByteIndex * 8] or Err("Unreachable")
                
                ByteValue := Mod[Quotient[State, Divisor], _MathConstants.Max32BitUInt] or Err("Unreachable")
                set HashBytes += array{Mod[ByteValue, 256]} or Err("Unreachable")
            }
        }

        Concatenate(for (Byte : HashBytes) {
            EncodeByteToHex[Byte, ?LowerCase := true] or Err("Unreachable")
        })
    }
}

ComputeMD5Hash<public>(InputString:string)<transacts>:string = {
    # Create a new MD5 digest for hashing the input
    HashDigest := NewDigest()

    # Feed the string into the MD5 digest
    HashDigest.WriteString(InputString)

    # Finalize the hash and get the resulting MD5
    HashDigest.Finalize()
}