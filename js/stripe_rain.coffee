class Stripe extends Backbone.Model
  isDead: ->
    @get('particle').translation.y > @get('height') * 1.6

  update: ->
    @get('particle').translation.addSelf(new Two.Vector(0, 20))


class @StripeRain
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @options.rotation ||= 0
    @_init()

  addOne: ->
    height = @two.height + Math.random()*500
    x = Math.random() * @two.width
    w = 25

    @stripes.add(new Stripe({
      x: x,
      y: -height,
      width: w,
      height: height,
      color: '#54EBFA'}))

    @stripes.add(new Stripe({
      x: x+w-1,
      y: -height,
      width: w,
      height: height,
      color: '#ffffff'}))

    @stripes.add(new Stripe({
      x: x+w+w-2,
      y: -height,
      width: w,
      height: height,
      color: '#FD031D'}))


  addSome: ->
    if @stripes.length < 50
      @addOne()
      @addOne()

  getAllParticles: ->
    @stripes.map (stripe) -> stripe.get('particle')

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
    rect = @two.makeRectangle(obj.get('x'), obj.get('y'), obj.get('width'), obj.get('height'));
    rect.noStroke()
    rect.fill = obj.get('color') || '#000000'
    rect.addTo(@group)
    obj.set({particle: rect})

    
