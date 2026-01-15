

# Abstract base class for hash digest implementations.
# WIP: Make it abstract and remove default implementations. (impossible currently due to verse limitations)
# (Verse does not allow making concrete classes from abstract classes of other modules)
digest<public> := class<internal><#<abstract>#><computes><allocates> {
    # Check if no data has been processed yet
    IsEmpty<public>()<computes><decides><reads>:void = {}

    # Succeeds if the digest is currently locked, preventing further writes
    # (Can be unlocked later by calling Reset)
    IsLocked<public>()<computes><decides><reads>:void = {}

    # Get the block size used by the hash function in bytes
    GetBlockSize<public>()<computes><reads>:int = { 0 }

    # Get the size of the final hash output in bytes
    GetHashSize<public>()<computes><reads>:int = { 0 }

    # Reset the digest to initial state (for reusing the same object)
    Reset<public>()<transacts>:void = {}

    # Add data to the hash computation.
    # Fails if the digest is Locked or if BytesToWrite contains invalid byte values
    Write<public>(BytesToWrite:[]int)<decides><transacts>:void = {}

    # Complete the hash computation and returns the final hash value as
    # a raw byte array and locks the digest preventing further writes.
    # Fails if the digest is Locked
    Finalize<public>()<decides><transacts>:[]int = { array{} }
}