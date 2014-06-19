class @WiggleOperation extends Backbone.Model
  defaults:
    'counter': 0
    'strength': 1
    'speed': 0.4
    'alive': true
    'particles': []

  # initialize: ->

  update: ->
    i = 0
    _.each @get('particles'), (particle) =>
      particle.translation.addSelf(@_curTranslation(i))
      i++

    @set({alive: false}) if @_curOffset() >= Math.PI*2

    @set({counter: @get('counter')+1})

  _curOffset: ->
    @get('counter') * @get('speed')

  _curTranslation: (idx)->
    strength = @get('strength')
    new Two.Vector(Math.sin(@_curOffset()+idx*0.2) * strength, 0)

