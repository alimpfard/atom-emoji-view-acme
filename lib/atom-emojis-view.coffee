fs = require 'fs'
path = require 'path'

module.exports =
class AtomEmojisView
  constructor: (serializedState, emojsTable, dir) ->
    addEmoji = (emoji, gs, cursor) ->
      console.log(emoji)
      fpath = emojsTable[emoji]
      console.log(fpath)
      if fpath
        t = document.createElement 'img'
        t.src = path.join dir, fpath
        t.style = 'max-width: 1em;'
        d = gs.decorateMarker cursor.getMarker(), {type: 'gutter', item: t}
        cursor.onDidChangePosition (e) ->
          d.destroy()
    gs = null
    EMOJI_REG = /[\u{1f300}-\u{1f5ff}\u{1f900}-\u{1f9ff}\u{1f600}-\u{1f64f}\u{1f680}-\u{1f6ff}\u{2600}-\u{26ff}\u{2700}-\u{27bf}\u{1f1e6}-\u{1f1ff}\u{1f191}-\u{1f251}\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}\u{00ae}\u{2122}\u{23f3}\u{24c2}\u{23e9}-\u{23ef}\u{25b6}\u{23f8}-\u{23fa}]/ug
    EMOJI_NAME = /\\N\{([\w ]*)\}/g
    atom.workspace.observeTextEditors (editor) ->
      editor.onDidChangeCursorPosition (evt) ->
        if !gs
          gs = editor.addGutter {name: 'Emojis'}
        {cursor} = evt
        if !cursor || cursor == undefined
          console.log 'WTF no cursor?'
          return
        if cursor.isInsideWord ({wordRegex: EMOJI_REG})
          emoji = editor.getWordUnderCursor({wordRegex: EMOJI_REG})
          addEmoji emoji, gs, cursor
        if cursor.isInsideWord ({wordRegex: EMOJI_NAME})
          emoji = editor.getWordUnderCursor({wordRegex: EMOJI_NAME})
          emojis = emoji.match(EMOJI_NAME)[0]
          addEmoji emojis.substr(3, emojis.length-4), gs, cursor
  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  getElement: ->
