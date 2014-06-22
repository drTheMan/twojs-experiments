class @AppUi extends Backbone.Model
  constructor: (_opts) ->
    @options = _opts
    @_initGui()

  _initGui: ->
    @gui = new dat.GUI() # ({autoPlace:true});
    folder = @gui.addFolder 'Actions'
    folder.add({Shake: => @trigger 'shake'}, 'Shake')
    folder.add({Shutter: => @trigger 'shutter'}, 'Shutter')
    folder.add({Arrows: => @trigger 'arrows'}, 'Arrows')
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

    @app_ui.on 'shake', =>
      all_particles = _.flatten(_.map(@stripes, (stripe) -> stripe.getAllParticles()))
      @operations.add(new WiggleOperation({particles: all_particles, strength: 10+Math.random()*10}))

    @app_ui.on 'shutter', => @circle_closer_operations.shutter()

    @app_ui.on 'arrows', => @arrows_operations.move_out({spirality: 200})

  _initScene: ->
    @_initBG()
    @_initStripes()
    @_initCircles()
    @_initArrows()
    @_initLetterbox()
    @two.bind 'update', -> TWEEN.update()

  _initBG: ->
    bg = @two.makeRectangle(@two.width/2,@two.height/2, @two.width, @two.height)
    bg.fill = '#000000'
    bg.noStroke()
    @two.add(bg)

  _initStripes: ->
    @stripes = [
      new StripeRain({two: @two, translation: new Two.Vector(-@two.width/2, 0), fatness: 15, rotation: -0.3, shadowOffset: 22, startAmount: 10})
      new StripeRain({two: @two, translation: new Two.Vector(@two.width/2, 0), rotation: 0.3 + Math.PI, shadowOffset: -22, startAmount: 10})
    ]

  _initCircles: ->
    @circle_closer = new CircleCloser({two: @two, color: '#FFFF00', radius: 200})
    @circle_closer_operations = new CircleCloserOperations({target: @circle_closer})
    @circle_closer_operations.open()

  _initArrows: ->
    @arrows = new Arrows(two: @two)
    @arrows_operations = new ArrowsOperations(target: @arrows)
    @arrows_operations.hide()

  _initLetterbox: ->
    fatness = @two.height * 0.1
    bar = @two.makeRectangle(@two.width/2, fatness/2, @two.width, fatness)
    bar.fill = '#000000'
    bar.noStroke()
    @two.add(bar)

    bar = @two.makeRectangle(@two.width/2, @two.height-fatness/2, @two.width, fatness)
    bar.fill = '#000000'
    bar.noStroke()
    @two.add(bar)

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
    #console.log(e)

    return if (e.metaKey || e.ctrlKey)
    e.preventDefault()
    if e.keyCode == 32 # SPACE
      @running = (@running == false ? true : false)
      if @running
        @two.play() 
      else
        @two.pause()

    if e.keyCode == 67 && @circle_closer # 'c'
      @circle_closer_operations.shutter()


  _mouseMove: (event) =>
    if @lastMouseX && @lastMouseY && @operations.length < 20
      v = new Two.Vector(event.pageX - @lastMouseX, event.pageY - @lastMouseY)
      all_particles = _.flatten(_.map(@stripes, (stripe) -> stripe.getAllParticles()))
      @operations.add(new WiggleOperation({particles: all_particles, strength: v.length()*0.03}))

    @lastMouseX = event.pageX
    @lastMouseY = event.pageY
