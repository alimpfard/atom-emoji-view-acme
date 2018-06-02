AtomEmojisView = require './atom-emojis-view'
{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports = AtomEmojis =
  atomEmojisView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    table = JSON.parse(fs.readFileSync(path.join __dirname, 'res.json'))
    @atomEmojisView = new AtomEmojisView(state.atomEmojisViewState, table, __dirname)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-emojis:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @atomEmojisView.destroy()

  serialize: ->
    atomEmojisViewState: @atomEmojisView.serialize()

  toggle: ->
    console.log 'AtomEmojis was toggled!'
