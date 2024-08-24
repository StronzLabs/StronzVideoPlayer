import 'dart:async';

mixin StreamListener {
    final List<StreamSubscription> _subscriptions = [];

    void updateSubscriptions(Iterable<StreamSubscription> iterable) {
        if(this._subscriptions.isEmpty)
            this._subscriptions.addAll(iterable);
    }

    void disposeSubscriptions() {
        for (StreamSubscription subscription in this._subscriptions)
            subscription.cancel();
    }
}
