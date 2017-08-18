#
# Extention for types.js to create model/store classes with dynamic type checking
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

RESERVED= [ 'SET', 'GET', 'LOCK', 'UNLOCK', 'IS_LOCKED', 'LOCKED', '_KEYS', '_HANDLERS', 'ON', 'OFF' ]




types.create= ( id, model ) ->

	# allow for optional id
	if types.isString id
		model= types.forceObject model
	else model= types.forceObject id

	id= types.forceString id


	class CustomType

		# event handler id's
		@UNKNOWN_KEY	: 'unknown-key'
		@TYPE_ERROR		: 'type-error'
		@LOCKED			: 'locked'
		@SET				: 'set'

		@id				: id
		@_types			: {}
		@_model			: {}
		@_settings		:
			logMethod		: ( text ) -> console.log id+ ': error! - '+ types.forceString text

		@getModel		: ->
			# protect the model
			copy= {}
			for own key, value of CustomType._model then	copy[ key ]= value
			return copy

		# 'hidden' static to be called with context, reducing prototype methods
		@_handleEvent	: ( id, args... ) ->
			if (@_HANDLERS.hasOwnProperty id) then for handler in @_HANDLERS[ id ]
				handler.apply null, args

		@has				: ( key ) -> CustomType._model.hasOwnProperty key

		@_has				: ( key ) ->
			return true if CustomType.has key
			CustomType.showError key+ ' doesn\'t exist in the model!'
			CustomType._handleEvent.call @, CustomType.UNKNOWN_KEY, key
			return false

		@setLogMethod	: ( logMethod ) -> CustomType._settings.logMethod= types.forceFunction logMethod
		@showError		: ( text ) -> CustomType._settings.logMethod text

		@_isValidType	: ( key, value ) ->
			return true	if (types.typeof value) is CustomType._types[ key ]
			CustomType._handleEvent.call @, CustomType.TYPE_ERROR, key, value
			CustomType.showError ' cannot apply the '+ types.typeof(value)+ ' type value: '+ value+ ' to field "'+ key+ '", the value should be of type '+ CustomType._types[ key ]

		@_addGetSet		: ( key ) ->
			# only set once
			if not @[ key ]
				Object.defineProperty @, key,
					set: ( value ) =>	@SET key, value
					get: => @_KEYS[ key ]



		constructor: ( object ) ->
			object		= types.forceObject object
			@_KEYS		= {}
			@LOCKED		= []

			@_HANDLERS	= {}
			@_HANDLERS[	CustomType.UNKNOWN_KEY ]	= []
			@_HANDLERS[	CustomType.TYPE_ERROR ]		= []
			@_HANDLERS[	CustomType.LOCKED ]			= []
			@_HANDLERS[	CustomType.SET ]				= []

			for key, value of types.forceObject CustomType._model
				CustomType._addGetSet.call @, key, value
				# use the setter for catching type errors if object has a valid key
				if (object.hasOwnProperty key) then @SET key, object[key]
				# else bypass the setter for filling in model keys
				else @_KEYS[ key ]= value

			types.forceFunction( Object.freeze ) @


		IS_LOCKED: ( key ) -> !!~@LOCKED.indexOf key

		LOCK: ( keys... ) ->
			for key in types.intoArray keys
				if (CustomType._has.call @, key) then @LOCKED.push key

		UNLOCK: ( keys... ) ->
			for key in types.intoArray keys
				if CustomType._has.call @, key
					index= @LOCKED.indexOf key
					@LOCKED.splice index, 1

		GET: ( keys... ) ->
			object= {}
			# return all keys if no arguments are given
			if keys.length < 1 then keys= Object.keys @_KEYS
			for key in types.intoArray keys
				if CustomType._has.call @, key
					object[ key ]= @_KEYS[ key ]
			return object


		# TODO: return true if successful, false when error occurred
		# accepts object or 'key','value' arguments
		SET: ( object, value ) ->

			setValue= ( key, value ) =>
				if CustomType._has.call @, key
					if @IS_LOCKED key
						CustomType.showError 'cannot set field "'+ key+ '" to: "'+ value+ '", "'+ key+ '" is locked!'
						CustomType._handleEvent.call @, CustomType.LOCKED, key
					else if (CustomType._isValidType.call @, key, value)
						@_KEYS[ key ]= value
						CustomType._handleEvent.call @, CustomType.SET, key, value
				else CustomType.showError 'cannot set value for key: "'+ key+ '", it doesn\'t exist in the model!'

			if types.isObject object
				for own key, value of types.forceObject object
					setValue key, value
			else if types.isString object then setValue object, value

		ON: ( id, action ) ->
			if (@_HANDLERS.hasOwnProperty id) and (types.isFunction action)
				@_HANDLERS[ id ].push action

		OFF: ( id, action ) ->
			if @_HANDLERS.hasOwnProperty id
				if types.isFunction action
					index= @_HANDLERS[ id ].indexOf action
					if index > -1 then @_HANDLERS[ id ].splice index, 1
				# remove all handlers for id if no action is provided
				else @_HANDLERS[ id ]= []


	for own key, value of model
		if key in RESERVED
			CustomType.showError '"'+ key+ '" is a reserved word and cannot be used in a model'
			continue
		CustomType._types[ key ]= types.typeof value
		CustomType._model[ key ]= value

	types.forceFunction( Object.freeze ) CustomType
	return CustomType


module.exports= types