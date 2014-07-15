class Triad
  constructor: (_opts) ->
    @options = _opts
    @_init()

  _init: ->
    @polygon = @_createPolygon()

  _sideLength: ->
    @options.sideLength || 50

  _halfSide: ->
    @_sideLength()/2

  _centerLength: ->
    @__centerLength ||= Math.sqrt(Math.pow(@_sideLength(),2) - Math.pow(@_halfSide(), 2))

  _createPolygon: ->
    new Two.Polygon(@anchors(), true, false)

  anchor1: -> new Two.Anchor 0,0
  anchor2: -> new Two.Anchor @_halfSide(), @_centerLength()
  anchor3: -> new Two.Anchor -@_halfSide(), @_centerLength()
  anchors: -> [@anchor1(), @anchor2(), @anchor3()]

class PerspectiveSquare extends Triad
  anchor4: -> new Two.Anchor -@_sideLength(), 0
  anchors: -> [@anchor1(), @anchor2(), @anchor3(), @anchor4()]

class TriGrid extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  _init: ->
    # create group
    @group = @two.makeGroup()
    @group.translation.set(0,0)

    # create triads (shapes)
    _.each @createEveryOtherTriad(), (t) => t.polygon.addTo(@group)

    # create look
    @group.noFill()
    @group.stroke = @_stroke()
    @group.lineWidth = 2

  destroy: ->
    @trigger 'destroy'

    # remove group containing all triads
    @two.remove @group
    @group = undefined

  _sideLength: ->
    @options.sideLength || 50

  _halfSide: ->
    @_sideLength()/2

  _centerLength: ->
    @__centerLength ||= Math.sqrt(Math.pow(@_sideLength(),2) - Math.pow(@_halfSide(), 2))

  _rows: -> @options.rows || @two.height/@_centerLength()
  _cols: -> @options.cols || @two.width/@_sideLength()
  _stroke: -> @options.stroke || '#555555'

  createEveryOtherTriad: ->
    _.flatten _.map _.range(@_rows()), (ri) =>
      _.map _.range(@_cols()), (ci) =>
        # coordinates        
        x = ci*@_sideLength()
        x += @_sideLength()/2 if ri % 2 == 1
        y = ri*@_centerLength()
        # shape / polygon object
        t = new Triad({sideLength: @_sideLength()})
        t.polygon.translation.set(x,y)
        t

  squarePolygon: (x,y,w,h) ->
    ps = new PerspectiveSquare({sideLength: @_sideLength()})
    ps.polygon.noFill()
    ps.polygon.stroke = @_stroke()
    ps.polygon

  cubePolygon: (x,y,w,h) ->
    p1 = @squarePolygon(x,y,w,h)
    p2 = @squarePolygon(x,y,w,h)
    p2.rotation = Math.PI*0.67
    p3 = @squarePolygon(x,y,w,h)
    p3.rotation = Math.PI*0.34
    p3.translation.x = @_sideLength()
    g = @two.makeGroup()
    p1.addTo g
    p2.addTo g
    p3.addTo g
    return g

class TriGridCoords extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts

  sideLength: -> @options.sideLength || 50
  halfSide: -> @sideLength()/2
  centerLength: -> @_centerLength ||= Math.sqrt(Math.pow(@_sideLength(),2) - Math.pow(@_halfSide(), 2))

  cubePos: (row,col) ->
    {x: @sideLength()*col + @halfSide() * row / 2, y: @halfSide()*row}


class @TriGridOps extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @target = @options.target || @options.tri_grid || @options.trigrid || new TriGrid({two: @options.two})

    # event listener; when a traveler tween completes, remove its visual element from the scene
    @on 'travelerComplete', ((tween, polygon) -> @target.two.remove(polygon)), this


  lonelyTravelerTween: ->
    coords = new TriGridCoords({sideLength: @target._sideLength()})

    row = Math.floor(Math.random(@target._rows()))
    targetRow = row
    col = -1
    targetCol = @target._cols()

    if Math.random() > 0.5
      col = Math.floor(Math.random(@target._cols()))
      targetCol = col
      row = -1
      targetRow = @target._rows()

    # create traveler visual element
    p = @target.cubePolygon()
    # p.stroke = '#FF0000'
    pos = coords.cubePos(col, row)
    p.translation.set(pos.x, pos.y)
    p.addTo @target.group

    target = coords.cubePos(targetCol, targetRow)

    duration = 5000
    console.log p.translation
    console.log target
    that = this
    tween = new TWEEN.Tween(p.translation)
      .to(target, duration)
      .easing( TWEEN.Easing.Linear.None )

    tween.onComplete =>
      @trigger 'travelerComplete', tween, p
