Template.box.message = ->
  if message = Messages.findOne(permalink: "sample-box")
    message.text

Template.box.events =
  'keyup textarea': (e) ->
    typedText = $(e.srcElement).val()
    Messages.update({permalink: "sample-box"}, {$set: text: typedText})

  'click input': (e) ->
    Strokes.remove({})
    frame = document.getElementById('frame')
    frame.getContext('2d').clearRect(0, 0, frame.width, frame.height)

Meteor.startup ->
  RADIUS = 2
  PACKING = 2

  frame = document.getElementById('frame')
  ctx = frame.getContext('2d')
  (new Brush()).initialize(frame: frame, ctx: ctx, radius: RADIUS, packing: PACKING)

  Meteor.setInterval(->
  5 * 1000)
