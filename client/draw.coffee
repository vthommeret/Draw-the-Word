Template.box.message = ->
  return unless messageBox = Session.get("messageBox")
  if updatedMessageBox = Messages.findOne(permalink: messageBox.permalink)
    updatedMessageBox.text

Template.box.events =
  'keyup textarea': (e) ->
    typedText = $(e.srcElement).val()
    Messages.update({permalink: Session.get("messageBox").permalink}, {$set: text: typedText})

  'click .clear': (e) ->
    Strokes.remove({})

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

  unless messageBox = Messages.findOne(permalink: "sample-box")
    Messages.insert(permalink: "sample-box", text: "Type something")

  Session.set("messageBox", messageBox or Messages.findOne(permalink: "sample-box"))

  unless currentRoom = Rooms.findOne(permalink: ROOM_NAME)
    Rooms.insert(permalink: ROOM_NAME, users: [], activePlayer: null)

  Session.set("currentRoom", currentRoom or Rooms.findOne(permalink: ROOM_NAME))

  Meteor.subscribe("allplayers", ->
    currentPlayer = Players.findOne(_id: readCookie("player-id"))
    unless currentPlayer?
      name = prompt("Enter your name:", "verlo")
      playerID = Players.insert(name: name)
      createCookie("player-id", playerID, 365)
      currentPlayer = Players.findOne(_id: playerID)

    Session.set("currentPlayer", currentPlayer))

  frame = document.getElementById('frame')
  outerFrame = document.getElementById('outer-frame')
  ctx = frame.getContext('2d')
  brush = new Brush()
  brush.initialize(frame: frame, outerFrame: outerFrame, ctx: ctx, radius: RADIUS, packing: PACKING, active: false)

  Strokes.find({}).observe(
    added: (stroke) ->
      unless brush.active
        brush.currentColor = stroke.color
        _.each(stroke.segments, (segment) ->
          brush.fillLine(segment.start, segment.end))
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
