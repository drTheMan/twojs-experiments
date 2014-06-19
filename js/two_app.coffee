class @TwoApp
  constructor: (_opts) ->
    @options = _opts
    @init()

  init: ->
    @two = new Two({fullscreen: true, type: Two.Types.svg}).appendTo(document.body)
    $(window).bind('resize', @_resize)

    @stripes = [
      new StripeRain({two: @two, color: '#666666', rotation: -0.3})
      new StripeRain({two: @two, color: '#000000', rotation: 0.3 + Math.PI}),
      new StripeRain({two: @two, color: '#AAAAAA', rotation: -0.3})
    ]
    @stripes[0].group.translation.set(-800, 0)
    @stripes[1].group.translation.set(@two.width, 200)
    @stripes[2].group.translation.set(800, 0)
    @two.play()

  _resize: ->
    return if !@two
    @two.renderer.setSize $(window).width(), $(window).height()
    @two.width = @two.renderer.width;
    @two.height = @two.renderer.height;
