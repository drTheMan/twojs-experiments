class @AppUi extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @_initGui()

  _initGui: ->
    @gui = new dat.GUI() # ({autoPlace:true});

    folder = @gui.addFolder 'Elements'
    folder.add({Stripes: => @trigger 'toggleStripes'}, 'Stripes')
    folder.add({Circles: => @trigger 'toggleCircles'}, 'Circles')
    folder.add({Rings: => @trigger 'toggleRings'}, 'Rings')
    folder.add({Arrows: => @trigger 'toggleArrows'}, 'Arrows')
    folder.add({TriGrid: => @trigger 'toggleTriGrid'}, 'TriGrid')
    folder.add({BrokenSquares: => @trigger 'toggleBrokenSquares'}, 'BrokenSquares')
    folder.add({Letterbox: => @trigger 'toggleLetterbox'}, 'Letterbox')
    folder.open()

    folder = @gui.addFolder 'Actions'
    folder.add({Shaker: => @trigger 'shake'}, 'Shaker')
    folder.add({Shutter: => @trigger 'shutter'}, 'Shutter')
    folder.add({Arrows: => @trigger 'arrows'}, 'Arrows')
    folder.add({Rings: => @trigger 'scale'}, 'Rings')
    folder.add({Traveler: => @trigger 'traveler'}, 'Traveler')
    folder.add({BreakSquares: => @trigger 'breaksquares'}, 'BreakSquares')
    folder.open()

class @TwoApp
  constructor: (_opts) ->
    @options = _opts
    @init()

  init: ->
    @two = new Two({autostart: true, fullscreen: true, type: Two.Types.svg}).appendTo(document.body)
    $(window).on('resize', @_resize).on('keydown', @_keyDown).mousemove(@_mouseMove)
    @_initUI()
    @_initScene()
    @_initOperations()

  _initUI: ->
    @app_ui = new AppUi()

    @app_ui.on 'toggleStripes', => @_toggleStripes()
    @app_ui.on 'toggleCircles', => @_toggleCircles()
    @app_ui.on 'toggleRings', => @_toggleRingers()
    @app_ui.on 'toggleArrows', => @_toggleArrows()
    @app_ui.on 'toggleTriGrid', => @_toggleTriGrid()
    @app_ui.on 'toggleLetterbox', => @_toggleLetterbox()
    @app_ui.on 'toggleBrokenSquares', => @_toggleBrokenSquares()

    @app_ui.on 'shutter', => @circle_closer_operations.shutter() if @circle_closer_operations
    @app_ui.on 'arrows', => @arrows_operations.move_out({spirality: 200}) if @arrows_operations
    @app_ui.on 'scale', => @ringer_operations.scale() if @ringer_operations
    @app_ui.on 'traveler', => @_triGridOps.lonelyTravelerTween().start() if @_triGridOps
    @app_ui.on 'breaksquares', => @_brokenSquaresOps.randomBreak() if @_brokenSquaresOps

  _initScene: ->
    @_initBG()
    # @_toggleStripes()
    # @_toggleCircles()
    # @_toggleRingers()
    # @_toggleArrows()
    # @_toggleTriGrid()
    @_toggleBrokenSquares()
    @_toggleLetterbox()
    @two.bind 'update', -> TWEEN.update()

  _initBG: ->
    bg = @two.makeRectangle(@two.width/2,@two.height/2, @two.width, @two.height)
    bg.fill = '#000000'
    bg.noStroke()
    @two.add(bg)

  _toggleStripes: ->
    # destroy objects
    if @_stripeRains
      _.each @_stripeRains, (stripeRain) -> stripeRain.destroy()
      @_stripeRains = undefined
      return

    # create stripe objects
    @_stripeRains = [
      new StripeRain({two: @two, translation: new Two.Vector(-@two.width/2, 0), fatness: 15, rotation: -0.3, shadowOffset: 22, startAmount: 10})
      new StripeRain({two: @two, translation: new Two.Vector(@two.width/2, 0), rotation: 0.3 + Math.PI, shadowOffset: -22, startAmount: 10})
    ]

    # create UI event hooks
    @app_ui.on 'shake', =>
      all_particles = _.flatten(_.map(@_stripeRains, (stripe) -> stripe.getAllParticles()))
      @operations.add(new WiggleOperation({particles: all_particles, strength: 10+Math.random()*10}))

  _toggleCircles: ->
    if @circle_closer
      @circle_closer.destroy()
      @permanent_circle.destroy()
      # no need to do a destroy on the operations objects as they destroy automatically when their target is destroyed
      @circle_closer = @permanent_circle = @circle_closer_operations = @permanent_circle_operations = undefined
      return

    @circle_closer = new CircleCloser({two: @two, color: '#F3CB5A', radius: 200})
    @circle_closer_operations = new CircleCloserOperations({target: @circle_closer})
    @circle_closer_operations.open()
    @permanent_circle = new CircleCloser({two: @two, radius: _.min([@two.width, @two.height])*0.6})
    @permanent_circle_operations = new CircleCloserOperations({target: @permanent_circle})
    @permanent_circle_operations.open(-1)

  _toggleRingers: ->
    if @ringer
      @ringer.destroy()
      @ringer = @ringer_operations = undefined
      return

    minRadius = _.min([@two.width, @two.height])*0.6+10
    @ringer = new Ringer({two: @two, minRadius: minRadius, maxRadius: minRadius+400, minThickness: 30, maxThickness: 100})
    @ringer_operations = new RingerOperations({target: @ringer})
    @ringer_operations.rotate()

  _toggleArrows: ->
    if @arrows
      @arrows.destroy()
      @arrows = @arrows_operations = undefined
      return

    @arrows = new Arrows(two: @two)
    @arrows_operations = new ArrowsOperations(target: @arrows)
    @arrows_operations.hide()

  _toggleTriGrid: ->
    if @_triGridOps
      @_triGridOps.target.destroy()
      @_triGridOps = undefined
      return

    @_triGridOps = new TriGridOps({two: @two})

  _toggleBrokenSquares: ->
    if @_brokenSquaresOps
      @_brokenSquaresOps.target.destroy()
      @_brokenSquaresOps = undefined
      return

    @_brokenSquaresOps = new BrokenSquaresOps({two: @two})
    @_brokenSquaresOps.randomBreak()

  _toggleLetterbox: ->
    if @letterboxGroup
      @two.remove @letterboxGroup
      @letterboxGroup = undefined
      return

    fatness = @two.height * 0.1

    @letterboxGroup = @two.makeGroup()

    bar = @two.makeRectangle(@two.width/2, fatness/2, @two.width, fatness)
    @letterboxGroup.add(bar)

    bar = @two.makeRectangle(@two.width/2, @two.height-fatness/2, @two.width, fatness)
    @letterboxGroup.add(bar)

    @letterboxGroup.fill = '#000000'
    @letterboxGroup.noStroke()

  _initOperations: ->
    @operations = new Backbone.Collection([])

    @two.bind 'update', (frameCount) =>
      @operations.each (op) -> op.update()

    @operations.on 'change:alive', (op) =>
      @operations.remove(op)

  _resize: ->
    return if !@two
    @two.renderer.setSize $(window).width(), $(window).height()
    @two.width = @two.renderer.width;
    @two.height = @two.renderer.height;

  _keyDown: (e) =>
    #console.log('keydown event:')
    # console.log(e)

    return if (e.metaKey || e.ctrlKey)
    e.preventDefault()
    if e.keyCode == 32 # SPACE
      @running = (@running == false ? true : false)
      if @running
        @two.play()
      else
        @two.pause()

    @app_ui.trigger 'shutter' if e.keyCode == 67 # 'c'

    @app_ui.trigger('shake') if e.keyCode == 49 # '1'
    @app_ui.trigger('shutter') if e.keyCode == 50
    @app_ui.trigger('arrows') if e.keyCode == 51
    @app_ui.trigger('scale') if e.keyCode == 52

  _mouseMove: (event) =>
    if @lastMouseX && @lastMouseY && @operations.length < 20
      v = new Two.Vector(event.pageX - @lastMouseX, event.pageY - @lastMouseY)
      all_particles = _.flatten(_.map(@_stripesRains, (stripe) -> stripe.getAllParticles()))
      @operations.add(new WiggleOperation({particles: all_particles, strength: v.length()*0.03}))

    @lastMouseX = event.pageX
    @lastMouseY = event.pageY
