Template.box.message = ->
  if message = Messages.findOne(permalink: "sample-box")
    message.text

Template.box.events =
  'keyup textarea': (e) ->
    typedText = $(e.srcElement).val()
    Messages.update({permalink: "sample-box"}, {$set: text: typedText})
