class Stripe extends Backbone.Model
  isDead: ->
    @get('particle').translation.y > @get('height') * 1.6

  update: ->
    @get('particle').translation.addSelf(new Two.Vector(0, 30))


class @StripeRain
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @_init()

  addOne: ->
    @stripes.add(new Stripe({height: @two.height + Math.random()*500}))

  addSome: ->
    @target ||= 250

    @target = 0 if @target == 250 && @stripes.length > 250
    @target = 250 if @target == 0 && @stripes.length == 0

    if @stripes.length < 250
      @addOne()
      @addOne()

  _init: ->
    @stripes = new Backbone.Collection([])
    @stripes.on('add', @_added, this)
    @stripes.on('remove', @addSome, this)

    @two.bind('update', @_update, this)

    @addOne();

  _update: (frameCount) ->
    @stripes.each (obj) =>
      if obj.isDead()
        @stripes.remove(obj)
      else
        obj.update()

  _added: (obj) ->
    height = obj.get('height')
    rect = @two.makeRectangle(Math.random() * @two.width, -height, 20+Math.random()*30, height);
    rect.noStroke()
    rect.fill = '#000000'
    obj.set({particle: rect})

