// Generated by CoffeeScript 1.6.3
(function() {
  this.Arrows = (function() {
    function Arrows(_opts) {
      this.options = _opts;
      this.two = this.options.two;
      this._init();
    }

    Arrows.prototype._group = function() {
      if (this.group) {
        return this.group;
      }
      this.group = this.two.makeGroup();
      this.group.translation.set(this.two.width / 2, this.two.height / 2);
      return this.group;
    };

    Arrows.prototype._init = function() {
      var count, dr, models,
        _this = this;
      count = this.options.count || 10;
      dr = Math.PI * 2 / count;
      models = _.map(_.range(count), function(i) {
        return new Backbone.Model({
          polygon: _this._initArrow(dr * i)
        });
      });
      this.arrows = new Backbone.Collection(models);
      this._group().fill = this.options.color || '#51EE98';
      return this._group().noStroke();
    };

    Arrows.prototype._initArrow = function(rotation) {
      var points, polygon;
      points = [new Two.Anchor(0, 15), new Two.Anchor(10, 0), new Two.Anchor(-10, 0)];
      polygon = new Two.Polygon(points, false, false);
      if (rotation) {
        polygon.rotation = rotation;
      }
      polygon.addTo(this._group());
      return polygon;
    };

    Arrows.prototype.polygons = function() {
      return this.arrows.map(function(model) {
        return model.get('polygon');
      });
    };

    return Arrows;

  })();

  this.ArrowsOperations = (function() {
    function ArrowsOperations(opts) {
      this.options = opts;
    }

    ArrowsOperations.prototype.target = function() {
      return this.options.target || this.options.circle_closer;
    };

    ArrowsOperations.prototype.hide = function() {
      return this.target().group.opacity = 0;
    };

    ArrowsOperations.prototype.show = function() {
      return this.target().group.opacity = 1;
    };

    ArrowsOperations.prototype.reset = function() {
      return _.each(this.target().polygons(), function(polygon) {
        polygon.translation.set(0, 0);
        return polygon.scale = 1.5;
      });
    };

    ArrowsOperations.prototype.move_out = function(opts) {
      var radius, total_duration;
      this.hide();
      this.reset();
      radius = 1000;
      total_duration = 2000;
      _.map(this.target().polygons(), function(polygon) {
        var angle, x, y;
        angle = polygon.rotation;
        x = -Math.sin(angle) * (radius + angle * opts.spirality || 0);
        y = Math.cos(angle) * (radius + angle * opts.spirality || 0);
        return new TWEEN.Tween(polygon.translation).to({
          x: x,
          y: y
        }, total_duration).easing(TWEEN.Easing.Linear.None).start().onStart(function() {
          return new TWEEN.Tween(polygon).to({
            scale: 3
          }, total_duration * 0.1).easing(TWEEN.Easing.Linear.None).start().onComplete(function() {
            return new TWEEN.Tween(polygon).to({
              scale: 0
            }, total_duration * 0.7).easing(TWEEN.Easing.Linear.None).start();
          });
        });
      });
      new TWEEN.Tween(this.target().group).to({
        rotation: Math.PI * Math.random() * 1.5
      }, total_duration).start();
      return this.show();
    };

    return ArrowsOperations;

  })();

}).call(this);
