class @TwoApp
  constructor: (_opts) ->
    @options = _opts
    @init()

  init: ->
    @two = new Two({autostart: true, fullscreen: true, type: Two.Types.svg}).appendTo(document.body)
    $(window).on('resize', @_resize).on('keydown', @_keyDown).mousemove(@_mouseMove)
    @_initScene()
    @_initOperations()

  _initScene: ->
    @_initBG()
    @_initStripes()
    @_initLetterbox()

  _initBG: ->
    bg = @two.makeRectangle(@two.width/2,@two.height/2, @two.width, @two.height)
    bg.fill = '#000000'
    bg.noStroke()
    @two.add(bg)

  _initStripes: ->
    @stripes = [
      new StripeRain({two: @two, translation: new Two.Vector(-@two.width/2, 0), rotation: -0.3, shadowOffset: 22})
      new StripeRain({two: @two, translation: new Two.Vector(@two.width/2, 0), rotation: 0.3 + Math.PI, shadowOffset: -22})
    ]

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
    return if (e.metaKey || e.ctrlKey)
    e.preventDefault()
    if e.keyCode == 32 # SPACE
      @running = (@running == false ? true : false)
      if @running
        @two.play() 
      else
        @two.pause()

  _mouseMove: (event) =>
    if @lastMouseX && @lastMouseY && @operations.length < 20
      v = new Two.Vector(event.pageX - @lastMouseX, event.pageY - @lastMouseY)
      all_particles = _.flatten(_.map(@stripes, (stripe) -> stripe.getAllParticles()))
      @operations.add(new WiggleOperation({particles: all_particles, strength: v.length()*0.03}))

    @lastMouseX = event.pageX
    @lastMouseY = event.pageY
