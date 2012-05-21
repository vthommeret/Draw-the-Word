
Template.box.message = ->
  if message = Messages.findOne(permalink: "sample-box")
    message.text

Template.box.events =
  'keyup textarea': (e) ->
    typedText = $(e.srcElement).val()
    Messages.update({permalink: "sample-box"}, {$set: text: typedText})

  'click .clear': (e) ->
    Strokes.remove({})

  # Find a way to get rid of all this jquery code via Meteor

  'click .start': (e) =>
    Rooms.update({permalink: Session.get("currentRoom").permalink}, {$set: activePlayer: Session.get("currentPlayer")})

Template.box.startButtonEnabled = ->
  return unless currentRoom = Session.get("currentRoom")
  return unless currentPlayer = Session.get("currentPlayer")

  roomActivePlayer = Rooms.findOne(permalink: currentRoom.permalink).activePlayer
  return true unless roomActivePlayer

  roomActivePlayer._id isnt currentPlayer._id

Template.box.players = ->
  Players.find({})

Meteor.startup ->
  RADIUS = 2
  PACKING = 2
  ROOM_NAME = "room2"

  unless currentRoom = Rooms.findOne(permalink: ROOM_NAME)
    Rooms.insert(permalink: ROOM_NAME, users: [], activePlayer: null)

  Session.set("currentRoom", currentRoom or Rooms.findOne(permalink: ROOM_NAME))

  randomNumber = Math.floor(Math.random() * 100)

  unless currentPlayer = Players.findOne(name: "#{randomNumber}")
    Players.insert(name: "#{randomNumber}")

  Session.set("currentPlayer", currentPlayer or Players.findOne(name: "#{randomNumber}"))

  frame = document.getElementById('frame')
  ctx = frame.getContext('2d')
  brush = new Brush()
  brush.initialize(frame: frame, ctx: ctx, radius: RADIUS, packing: PACKING, active: false)

  Strokes.find({}).observe(
    added: (stroke) ->
      brush.fillLine(stroke.start, stroke.end, stroke.color) unless brush.active
    removed: -> # any remove event is a 'remove all' event, for now
      ctx.clearRect(0, 0, frame.width, frame.height)
  )

  Rooms.find(permalink: ROOM_NAME).observe(
    changed: (room) ->
      if room.activePlayer._id is Session.get("currentPlayer")._id
        Session.get("brush").activate()
      else
        Session.get("brush").deactivate()
  )
