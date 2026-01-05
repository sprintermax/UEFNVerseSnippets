# TODO TEST FUNCTIONALITY

Snowflake<public> := module {
    using. BitMath

    #Used to specify custom options for the Snowflake ID generator worker.
    # A max of 22 Bits are shared between WorkerID, ProcessID and SequenceBits.
    worker_options<public> := struct<computes><concrete> {
        StartEpochSeconds<public> : float = 1767225600.000 # Default to January 1, 2026
        WorkerIDBits<public> : int = 5 # How Many Bits are used for Worker ID
        ProcessIDBits<public> : int = 5 # How Many Bits are used for Process ID
        SequenceBits<public> : int = 12 # How Many Bits are used for Sequence Number # WIP: Check if can remove this and calculate automatically later
    }

    NewWorker<public><constructor>(
        ?WorkerID:int = 0,
        ?ProcessID:int = 0,
        ?Options:worker_options = worker_options{}
    )<transacts> := worker{
        let {
            MaxWorkerID := BitwiseLeftShift(1, Options.WorkerIDBits)
            MaxProcessID := BitwiseLeftShift(1, Options.ProcessIDBits)
            
            _Guard := block {
                Options.StartEpochSeconds.IsFinite[] or Err("StartEpochSeconds must be a finite number")
                (Options.WorkerIDBits + Options.ProcessIDBits + Options.SequenceBits) <= 22 or Err("Total bits for WorkerID, ProcessID and SequenceNumber must not exceed 22")
                WorkerID >= 0 or Err("WorkerID must be non-negative")
                WorkerID < MaxWorkerID or Err("WorkerID {WorkerID} exceeds the maximum value ({MaxWorkerID}) for the specified number of bits ({Options.WorkerIDBits})")
                ProcessID >= 0 or Err("ProcessID must be non-negative")
                ProcessID < MaxProcessID or Err("ProcessID {ProcessID} exceeds the maximum value ({MaxProcessID}) for the specified number of bits ({Options.ProcessIDBits})")
            }
        }
        
        Worker := WorkerID
        Process := ProcessID
        Options := Options

        MaxSequence := BitwiseLeftShift(1, Options.SequenceBits) - 1

        WorkerIDShift := Options.SequenceBits
        ProcessIDShift := Options.SequenceBits + Options.WorkerIDBits
        TimeStampShift := Options.SequenceBits + Options.WorkerIDBits + Options.ProcessIDBits
    }

    worker<public> := class<internal><computes><allocates> {
        Worker<internal> : int
        Process<internal> : int
        Options<internal> : worker_options

        MaxSequence<internal>:int

        WorkerIDShift<internal>:int
        ProcessIDShift<internal>:int
        TimeStampShift<internal>:int

        var<private> CurrentSequence<private> : int = 0
        var<private> LastTimeStamp<private> : float = -1.0

        # Fails if sequence overflow on current milissecond
        NextID<public>()<decides><transacts>:int = {
            CurrentTimeStamp := GetSecondsSinceEpoch()

            CurrentTimeStamp >= Self.LastTimeStamp or Err("Clock moved backwards. Can't generate new ID for {Self.LastTimeStamp - CurrentTimeStamp} seconds")

            # If in the same millisecond, increment the sequence, else reset it
            set Self.CurrentSequence = BitwiseAnd(Self.CurrentSequence + 1, Self.MaxSequence)

            # If sequence overflows, fail the generation
            CurrentTimeStamp <> Self.LastTimeStamp or Self.CurrentSequence <> 0

            set Self.LastTimeStamp = CurrentTimeStamp

            TimeInMiliseconds := Int[(CurrentTimeStamp - Self.Options.StartEpochSeconds) * 1000.0] or Err("Unreachable")

            # Construct the Snowflake ID by shifting and combining the components
            TimePart := BitwiseLeftShift(TimeInMiliseconds, Self.TimeStampShift)
            ProcessPart := BitwiseLeftShift(Self.Process, Self.ProcessIDShift)
            WorkerPart := BitwiseLeftShift(Self.Worker, Self.WorkerIDShift)

            return TimePart + ProcessPart + WorkerPart + Self.CurrentSequence
        }

        # Gets the timestamp (in seconds since epoch) from a given Snowflake ID
        GetTimestampFromID<public>(Showflake:int)<transacts>:float = {
            TimeInMiliseconds := BitwiseRightShift(Showflake, Self.TimeStampShift)
            return (TimeInMiliseconds * 1.0) / 1000.0 + Self.Options.StartEpochSeconds
        }

        # WIP: Extract WorkerID, ProcessID and SequenceNumber from Snowflake ID
    }
}