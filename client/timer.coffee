# TODO: Clear out timers from @timers when done.
# TODO: Separate @timers array necessary?
class TimerQueue
  constructor: ->
    @queue = []
    @timers = []
    @running = false

  add: (timers) ->
    @queue.push(timers)

  run: ->
    return if not @queue.length or @running
    @running = true
    timers = @queue.shift()
    _.each(timers, (timer, i) =>
      if i is timers.length - 1
        fn = =>
          @running = false
          timer.fn()
          @run()
      else
        fn = timer.fn
      @timers.push(setTimeout(fn, timer.time))
    )

  clear: ->
    @queue = []
    _.each(@timers, (timer) ->
      clearTimeout timer
    )
    @timers = []
    @running = false
