class @TwoApp
  constructor: (_opts) ->
    @options = _opts
    @init()

  init: ->
    @two = new Two({fullscreen: true, type: Two.Types.svg}).appendTo(document.body)
    $(window).bind('resize', @_resize)

    @stripes = new Stripes({two: @two})
    @two.play()

  _resize: ->
    return if !@two
    @two.renderer.setSize $(window).width(), $(window).height()
    @two.width = @two.renderer.width;
    @two.height = @two.renderer.height;
