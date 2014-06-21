// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.TwoApp = (function() {
    function TwoApp(_opts) {
      this._mouseMove = __bind(this._mouseMove, this);
      this._keyDown = __bind(this._keyDown, this);
      this.options = _opts;
      this.init();
    }

    TwoApp.prototype.init = function() {
      this.two = new Two({
        autostart: true,
        fullscreen: true,
        type: Two.Types.svg
      }).appendTo(document.body);
      $(window).on('resize', this._resize).on('keydown', this._keyDown).mousemove(this._mouseMove);
      this._initScene();
      return this._initOperations();
    };

    TwoApp.prototype._initScene = function() {
      this._initBG();
      this._initStripes();
      this._initCircles();
      return this._initLetterbox();
    };

    TwoApp.prototype._initBG = function() {
      var bg;
      bg = this.two.makeRectangle(this.two.width / 2, this.two.height / 2, this.two.width, this.two.height);
      bg.fill = '#000000';
      bg.noStroke();
      return this.two.add(bg);
    };

    TwoApp.prototype._initStripes = function() {
      return this.stripes = [
        new StripeRain({
          two: this.two,
          translation: new Two.Vector(-this.two.width / 2, 0),
          rotation: -0.3,
          shadowOffset: 22
        }), new StripeRain({
          two: this.two,
          translation: new Two.Vector(this.two.width / 2, 0),
          rotation: 0.3 + Math.PI,
          shadowOffset: -22
        })
      ];
    };

    TwoApp.prototype._initCircles = function() {
      var amount, circle, distance, last, min_dimension, points, radius;
      min_dimension = _.min([this.two.width, this.two.height]);
      amount = 25;
      last = amount - 1;
      radius = min_dimension * 0.33;
      distance = this.two.height / 6;
      points = _.map(_.range(amount), function(i) {
        var pct, theta, x, y;
        pct = i / last;
        theta = pct * Math.PI + Math.PI * 0.25;
        x = radius * Math.cos(theta);
        y = radius * Math.sin(theta);
        return new Two.Anchor(x, y);
      });
      circle = new Two.Polygon(points, false, true);
      circle.fill = '#BF00A5';
      circle.noStroke();
      circle.opacity = 0.8;
      circle.translation.set(this.two.width / 2, this.two.height / 2);
      return this.two.add(circle);
    };

    TwoApp.prototype._initLetterbox = function() {
      var bar, fatness;
      fatness = this.two.height * 0.1;
      bar = this.two.makeRectangle(this.two.width / 2, fatness / 2, this.two.width, fatness);
      bar.fill = '#000000';
      bar.noStroke();
      this.two.add(bar);
      bar = this.two.makeRectangle(this.two.width / 2, this.two.height - fatness / 2, this.two.width, fatness);
      bar.fill = '#000000';
      bar.noStroke();
      return this.two.add(bar);
    };

    TwoApp.prototype._initOperations = function() {
      var _this = this;
      this.operations = new Backbone.Collection([]);
      this.two.bind('update', function(frameCount) {
        return _this.operations.each(function(op) {
          return op.update();
        });
      });
      return this.operations.on('change:alive', function(op) {
        return _this.operations.remove(op);
      });
    };

    TwoApp.prototype._resize = function() {
      if (!this.two) {
        return;
      }
      this.two.renderer.setSize($(window).width(), $(window).height());
      this.two.width = this.two.renderer.width;
      return this.two.height = this.two.renderer.height;
    };

    TwoApp.prototype._keyDown = function(e) {
      var _ref;
      if (e.metaKey || e.ctrlKey) {
        return;
      }
      e.preventDefault();
      if (e.keyCode === 32) {
        this.running = (_ref = this.running === false) != null ? _ref : {
          "true": false
        };
        if (this.running) {
          return this.two.play();
        } else {
          return this.two.pause();
        }
      }
    };

    TwoApp.prototype._mouseMove = function(event) {
      var all_particles, v;
      if (this.lastMouseX && this.lastMouseY && this.operations.length < 20) {
        v = new Two.Vector(event.pageX - this.lastMouseX, event.pageY - this.lastMouseY);
        all_particles = _.flatten(_.map(this.stripes, function(stripe) {
          return stripe.getAllParticles();
        }));
        this.operations.add(new WiggleOperation({
          particles: all_particles,
          strength: v.length() * 0.03
        }));
      }
      this.lastMouseX = event.pageX;
      return this.lastMouseY = event.pageY;
    };

    return TwoApp;

  })();

}).call(this);
