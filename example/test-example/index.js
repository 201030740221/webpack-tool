var store = require('./lib/store');
module.exports = {
    validator: require('./lib/validator'),
    store: store.store,
    action: store.action,
    event: store.event,
    mixins:{
        storeMixin: require('./lib/mixins/storeMixin'),
        linkedStoreMixin: require('./lib/mixins/linkedStoreMixin')
    }
};
