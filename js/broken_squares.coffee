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

  randomBreak: ->
    _.each @target.broken_squares, (broken_square) ->
      _.each broken_square.triangles, (triangle) ->
        if Math.random() > 0.5
          triangle.opacity = 0.0
        else
          triangle.opacity = 1.0


class BrokenSquares extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = _opts.two
    @init()

  init: ->
    @destroy()
    # @polygon = @_createPolygon()
    @group = @two.makeGroup()
    @broken_squares = @_createBrokenSquares()
    _.each @broken_squares, (broken_square) => broken_square.group.addTo @group

  destroy: ->
    @trigger 'destroy', this

    if @broken_squares
      _.each @broken_squares, (broken_square) -> broken_square.destroy()
      @broken_squares = undefined

    if @group
      @two.remove @group
      @group = undefined

  _createBrokenSquares: ->
    broken_squares = []

    y = 0
    while y < @two.height
      x = 0
      while x < @two.width
        bSquare = new BrokenSquare(two: @two)
        bSquare.group.translation.set(x,y)
        broken_squares = _.union(broken_squares, [bSquare])
        x += bSquare.width()
      y += bSquare.height()
    return broken_squares



    [new BrokenSquare(two: @two)]



class BrokenSquare extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = _opts.two
    @init()

  init: ->
    @destroy()
    @group = @two.makeGroup()
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

  width: -> @options.width || 100
  height: -> @options.height || 100

  # 0 --- 1 --- 2
  # | \   |   / |
  # |   \ | /   |
  # 3 --- 4 --- 5
  # |   / | \   |
  # | /   |   \ |
  # 6 --- 7 --- 8

  coords: -> [
    new Two.Anchor(0,0),
    new Two.Anchor(@width()/2,0),
    new Two.Anchor(@width(),0),
    new Two.Anchor(0,@height()/2),
    new Two.Anchor(@width()/2,@height()/2),
    new Two.Anchor(@width(),@height()/2),
    new Two.Anchor(0,@height()),
    new Two.Anchor(@width()/2,@height()),
    new Two.Anchor(@width(),@height()) 
  ]

  _createTriangles: -> 
    coords = @coords()
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

