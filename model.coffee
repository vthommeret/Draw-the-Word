globalObject = if Meteor.is_client then window else global
globalObject.Strokes = new Meteor.Collection("strokes")
globalObject.Rooms = new Meteor.Collection("rooms")
globalObject.Players = new Meteor.Collection("players")
