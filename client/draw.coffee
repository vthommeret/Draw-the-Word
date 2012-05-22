Template.box.events =
  'click .clear': (e) ->
    Strokes.remove({})

  'click .start': (e) =>
    Rooms.update("#{Session.get("currentRoomID")}", {$set: activePlayerID: Session.get("currentPlayerID")})

Template.box.startButtonEnabled = ->
  not Session.get("brushIsActive")

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

    Meteor.subscribe "allplayers", ->
      currentPlayer = Players.findOne(_id: readCookie("player-id"))
      unless currentPlayer?
        name = prompt("Enter your name:", "verlo")
        playerID = Players.insert(name: name, last_keepalive: new Date().getTime(), roomID: currentRoom._id)
        createCookie("player-id", playerID, 365)
        currentPlayer = Players.findOne(_id: playerID)

      Session.set("currentPlayerID", currentPlayer._id)
      brush.activate() if currentRoom.activePlayerID is currentPlayer._id

      # to do, subscribe to 'strokesforthisroom' and have corresponding publish function
      # this will also make it so we can populate the canvas when the user joins





  frame = document.getElementById('frame')
  outerFrame = document.getElementById('outer-frame')
  ctx = frame.getContext('2d')
  brush = new Brush()
  brush.initialize(frame: frame, outerFrame: outerFrame, ctx: ctx, radius: RADIUS, packing: PACKING, active: false)

  Strokes.find({}).observe
    added: (stroke) ->
      unless brush.active
        brush.currentColor = stroke.color
        _.each stroke.segments, (segment) ->
          brush.fillLine(segment.start, segment.end)
    removed: -> # any remove event is a 'remove all' event, for now
      ctx.clearRect(0, 0, frame.width, frame.height)

  Rooms.find(name: "My Room").observe
    changed: (room) ->
      if room.activePlayerID is Session.get("currentPlayerID")
        brush.activate()
      else
        brush.deactivate()

Meteor.setInterval(->
  if Meteor.status().connected
    console.log "sending keepalive"
    Meteor.call("keepalive", Session.get("currentPlayerID"))
5 * 1000)
