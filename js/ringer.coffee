class @RingerPart
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  _init: ->
    @polygon = @_initPolygon()

  _radius: ->
    @options.radius || _.min([@two.width, @two.height])/2

  _angle: ->
    @options.angle || Math.PI/4

  _thickness: ->
    @options.thickness || 30

  _group: ->
    return @group if @group
    @group = @two.makeGroup()
    @group.translation.set(@two.width/2, @two.height/2)
    return @group


  _initPolygon: ->
    rotation = @options.rotation #|| Math.PI*0.8 # if rotation == undefined
    amount = 50
    last = amount - 1
    radius = @_radius()
    angle = @_angle()

    inner_points = _.map _.range(0, angle, angle/amount), (theta) ->
      x = radius * Math.cos(theta)
      y = radius * Math.sin(theta)
      return new Two.Anchor(x, y)

    radius += @_thickness()

    outer_points = _.map _.range(angle, 0, -angle/amount), (theta) ->
      x = radius * Math.cos(theta)
      y = radius * Math.sin(theta)
      return new Two.Anchor(x, y)

    polygon = new Two.Polygon(_.union(inner_points, outer_points), true, false)
    polygon.rotation = rotation
    polygon.addTo(@_group())


class @Ringer
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  _amount: -> @options.amount || 10
  _minAngle: -> @options.minAngle || (Math.PI/10)
  _maxAngle: -> @options.maxAngle || (Math.PI/4)
  _minRadius: -> @options.minRadius || 10
  _maxRadius: -> @options.maxRadius || _.min([@two.width, @two.height])
  _minThickness: -> @options.minThickness || 10
  _maxThickness: -> @options.maxThickness || 30

  _init: ->
    @ringer_parts = _.map _.range(@_amount()), (i) =>
      a = @_minAngle()+Math.random()*(@_maxAngle()-@_minAngle())
      rot = Math.random()*Math.PI*2
      # console.log rot
      new RingerPart({
        two: @two,
        radius: @_minRadius()+Math.random()*(@_maxRadius()-@_minRadius()),
        angle: a,
        thickness: @_minThickness()+Math.random()*(@_maxThickness()-@_minThickness()),
        rotation: rot
      })

class @RingerOperations
  constructor: (opts) ->
    @options = opts

  target: ->
    @options.target || @options.ringer

  rotate: (speed, divergence) ->
    # rotation speed
    speed = 1 if speed == undefined
    # divergence is the maximum difference of speed between different ring
    divergence = 1000 if divergence == undefined

    # each tween will make its polygon rotate virtually endlessly
    rotations = 10000
    duration = 10000*rotations/speed

    # create one tween per ringer part
    rotation_tweens = _.map @target().ringer_parts, (rp) ->
      new TWEEN.Tween( rp.group ) 
        .to({rotation: rp.group.rotation + Math.PI * 2 * rotations}, duration - Math.random()*divergence*40000)
        .easing( TWEEN.Easing.Linear.None )
        .start()



