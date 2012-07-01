# Title template

Session.set('currentWord', 'Crayon')

Template.title.text = ->
  word = Session.get('currentWord')
  if Session.get('brushIsActive')
    word
  else
    blanks = ''
    _(word.length).times(->
      blanks += '_'
    )
    blanks

Template.title.isBlank = ->
  not Session.get('brushIsActive')

# Eraser template

startButtonEnabled = ->
  not Session.get("brushIsActive")

Template.eraser.startButtonEnabled = startButtonEnabled

Template.eraser.events =
  'click .clear': (e) ->
    Strokes.remove({})
    frame = document.getElementById("frame")
    ctx = frame.getContext("2d")
    ctx.clearRect(0, 0, frame.width, frame.height)

# Start template

Template.start.events =
  'click .start': (e) =>
    Rooms.update("#{Session.get("currentRoomID")}", {$set: activePlayerID: Session.get("currentPlayerID")})

Template.start.startButtonEnabled = startButtonEnabled

# Players template

Template.players.players = ->
  return unless Session.get("currentRoomID")
  Players.find(roomID: Session.get("currentRoomID"))

Template.players.isDrawing = ->
  roomId = Session.get("currentRoomID").toString()
  room = Rooms.findOne(roomId)
  room.activePlayerID is this._id

# Guess template

Template.guess.events =
  'submit #guess-form': (e) ->
    e.preventDefault()
    guess = $('#guess')
    guess.val('')
    guess.blur()

Template.guess.isDrawing = ->
  Session.get('brushIsActive')


# Startup

Meteor.startup ->
  RADIUS = 2
  PACKING = 2

  if /mobile/i.test(navigator.userAgent) && !location.hash
    setTimeout(->
      window.scrollTo(0, 1)
    , 1000)

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
  brush = new Brush(frame: frame, outerFrame: outerFrame, ctx: ctx, radius: RADIUS, packing: PACKING, aggressive: true)
  timerQueue = new TimerQueue()

  Meteor.subscribe("allstrokes")

  Strokes.find({}).observe(
    added: (stroke) ->
      return if brush.didDraw()
      timers = []
      _.each stroke.segments, (segment) ->
        timers.push(
          fn: -> brush.drawSegment(segment.start, segment.end),
          time: segment.time
        )
      timerQueue.add(timers)
      timerQueue.run()
    removed: ->
      timerQueue.clear()
      ctx.clearRect(0, 0, frame.width, frame.height)
  )

Meteor.setInterval(->
  if Meteor.status().connected
    Meteor.call("keepalive", Session.get("currentPlayerID"))
5 * 1000)
