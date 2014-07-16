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

  randomBreak: (likeliness, broken_squares) ->
    _.each (broken_squares || @target.broken_squares), (broken_square) ->
      _.each broken_square.triangles, (triangle) ->
        if Math.random() > (likeliness || 0.4)
          triangle.opacity = 0.0
        else
          triangle.opacity = 1.0

    # setTimeout (=> @randomBreak()), 3000

  scrollTween: ->
    height = @target.gridH() * @target.rowH()
    squares = @target._createBrokenSquares(0, height-@target.group.translation.y)
    @randomBreak 0.4, squares
    @target.addBrokenSquares squares

    console.log [@two.height, height]
    tween = new TWEEN.Tween( @target.group.translation )
      .to({y: @target.group.translation.y-height}, 2500)
      .easing( TWEEN.Easing.Linear.None )


    # tween.onComplete =>
    #   if @trigger 'scrollTweenComplete', tween
    #     _.each _.range(@target.broken_squares.length/2), (idx) =>
    #       console.log 'removing sq'
    #       @target.two.remove @target.broken_squares[idx].group
    #     @target.broken_squares = _.map _.range(@target.broken_squares.length/2, @target.broken_squares.length/2), (idx) =>
    #       @target.broken_squares[idx]



class BrokenSquares extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = _opts.two
    @init()

  init: ->
    @destroy()
    # @polygon = @_createPolygon()
    @group = @two.makeGroup()
    @addBrokenSquares @_createBrokenSquares()

  destroy: ->
    @trigger 'destroy', this

    if @broken_squares
      _.each @broken_squares, (broken_square) -> broken_square.destroy()
      @broken_squares = undefined

    if @group
      @two.remove @group
      @group = undefined

  size: -> @options.size || 50
  colSpacing: -> @options.colSpacing || 30
  rowSpacing: -> @options.rowSpacing || 30
  colW: -> @size() + @colSpacing()
  rowH: -> @size() + @rowSpacing()
  gridW: -> @two.width / @colW() + 1
  gridH: -> @two.height / @rowH() + 1

  addBrokenSquares: (broken_squares) ->
    @broken_squares ||= []
    @broken_squares = _.union @broken_squares, broken_squares
    _.each broken_squares, (broken_square) => broken_square.group.addTo @group

  _createBrokenSquares: (startX, startY) ->
    result = _.map _.range(@gridH()), (y, idx, list) =>
      _.map _.range(@gridW()), (x, idx, list) =>
        bSquare = new BrokenSquare(two: @two, size: @size())
        bSquare.group.translation.set((startX || 0) + x * @colW(), (startY || 0) + y * @rowH())
        bSquare
    return _.flatten result

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

  width: -> @options.width || @options.size || 50
  height: -> @options.height || @options.size || 50

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

class BrokenSquareRow extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = _opts.two
    @init()

  init: ->
    @destroy()
    @group = @two.makeGroup()
    @broken_squares = @_create()
    _.each @broken_squares, (broken_square) => broken_square.group.addTo @group
    @group.fill = '#FFFFFF'
    @group.noStroke()

  destroy: ->
    @trigger 'destroy'

    if @broken_squares
      _.each @broken_squares, (broken_square) => broken_square.destroy()
      @broken_squares = undefined

    if @group
      @two.remove @group
      @group = undefined

  size: -> @options.size || 50
  colSpacing: -> @options.colSpacing || 30
  rowSpacing: -> @options.rowSpacing || 30
  colW: -> @size() + @colSpacing()
  rowH: -> @size() + @rowSpacing()
  gridW: -> @two.width / @colW() + 1
  gridH: -> @two.height / @rowH() + 1

  _create: ->
    _.map _.range(@gridW()), (x) =>
      bSquare = new BrokenSquare(two: @two, size: @size())
      bSquare.group.translation.set(x*@colW(), 0)
      bSquare
