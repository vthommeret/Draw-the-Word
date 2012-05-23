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
    @currentColor = "#28d2f1" # sky blue
    @aggressive = opts.aggressive
    document.addEventListener((if @isTouch then 'touchstart' else 'mousedown'), @_mouseDownEvent)

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

  _mouseDownEvent: (e) =>
    return unless @_active()
    return if e.target isnt @frame
    e.preventDefault()

    # @currentColor = "rgb(#{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())})"
    upFn = (e) =>
      document.removeEventListener((if @isTouch then 'touchmove' else 'mousemove'), @_move)
      document.removeEventListener((if @isTouch then 'touchend' else 'mouseup'), upFn)
      if @aggressive then @currentStrokeID = null else @_passiveFlush()
      @last = null

    document.addEventListener((if @isTouch then 'touchmove' else 'mousemove'), @_move)
    document.addEventListener((if @isTouch then 'touchend' else 'mouseup'), upFn)

  _addSegment: (start, end) ->
    if @aggressive
      @_aggressiveFlush(start, end)
    else
      (@segments ||= []).push(start: start, end: end)

  _move: (e) =>
    e.preventDefault()

    cursor = if @isTouch then x: e.touches[0].pageX, y: e.touches[0].pageY else x: e.clientX, y: e.clientY

    start = x: cursor.x - @outerFrame.offsetLeft, y: cursor.y - @outerFrame.offsetTop
    inFrame = (e.target is @frame) or (e.target.parentElement is @outerFrame)

    if @lastInFrame or inFrame
      @drawSegment(start, @last)
      @_addSegment(start, @last)

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

  _passiveFlush: ->
    Strokes.insert(segments: @segments, color: @currentColor)
    @segments = []

  _aggressiveFlush: (start, end) ->
    if @currentStrokeID?
      Strokes.update("#{@currentStrokeID}", $push: {segments: {start: start, end: end}})
    else
      @currentStrokeID = Strokes.insert(segments: [start: start, end: end], color: @currentColor)

  _active: ->
    Session.get("brushIsActive")
