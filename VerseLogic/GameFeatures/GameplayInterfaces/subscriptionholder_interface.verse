subscriptionholder_interface<public> := interface {
    var<private> TrackedSubscriptions<private> : []cancelable = array{}

    RegisterSubscription<public>(Subscription:cancelable):void = {
        set TrackedSubscriptions += array{Subscription}
    }

    RegisterSubscriptions<public>(Subscriptions:[]cancelable):void = {
        set TrackedSubscriptions += Subscriptions
    }

    UnregisterSubscriptions<public>():void = {
        for (Subscription : TrackedSubscriptions) {
            Subscription.Cancel()
        }
        set TrackedSubscriptions = array{}
    }
}

subscriptionholder_container<public> := class(subscriptionholder_interface) {}