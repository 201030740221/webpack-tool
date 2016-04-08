var liteFlux = require('../store');
var _ = require('../utils');
var ReactLink = require("react/lib/ReactLink");

var ReactStoreSetters = {

    createStoreKeySetter: function(component, store, path) {
        var cache = component.__keySetters || (component.__keySetters = {});
        return cache[path] || (cache[path] = createStoreKeySetter(component, store, path));
    }
};

function createStoreKeySetter(component, store, path) {
    return function storeKeySetter(value) {
        var pathArr = path.split('\.'),
            partialStore = _.extend({}, liteFlux.store(store).getStore()),
            _partialStore = {};

        _partialStore = partialStore;

        for(var k in pathArr){
            if(k == pathArr.length-1){
                _partialStore[pathArr[k]] = value;
            }else{
                _partialStore[pathArr[k]] = _partialStore[pathArr[k]] || {};
            }
            _partialStore = _partialStore[pathArr[k]];
        }

        liteFlux.store(store).setStore(partialStore);
    };
}

module.exports = {

    linkStore: function(store, path) {

        //获取path对应的值
        var pathArr = path.split('\.');
        var partialStore = _.extend({}, liteFlux.store(store).getStore());

        for (var i in pathArr) {
            partialStore = partialStore[pathArr[i]];
        }

        return new ReactLink(
            partialStore,
            ReactStoreSetters.createStoreKeySetter(this, store, path)
        );
    }

};
