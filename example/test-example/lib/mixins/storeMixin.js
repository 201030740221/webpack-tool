var liteFlux = require('../store');

module.exports = function() {
    var stores = Array.prototype.slice.call(arguments);
    //var store = storeNames.shift();
    return {

        getInitialState: function() {
            if(typeof this.getStateFromStore !== "function"){
                return this._getStateFromStore();
            }else{
                return this.getStateFromStore();
            }
        },

        componentDidMount: function() {
            var _this = this;
            liteFlux.event.on("_storeChange",_this._setStateFromStore);
        },

        componentWillUnmount: function(){
            var _this = this;
            liteFlux.event.off("_storeChange",_this._setStateFromStore);

        },

        _setStateFromStore: function(){
            if(typeof this.setStateFromStore !== "function"){
                if (this.isMounted()) {
                    this.setState(this._getStateFromStore());
                }
            }else{
                this.setStateFromStore.call(this,this._getStateFromStore());
            }
        },

        _getStateFromStore: function(){
            var ret = {};
            stores.map(function(store){
                ret[store] = liteFlux.store(store).getStore();
            });
            return ret;
        }
    };
};
