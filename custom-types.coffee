#
# Addon for types.js to allow for creating and managing custom types.
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



# removes a key from an object and returns the key's last value
consume= ( object, key ) ->
	if (types.isObject object) and (types.isString key)
		value= object[ key ]
		delete object[ key ]
		return value



types.create= ( model ) ->

	model	= types.forceObject model
	id		= types.forceString consume model, 'id'


	class CustomType

		@id				: id
		@_types			: {}
		@_model			: {}

		@getModel		: ->
			copy= {}
			for own key, value of CustomType._model then	copy[ key ]= value
			return copy

		@exists			: ( key ) -> CustomType._model.hasOwnProperty key

		@showError		: ( text ) -> console.log id+ ': error! - '+ types.forceString text

		@isValidType	: ( key, value ) ->
			return true	if (types.typeof value) is CustomType._types[ key ]
			return CustomType.showError 'type mismatch for key: "'+ key+ '", the given value is of type: '+ (types.typeof value)+ ', but it should be of type: '+ CustomType._types[key]+ '!'

		@_addGetSet: ( key, value ) ->
			if (not @[key]) and (CustomType.isValidType key, value)
				Object.defineProperty @, key,
					set: ( value ) =>	@SET key, value
					get: => @_keys[ key ]


		constructor: ( object ) ->
			object	= types.forceObject object
			@_keys	= {}
			@LOCKED	= []

			for key, value of (types.forceObject CustomType._model) # then do (key, value) =>
				CustomType._addGetSet.call @, key, value
				if (object.hasOwnProperty key) and (CustomType.isValidType key, object[key])
					@SET key, object[key]
				else @_keys[ key ]= value


		IS_LOCKED: ( key ) -> ~@LOCKED.indexOf key

		LOCK		: ( keys... ) ->
			for key in types.intoArray keys
				if (CustomType.exists key) then @LOCKED.push key

		UNLOCK	: ( keys... ) ->
			for key in types.intoArray keys
				if CustomType.exists key
					index= @LOCKED.indexOf key
					@LOCKED.splice index, 1


		# accept both objects and key:value pairs
		SET: ( object, value ) ->

			setValue= ( key, value ) =>
				if CustomType.exists key
					if (@IS_LOCKED key) then return CustomType.showError 'cannot set field "'+ key+ '" to: "'+ value+ '", "'+ key+ '" is locked!'
					else if (CustomType.isValidType key, value) then @_keys[ key ]= value
				else CustomType.showError 'cannot set value for key: "'+ key+ '", as it doesn\'t exist in the model!'

			if types.isObject object
				for own key, value of types.forceObject object
					setValue key, value
			else if types.isString object
				setValue object, value


	for key, value of model
		CustomType._types[ key ]= types.typeof value
		CustomType._model[ key ]= value

	return CustomType


module.exports= types