// Generated by CoffeeScript 2.0.0-beta2
(function() {
  var RESERVED, types,
    hasProp = {}.hasOwnProperty,
    indexOf = [].indexOf;

  types = require('types.js');

  RESERVED = ['SET', 'GET', 'LOCK', 'UNLOCK', 'IS_LOCKED', 'LOCKED', '_KEYS', '_HANDLERS', 'ON', 'OFF'];

  types.create = function(id, model) {
    var CustomType, key, value;
    if (types.isString(id)) {
      model = types.forceObject(model);
    } else {
      model = types.forceObject(id);
    }
    id = types.forceString(id);
    CustomType = (function() {
      class CustomType {
        static getModel() {
          var copy, key, ref, value;
          copy = {};
          ref = CustomType._model;
          for (key in ref) {
            if (!hasProp.call(ref, key)) continue;
            value = ref[key];
            copy[key] = value;
          }
          return copy;
        }

        static _handleEvent(id, ...args) {
          var handler, i, len, ref, results;
          if (this._HANDLERS.hasOwnProperty(id)) {
            ref = this._HANDLERS[id];
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              handler = ref[i];
              results.push(handler.apply(null, args));
            }
            return results;
          }
        }

        static has(key) {
          return CustomType._model.hasOwnProperty(key);
        }

        static _has(key) {
          if (CustomType.has(key)) {
            return true;
          }
          CustomType.showError(key + ' doesn\'t exist in the model!');
          CustomType._handleEvent.call(this, CustomType.UNKNOWN_KEY, key);
          return false;
        }

        static setLogMethod(logMethod) {
          return CustomType._settings.logMethod = types.forceFunction(logMethod);
        }

        static showError(text) {
          return CustomType._settings.logMethod(text);
        }

        static _isValidType(key, value) {
          if ((types.typeof(value)) === CustomType._types[key]) {
            return true;
          }
          CustomType._handleEvent.call(this, CustomType.TYPE_ERROR, key, value);
          return CustomType.showError(' cannot apply the ' + types.typeof(value) + ' type value: ' + value + ' to field "' + key + '", the value should be of type ' + CustomType._types[key]);
        }

        static _addGetSet(key) {
          if (!this[key]) {
            return Object.defineProperty(this, key, {
              set: (value) => {
                return this.SET(key, value);
              },
              get: () => {
                return this._KEYS[key];
              }
            });
          }
        }

        constructor(object) {
          var key, ref, value;
          object = types.forceObject(object);
          this._KEYS = {};
          this.LOCKED = [];
          this._HANDLERS = {};
          this._HANDLERS[CustomType.UNKNOWN_KEY] = [];
          this._HANDLERS[CustomType.TYPE_ERROR] = [];
          this._HANDLERS[CustomType.LOCKED] = [];
          this._HANDLERS[CustomType.SET] = [];
          ref = types.forceObject(CustomType._model);
          for (key in ref) {
            value = ref[key];
            CustomType._addGetSet.call(this, key, value);
            if (object.hasOwnProperty(key)) {
              this.SET(key, object[key]);
            } else {
              this._KEYS[key] = value;
            }
          }
          types.forceFunction(Object.freeze)(this);
        }

        IS_LOCKED(key) {
          return !!~this.LOCKED.indexOf(key);
        }

        LOCK(...keys) {
          var i, key, len, ref, results;
          ref = types.intoArray(keys);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            key = ref[i];
            if (CustomType._has.call(this, key)) {
              results.push(this.LOCKED.push(key));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }

        UNLOCK(...keys) {
          var i, index, key, len, ref, results;
          ref = types.intoArray(keys);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            key = ref[i];
            if (CustomType._has.call(this, key)) {
              index = this.LOCKED.indexOf(key);
              results.push(this.LOCKED.splice(index, 1));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }

        GET(...keys) {
          var i, key, len, object, ref;
          object = {};
          if (keys.length < 1) {
            keys = Object.keys(this._KEYS);
          }
          ref = types.intoArray(keys);
          for (i = 0, len = ref.length; i < len; i++) {
            key = ref[i];
            if (CustomType._has.call(this, key)) {
              object[key] = this._KEYS[key];
            }
          }
          return object;
        }

        SET(object, value) {
          var key, ref, results, setValue;
          setValue = (key, value) => {
            if (CustomType._has.call(this, key)) {
              if (this.IS_LOCKED(key)) {
                CustomType.showError('cannot set field "' + key + '" to: "' + value + '", "' + key + '" is locked!');
                return CustomType._handleEvent.call(this, CustomType.LOCKED, key);
              } else if (CustomType._isValidType.call(this, key, value)) {
                this._KEYS[key] = value;
                return CustomType._handleEvent.call(this, CustomType.SET, key, value);
              }
            } else {
              return CustomType.showError('cannot set value for key: "' + key + '", it doesn\'t exist in the model!');
            }
          };
          if (types.isObject(object)) {
            ref = types.forceObject(object);
            results = [];
            for (key in ref) {
              if (!hasProp.call(ref, key)) continue;
              value = ref[key];
              results.push(setValue(key, value));
            }
            return results;
          } else if (types.isString(object)) {
            return setValue(object, value);
          }
        }

        ON(id, action) {
          if ((this._HANDLERS.hasOwnProperty(id)) && (types.isFunction(action))) {
            return this._HANDLERS[id].push(action);
          }
        }

        OFF(id, action) {
          var index;
          if (this._HANDLERS.hasOwnProperty(id)) {
            if (types.isFunction(action)) {
              index = this._HANDLERS[id].indexOf(action);
              if (index > -1) {
                return this._HANDLERS[id].splice(index, 1);
              }
            } else {
              return this._HANDLERS[id] = [];
            }
          }
        }

      };

      CustomType.UNKNOWN_KEY = 'unknown-key';

      CustomType.TYPE_ERROR = 'type-error';

      CustomType.LOCKED = 'locked';

      CustomType.SET = 'set';

      CustomType.id = id;

      CustomType._types = {};

      CustomType._model = {};

      CustomType._settings = {
        logMethod: function(text) {
          return console.log(id + ': error! - ' + types.forceString(text));
        }
      };

      return CustomType;

    })();
    for (key in model) {
      if (!hasProp.call(model, key)) continue;
      value = model[key];
      if (indexOf.call(RESERVED, key) >= 0) {
        CustomType.showError('"' + key + '" is a reserved word and cannot be used in a model');
        continue;
      }
      CustomType._types[key] = types.typeof(value);
      CustomType._model[key] = value;
    }
    types.forceFunction(Object.freeze)(CustomType);
    return CustomType;
  };

  module.exports = types;

}).call(this);
