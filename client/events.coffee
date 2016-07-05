window.Events =
  switchUser: ->
    Rooms.update("#{Session.get("currentRoomID")}", {$set: activePlayerID: Session.get("currentPlayerID")})

  clearCanvas: ->
    Strokes.remove({})
    frame = document.getElementById("frame")
    ctx = frame.getContext("2d")
    ctx.clearRect(0, 0, frame.width, frame.height)
