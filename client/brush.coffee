class window.Brush
  constructor: (opts) ->
    @isTouch = document.hasOwnProperty('ontouchstart')
    @last = null
    @lastInFrame = true
    @outerFrame = opts.outerFrame
    @frame = opts.frame
    @ctx = opts.ctx
    @radius = opts.radius
    @packing = opts.packing
    @currentColor = "rgba(40, 210, 241, 1)" # sky blue
    @startTime = null
    @segments = []
    document.addEventListener((if @isTouch then 'touchstart' else 'mousedown'), @_mouseDownEvent)
    @justDrew = false

  drawSegment: (start, end) ->
    r = @radius
    d = r * 2

    if end
      @_drawCircle(end.x, end.y, r)
      dots = @packing * @_dist(start, end) / d
      for i in [0...dots]
        @_drawCircle(
          start.x + (i + 1) * (end.x - start.x) / (dots + 1),
          start.y + (i + 1) * (end.y - start.y) / (dots + 1),
          r
        )
    else @_drawCircle(start.x, start.y, r)

  # This is pretty hacky, but we use this to avoid double drawing.
  # A better solution would to have a hash of drawn strokes keyed
  # against stroke IDs, but we can't get the ID until we've already
  # inserted a stroke and the drawing happens
  didDraw: ->
    if @justDrew
      @justDrew = false
      return true
    else
      return @justDrew # false

  _mouseDownEvent: (e) =>
    return unless @_active()
    return if e.target isnt @frame
    e.preventDefault()

    @startTime = e.timeStamp

    # @currentColor = "rgb(#{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())})"
    upFn = (e) =>
      document.removeEventListener((if @isTouch then 'touchmove' else 'mousemove'), @_move)
      document.removeEventListener((if @isTouch then 'touchend' else 'mouseup'), upFn)

      @_flush()

      @last = null
      @startTime = null

    document.addEventListener((if @isTouch then 'touchmove' else 'mousemove'), @_move)
    document.addEventListener((if @isTouch then 'touchend' else 'mouseup'), upFn)

  _move: (e) =>
    e.preventDefault()

    cursor = if @isTouch then x: e.touches[0].pageX, y: e.touches[0].pageY else x: e.clientX, y: e.clientY

    start = x: cursor.x - @outerFrame.offsetLeft, y: cursor.y - @outerFrame.offsetTop
    inFrame = (e.target is @frame) or (e.target.parentElement is @outerFrame)

    if @lastInFrame or inFrame
      @drawSegment(start, @last)
      @segments.push(start: start, end: @last, time: e.timeStamp - @startTime)

    @last = start
    @lastInFrame = inFrame

  _drawCircle: (x, y, radius) ->
    @ctx.save()
    @ctx.fillStyle = @currentColor
    @ctx.beginPath()
    @ctx.arc(x, y, radius, 0, Math.PI * 2)
    @ctx.closePath()
    @ctx.fill()
    @ctx.restore()

  _dist: (start, end) ->
    Math.sqrt(Math.pow(end.x - start.x, 2) + Math.pow(end.y - start.y, 2))

  _flush: ->
    @justDrew = true
    strokeId = Strokes.insert(segments: @segments, color: @currentColor)
    @segments = []

  _active: ->
    Session.get("brushIsActive")
