class @Arrows
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  _group: ->
    return @group if @group
    @group = @two.makeGroup()
    @group.translation.set(@two.width/2, @two.height/2)
    return @group

  _init: ->
    count = @options.count || 10
    dr = Math.PI * 2 / count

    # create an array of models which each represent one arrow
    models = _.map _.range(count), (i) =>  
      new Backbone.Model({polygon: @_initArrow(dr * i)})
    
    # put all the model in a backbone collection
    @arrows = new Backbone.Collection(models)

    # put all polygon in a group and give them all the same appearance
    @_group().fill = @options.color || '#51EE98'
    @_group().noStroke()
    # @_group().opacity = 0.8

  _initArrow: (rotation) ->
    points = [
      new Two.Anchor(0, 15),
      new Two.Anchor(10, 0),
      new Two.Anchor(-10, 0)
    ]

    polygon = new Two.Polygon(points, false, false)
    polygon.rotation = rotation if rotation
    polygon.addTo(@_group())
    return polygon

  polygons: ->
    @arrows.map (model) -> model.get('polygon')


class @ArrowsOperations
  constructor: (opts) ->
    @options = opts

  target: ->
    @options.target || @options.circle_closer

  hide: ->
    @target().group.opacity = 0

  show: ->
     @target().group.opacity = 1

  reset: ->
    _.each @target().polygons(), (polygon) ->
      polygon.translation.set(0,0)
      polygon.scale = 1.5

  move_out: (opts) ->
    @hide()
    @reset()

    radius = 1000
    total_duration = 2000

    _.map @target().polygons(), (polygon) ->
      angle = polygon.rotation
      x = -Math.sin(angle)*(radius + angle * opts.spirality || 0)
      y = Math.cos(angle)*(radius + angle * opts.spirality || 0)

      new TWEEN.Tween(polygon.translation)
        .to({x: x, y: y}, total_duration)
        .easing( TWEEN.Easing.Linear.None )
        .start()
        .onStart ->
          new TWEEN.Tween(polygon)
            .to({scale: 3}, total_duration*0.1)
            .easing( TWEEN.Easing.Linear.None )
            .start()
            .onComplete ->
              new TWEEN.Tween(polygon)
                .to({scale: 0}, total_duration * 0.7)
                .easing( TWEEN.Easing.Linear.None )
                .start()

    new TWEEN.Tween(@target().group)
      .to({rotation: Math.PI*Math.random()*1.5}, total_duration)
      .start()

    @show()
