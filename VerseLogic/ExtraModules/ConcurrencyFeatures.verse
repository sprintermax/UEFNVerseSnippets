using. /Verse.org/Concurrency
using. /Verse.org/Simulation

ConcurrencyFeatures<public> := module {

    AwaitableHandler<public>(Awaitable:awaitable(t) where t:type)<suspends>:t = Awaitable.Await()

    # Race between all elements of the array: returns the result of
    # the first to complete, and cancel all other running handlers
    ArrayRace<public>(Array:[]t, HandlerFunction(Element:t)<suspends>:u where t:type, u:type)<suspends>:u = {
        if (
            Array.Length > 1
            MidPoint := Floor(Array.Length / 2)
            LeftArray := Array.Slice[0, MidPoint]
            RightArray := Array.Slice[MidPoint]
        ) {
            race {
                ArrayRace(LeftArray, HandlerFunction)
                ArrayRace(RightArray, HandlerFunction)
            }
        } else if (FirstElement := Array[0]) {
            HandlerFunction(FirstElement)
        } else {
            Sleep(Inf)
            Err("Unreachable")
        }
    }

    # Rush between all elements of the array: returns the result of the
    # first to complete, without cancelling the other running handlers
    ArrayRush<public>(Array:[]t, HandlerFunction(Element:t)<suspends>:u where t:type, u:type)<suspends>:u = {
        if (
            Array.Length > 1
            MidPoint := Floor(Array.Length / 2)
            LeftArray := Array.Slice[0, MidPoint]
            RightArray := Array.Slice[MidPoint]
        ) {
            rush {
                ArrayRush(LeftArray, HandlerFunction)
                ArrayRush(RightArray, HandlerFunction)
            }
        } else if (FirstElement := Array[0]) {
            HandlerFunction(FirstElement)
        } else {
            Sleep(Inf)
            Err("Unreachable")
        }
    }

    # Sync between all elements of the array: waits for all the
    # handlers to complete, then return an array with all the results
    ArraySync<public>(Array:[]t, HandlerFunction(Element:t)<suspends>:u where t:type, u:type)<suspends>:[]u = {
        if (
            Array.Length > 1
            MidPoint := Floor(Array.Length / 2)
            LeftArray := Array.Slice[0, MidPoint]
            RightArray := Array.Slice[MidPoint]
        ) {
            SyncResult := sync {
                ArraySync(LeftArray, HandlerFunction)
                ArraySync(RightArray, HandlerFunction)
            }

            SyncResult(0) + SyncResult(1)

        } else if (FirstElement := Array[0]) {
            array{HandlerFunction(FirstElement)}
        } else {
            array{}
        }
    }

    (Awaitable:awaitable(t)).Await<public>(MaxTimeout:float where t:type)<suspends>:?t = {
        race {
            (EventData := Awaitable.Await(); option{EventData})
            (Sleep(MaxTimeout); false)
        }
    }

    (Awaitable:awaitable(t)).AwaitFor<public>((Query:t, ?MaxTimeout:float=Inf) where t:subtype(comparable))<suspends>:logic = {
        race {
            (loop {
                EventData := Awaitable.Await()
                if (EventData = Query). break
            }; true)
            (Sleep(MaxTimeout); false)
        }
    }

    (Awaitable:awaitable(t)).AwaitForCondition<public>((Condition:type{_(:t)<reads><decides>:any}, ?MaxTimeout:float=Inf) where t:type)<suspends>:logic = {
        race {
            (loop {
                EventData := Awaitable.Await()
                if (Condition[EventData]). break
            }; true)
            (Sleep(MaxTimeout); false)
        }
    }

    (Awaitable:awaitable(t)).AwaitForCondition<public>((Condition:type{_(:t, :t2)<reads><decides>:any}, Args:t2, ?MaxTimeout:float=Inf) where t:type, t2:type)<suspends>:logic = {
        race {
            (loop {
                EventData := Awaitable.Await()
                if (Condition[EventData, Args]). break
            }; true)
            (Sleep(MaxTimeout); false)
        }
    }
}