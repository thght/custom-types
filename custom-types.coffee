#
# Extention for types.js to create classes containing model and stores with dynamic type checking.
#
# MIT License
#
# Copyright (c) 2017 Dennis Raymondo van der Sluis
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

types= require 'types.js'

RESERVED= [ 'SET', 'GET', 'LOCK', 'UNLOCK', 'IS_LOCKED', 'LOCKED', '_KEYS' ]



types.create= ( id, model ) ->

	# allow for optional id
	if types.isString id
		model= types.forceObject model
	else model= types.forceObject id

	id= types.forceString id

	class CustomType

		@id				: id
		@_types			: {}
		@_model			: {}

		@getModel		: ->
			# protect the model
			copy= {}
			for own key, value of CustomType._model then	copy[ key ]= value
			return copy

		@has				: ( key ) -> CustomType._model.hasOwnProperty key

		@showError		: ( text ) -> console.log id+ ': error! - '+ types.forceString text

		@_isValidType	: ( key, value ) ->
			return true	if (types.typeof value) is CustomType._types[ key ]
			return CustomType.showError ' cannot apply the '+ types.typeof(value)+ ' type value: '+ value+ ' to field "'+ key+ '", the value should be of type '+ CustomType._types[ key ]

		@_addGetSet: ( key ) ->
			# only set once
			if not @[ key ]
				Object.defineProperty @, key,
					set: ( value ) =>	@SET key, value
					get: => @_KEYS[ key ]



		constructor: ( object ) ->
			object	= types.forceObject object
			@_KEYS	= {}
			@LOCKED	= []

			for key, value of types.forceObject CustomType._model
				CustomType._addGetSet.call @, key, value
				if (object.hasOwnProperty key) and (CustomType._isValidType key, object[key])
					@SET key, object[key]
				else @_KEYS[ key ]= value


		IS_LOCKED: ( key ) -> !!~@LOCKED.indexOf key

		LOCK: ( keys... ) ->
			for key in types.intoArray keys
				if (CustomType.has key) then @LOCKED.push key

		UNLOCK: ( keys... ) ->
			for key in types.intoArray keys
				if CustomType.has key
					index= @LOCKED.indexOf key
					@LOCKED.splice index, 1

		GET: ( keys... ) ->
			object= {}
			# return all keys if no arguments are given
			if keys.length < 1 then keys= Object.keys @_KEYS
			for key in types.intoArray keys
				if CustomType.has key
					object[ key ]= @_KEYS[ key ]
				else CustomType.showError 'could not get: '+ key+ ', it doesn\'t exist in the model!'
			return object


		# accept both objects and key:value pairs
		SET: ( object, value ) ->

			setValue= ( key, value ) =>
				if CustomType.has key
					if (@IS_LOCKED key) then return CustomType.showError 'cannot set field "'+ key+ '" to: "'+ value+ '", "'+ key+ '" is locked!'
					else if (CustomType._isValidType key, value) then @_KEYS[ key ]= value
				else CustomType.showError 'cannot set value for key: "'+ key+ '", it doesn\'t exist in the model!'

			if types.isObject object
				for own key, value of types.forceObject object
					setValue key, value
			else if types.isString object
				setValue object, value


	for own key, value of model
		if key in RESERVED
			CustomType.showError '"'+ key+ '" is a reserved word and cannot be used in a model'
			continue
		CustomType._types[ key ]= types.typeof value
		CustomType._model[ key ]= value

	return CustomType


module.exports= types