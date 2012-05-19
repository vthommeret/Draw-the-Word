globalObject = if Meteor.is_client then window else global
globalObject.Messages = new Meteor.Collection("messages")
