Template.box.message = ->
  if message = Messages.findOne(permalink: "sample-box")
    message.text

Template.box.events =
  'keyup textarea': (e) ->
    typedText = $(e.srcElement).val()
    Messages.update({permalink: "sample-box"}, {$set: text: typedText})

  'click .clear': (e) ->
    Strokes.remove({})
    frame = document.getElementById('frame')
    frame.getContext('2d').clearRect(0, 0, frame.width, frame.height)

  'click .start': (e) ->
    brush.startDrawing()

  'click .stop': (e) ->
    brush.stopDrawing()

Meteor.startup ->
  Strokes.remove({})
  RADIUS = 2
  PACKING = 2

  frame = document.getElementById('frame')
  ctx = frame.getContext('2d')
  window.brush = new Brush()
  window.brush.initialize(frame: frame, ctx: ctx, radius: RADIUS, packing: PACKING, startDrawing: false)

  Strokes.find({}).observe(
    added: (stroke) ->
      brush.fillLine(stroke.start, stroke.end, stroke.color) unless brush.isDrawing
    removed: -> # any remove event is a 'remove all' event, for now
      ctx.clearRect(0, 0, frame.width, frame.height)
  )
