class window.Brush
  initialize: (opts) ->
    @isTouch = document.hasOwnProperty('ontouchstart')
    @last = undefined
    @lastInFrame = true
    @frame = opts.frame
    @ctx = opts.ctx
    @radius = opts.radius
    @packing = opts.packing
    document.addEventListener((if @isTouch then 'touchstart' else 'mousedown'), (e) =>
      return if e.target isnt frame
      e.preventDefault()

      color = "rgb(#{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())} , #{Math.floor(255 * Math.random())})"
      moveFn = @move(color)

      document.addEventListener((if @isTouch then 'touchmove' else 'mousemove'), moveFn)

      document.addEventListener((if @isTouch then 'touchend' else 'mouseup'), (e) =>
        document.removeEventListener((if @isTouch then 'touchmove' else 'mousemove'), moveFn)
        @last = null
      )
    )

  move: (color) ->
    (e) =>
      e.preventDefault()

      cursor = if @isTouch then x: e.touches[0].pageX, y: e.touches[0].pageY else x: e.clientX, y: e.clientY

      pos = x: cursor.x - @frame.offsetLeft, y: cursor.y - @frame.offsetTop
      inFrame = e.target is @frame

      @fillLine(pos, @last, color) if @lastInFrame or inFrame

      @last = pos
      @lastInFrame = inFrame

  fillLine: (start, end, color) ->
    Strokes.insert(start: start, end: end, color: color)
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

