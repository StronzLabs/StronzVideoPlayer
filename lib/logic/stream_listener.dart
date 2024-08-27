import 'dart:async';

mixin StreamListener {
    final List<StreamSubscription> _subscriptions = [];

    void updateSubscriptions(Iterable<StreamSubscription> iterable) {
        if(this._subscriptions.isEmpty)
            this._subscriptions.addAll(iterable);
    }

    Future<void> disposeSubscriptions() async {
        for (StreamSubscription subscription in this._subscriptions)
            await subscription.cancel();
    }
}
