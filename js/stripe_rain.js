// Generated by CoffeeScript 1.6.3
(function() {
  var Stripe, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Stripe = (function(_super) {
    __extends(Stripe, _super);

    function Stripe() {
      _ref = Stripe.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Stripe.prototype._isDead = function() {
      return this.get('particle').translation.y > this.get('height') * 2;
    };

    Stripe.prototype.update = function() {
      this.get('particle').translation.addSelf(new Two.Vector(0, 20));
      if (this._isDead()) {
        return this.set({
          alive: false
        });
      }
    };

    return Stripe;

  })(Backbone.Model);

  this.StripeRain = (function() {
    function StripeRain(_opts) {
      var _base;
      this.options = _opts;
      this.two = this.options.two;
      (_base = this.options).rotation || (_base.rotation = 0);
      this._init();
    }

    StripeRain.prototype.getPos = function() {
      var pos;
      this.maxPos || (this.maxPos = _.max([this.two.width, this.two.height]));
      return pos = (Math.random() - 0.5) * this.maxPos;
    };

    StripeRain.prototype.getSize = function() {
      var size;
      this.minSize || (this.minSize = Math.sqrt(Math.pow(this.two.width, 2), Math.pow(this.two.height, 2)));
      return size = this.minSize + Math.random() * 500;
    };

    StripeRain.prototype.getFatness = function() {
      return 25;
    };

    StripeRain.prototype.getNewStripeData = function() {
      var size;
      size = this.getSize();
      return {
        x: this.getPos(),
        y: -size,
        width: this.getFatness(),
        height: size
      };
    };

    StripeRain.prototype.addOne = function() {
      return this.stripes.add(new Stripe(this.getNewStripeData()));
    };

    StripeRain.prototype.addSome = function() {
      if (this.stripes.length < 30) {
        this.addOne();
        return this.addOne();
      }
    };

    StripeRain.prototype.getAllParticles = function() {
      return this.stripes.map(function(stripe) {
        return stripe.get('particle');
      });
    };

    StripeRain.prototype._init = function() {
      var _this = this;
      this.stripes = new Backbone.Collection([]);
      this.stripes.on('add', this._added, this);
      this.stripes.on('remove', this.addSome, this);
      this.stripes.on('remove', function(stripe) {
        return _this.group.remove(stripe.get('particle'));
      });
      this.stripes.on('change:alive', this._onAliveChange, this);
      this.two.bind('update', this._update, this);
      this.group = this.two.makeGroup();
      this.group.translation.set(this.two.width / 2, this.two.height / 2);
      if (this.options.rotation) {
        this.group.rotation = this.options.rotation;
      }
      return this.addOne();
    };

    StripeRain.prototype._update = function(frameCount) {
      return this.stripes.each(function(stripe, col) {
        return stripe.update();
      });
    };

    StripeRain.prototype._added = function(obj) {
      var group, h, rect, w;
      group = new Two.Group();
      w = obj.get('width');
      h = obj.get('height');
      rect = this.two.makeRectangle(w * 2.8, 0, w, h);
      rect.fill = 'rgba(0, 0, 0, 0.3)';
      rect.addTo(group);
      rect = this.two.makeRectangle(0, 0, w, h);
      rect.fill = '#54EBFA';
      rect.addTo(group);
      rect = this.two.makeRectangle(w - 1, 0, w, h);
      rect.fill = '#FFFFFF';
      rect.addTo(group);
      rect = this.two.makeRectangle(w + w - 1, 0, w, h);
      rect.fill = '#FD031D';
      rect.addTo(group);
      group.translation.addSelf(new Two.Vector(obj.get('x'), obj.get('y')));
      group.noStroke();
      group.addTo(this.group);
      return obj.set({
        particle: group
      });
    };

    StripeRain.prototype._onAliveChange = function(stripe, value, data) {
      if (value === false) {
        stripe.set($.extend(this.getNewStripeData(), {
          alive: true
        }));
      }
      if (value === true) {
        stripe.get('particle').translation.set(stripe.get('x'), stripe.get('y'));
      }
      if (value === false) {
        return this.addSome();
      }
    };

    return StripeRain;

  })();

}).call(this);
