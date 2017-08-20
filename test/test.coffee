types     = require '../custom-types.js'
assert    = require 'assert'
chai      = require 'chai'
expect    = chai.expect
sinon     = require 'sinon'


CONTEXT_RESERVED    = [ 'SET', 'GET', 'LOCK', 'UNLOCK', 'IS_LOCKED', 'LOCKED', '_KEYS', '_HANDLERS', 'ON', 'OFF' ]
DEFAULT_LOG_PREFIX  = ': error! - "'

exampleModel=
    string        : 'string'
    number        : 11
    array         : []
    object        : {}
    boolean       : true
    date          : new Date
    _null         : null
    _undefined    : undefined
    nan           : NaN


describe 'Class', ->


  describe 'creation', ->

    it 'should return a Class with all static properties of the correct type', ->
        CustomType= types.create()

        expect( CustomType ).to.be.a 'function'
        expect( CustomType.id ).to.be.a 'string'
        expect( CustomType._types ).to.be.an 'object'
        expect( CustomType._model ).to.be.an 'object'
        expect( CustomType._settings ).to.be.an 'object'
        expect( CustomType._settings.logMethod ).to.be.a 'function'
        expect( CustomType.getModel ).to.be.a 'function'
        expect( CustomType._handleEvent ).to.be.a 'function'
        expect( CustomType.has ).to.be.a 'function'
        expect( CustomType._has ).to.be.a 'function'
        expect( CustomType.setLogMethod ).to.be.a 'function'
        expect( CustomType.showError ).to.be.a 'function'
        expect( CustomType._isValidType ).to.be.a 'function'
        expect( CustomType._addGetSet ).to.be.a 'function'

    it 'should not be possible to add or remove static properties', ->
        CustomType= types.create()
        CustomType._test_= 'testing'
        expect( CustomType._test_ ).to.be.an 'undefined'
        delete CustomType._model
        expect( CustomType._model ).to.be.an 'object'

    it 'should still be possible to change deep properties from static properties', ->
        CustomType= types.create()
        CustomType._settings.hello= 'hello'
        expect( CustomType._settings.hello ).to.equal 'hello'

    it 'should accept the first argument as static id if it is of type string', ->
        CustomType= types.create 'Dennis'
        expect( CustomType.id ).to.equal 'Dennis'

    it 'should accept the first argument as static model if it is of type object', ->
        model= hello: 'world!'
        CustomType= types.create model
        expect( CustomType._model ).to.deep.equal model

    it 'should accept the first and second arguments as id and model if given as type string and type object ', ->
        model= hello: 'world!'
        CustomType= types.create 'MyModel', model
        expect( CustomType._model ).to.deep.equal model
        expect( CustomType.id ).to.equal 'MyModel'

    it 'should not be possible to have context-reserved words in the static _model and _types objects', ->
        spy= sinon.spy console, 'log'

        for key in CONTEXT_RESERVED
            object= {}
            object[ key ]= ''
            CustomType= types.create object
            expect( CustomType._model[key] ).to.be.an 'undefined'
            expect( CustomType._types[key] ).to.be.an 'undefined'
            correctErrorLog= spy.calledWith DEFAULT_LOG_PREFIX+ key+ '" is a reserved word and cannot be used in a model'
            expect( correctErrorLog ).to.be.true;

        spy.restore()

    it 'the _types object should have the same keys and the same amount of keys as the _model object', ->
        CustomType= types.create exampleModel
        _modelKeys= Object.keys CustomType._model
        _typesKeys= Object.keys CustomType._types
        expect( _modelKeys ).to.deep.equal _typesKeys




  describe 'usage', ->

    it '.getModel() should return the model as given by creation', ->
        CustomType= types.create exampleModel
        expect( CustomType.getModel() ).to.deep.equal exampleModel

    it '.has should properly verify existence of a key in ._model ', ->
        CustomType= types.create exampleModel
        for key of exampleModel
            expect( CustomType.has(key) ).to.be.true

