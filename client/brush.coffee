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
    @activate() if opts.active
    @strokes = []
    @_updateSession()

  activate: ->
    document.addEventListener((if @isTouch then 'touchstart' else 'mousedown'), @eventListener)
    @active = true
    @_updateSession()

  deactivate: ->
    document.removeEventListener((if @isTouch then 'touchstart' else 'mousedown'), @eventListener)
    @active = false
    @_updateSession()

  eventListener: (e) =>
    return if e.target isnt @frame
    e.preventDefault()

    color = "rgb(#{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())})"
    moveFn = @move(color)

    document.addEventListener((if @isTouch then 'touchmove' else 'mousemove'), moveFn)

    document.addEventListener((if @isTouch then 'touchend' else 'mouseup'), (e) =>
      @flush()
      document.removeEventListener((if @isTouch then 'touchmove' else 'mousemove'), moveFn)
      @last = null
    )

  move: (color) ->
    (e) =>
      e.preventDefault()

      cursor = if @isTouch then x: e.touches[0].pageX, y: e.touches[0].pageY else x: e.clientX, y: e.clientY

      pos = x: cursor.x - @outerFrame.offsetLeft, y: cursor.y - @outerFrame.offsetTop
      inFrame = (e.target is @frame) or (e.target.parentElement is @outerFrame)

      @fillLine(pos, @last, color) if @lastInFrame or inFrame

      @last = pos
      @lastInFrame = inFrame

  fillLine: (start, end, color) ->
    @strokes.push(start: start, end: end, color: color) if @active
    color = 'black' unless color?
    r = @radius
    d = r * 2

    if end
      @drawCircle(end.x, end.y, r, color)
      dots = @packing * @dist(start, end) / d
      for i in [0...dots]
        @drawCircle(
          start.x + (i + 1) * (end.x - start.x) / (dots + 1),
          start.y + (i + 1) * (end.y - start.y) / (dots + 1),
          r,
          color
        )
    else @drawCircle(start.x, start.y, r, color)

  drawCircle: (x, y, radius, color) ->
    color = 'black' unless color?

    @ctx.save()
    @ctx.fillStyle = color
    @ctx.beginPath()
    @ctx.arc(x, y, radius, 0, Math.PI * 2)
    @ctx.closePath()
    @ctx.fill()
    @ctx.restore()

  dist: (start, end) ->
    Math.sqrt(Math.pow(end.x - start.x, 2) + Math.pow(end.y - start.y, 2))

  flush: ->
    _.each(@strokes, (stroke) ->
      Strokes.insert(start: stroke.start, end: stroke.end, color: stroke.color)
    )
    @strokes = []

  _updateSession: ->
    Session.set("brush", @)
