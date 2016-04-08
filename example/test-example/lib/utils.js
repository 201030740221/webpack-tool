exports.guid = function(prefix) {
    prefix = prefix || "store-";
    return (prefix + Math.random() + Math.random()).replace(/0\./g, "");
};

exports.proxy = function(func,target){
    return (function(){
        return func.apply(target,arguments);
    });
};

exports.extend = function(target) {
    for (var i = 1; i < arguments.length; i++) {
        var source = arguments[i];

        for (var key in source) {
            if (source.hasOwnProperty(key)) {
                target[key] = source[key];
            }
        }
    }

    return target;
};


function ToObject(val) {
	if (val === null) {
		throw new TypeError('Object.assign cannot be called with null or undefined');
	}

	return Object(val);
}

exports.assign = Object.assign || function (target) {
	var from;
	var keys;
	var to = ToObject(target);

	for (var s = 1; s < arguments.length; s++) {
		from = arguments[s];
		keys = Object.keys(Object(from));

		for (var i = 0; i < keys.length; i++) {
			to[keys[i]] = from[keys[i]];
		}
	}

	return to;
};

exports.keys = function (obj) {
  var keyArr = [];
  obj = obj || {};

  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      keyArr.push(key);
    }
  }

  return keyArr;
};
