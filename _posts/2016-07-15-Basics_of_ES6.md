---
layout: post
title: Basics of ES6
---

### Variables

* Try to use `let` instead of `var` to avoid issues like "undefined" variables.
* When you use `var`, JS does **hoisting** - moves all the variable declaration to the top.
* So if there is any `var` which is declared somewhere in the code and you try to access it before its declaration, it will be set to undefined.
* For the same case, if you use `let`, its scope is defined within that context. Referencing `let` variables elsewhere will result in error.

![My helpful screenshot]({{ site.url }}/public/images/unexpected_behavior_with_var.PNG)

* `let` variables cannot be redeclared
* `const` are read-only constants & must be assigned an initial value.

### Destructuring

* Allows you to assign variables in bulk or interchange values.

{% highlight js %}
let x = 2;
let y = 3;
//this will interchange the values
//on the LHS, its not depicting its an array, instead the list of varibles.
[x,y] = [y,x]
{% endhighlight %}


{% highlight js %}
let [x,y] = [1,2];

//if you need to skip some values
let [,x,y] = [1,2,3];

//for object literals
let x = {
  firstName: 'Ranjith',
  lastName: 'Nair'
};

//the first one in the declaration should be the object property name
let {firstName:  ownerFirstName,
    lastName: ownerLastName} = x;

//if the variable name is same, you dont need to specify that

let {firstName, lastName} = x;

{% endhighlight %}

![My helpful screenshot]({{ site.url }}/public/images/destructuring_params.PNG)


### Function Defaults

* You can use default values for parameters inside the function signature which can prevent from putting in null checks.

* The default parameters would only be set when those parameters are not at all sent.

{% highlight js %}
loadProfiles(['Roger','Nadal','Murray']);

function loadProfiles(players = []) {
  let players_length = players.length;
  //would have failed if we hadn't initialized the parameter.
}
{% endhighlight %}

#### Options Object

* Useful when passing in an object parameter.
* options parameter can be initialized to empty object within the function definition.

![My helpful screenshot]({{ site.url }}/public/images/Options_object.PNG)

#### Using Named parameters

* Can be used as a replacement for `options` object.

![My helpful screenshot]({{ site.url }}/public/images/named_parameters.PNG)

#### Arguments object

* Built in array-like object used for parameters.
* Used when there are varying number of parameters which can be passed on to the function.

![My helpful screenshot]({{ site.url }}/public/images/arguments_object.PNG)


#### Rest parameters

* Denoted by 3 dots and signifies as a pure arguments array.
* Wont break the function if a new parameter is explicitly added to the function signature.
* Must always be the last parameter.
* If the value is not sent, it will be an empty array.

![My helpful screenshot]({{ site.url }}/public/images/rest_param.PNG)

#### Spread Operator

* Split an array arguments into individual elements.
* Syntax is same as Rest parameter except the context where its applied.


![My helpful screenshot]({{ site.url }}/public/images/spread_operator.PNG)

### Template literals

* Useful for concatinating strings.

{% highlight js %}
let category = "music";
let id = "10"
let url = `http://myapiserver/${category}/${id}`;
{% endhighlight %}

### Class

* Earlier we had to create objects and use prototypes to define certain methods.
* Now we can define classes and create constructors within it.

{% highlight js %}
class Employee {
  constructor(name) {
    this.empName = name;
  }

  getEmployeeName() {
    return this.empName;
  }

  //getters and setters
  get name() {
    return this.empName;
  }

  set name(value) {
    this.empName = value;
  }
}
let e1 = new Employee("Ranjith");
console.log(e1.getEmployeeName);
//getters and setters
console.log(e1.name);
e1.name = "Ram";
{% endhighlight %}


#### Converting functions to objects

* For encapsulation, reusability and testability.
* Can be used in combination with arrow function.
* Arrow function helps a great deal in tackling with scoping issues in callback.

![My helpful screenshot]({{ site.url }}/public/images/arrow_objects.PNG)

### Iterators
{% highlight js %}
let x = [1,2,3,4,5];
let sum = 0;
let iterator = x.values();
let next = iterator.next();
while(!next.done) {
  sum += next.value;
  iterator.next();
}
{% endhighlight %}


### For of

* Used to loop over values and not keys like for in
{% highlight js %}
let x = [1,2,3,4,5];
for(let i of x) {
  console.log(i);
}
{% endhighlight %}

#### Arrow functions

* Converting a simple function to arrow functions

{% highlight js %}
var x = function(a) { return a;};
alert(x);

//Arrow function equivalent
var x = a => a;
alert(x);

//When no parameter
var x = () => {alert("testing")};
x();

//multiple arguments
// the bracket outside params is only needed when there are multiple arguments.
var x = (a,b,c) => a+b+c;
alert(x(1,2,3));

//function as parameter
setTimeout( function() {alert("2 seconds passed !");},2000);
setTimeout( () => {alert("2 seconds passed !");},2000);

// fixes the usage of "this" in callbacks

setTimeout(() => {
    //the value of this here will be same as its in outer context
})

{% endhighlight %}


<p data-height="265" data-theme-id="0" data-slug-hash="vKdOzg" data-default-tab="js" data-user="ranjithnair" data-embed-version="2" class="codepen">See the Pen <a href="http://codepen.io/ranjithnair/pen/vKdOzg/">vKdOzg</a> by Ranjith (<a href="http://codepen.io/ranjithnair">@ranjithnair</a>) on <a href="http://codepen.io">CodePen</a>.</p>
<script async src="//assets.codepen.io/assets/embed/ei.js"></script>
