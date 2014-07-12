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
  _createPolygon: ->
    new Two.Polygon(@anchors(), true, false)

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

class @TriGridOps extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @target = @options.target || @options.tri_grid || @options.trigrid || new TriGrid({two: @options.two})

    # event listener; when a traveler tween completes, remove its visual element from the scene
    @on 'travelerComplete', ((tween, polygon) -> @target.two.remove(polygon)), this

  lonelyTravelerTween: (row, duration) ->
    # create traveler visual element
    p = @target.squarePolygon()
    # p.stroke = '#FF0000'
    p.translation.set -10, @target._centerLength()*row
    p.addTo @target.group
    duration = 10000 if duration == undefined

    that = this
    tween = new TWEEN.Tween(p.translation)
      .to({x: @target.two.width+100}, duration)
      .easing( TWEEN.Easing.Linear.None )

    tween.onComplete =>
      @trigger 'travelerComplete', tween, p
