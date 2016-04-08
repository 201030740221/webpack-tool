var _ = require('./utils');

var rules = {
    name: function(val) {
        return /^[\u4e00-\u9fa5]{1,10}[·.]{0,1}[\u4e00-\u9fa5]{1,10}$/.test(val);
    },
    username: function(val) {
        return /^[a-zA-Z][\w+]{3,16}$/.test(val);
    },
    password: function(val) {
        return /^[\@A-Za-z0-9\!\#\$\%\^\&\*\.\~]{6,22}$/.test(val);
    },
    phone: function(val) {
        return /^(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$/.test(val);
    },
    tel: function(val) {
        return /^\d{3}-\d{7,8}|\d{4}-\d{7,8}|(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$/.test(val);
    },
    date: function(val) {
        return /^[1-2][0-9][0-9][0-9]-[0-1]{0,1}[0-9]-[0-3]{0,1}[0-9]$/.test(val);
    },
    email: function(val) {
        return /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/.test(val);
    },
    url: function(val){
        return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(val);
    },
    // 可带小数点的数字
    number: function(val){
        return /^(?:-?\d+|-?\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(val);
    },
    // 不带小数点的数字
    digits: function(val){
        return /^\d+$/.test(val);
    },
    minLength: function(val, length) {
        return val.length >= length;
    },
    maxLength: function(val, length) {
        return val.length <= length;
    },
    equal: function(val1, val2) {
        return val1 === val2;
    },
    required: function(val) {
        return val.length > 0;
    },
    regex: function(val, reg) {
        var re = new RegExp(reg);
        return re.test(val);
    }
};

var Validator = function(store, ruleList, options) {
    if (!(this instanceof Validator)) {
        return new Validator(store, ruleList, options || {});
    }

    this.store = store;
    this.rules = rules;
    this.ruleList = ruleList;
    this.options = options || {};
    this.fieldErrors = {};

};

Validator.prototype.valid = function(path) {

    var self = this;
    var success = true;


    // 验证数据方法
    var validate = function(path){
        //获取path对应的校验规则
        var ruleObj = self.ruleList[path];
        var messageInfo = [];

        //获取path对应的值
        var pathArr = path.split('\.');
        var val = _.extend({}, self.store.getStore());

        for (var i in pathArr) {
            val = val[pathArr[i]];
        }

        var ruleNameList = _.keys(ruleObj).filter(function(ruleName) {
            return ruleName !== 'message';
        });

        for (var j = 0, len = ruleNameList.length; j < len; j++) {
            var ruleName = ruleNameList[j];
            var ruleValue = ruleObj[ruleName];

            //如果不是必填项，当值为空字时，不校验
            if (ruleName !== 'required' && val === '') {
                continue;
            }

            if (typeof(ruleName) === 'undefined') {
                throw new Error(path + ':' + ruleName + ' can not find.');
            }

            var result = self.rules[ruleName](val,ruleValue);

            if(!result){
                success = false;
                var vaildMsg = (ruleObj.message || {})[ruleName];
                if(!vaildMsg){
                    // 没有错误信息
                }

                messageInfo.push( vaildMsg || '' );

                // 只显示一个错误
                if( self.options.oneError && self.options.oneError!==false){
                    break;
                }
            }

        }

        // 更新错误信息

        var _fieldErrors = self.fieldErrors;
        for(var k in pathArr){
            if(k == pathArr.length-1){
                _fieldErrors[pathArr[k]] = messageInfo;
            }else{
                _fieldErrors[pathArr[k]] = _fieldErrors[pathArr[k]] || {};
            }
            _fieldErrors = _fieldErrors[pathArr[k]];
        }

    };


    // 检测单条信息
    if(typeof path !== "undefined"){
        if(this.ruleList[path]){
            validate(path);
        } else {
            throw new Error('can not find match path.');
        }
    } else {
        // 检测全部信息
        _.keys(this.ruleList).forEach(function(path){
            validate(path);
        });
    }


    // 更新store的错误信息
    var store = this.store.getStore();
    store.fieldError = this.fieldErrors;
    this.store.setStore(store);

    return success;

};

// 增加校验条件
Validator.prototype.rule = function(name,fn){
    rules[name] = fn;
};

module.exports = Validator;
