class Spinner
  constructor: (@el, @frames) ->
    @height = @el.height()
    @frame = 0
    @timer = null

  start: ->
    @timer = setInterval =>
      @frame = 0 if @frame > @frames - 1
      @el.css 'background-position', '0 -' + (@height * @frame) + 'px'
      @frame++
    , 100
    @el.addClass 'show'

  stop: ->
    return unless @timer?
    clearInterval @timer
    @timer = null
    @el.addClass 'show'
