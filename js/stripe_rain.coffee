class Stripe extends Backbone.Model
  _isDead: ->
    @get('particle').translation.y > @get('height') * 2

  update: ->
    @get('particle').translation.addSelf(new Two.Vector(0, 20))
    @set({alive: false}) if @_isDead()

  randomize: ->
    return if !@get('particle')

    if key = _.last(Object.keys(@get('particle').children)) 
      if poly = @get('particle').children[key]
        if Math.random() > 0.5
          poly.opacity = 0
        else
          poly.opacity = 1

class @StripeRain
  constructor: (_opts) ->
    @options = _opts
    @two = @options.two
    @options.rotation ||= 0
    @_init()

  _init: ->
    # put all visual stripe elements inside one main (centered) group
    @group = @two.makeGroup()
    @group.translation.set(@two.width/2, @two.height/2)
    @group.translation.addSelf(@options.translation) if @options.translation
    @group.rotation = @options.rotation if @options.rotation

    # our collection of elements in the scene (+hooks to maintain them)
    @stripes = new Backbone.Collection([])

    # event listeners
    @stripes.on('add', @_added, this)     # after a 'record' is created; create the visual elements in the Two scene automatically
    @stripes.on('remove', (stripe) => console.log('removing stripe Two.js visual element'); @group.remove stripe.get('particle')) # when a stripe 'dies', also remove it's visual elements
    @stripes.on('change:alive', @_onAliveChange, this)
    @two.bind('update', @_update, this) # keep updating the scene

    # create initial stripes
    _.each _.range(@options.startAmount || 1), (i) => @addOne();

  destroy: ->
    # first remove event listeners
    @stripes.off()
    @two.off('update', @_update)

    # this is probably not necessary, as we're already removing the entire group
    # but let's be thorough
    if @stripes
      @stripes.each (stripe) -> stripe.destroy()
      @stripes = undefined

    if @two && @group
      @two.remove(@group)

  _update: (frameCount) ->
    @stripes.each (stripe,col) -> stripe.update()

  addOne: -> @stripes.add(new Stripe(@getNewStripeData()))

  getNewStripeData: ->
    # minimum size is the diagonal of the scene
    @minSize ||= Math.sqrt(Math.pow(@two.width,2), Math.pow(@two.height,2))
    # get a nice size for a new stripe
    size = @minSize + Math.random()*500

    w = @options.fatness || 25

    @maxPos ||= _.max([@two.width, @two.height])
    pos = (Math.random()-0.5) * @maxPos

    { x: pos, y: -size, width: w, height: size }

  getAllParticles: ->
    @stripes.map (stripe) -> stripe.get('particle')


  # this method creates the visual two elements (rectangles) for each stripe Model
  _added: (obj) ->
    group = new Two.Group()

    w = obj.get('width')
    h = obj.get('height')

    # shadow
    rect = @two.makeRectangle(w+(@options.shadowOffset || 0), 0, w*3, h)
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
    obj.randomize()

  _onAliveChange: (stripe, value, data) ->
    # a stripe died; resurrect
    stripe.set $.extend(@getNewStripeData(), {alive: true}) if value == false

    # a stripe revived; move it's visual elements into position
    if value == true
      stripe.get('particle').translation.set(stripe.get('x'), stripe.get('y'))
      stripe.randomize()

    # stripe died; add another stripe if limit hasn't been reached yet
    @addOne() if @stripes.length < (@options.maxAmount || 50) if value == false

    
