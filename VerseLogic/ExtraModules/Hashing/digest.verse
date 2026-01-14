

# Abstract base class for hash digest implementations.
# WIP: Make it abstract and remove default implementations.
# (Verse does not allow making concrete classes from abstract classes of other modules)
digest<public> := class<internal><#<abstract>#><computes><allocates> {
    # Check if no data has been processed yet
    IsEmpty<public>()<computes><decides><reads>:void = {}

    # Get the block size used by the hash function in bytes
    GetBlockSize<public>()<computes><reads>:int = { 0 }

    # Get the size of the final hash output in bytes
    GetHashSize<public>()<computes><reads>:int = { 0 }

    # Reset the digest to initial state (for reusing the same object)
    Reset<public>()<transacts>:void = {}

    # Add the input string to the hash computation.
    WriteString<public>(Input:string)<transacts>:void = {}

    # Add data to the hash computation.
    # WIP: Fail if BytesToWrite contains invalid byte values.
    WriteRawBytes<public>(BytesToWrite:[]int)<transacts>:void = {}

    # Complete the hash computation and returns the
    # final hash value as a hex string.
    FinalizeHex<public>()<transacts>:string = { "" }

    # Complete the hash computation and returns the
    # final hash value as a raw byte array.
    FinalizeRaw<public>()<transacts>:[]int = { array{} }
}