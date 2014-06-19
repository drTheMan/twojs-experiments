class Stripe extends Backbone.Model
  isDead: ->
    @get('particle').translation.y > @get('height') * 1.6

  update: ->
    @get('particle').translation.addSelf(new Two.Vector(0, 30))


class @StripeRain
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @options.rotation ||= 0
    @_init()

  addOne: ->
    @stripes.add(new Stripe({height: @two.height + Math.random()*500}))

  addSome: ->
    if @stripes.length < 50
      @addOne()
      @addOne()

  _init: ->
    @stripes = new Backbone.Collection([])
    @stripes.on('add', @_added, this)
    @stripes.on('remove', @addSome, this)
    @stripes.on 'remove', (stripe) => @group.remove stripe.get('particle')

    @two.bind('update', @_update, this)

    @group = @two.makeGroup()
    @group.rotation = @options.rotation
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
    rect.fill = @options.color || '#000000'
    rect.addTo(@group)
    obj.set({particle: rect})

