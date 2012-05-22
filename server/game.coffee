Meteor.startup ->
  Meteor.publish "allplayers", ->
    Players.find({})

  Meteor.publish "allrooms", ->
    Rooms.find({})
