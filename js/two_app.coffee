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
    @_initCircles()
    @_initLetterbox()
    @two.bind 'update', -> TWEEN.update()

  _initBG: ->
    bg = @two.makeRectangle(@two.width/2,@two.height/2, @two.width, @two.height)
    bg.fill = '#000000'
    bg.noStroke()
    @two.add(bg)

  _initStripes: ->
    @stripes = [
      new StripeRain({two: @two, translation: new Two.Vector(-@two.width/2, 0), rotation: -0.3, shadowOffset: 22, startAmount: 10})
      new StripeRain({two: @two, translation: new Two.Vector(@two.width/2, 0), rotation: 0.3 + Math.PI, shadowOffset: -22, startAmount: 10})
    ]

  _initCircles: ->
    @circle_closer = new CircleCloser({two: @two, color: '#FFFF00', radius: 200})

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
      @circle_closer.group.rotation = Math.random()*Math.PI*2
      new TWEEN.Tween( @circle_closer.group )
        .to({rotation: @circle_closer.group.rotation + Math.random()*Math.PI*2}, 750)
        .easing( TWEEN.Easing.Exponential.InOut )
        .start()
        .onComplete =>
          @circle_closer.group.rotation = Math.random()*Math.PI*2
          new TWEEN.Tween( @circle_closer.group )
            .to({rotation: @circle_closer.group.rotation + Math.random()*Math.PI*2}, 750)
            .easing( TWEEN.Easing.Exponential.InOut )
            .delay(500)
            .start()
        .onStart =>
          new TWEEN.Tween( @circle_closer.polygon1.translation )
            .to( { y: -1 }, 750)
            # .easing( TWEEN.Easing.Bounce.InOut )
            .easing( TWEEN.Easing.Exponential.InOut )
            .start()
            .onComplete =>
              new TWEEN.Tween( @circle_closer.polygon1.translation )
                .to( { y: 2000 }, 750)
                .easing( TWEEN.Easing.Exponential.InOut )
                .delay(500)
                .start()

          new TWEEN.Tween( @circle_closer.polygon2.translation )
            .to( { y: 1 }, 750)
            .easing( TWEEN.Easing.Exponential.InOut )
            .start()
            .onComplete =>
              new TWEEN.Tween( @circle_closer.polygon2.translation )
                .to( { y: -2000 }, 750)
                .easing( TWEEN.Easing.Exponential.InOut )
                .delay(500)
                .start()


  _mouseMove: (event) =>
    if @lastMouseX && @lastMouseY && @operations.length < 20
      v = new Two.Vector(event.pageX - @lastMouseX, event.pageY - @lastMouseY)
      all_particles = _.flatten(_.map(@stripes, (stripe) -> stripe.getAllParticles()))
      @operations.add(new WiggleOperation({particles: all_particles, strength: v.length()*0.03}))

    @lastMouseX = event.pageX
    @lastMouseY = event.pageY
