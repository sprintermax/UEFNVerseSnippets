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
# # Fails if KeyBytes contains invalid byte values
NewDigest<public><constructor>(KeyBytes:[]int, hasher_digest:concrete_subtype(digest))<decides><transacts> := digest_hmac{
    let {
        # NOTE: need to do `(concrete_subtype(digest)(hasher)){}` instead of just `hasher_digest{}` due to verse bug
        Digest := (concrete_subtype(digest)(hasher_digest)){}

        BlockSize := Digest.GetBlockSize()

        # Process the key to ensure it fits the block size

        var FixedKeyBytes : []int = for (Byte : KeyBytes) {
            # We validate the byte values are in 0-255 range and fail otherwise
            Byte >= 0 and Byte <= 255
        }

        # If key is longer than block size, hash it
        _Guard_Bigger := if (FixedKeyBytes.Length > BlockSize) {
            Digest.Write[FixedKeyBytes] or Err("Unreachable")
            HashedKey := Digest.Finalize[] or Err("Unreachable")
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

        _Guard_Init := Digest.Write[InnerPadKey] or Err("Unreachable")
    }

    HasherDigest := Digest

    InnerPadKey := InnerPadKey
    OuterPadKey := OuterPadKey
}

# Maintains the state of an ongoing HMAC hash computation.
# Allows incremental hashing of data in multiple chunks.
digest_hmac<public> := class<internal><computes><allocates><final>(digest) {

    HasherDigest<internal> : digest

    InnerPadKey<internal> : []int
    OuterPadKey<internal> : []int

    # Internal flag indicating if the digest is empty (no data written yet)
    # This is needed instead of calling `HasherDigest.IsEmpty[]` because the
    # HMAC requires writing the inner pad key at the start, so the underlying
    # digest is never actually empty after initialization or reset.
    var<private> IsEmptyInternal<private> : logic = true

    # Internal flag indicating if the digest is locked (finalized)
    var<private> IsLockedInternal<private> : logic = false

    # Check if no data has been processed yet
    IsEmpty<override>()<computes><decides><reads>:void = Self.IsEmptyInternal?

    # Succeeds if the digest is currently locked, preventing further writes
    # (Can be unlocked later by calling Reset())
    IsLocked<override>()<computes><decides><reads>:void = Self.IsLockedInternal

    # Get the block size used by the hash function in bytes
    GetBlockSize<override>()<computes><reads>:int = Self.HasherDigest.GetBlockSize()

    # Get the size of the final hash output in bytes
    GetHashSize<override>()<computes><reads>:int = Self.HasherDigest.GetHashSize()

    # Reset the digest to initial state (for reusing the same object)
    Reset<override>()<transacts>:void = {
        Self.HasherDigest.Reset()
        Self.HasherDigest.Write[InnerPadKey] or Err("Unreachable")
        set Self.IsLockedInternal = false
        set Self.IsEmptyInternal = true
    }

    # Add data to the hash computation.
    # Fails if the digest is Locked or if BytesToWrite contains invalid byte values
    Write<override>(BytesToWrite:[]int)<decides><transacts>:void = {
        not Self.IsLockedInternal?

        Self.HasherDigest.Write[BytesToWrite]
        
        option{
            Self.IsEmptyInternal?
            BytesToWrite.Length > 0
            set Self.IsEmptyInternal = false
        }
    }

    # Complete the hash computation by applying paddings and returning
    # the final hash value as a raw byte array.
    # Fails if the digest is Locked
    Finalize<override>()<decides><transacts>:[]int = {
        not Self.IsLockedInternal?
        defer {
            set Self.IsLockedInternal = true
        }

        HashedInner := Self.HasherDigest.Finalize[] or Err("Unreachable")
        Self.HasherDigest.Reset()

        # STEP 4: Outer Hash
        Self.HasherDigest.Write[Self.OuterPadKey] or Err("Unreachable")
        Self.HasherDigest.Write[HashedInner] or Err("Unreachable")
        Self.HasherDigest.Finalize[] or Err("Unreachable")
    }
}

# Computes the HMAC signature for a given Secret Key and Message byte arrays with the specified hasher.
# Fails if KeyBytes or MessageBytes contain invalid byte values
ComputeHMACHash<public>(KeyBytes:[]int, MessageBytes:[]int, hasher:concrete_subtype(digest))<decides><transacts>:[]int = {
    # Create a new HMAC digest for hashing the input
    HashDigest := NewDigest[KeyBytes, hasher]

    # Feed the string into the MD5 digest
    HashDigest.Write[MessageBytes]

    # Finalize the hash and get the resulting byte array
    HashDigest.Finalize[] or Err("Unreachable")
}