# lite-flux
** A small and simple flux library for react app **

===

## 如何安装

```
npm install lite-flux --save

```

## 创建 store 与 action

> 与所有的 flux 框架一样，可以创建 store,action，通过事件进行数据的单向流动。liteFlux 实现更便捷的开发体验，简化了 flux 的流程与 api

```javascript

var liteFlux = require('lite-flux');

// 创建名为store1的store,顺便创建相应操作store的action
var store1 = liteFlux.store("store1",{
	data: {
		name: "tom"
	},
	actions: {
		getName: function(){
			// 获取 store
			console.log(this.getStore());
		},
		setName: function(){
			// 修改 store
			var data = this.getStore();
			data.name = "mary";
			this.setStore(data);
		}
	}
});

// 新增一个action
store1.addAction('changeNameAgain', function(){
	...
});

// 获取store
liteFlux.store("store1").getStore();

// 修改store
liteFlux.store("store1").setStore({
	name: "haha"
});

// 重置 store
liteFlux.store("store1").reset();

// 注销store
liteFlux.store("store1").destroy();

// 触发action
store1.getAction().getName();
liteFlux.action("store1").getName();
liteFlux.event.emit("store1.getName");

// 你也可以这样创建action
liteFlux.action("store1",{
	getName: function(){
		// 获取 store
		console.log(this.getStore());
	},
	setName: function(){
		// 修改 store
		var data = this.getStore();
		data.name = "mary";
		this.setStore(data);
	}
})


```

## 把组件的 state 与 store 绑定

> 通过 store 管理组件间的状态，通过监听 store 实现修改 store的同时，state 也会作相应的改变

```javascript

var liteFlux = require('lite-flux');
var React = require('react');

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
		Event.emit("store8.realChangeName", "mary");
	},
	render: function() {
		return (
			<div>dddddddd</div>
		);
	}
});

```

## 使用 linkedStoreMixin 实现双向绑定

> 在React里面，数据流是一个方向的。但是，有很多应用需要你读取一些数据，然后传回给你的程序，比如表单，我们常规的方法是绑定一个 onChange 方法监听再修改 state，表单一多，这样的写法就不好看了。这时，使用 linkedStoreMixin 就可以实现 store 与 表单之间的双向绑定。（如果想实现 state 与表单之间的双向绑定参考官方的React.addons.LinkedStateMixin）

```javascript

//假设对应 store 可能是这样的,store 名字为 hello
{
    tom: {
        message: "xxx"    
    }
}
// 如此绑定
var WithLink = React.createClass({
  mixins: [liteFlux.mixins.linkedStoreMixin],
  render: function() {
  // 是的，通过.绑定深层的对象
    return <input type="text" valueLink={this.linkStore('hello','tom.message')} />;
  }
});

```

## 使用 liteFlux.validator 实现不与 UI 绑定的数据校验

> 在数据层进行数据校验，更多直观高效。内置了一些常见的验证类型，可自定义验证类型。

```javascript

// 内置可验证类型如下：
// name() 用户名
// username() 用户名
// password() 密码
// phone() 手机
// tel() 电话
// date() 日期
// email() 电子邮件
// url() 网址
// number() 可带小数点的数字
// digits() 不带小数点的数字
// minLength(length) 最小长度
// maxLength(length) 最大长度
// equal(val) 相等
// required() 必须
// regex(reg) 添加正则

var Validator = liteFlux.validator;

var store2 = liteFlux.store("store2",{
	data: {
		form: {
			username: '111111',
			password: '',
			email: ''
		},
		fieldError: {
			form: {
				  username: ['', ''] //最终的错误信息会保存成数组放置在这里
			}
		}
	}
});

var validatorTest = Validator(store2,{
	'form.username':{
		required: true,
		lessThen3: true,
		message: {
			required: "不能为空",
			lessThen3: "不能少于三位" // 对应出错信息提示
		}
	},
	'form.password':{
		required: true,
		message: {
			required: "不能为空"
		}
	}
	},{
		//oneError: true //是否只要错了一次就中断
});

//自定义校验规则，在valid调用之前定义
validatorTest.rule('lessThen3', function(val) {
	return val < 3;
});

// 全部校检一次
validatorTest.valid(); //true || false

// 只校检单条数据
validatorTest.valid('form.username');

```
