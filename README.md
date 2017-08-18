# custom-types
<br/>
Creates a class that holds a static data model including it's types. Every new instance of the class gets a fresh model as store. Writing to the store(context) invokes the setter to check the type of the value. You can lock a property, making it read-only, or unlock it again.


This tool is based upon (and returns) <a href="https://github.com/phazelift/types.js">types.js</a>. It only adds a create method to it.


I will add to this if time allows. Just the base for now, not fully tested, but ready to play with.


---

**API**

The class method identifiers are all in UPPERCASE. This way you can use anything lowercase for model fields without having to worry about name collisions.

All reserved words in context: .SET, .GET, .LOCK, .UNLOCK, .IS_LOCKED, .LOCKED, ._KEYS

some code:
```javascript

// require it
const types = require( 'custom-types' );


// create a model, this will serve both as a model and internal type reference
// the type of each key will be defined internally using types.js
const Person = types.create({
	name			: '',
	age			: 0,
	firstLogin	: new Date(0),
	active		: false,
	friends		: [],
	settings		: {},
	etc			: '...'
});

// to show the model's name as reference in error messages you can optionally
// give an id by calling .create with the id as first parameter
const Person = types.create( 'Person', {
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
