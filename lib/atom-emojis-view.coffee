fs = require 'fs'
path = require 'path'

EMOJI_REG = (require 'emoji-regex')()
EMOJI_NAME = /\\N\{([\w ]*)\}/

module.exports =
class AtomEmojisView
  repls: null
  emojsTable: null
  constructor: (serializedState, emojsTable, repls, dir, subs) ->
    maps = {}
    cmds = {}
    @repls = repls
    @emojsTable = emojsTable
    addEmoji = (emoji, editor, cursor, c) ->
      emoji = editor.getTextInBufferRange(emoji)
      fpath = emojsTable[emoji]
      if fpath
        t = document.createElement 'img'
        t.src = path.join dir, fpath
        t.style = 'max-width: Xem; height: Xem;'.replace('X', atom.config.get 'atom-emojis.emojiDisplaySize')
        div = document.createElement 'div'
        div.appendChild t
        div.style = 'float: left'
        d = editor.decorateMarker cursor.getMarker(), {type: 'overlay', item: div}
        maps[cursor.getBufferPosition()] = true
        cursor.onDidChangePosition (e) ->
          maps[cursor.getBufferPosition()] = false
          d.destroy()
          if c
            c.dispose()
    gs = null
    atom.workspace.observeTextEditors (editor) ->
      editor.onDidChangeCursorPosition (evt) ->
        {cursor} = evt
        if !cursor || cursor == undefined
          console.log 'WTF no cursor?'
          return
        do_replace = (cursor, emoji) ->
          if maps[cursor.getBufferPosition()]
            text = editor.getTextInBufferRange emoji
            emojiText = text.match(EMOJI_NAME)?[1] or ''
            repl = repls[emojiText]
            if !repl
              console.log "Missing descriptor for " + text
              return
            maps[cursor.getBufferPosition()] = false
            emojiText = editor.getTextInBufferRange(emoji)
            editor.setTextInBufferRange(emoji, repl)
        emojiR = cursor.getCurrentWordBufferRange({wordRegex: EMOJI_REG})
        if !emojiR.isEmpty()
          addEmoji emojiR, editor, cursor, null
          return

        emojiR = cursor.getCurrentWordBufferRange({wordRegex: EMOJI_NAME})
        if !emojiR.isEmpty()
          range = emojiR
          c = atom.commands.add 'atom-workspace', 'atom-emojis:do_replace': => do_replace(cursor, range)
          emojiR = emojiR.translate [0, 3], [0, -1]
          addEmoji emojiR, editor, cursor, c


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  getElement: ->

  emojiCompletion: ->
    repls = @repls
    emojsTable = @emojsTable
    r =
      selector: '*'
      # This will take priority over the default provider, which has an inclusionPriority of 0.
      # `excludeLowerPriority` will suppress any providers with a lower priority
      # i.e. The default provider will be suppressed
      inclusionPriority: 1
      excludeLowerPriority: false

      # This will be suggested before the default provider, which has a suggestionPriority of 1.
      suggestionPriority: 2

      # Let autocomplete+ filter and sort the suggestions you provide.
      filterSuggestions: false

      # Required: Return a promise, an array of suggestions, or null.
      getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
        matching = []
        src = editor.getTextInBufferRange([[bufferPosition.row, 0], bufferPosition])
        re = /\\N\{([\w ]*)/g
        text = ''
        while true
          vtext = re.exec(src)
          if vtext == null
            break
          text = vtext
        return if !text || (text.index + text[0].length) < bufferPosition.column
        textPrefix = text[1]
        text = text[1].replace(/\s/g, ' ').trim()
        new Promise (resolve) ->
          if text
            matching = Object.entries(repls).filter((v) -> v[1].match('\\b'+text))
          resolve(matching.map((f) -> {
            text: f[1] + '}',
            displayText: f[1],
            replacementPrefix: textPrefix,
            leftLabelHTML: '<img src="X">'.replace('X', path.join(__dirname, emojsTable[f[0]])),
            description: f[0]
            })
          )

    return r
