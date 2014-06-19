class @Stripes
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  _init: ->
    @circle = @two.makeCircle(-70, 0, 50);
    @rect = @two.makeRectangle(70, 0, 100, 100);
    @circle.fill = '#FF8000';
    @rect.fill = 'rgba(0, 200, 255, 0.75)';

    @group = @two.makeGroup(@circle, @rect);
    @group.translation.set(@two.width / 2, @two.height / 2);
    @group.scale = 0
    @group.noStroke()

    @two.bind('update', @_update, this)

  _update: (frameCount) ->
    @group.scale = @group.rotation = 0 if @group.scale > 0.9999
    t = (1 - @group.scale) * 0.125
    @group.scale += t
    @group.rotation += t * 4 * Math.PI
    @group.translation.addSelf(new Two.Vector(Math.sin(frameCount * 0.03) * 1, 0))
