
/*!
sarine.viewer - v0.0.13 -  Wednesday, March 25th, 2015, 4:01:39 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
 */

(function() {
  var ResourceManager, Viewer;

  Viewer = (function() {
    var error, rm;

    rm = ResourceManager.getInstance();

    function Viewer(options) {
      this.first_init_defer = $.Deferred();
      this.full_init_defer = $.Deferred();
      this.src = options.src, this.element = options.element, this.autoPlay = options.autoPlay, this.callbackPic = options.callbackPic;
      this.id = this.element[0].id;
      this.element = this.convertElement();
      Object.getOwnPropertyNames(Viewer.prototype).forEach(function(k) {
        if (this[k].name === "Error") {
          return console.error(this.id, k, "Must be implement", this);
        }
      }, this);
      this.element.data("class", this);
      this.element.on("play", function(e) {
        return $(e.target).data("class").play.apply($(e.target).data("class"), [true]);
      });
      this.element.on("stop", function(e) {
        return $(e.target).data("class").stop.apply($(e.target).data("class"), [true]);
      });
      this.element.on("cancel", function(e) {
        return $(e.target).data("class").cancel().apply($(e.target).data("class"), [true]);
      });
    }

    error = function() {
      return console.error(this.id, "must be implement");
    };

    Viewer.prototype.first_init = Error;

    Viewer.prototype.full_init = Error;

    Viewer.prototype.play = Error;

    Viewer.prototype.stop = Error;

    Viewer.prototype.convertElement = Error;

    Viewer.prototype.cancel = function() {
      return rm.cancel(this);
    };

    Viewer.prototype.loadImage = function(src) {
      return rm.loadImage.apply(this, [src]);
    };

    Viewer.prototype.setTimeout = function(delay, callback) {
      return rm.setTimeout.apply(this, [this.delay, callback]);
    };

    return Viewer;

  })();

  this.Viewer = Viewer;

  ResourceManager = (function() {
    var ImageManger, TimeoutManager, _imageManger, _instance, _timeoutManager;

    _instance = void 0;

    _timeoutManager = void 0;

    _imageManger = void 0;

    function ResourceManager() {
      console.log('new singleton');
      _timeoutManager = new TimeoutManager();
      _imageManger = new ImageManger();
    }

    ResourceManager.getInstance = function() {
      if (_instance === void 0) {
        _instance = new this();
      }
      return _instance;
    };

    ImageManger = (function() {
      function ImageManger() {}

      ImageManger.prototype.viewerImagesObj = {};

      ImageManger.prototype.loadImage = function(src, viewer, defer) {
        var img, _t;
        _t = this;
        if (this.viewerImagesObj[viewer.id] === void 0) {
          this.viewerImagesObj[viewer.id] = {
            capacity: viewer.downloadLimit || 1000,
            bag: [],
            threshhold: [],
            order: parseInt(viewer.element.data("order"))
          };
        }
        defer = defer || $.Deferred();
        img = new Image();
        img.crossOrigin = "Anonymous";
        img.onload = function(e) {
          var index, obj, popped;
          index = $.inArray(_t.viewerImagesObj[viewer.id].threshhold.filter((function(_this) {
            return function(v) {
              return v.src === e.target.src;
            };
          })(this))[0], _t.viewerImagesObj[viewer.id].threshhold);
          obj = _t.viewerImagesObj[viewer.id].threshhold[index];
          popped = _t.viewerImagesObj[viewer.id].bag.shift();
          if (popped) {
            popped.img.src = popped.src;
            _t.viewerImagesObj[viewer.id].threshhold.push(popped);
          }
          _t.viewerImagesObj[viewer.id].threshhold.splice(index, 1);
          return obj.defer.resolve(e.target);
        };
        if (this.viewerImagesObj[viewer.id].threshhold.length < this.viewerImagesObj[viewer.id].capacity) {
          this.viewerImagesObj[viewer.id].threshhold.push({
            defer: defer,
            src: src,
            img: img
          });
          img.src = src;
        } else {
          this.viewerImagesObj[viewer.id].bag.push({
            defer: defer,
            src: src,
            img: img
          });
        }
        img.onerror = function(e) {
          var index, obj;
          index = $.inArray(_t.viewerImagesObj[viewer.id].threshhold.filter((function(_this) {
            return function(v) {
              return v.src === e.target.src;
            };
          })(this))[0], _t.viewerImagesObj[viewer.id].threshhold);
          obj = _t.viewerImagesObj[viewer.id].threshhold[index];
          if (e.target.src !== viewer.callbackPic) {
            return _t.loadImage(viewer.callbackPic, viewer, defer);
          } else {
            throw new Error('callbackPic not exist');
          }
        };
        return defer;
      };

      return ImageManger;

    })();

    ResourceManager.prototype.loadImage = function(src) {
      return _imageManger.loadImage(src, this);
    };

    TimeoutManager = (function() {
      var funcArr;

      function TimeoutManager() {}

      funcArr = {};

      TimeoutManager.add = function(delay, callback, item) {
        var obj;
        if (!funcArr[delay]) {
          setTimeout(function(delay) {
            var temp, unique;
            temp = funcArr[delay];
            funcArr[delay] = void 0;
            unique = $.unique(temp.map(function(v) {
              return v.item.id;
            }));
            return temp.forEach(function(i) {
              return i.callback.apply(i.item);
            });
          }, delay, delay);
          funcArr[delay] = [];
        }
        obj = {
          callback: callback,
          item: item
        };
        if ((funcArr[delay].filter(function(v) {
          return v.item.id === obj.item.id;
        })).length === 0) {
          return funcArr[delay].push(obj);
        }
      };

      return TimeoutManager;

    })();

    ResourceManager.prototype.setTimeout = function(delay, callback) {
      return TimeoutManager.add(delay, callback, this);
    };

    return ResourceManager;

  })();

  this.ResourceManager = ResourceManager;

}).call(this);
