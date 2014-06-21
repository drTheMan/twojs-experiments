class @CircleCloser
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  _radius: ->
    @options.radius || _.min([@two.width, @two.height])/2

  _closerWidth: ->
    # full diagonal of the scene
    Math.sqrt(Math.pow(@two.width, 2), Math.pow(@two.height, 2))*1.5

  _closerLength: ->
    # half diagonal of the scene
    @_closerWidth() / 2

  _group: ->
    return @group if @group
    @group = @two.makeGroup()
    @group.translation.set(@two.width/2, @two.height/2)
    return @group

  _init: ->
    @polygon1 = @_initPolygon()
    @polygon2 = @_initPolygon(Math.PI)
    @_group().fill = @options.color || '#000000'
    @_group().noStroke()
    # @_group().opacity = 0.8

  _initPolygon: (rotation) ->
    rotation = 0 if rotation == undefined
    min_dimension = _.min([@two.width, @two.height])
    amount = 25
    last = amount - 1
    radius = @_radius() # min_dimension * 0.33
    distance = @two.height / 6

    points = _.map _.range(amount), (i) ->
      pct = i / last
      theta = pct * Math.PI
      x = radius * Math.cos(theta)
      y = radius * Math.sin(theta)
      return new Two.Anchor(x, y)

    last = _.last(points)
    points.push(new Two.Anchor(last.x + radius - @_closerWidth()/2, last.y))
    last = _.last(points)
    points.push(new Two.Anchor(last.x, last.y + @_closerLength()))
    last = _.last(points)
    points.push(new Two.Anchor(last.x + @_closerWidth(), last.y))
    last = _.last(points)
    points.push(new Two.Anchor(last.x, last.y - @_closerLength()))
    
    polygon = new Two.Polygon(points, false, false)
    polygon.rotation = rotation
    polygon.addTo(@_group())


class @CircleCloserOperations
  constructor: (opts) ->
    @options = opts

  target: ->
    @options.target || @options.circle_closer

  open: (amount) ->
    amount = @target()._closerWidth() if amount == undefined
    @target().polygon1.translation.set(0, amount/2)
    @target().polygon2.translation.set(0, -amount/2)

  shutter: (opts) ->
    @target().group.rotation = Math.random()*Math.PI*2

    new TWEEN.Tween( @target().group )
      .to({rotation: @target().group.rotation + Math.random()*Math.PI*2}, 750)
      .easing( TWEEN.Easing.Exponential.InOut )
      .start()
      .onComplete =>
        @target().group.rotation = Math.random()*Math.PI*2
        new TWEEN.Tween( @target().group )
          .to({rotation: @target().group.rotation + Math.random()*Math.PI*2}, 750)
          .easing( TWEEN.Easing.Exponential.InOut )
          .delay(500)
          .start()
      .onStart =>
        new TWEEN.Tween( @target().polygon1.translation )
          .to( { y: -1 }, 750)
          # .easing( TWEEN.Easing.Bounce.InOut )
          .easing( TWEEN.Easing.Exponential.InOut )
          .start()
          .onComplete =>
            new TWEEN.Tween( @target().polygon1.translation )
              .to( { y: 2000 }, 750)
              .easing( TWEEN.Easing.Exponential.InOut )
              .delay(500)
              .start()

        new TWEEN.Tween( @target().polygon2.translation )
          .to( { y: 1 }, 750)
          .easing( TWEEN.Easing.Exponential.InOut )
          .start()
          .onComplete =>
            new TWEEN.Tween( @target().polygon2.translation )
              .to( { y: -2000 }, 750)
              .easing( TWEEN.Easing.Exponential.InOut )
              .delay(500)
              .start()

