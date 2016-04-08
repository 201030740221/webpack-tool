var Event = require('./event');
var _ = require('./utils');

function extendAction(proxyObj, target){

    for (var i = 2; i < arguments.length; i++) {
        var source = arguments[i];
        for (var key in source) {
            if (source.hasOwnProperty(key)) {
                target[key] = _.proxy(source[key],proxyObj);
                Event.on(proxyObj.id+'.'+key,_.proxy(source[key],proxyObj));
            }
        }
    }

    return target;
}


function Store() {}

Store.prototype = {
    get: function(name) {
        var store = this[name];
        return _.extend({},store);
    },
    set: function(name, props) {
        this[name] = props;
        Event.emit("_storeChange");
        return this.get(name);
    }
};

var storeList = new Store();

var actionsList = {};

var storeObjList = {};

function createStore(name,options) {

    var self = this;

    if( !(this instanceof createStore) ){
        self = new createStore(options);

        self.id = name;
        self._data = _.assign(options.data);
        storeList.set([self.id], self._data);

        if(options.actions){
            actionsList[self.id]  = actionsList[self.id] || {};
            actionsList[self.id] = extendAction(self,actionsList[self.id],options.actions);
        }

        storeObjList[name] = self;
    }

    return self;

}

createStore.prototype.getStore = function(){
    return storeList.get(this.id);
};

createStore.prototype.setStore = function(data,callback){
    var oldStore = this.getStore();
    storeList.set([this.id], _.assign(oldStore,data));
    if(callback) callback(this.getStore());
};

createStore.prototype.getAction = function(){
    return actionsList[this.id];
};

createStore.prototype.addAction = function(name,func){
    actionsList[this.id] = actionsList[this.id] || {};
    actionsList[this.id][name] = _.proxy(func,this);
};

createStore.prototype.reset = function(){
    storeList.set([this.id], this._data);
};

createStore.prototype.destroy = function(){
    delete storeList[this.id];
    delete actionsList[this.id];
};

// 批量绑定action
var createAction = function(name,newAction){
    actionsList[name]  = actionsList[name] || {};
    actionsList[name] = extendAction(storeObjList[name],actionsList[name],newAction);
    return actionsList[name];
};

module.exports = {
    store: function(name,options){
        if(options){
            return createStore(name,options);
        }else{
            return storeObjList[name];
        }
    },
    action: function(name,newAction){
        if(!name && !newAction){
            return actionsList;
        }else if(name && !newAction){
            return actionsList[name];
        }else {
            return createAction(name,newAction);
        }
    },
    event: Event
};
