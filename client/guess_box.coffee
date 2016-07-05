class window.GuessBox
  constructor: (opts) ->
    opts.el.bind("submit", (e) =>
      if $("input", e.target).val().toLowerCase() is Session.get("currentWord").toLowerCase()
        @guessedRight()
      else
        @guessedWrong()
    )

  guessedRight: ->
    # add cool style things here
    Events.clearCanvas()
    Events.switchUser()

  guessedWrong: ->
