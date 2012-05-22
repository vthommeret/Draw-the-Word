Meteor.startup ->
  Meteor.publish("allplayers", ->
    Players.find({}))

Meteor.setInterval(->

30 * 1000)
