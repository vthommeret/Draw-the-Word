Meteor.startup ->
  Meteor.publish "allplayers", ->
    Players.find({})

  Meteor.publish "allrooms", ->
    Rooms.find({})

  Meteor.publish "allstrokes", ->
    Strokes.find({})

Meteor.setInterval(->
  now = new Date().getTime()
  remove_threshold = now - 20 * 1000 # 20 seconds
  Players.remove(last_keepalive: {$lt: remove_threshold})
10 * 1000)

Meteor.methods
  keepalive: (playerID) ->
    Players.update("#{playerID}", $set: {last_keepalive: new Date().getTime()})
