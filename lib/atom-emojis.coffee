AtomEmojisView = require './atom-emojis-view'
{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports = AtomEmojis =
  atomEmojisView: null
  modalPanel: null
  subscriptions: null
  provide: ->
    if !@atomEmojisView
      @activate null
    console.log 'Providing shit'
    return @atomEmojisView.emojiCompletion()

  activate: (state) ->
    table = JSON.parse(fs.readFileSync(path.join __dirname, 'res.json'))
    trs = JSON.parse(fs.readFileSync(path.join __dirname, 'tr.json'))

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @atomEmojisView = new AtomEmojisView(state.atomEmojisViewState, table, trs, __dirname, @subscriptions)

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-emojis:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @atomEmojisView.destroy()

  serialize: ->
    atomEmojisViewState: @atomEmojisView.serialize()

  toggle: ->
    console.log 'AtomEmojis was toggled!'

  config:
    emojiDisplaySize:
      title: 'Size of the rendered emoji in em'
      type: 'integer'
      default: 3
      minimum: 1
