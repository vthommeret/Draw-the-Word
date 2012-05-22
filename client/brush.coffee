class window.Brush
  initialize: (opts) ->
    @isTouch = document.hasOwnProperty('ontouchstart')
    @last = null
    @lastInFrame = true
    @outerFrame = opts.outerFrame
    @frame = opts.frame
    @ctx = opts.ctx
    @radius = opts.radius
    @packing = opts.packing
    @currentColor = "black"
    @segments = []
    document.addEventListener((if @isTouch then 'touchstart' else 'mousedown'), @_mouseDownEvent)

  drawSegment: (start, end) ->
    @currentColor = "rgb(#{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())})"

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

  _mouseDownEvent: (e) =>
    return unless @_active()
    return if e.target isnt @frame
    e.preventDefault()

    moveFn = @_move()
    upFn = (e) =>
      document.removeEventListener((if @isTouch then 'touchmove' else 'mousemove'), moveFn)
      document.removeEventListener((if @isTouch then 'touchend' else 'mouseup'), upFn)
      @_flush()
      @last = null

    document.addEventListener((if @isTouch then 'touchmove' else 'mousemove'), moveFn)
    document.addEventListener((if @isTouch then 'touchend' else 'mouseup'), upFn)

  _move: ->
    (e) =>
      e.preventDefault()

      cursor = if @isTouch then x: e.touches[0].pageX, y: e.touches[0].pageY else x: e.clientX, y: e.clientY

      start = x: cursor.x - @outerFrame.offsetLeft, y: cursor.y - @outerFrame.offsetTop
      inFrame = (e.target is @frame) or (e.target.parentElement is @outerFrame)

      if @lastInFrame or inFrame
        @drawSegment(start, @last)
        @segments.push(start: start, end: @last)

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
    Strokes.insert(segments: @segments)
    @segments = []

  _active: ->
    Session.get("brushIsActive")
