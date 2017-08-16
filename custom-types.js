// Generated by CoffeeScript 2.0.0-beta2
(function() {
  var consume, types,
    hasProp = {}.hasOwnProperty;

  types = require('types.js');

  consume = function(object, key) {
    var value;
    if ((types.isObject(object)) && (types.isString(key))) {
      value = object[key];
      delete object[key];
      return value;
    }
  };

  types.create = function(model) {
    var CustomType, id, key, value;
    model = types.forceObject(model);
    id = types.forceString(consume(model, 'id'));
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

        static exists(key) {
          return CustomType._model.hasOwnProperty(key);
        }

        static showError(text) {
          return console.log(id + ': error! - ' + types.forceString(text));
        }

        static isValidType(key, value) {
          if ((types.typeof(value)) === CustomType._types[key]) {
            return true;
          }
          return CustomType.showError('type mismatch for key: "' + key + '", the given value is of type: ' + (types.typeof(value)) + ', but it should be of type: ' + CustomType._types[key] + '!');
        }

        static _addGetSet(key, value) {
          if ((!this[key]) && (CustomType.isValidType(key, value))) {
            return Object.defineProperty(this, key, {
              set: (value) => {
                return this.SET(key, value);
              },
              get: () => {
                return this._keys[key];
              }
            });
          }
        }

        constructor(object) {
          var key, ref, value;
          object = types.forceObject(object);
          this._keys = {};
          this.LOCKED = [];
          ref = types.forceObject(CustomType._model);
          for (key in ref) {
            value = ref[key];
            CustomType._addGetSet.call(this, key, value);
            if ((object.hasOwnProperty(key)) && (CustomType.isValidType(key, object[key]))) {
              this.SET(key, object[key]);
            } else {
              this._keys[key] = value;
            }
          }
        }

        IS_LOCKED(key) {
          return ~this.LOCKED.indexOf(key);
        }

        LOCK(...keys) {
          var i, key, len, ref, results;
          ref = types.intoArray(keys);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            key = ref[i];
            if (CustomType.exists(key)) {
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
            if (CustomType.exists(key)) {
              index = this.LOCKED.indexOf(key);
              results.push(this.LOCKED.splice(index, 1));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }

        SET(object, value) {
          var key, ref, results, setValue;
          setValue = (key, value) => {
            if (CustomType.exists(key)) {
              if (this.IS_LOCKED(key)) {
                return CustomType.showError('cannot set field "' + key + '" to: "' + value + '", "' + key + '" is locked!');
              } else if (CustomType.isValidType(key, value)) {
                return this._keys[key] = value;
              }
            } else {
              return CustomType.showError('cannot set value for key: "' + key + '", as it doesn\'t exist in the model!');
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

      };

      CustomType.id = id;

      CustomType._types = {};

      CustomType._model = {};

      return CustomType;

    })();
    for (key in model) {
      value = model[key];
      CustomType._types[key] = types.typeof(value);
      CustomType._model[key] = value;
    }
    return CustomType;
  };

  module.exports = types;

}).call(this);
