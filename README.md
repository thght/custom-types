# custom-types
<br/>
Creates a class that holds a static data model including it's types. Every new instance of the class gets a fresh model as store. The context is frozen so the store will always mirror the model, except for it's values of course. Writing to the store(context) invokes the setter, a value will only be stored if it has the correct type, otherwise an event is triggered and a error is logged. You can lock a property, making it read-only, or unlock it again. See the examples for more.
<br/>

This tool is based upon (and returns) <a href="https://github.com/phazelift/types.js">types.js</a>. It only adds a create method to it.
<br/>

I will add to this if time allows. This is it for now, not fully tested but ready to play with.


---

**API**

The idea is that the model (including it's fields types) never changes during runtime. The store always reflects the model, except for the values.

The class method identifiers are all in UPPERCASE. This way you can use anything lowercase for model fields without having to worry about name collisions.


All reserved words in context are:
> `SET, GET, LOCK, UNLOCK, IS_LOCKED, LOCKED, _KEYS, _HANDLERS, ON, OFF`


some code examples:
```javascript

// require it
const types = require( 'custom-types' );


// create a model, this will serve both as a model and internal type reference
// the type of each key will be defined internally using types.js
const Person = types.create({
	name			: '',
	age			: 0,
	firstLogin			: new Date(0),
	active		: false,
	friends		: [],
	settings		: {},
	etc			: '...'
});

// to show the model's name as reference in error messages you can optionally
// give an id by calling .create with the id as first parameter
const Inventory = types.create( 'Inventory', {
	yourModelHere: '...'
});

// create a new instance of Person and fill in some fields
const person = new Person({
	name    : 'John',
	age     : 34,
	active  : true
});

// obviously we can use basic JS to check whether person is a Person
console.log( person instanceof Person );

// the context is frozen, you cannot and should not write to it manually
person.what= 'huh?'
console.log( person.what )
// undefined

// check if a field exists in this model
const nameExists = Person.has( 'name' );

// get a value from person
console.log( person.name );

// or all person data as an object
console.log( person.GET() );

// or just a selection of key:value pairs in an object
console.log( person.GET('name', 'age') );

// change some value
person.age = 33;

// the setter will check the type of the new value
// and rejects if it doesn't match the type in the model:
person.name = 11;
// Person: error! - cannot apply the number type value: 11 to field "name",
// the value should be of type string

// assign multiple values at once
person.SET({
	name	 : 'Lisa',
	age	  : 24,
	active   : false
});

// you can lock a field making it read-only
person.LOCK( 'name' );

// check whether it's locked
const isLocked = person.IS_LOCKED( 'name' );

// or unlock it
person.UNLOCK( 'name' );

// check which fields are locked, returns an array with field names
console.log( person.LOCKED );

// you can use your custom logger instead of the default
Person.setLogMethod( (err) => console.log('BOO!', err) );
// or disable logging
Person.setLogMethod();


// you can add your own event handlers
const onSet= ( key, value ) => console.log( 'person.'+ key+ ' was set to:', value );
person.ON( 'set', onSet );

person.name= 'Lyn'
// person.name was set to: Lyn

// remove the handler
person.OFF( 'set', onSet );

// remove all 'set' handlers at once
person.OFF( 'set' );

// other handlers
const onUnknownKey= ( key ) => console.log( 'person.'+ key+ ' is not part of this model!' );
person.ON( 'unknown-key', onUnknownKey );

// trigger the event
person.SET({
	test	: 'fail'
});

// if we would assign like this: person.test= 'fail', we cannot catch the error
// because 'test' is a non-existing property for person and therefore has no setter

// all available events are: 'unknown-key', 'type-error', 'locked' and 'set'


// get a copy of the model if needed
const personModel = Person.getModel();

// all types.js dynamic type checking features are available
console.log( types.allArray(['renders'], [true]) );

// more to come..

```
---

Your feedback and/or feature requests are welcome.

You can donate to my open-source projects with bitcoin: `1GULvHiXkkQMNiGBpUF7sVpMPgNu5Sv3mZ`

---------------------------------------------------
**0.0.3**

- adds event handlers
- adds .ON and .OFF methods to prototype
- adds ._HANDLERS private property to prototype
- adds .TYPE_ERROR, .UNKNOWN_TYPE, .LOCKED and .SET static constants
- adds ._handleEvent and ._has private static methods
- adds ._settings static property
- adds .setLogMethod static method
- static showError now using log method from static ._settings
- the create method now returns a 'frozen' class
- the constructor now freezes the context when done initializing
- some refactoring
- updates readme

---
**0.0.2**

- changes CustomType.exists -> CustomType.has
- adds .GET method
- adds some protection against overwriting class methods
- removes consume
- removes id from model
- adds optional id setting by function parameter
- adds first readme content

---
**0.0.1**

-	initial commit

---

### license

MIT
