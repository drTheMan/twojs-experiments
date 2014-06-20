class Stripe extends Backbone.Model
  isDead: ->
    @get('particle').translation.y > @get('height') * 2

  update: ->
    @get('particle').translation.addSelf(new Two.Vector(0, 20))


class @StripeRain
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @options.rotation ||= 0
    @_init()

  addOne: ->
    # minimum size is the diagonal of the scene
    @minSize ||= Math.sqrt(Math.pow(@two.width,2), Math.pow(@two.height,2))
    @maxPos ||= _.max([@two.width, @two.height])

    # get a nice size for the new stripe
    size = @minSize + Math.random()*500
    pos = (Math.random()-0.5) * @maxPos
    w = 25

    @stripes.add(new Stripe({
      x: pos,
      y: -size,
      width: w,
      height: size,
      color: '#54EBFA'}))


  addSome: ->
    if @stripes.length < 30
      @addOne()
      @addOne()

  getAllParticles: ->
    @stripes.map (stripe) -> stripe.get('particle')

  _init: ->
    # our collection of elements in the scene (+hooks to maintain them)
    @stripes = new Backbone.Collection([])
    @stripes.on('add', @_added, this)     # after a 'record' is created; create the visual elements in the Two scene automatically
    @stripes.on('remove', @addSome, this) # after a stripes 'dies' add new stripes
    @stripes.on('remove', (stripe) => @group.remove stripe.get('particle')) # when a stripe 'dies', also remove it's visual elements
    @two.bind('update', @_update, this) # keep updating the scene

    # put all visual stripe elements inside one main (centered) group
    @group = @two.makeGroup()
    @group.translation.set(@two.width/2, @two.height/2)
    @group.rotation = @options.rotation if @options.rotation

    # start by adding one stripe
    @addOne();

  _update: (frameCount) ->
    @stripes.each (stripe,col) =>
      if stripe.isDead()
        @stripes.remove stripe
      else
        stripe.update()

  _added: (obj) ->
    group = new Two.Group()

    w = obj.get('width')
    h = obj.get('height')

    # shadow
    rect = @two.makeRectangle(w*2.8, 0, w, h)
    rect.fill = 'rgba(0, 0, 0, 0.3)'
    rect.addTo(group)
    # blue
    rect = @two.makeRectangle(0, 0, w, h)
    rect.fill = '#54EBFA'
    rect.addTo(group)
    # white
    rect = @two.makeRectangle(w-1, 0, w, h)
    rect.fill = '#FFFFFF'
    rect.addTo(group)
    # red
    rect = @two.makeRectangle(w+w-1, 0, w, h)
    rect.fill = '#FD031D'
    rect.addTo(group)
    # group
    group.translation.addSelf(new Two.Vector(obj.get('x'), obj.get('y')))
    group.noStroke()
    group.addTo(@group)

    obj.set({particle: group})

    
