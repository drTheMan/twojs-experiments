class @BrokenSquaresOps extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @init()

  init: ->
    @destroy()
    @target = @options.target || @options.brokenSqaures || @options.broken_squares || new BrokenSquares({two: @options.two})
    @two = @target.two
    @target.on 'destroy', (-> @destroy()), this

  destroy: ->
    # not much to do here
    @target = @two = undefined


class BrokenSquares extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = _opts.two
    @init()

  init: ->
    @destroy()
    # @polygon = @_createPolygon()
    @group = @two.makeGroup()
    @group.translation.set(100,100)
    new BrokenSquare(two: @two).group.addTo @group

  destroy: ->
    @trigger 'destroy', this

    if @group
      @two.remove @group
      @group = undefined


class BrokenSquare extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = _opts.two
    @init()

  init: ->
    @destroy()
    @group = @two.makeGroup()
    @group.translation.set(0,0)
    @triangles = @_createTriangles()
    _.each @triangles, (triangle) => triangle.addTo @group
    @group.fill = '#FFFFFF'
    @group.noStroke()

  destroy: ->
    @trigger 'destroy'

    if @triangles
      _.each @triangles, (triangle) => @two.remove triangle
      @triangles = undefined

    if @group
      @two.remove @group
      @group = undefined

  _width: -> @options.width || 100
  _height: -> @options.height || 100

  # 0 --- 1 --- 2
  # | \   |   / |
  # |   \ | /   |
  # 3 --- 4 --- 5
  # |   / | \   |
  # | /   |   \ |
  # 6 --- 7 --- 8

  _coords: -> [
    new Two.Anchor(0,0),
    new Two.Anchor(@_width()/2,0),
    new Two.Anchor(@_width(),0),
    new Two.Anchor(0,@_height()/2),
    new Two.Anchor(@_width()/2,@_height()/2),
    new Two.Anchor(@_width(),@_height()/2),
    new Two.Anchor(0,@_height()),
    new Two.Anchor(@_width()/2,@_height()),
    new Two.Anchor(@_width(),@_height()) 
  ]

  _createTriangles: -> 
    coords = @_coords()
    [
      new Two.Polygon([coords[0], coords[4], coords[3]], false, false),
      new Two.Polygon([coords[0], coords[1], coords[4]], false, false),
      new Two.Polygon([coords[1], coords[2], coords[4]], false, false),
      new Two.Polygon([coords[2], coords[4], coords[5]], false, false),
      new Two.Polygon([coords[3], coords[4], coords[6]], false, false),
      new Two.Polygon([coords[4], coords[6], coords[7]], false, false),
      new Two.Polygon([coords[4], coords[7], coords[8]], false, false),
      new Two.Polygon([coords[4], coords[5], coords[8]], false, false),
    ]


