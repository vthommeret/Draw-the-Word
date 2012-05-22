startButtonEnabled = ->
  not Session.get("brushIsActive")

Template.sidebar.startButtonEnabled = startButtonEnabled

Template.sidebar.events =
  'click .clear': (e) ->
    Strokes.remove({})
    frame = document.getElementById("frame")
    ctx = frame.getContext("2d")
    ctx.clearRect(0, 0, frame.width, frame.height)

Template.box.events =
  'click .start': (e) =>
    Rooms.update("#{Session.get("currentRoomID")}", {$set: activePlayerID: Session.get("currentPlayerID")})

Template.box.startButtonEnabled = startButtonEnabled

Template.box.players = ->
  return unless Session.get("currentRoomID")
  Players.find(roomID: Session.get("currentRoomID"))

Meteor.startup ->
  RADIUS = 2
  PACKING = 2

  Meteor.subscribe "allrooms", ->
    currentRoom = Rooms.findOne(name: "My Room")
    unless currentRoom?
      Rooms.insert(name: "My Room", activePlayerID: null)
      currentRoom = Rooms.findOne(name: "My Room")
    Session.set("currentRoomID", currentRoom._id)

    Rooms.find("#{currentRoom._id}").observe
      changed: (room) ->
        if room.activePlayerID is Session.get("currentPlayerID")
          Session.set("brushIsActive", true)
        else
          Session.set("brushIsActive", false)

    Meteor.subscribe "allplayers", ->
      currentPlayer = Players.findOne(_id: readCookie("player-id"))
      unless currentPlayer?
        name = prompt("Enter your name:", "verlo")
        playerID = Players.insert(name: name, last_keepalive: new Date().getTime(), roomID: currentRoom._id)
        createCookie("player-id", playerID, 365)
        currentPlayer = Players.findOne(_id: playerID)

      Session.set("currentPlayerID", currentPlayer._id)
      Session.set("brushIsActive", currentRoom.activePlayerID is currentPlayer._id)

  frame = document.getElementById('frame')
  outerFrame = document.getElementById('outer-frame')
  ctx = frame.getContext('2d')
  brush = new Brush()
  brush.initialize(frame: frame, outerFrame: outerFrame, ctx: ctx, radius: RADIUS, packing: PACKING, active: false)

  Meteor.autosubscribe ->
    ctx.clearRect(0, 0, frame.width, frame.height) unless Session.get("brushIsActive")
    Strokes.find({}).forEach (stroke) ->
      return if Session.get("brushIsActive")
      brush.currentColor = stroke.color
      _.each stroke.segments, (segment) ->
        brush.fillLine(segment.start, segment.end)

Meteor.setInterval(->
  if Meteor.status().connected
    Meteor.call("keepalive", Session.get("currentPlayerID"))
5 * 1000)
