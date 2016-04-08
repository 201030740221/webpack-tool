var assert = require('assert');
var liteFlux = require('../index.js');
var state1 = {
	name: "tom",
	array: [
		{
			"title": "title1",
			"desc": "desc"
		},
		{
			"title": "title2",
			"desc": "desc"
		}
	]
};

var state2 = {
	name: "joy",
	array: [
		{
			"title": "title1",
			"desc": "desc"
		},
		{
			"title": "title2",
			"desc": "desc"
		}
	]
};

var state3 = {
	data: [],
    type: 0,
    size: 10,
    currentPage: 1,
    lastPage: 1,
    itemCheck: false,
    keywords:{
        title:'',
        status: -1,
        category_id: 0
    },
    isSearch: false
};

var state4 = {
	data: [
		{
			"title": "title1",
			"desc": "desc"
		},
		{
			"title": "title2",
			"desc": "desc"
		}
	],
    type: 0,
    size: 10,
    currentPage: 1,
    lastPage: 16,
    itemCheck: false,
    keywords:{
        title:'',
        status: -1,
        category_id: 0
    },
    isSearch: false
};

var data3 = {
	currentPage: 1,
	lastPage: 16,
	data:[
		{
			"title": "title1",
			"desc": "desc"
		},
		{
			"title": "title2",
			"desc": "desc"
		}
	]
};

describe("Store 测试", function() {

	var store1,store2,store3,store4;


	it("创建一个 store，应该包含ID", function() {
		store1 = liteFlux.store("store1",{
			data: state1
		});

		return assert.equal( store1.id, "store1" );
	});

	it("创建一个 store，传入state", function() {
		store2 = liteFlux.store("store2",{
			data: state1
		});

		return assert.deepEqual( liteFlux.store("store2").getStore(), state1 );
	});


	it("不能直接修改 store 的数据", function() {

		store3 = liteFlux.store("store3",{
			data: state1
		});

		var data1 = store3.getStore();
		data1.name = "joy";
		return assert.deepEqual( store3.getStore(), state1 );
	});

	it("通过setStore接口修改 store 的数据", function() {

		store4 = liteFlux.store("store4",{
			data: state3
		});

		//var data1 = store4.getStore();
		//data1.name = "joy";
		store4.setStore(data3);
		return assert.deepEqual( store4.getStore(), state4 );
	});

	it("重置store数据", function() {

		store5 = liteFlux.store("store5",{
			data: state3
		});

		store5.setStore(data3);
		store5.reset();
		return assert.deepEqual( store5.getStore(), state3 );
	});

	it("注销store", function() {

		store6 = liteFlux.store("store6",{
			data: state3
		});

		store6.destroy();
		return assert.deepEqual( store6.getStore(), {} );
	});


});


describe("Action 测试", function() {

	it("直接创建 Action", function(){

		var store5 = liteFlux.store("store5",{
			data: state1,
			actions: {
				changeName: function(){
					return this.getStore();
				}
			}
		});

		return assert.deepEqual( store5.getAction().changeName(), state1 );
	});

	it("间接创建 Action", function(){

		var store6 = liteFlux.store("store6",{
			data: state1
		});

		store6.addAction('changeTime', function(){
			return this.getStore();
		});

		return assert.deepEqual( store6.getAction().changeTime(), state1 );
	});

	it("通过liteFlux对象 创建 Action", function(){

		var store6 = liteFlux.store("store6",{
			data: state1
		});

		liteFlux.action("store6",{
			changeTime2:function(){
				return this.getStore();
			}
		});

		return assert.deepEqual( liteFlux.action("store6").changeTime2(), state1 );
	});

	it("通过liteFlux获得所有的Action", function(){
		return assert.deepEqual( liteFlux.action("store6").changeTime(), state1 );
	});

	it("通过事件操作 Action", function(){

		var tmp7;

		var store7 = liteFlux.store("store7",{
			data: state1,
			actions: {
				changeName2: function(){
					tmp7 = this.getStore();
				}
			}
		});

		liteFlux.event.emit("store7.changeName2");

		return assert.deepEqual( tmp7, state1 );
	});

});


var React = require('react');
var TestUtils = require('react/lib/ReactTestUtils');
var expect = require('expect');

describe("Mixin 测试", function() {

	it("双向绑定状态", function(){

		var Event = liteFlux.event;

		var store8 = liteFlux.store("store8",{
			data: state1,
			actions: {
				realChangeName: function(name){
					var store = this.getStore();
					store.name = name;
					this.setStore(store);
				}
			}
		});

		var App = React.createClass({
			mixins:[liteFlux.mixins.storeMixin('store8')],
			changeName: function(name){
				//liteFlux.action.store8.realChangeName("mary");
				Event.emit("store8.realChangeName", "mary");
			},
			render: function() {
				return (
					<div>dddddddd</div>
				);
			}

		});

		var app = TestUtils.renderIntoDocument(<App />);

		expect(app).actual.changeName();

		assert.equal(expect(app).actual.state.store8.name, store8.getStore().name);

	});


});


describe("数据校验", function() {

	it("校验单条的数据", function(){

		var Validator = liteFlux.validator;

		var store9 = liteFlux.store("store8",{
			data: {
					form: {
				    	username: '1',
				    	password: '',
				    	email: ''
			  		},
			  		fieldError: {
				    	form: {
				    		username: ['', '']
				    	}
			  		}
				}
		});

		var validatorTest = Validator(store9,{
			'form.username':{
				required: true,
				minLength: 4,
				maxLength: 10,
				phone: '',
				message: {
					required: "不能为空",
					minLength: "用户名最小长度不能小于4位",
					maxLength: "用户名最大长度不能大于10位",
					phone: "用户名不是一个手机号"
				}
			},
			'form.password':{
				required: true,
				message: {
					required: "不能为空"
				}
			}
		},{
			//oneError: true
		});

		validatorTest.valid('form.username');

		return assert.deepEqual( {
			form: {
				username: '1',
				password: '',
				email: ''
			},
			fieldError: {
				form: {
					username: ['用户名最小长度不能小于4位', '用户名不是一个手机号'],
				}
			}
		}, store9.getStore() );

	});

	it("校验全部的数据", function(){

		var Validator = liteFlux.validator;

		var store9 = liteFlux.store("store8",{
			data: {
					form: {
				    	username: '1',
				    	password: '',
				    	email: ''
			  		},
			  		fieldError: {
				    	form: {
				    		username: ['', '']
				    	}
			  		}
				}
		});

		var validatorTest = Validator(store9,{
			'form.username':{
				required: true,
				minLength: 4,
				maxLength: 10,
				phone: '',
				message: {
					required: "不能为空",
					minLength: "用户名最小长度不能小于4位",
					maxLength: "用户名最大长度不能大于10位",
					phone: "用户名不是一个手机号"
				}
			},
			'form.password':{
				required: true,
				message: {
					required: "不能为空"
				}
			}
		},{
			//oneError: true
		});

		validatorTest.valid();

		return assert.deepEqual( {
			form: {
				username: '1',
				password: '',
				email: ''
			},
			fieldError: {
				form: {
					username: ['用户名最小长度不能小于4位', '用户名不是一个手机号'],
					password:['不能为空']
				}
			}
		}, store9.getStore() );

		//validatorTest.valid('form.username');

		//validatorTest.fieldErrors();

	});

	it("校验返回的错误信息", function(){

		var Validator = liteFlux.validator;

		var store9 = liteFlux.store("store8",{
			data: {
					form: {
				    	username: '1',
				    	password: '',
				    	email: ''
			  		},
			  		fieldError: {
				    	form: {
				    		username: ['', '']
				    	}
			  		}
				}
		});

		var validatorTest = Validator(store9,{
			'form.username':{
				required: true,
				minLength: 4,
				maxLength: 10,
				phone: '',
				message: {
					required: "不能为空",
					minLength: "用户名最小长度不能小于4位",
					maxLength: "用户名最大长度不能大于10位",
					phone: "用户名不是一个手机号"
				}
			},
			'form.password':{
				required: true,
				message: {
					required: "不能为空"
				}
			}
		},{
			//oneError: true
		});

		validatorTest.valid();

		return assert.deepEqual( {
			form: {
				username: ['用户名最小长度不能小于4位', '用户名不是一个手机号'],
				password:['不能为空']
			}
		}, validatorTest.fieldErrors );

	});

	it("自定义校验方法", function(){

		var Validator = liteFlux.validator;

		var store9 = liteFlux.store("store8",{
			data: {
					form: {
				    	username: '111111',
				    	password: '',
				    	email: ''
			  		},
			  		fieldError: {
				    	form: {
				    		username: ['', '']
				    	}
			  		}
				}
		});

		var validatorTest = Validator(store9,{
			'form.username':{
				required: true,
				lessThen3: '',
				message: {
					required: "不能为空",
					lessThen3: "不能少于三位"
				}
			},
			'form.password':{
				required: true,
				message: {
					required: "不能为空"
				}
			}
		},{
			//oneError: true
		});

		//自定义校验规则，在valid调用之前定义
		validatorTest.rule('lessThen3', function(val) {
			return val < 3;
		});

		validatorTest.valid(); //true || false

		return assert.deepEqual( {
			form: {
				username: ["不能少于三位"],
				password:['不能为空']
			}
		}, validatorTest.fieldErrors );

	});


});
