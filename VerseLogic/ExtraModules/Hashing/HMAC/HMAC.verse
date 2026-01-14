using. BitMath
using. Encoding.Hexadecimal
using. StringProcessing

# HMAC (Hash-based Message Authentication Code)
#
# A specific type of message authentication code (MAC) involving a cryptographic hash
# function and a secret cryptographic key defined in RFC 2104. It may be used to
# simultaneously verify both the data integrity and the authenticity of a message.
#
# It can be used with any iterative cryptographic hash function (MD5, SHA-1, etc.)
# in combination with a secret shared key.

# Creates a new HMAC digest object for incremental hashing
# with the provided key in raw bytes and hash digest class.
# Useful when you want to hash data in multiple chunks
NewDigestRaw<public><constructor>(KeyBytes:[]int, hasher_digest:concrete_subtype(digest))<transacts> := digest_hmac{
    let {
        # NOTE: need to do `(concrete_subtype(digest)(hasher)){}` instead of just `hasher_digest{}` due to verse bug
        Digest := (concrete_subtype(digest)(hasher_digest)){}

        BlockSize := Digest.GetBlockSize()

        # Process the key to ensure it fits the block size

        var FixedKeyBytes : []int = KeyBytes

        # If key is longer than block size, hash it
        _Guard_Bigger := if (FixedKeyBytes.Length > BlockSize) {
            Digest.WriteRawBytes(FixedKeyBytes)
            HashedKey := Digest.FinalizeRaw()
            Digest.Reset()
            set FixedKeyBytes = HashedKey
        }

        # If key is shorter than block size, pad it with zeros
        _Guard_Shorter := if (FixedKeyBytes.Length < BlockSize) {
            PadCount := BlockSize - FixedKeyBytes.Length
            Padding := for (X := 1..PadCount) { 0 }
            set FixedKeyBytes += Padding
        }

        # Create inner and outer pad keys
        var InnerPadKey : []int = array{}
        var OuterPadKey : []int = array{}

        _Guard_PadKeys := for (Byte : FixedKeyBytes) {
            set InnerPadKey += array{BitwiseXor(Byte, 0x36)}
            set OuterPadKey += array{BitwiseXor(Byte, 0x5C)}
        }

        _Guard_Init := Digest.WriteRawBytes(InnerPadKey)
    }

    HasherDigest := Digest

    InnerPadKey := InnerPadKey
    OuterPadKey := OuterPadKey
}

# Creates a new HMAC digest object for incremental hashing
# with the provided key string and hash digest class.
# Useful when you want to hash data in multiple chunks
NewDigestString<public><constructor>(Key:string, hasher_digest:concrete_subtype(digest))<transacts> := digest_hmac{
    let {
        ByteArray := StringToByteArray(Key)
    }

    NewDigestRaw<constructor>(ByteArray, hasher_digest)
}

# Maintains the state of an ongoing HMAC hash computation.
# Allows incremental hashing of data in multiple chunks.
digest_hmac<public> := class<internal><computes><allocates><final>(digest) {

    HasherDigest<internal> : digest

    InnerPadKey<internal> : []int
    OuterPadKey<internal> : []int

    var<private> IsEmptyInternal<private> : logic = true

    # Check if no data has been processed yet
    IsEmpty<override>()<computes><decides><reads>:void = Self.IsEmptyInternal?

    # Get the block size used by the hash function in bytes
    GetBlockSize<override>()<computes><reads>:int = Self.HasherDigest.GetBlockSize()

    # Get the size of the final hash output in bytes
    GetHashSize<override>()<computes><reads>:int = Self.HasherDigest.GetHashSize()

    # Reset the digest to initial state (for reusing the same object)
    Reset<override>()<transacts>:void = {
        Self.HasherDigest.Reset()
        Self.HasherDigest.WriteRawBytes(InnerPadKey)
        set Self.IsEmptyInternal = true
    }

    # Add the input string to the hash computation.
    WriteString<override>(Input:string)<transacts>:void = {
        Self.HasherDigest.WriteString(Input)
        if (Self.IsEmptyInternal?, Input.Length > 0) {
            set Self.IsEmptyInternal = false
        }
    }

    # Add data to the hash computation.
    WriteRawBytes<override>(BytesToWrite:[]int)<transacts>:void = {
        Self.HasherDigest.WriteRawBytes(BytesToWrite)
        if (Self.IsEmptyInternal?, BytesToWrite.Length > 0) {
            set Self.IsEmptyInternal = false
        }
    }

    # Finalize the HMAC computation by applying paddings and preparing for final hash.
    FinalizeInternal<private>()<transacts>:void = {
        HashedInner := Self.HasherDigest.FinalizeRaw()
        Self.HasherDigest.Reset()

        # STEP 4: Outer Hash
        Self.HasherDigest.WriteRawBytes(Self.OuterPadKey)
        Self.HasherDigest.WriteRawBytes(HashedInner)
    }

    # Complete the hash computation by applying paddings and returning
    # the final hash value as a hex string.
    FinalizeHex<override>()<transacts>:string = {
        Self.FinalizeInternal()
        Self.HasherDigest.FinalizeHex()
    }

    # Complete the hash computation by applying paddings and returning
    # the final hash value as a raw byte array.
    FinalizeRaw<override>()<transacts>:[]int = {
        Self.FinalizeInternal()
        Self.HasherDigest.FinalizeRaw()
    }
}

# Computes the HMAC signature for a given Secret Key and Message byte arrays with the specified hasher.
ComputeHMACHashRaw<public>(KeyBytes:[]int, MessageBytes:[]int, hasher:concrete_subtype(digest))<transacts>:[]int = {
    # Create a new HMAC digest for hashing the input
    HashDigest := NewDigestRaw(KeyBytes, hasher)

    # Feed the string into the MD5 digest
    HashDigest.WriteRawBytes(MessageBytes)

    # Finalize the hash and get the resulting byte array
    HashDigest.FinalizeRaw()
}

# Computes the HMAC signature for a given Secret Key and Message strings with the specified hasher.
ComputeHMACHashString<public>(Key:string, Message:string, hasher:concrete_subtype(digest))<transacts>:string = {
    KeyBytes := StringToByteArray(Key)
    MessageBytes := StringToByteArray(Message)
    OutputByteArray := ComputeHMACHashRaw(KeyBytes, MessageBytes, hasher)
    EncodeByteArrayToHex[OutputByteArray] or Err("Unreachable")
}