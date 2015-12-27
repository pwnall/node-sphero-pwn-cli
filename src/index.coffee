fs = require 'fs-promise'
Sphero = require 'sphero-pwn'

runBasic = (robot, sourcePath) ->
  sourceCode = null
  fs.readFile(sourcePath, encoding: 'utf8')
    .then (data) ->
      console.log "Read orBasic from #{sourcePath}"
      sourceCode = data
      robot.abortBasic()
    .then ->
      console.log 'Aborted current orBasic program'
      robot.loadBasic 'ram', sourceCode
    .then ->
      console.log 'Loaded orBasic into Sphero RAM'
      robot.executeBasic 'ram', 10
    .then ->
      console.log 'Started orBasic at line 10 in Sphero RAM'
    .catch (error) ->
      console.error error
      robot.close()

runMacro = (robot, sourcePath) ->
  macro = null
  fs.readFile(sourcePath, encoding: 'utf8')
    .then (data) ->
      console.log "Read macro from #{sourcePath}"
      macro = Sphero.Macro.compile data
      console.log "Compiled macro"
      robot.resetMacros()
    .then ->
      console.log "Reset Sphero macro executive"
      robot.setMacro 0xFF, new Buffer(macro.bytes)
    .then ->
      console.log "Loaded macro into Sphero RAM"
      robot.runMacro 0xFF
    .then ->
      console.log "Started macro"
    .catch (error) ->
      console.error error
      robot.close()

module.exports.bootCli = ->
  sourceId = process.argv[2]
  sourcePath = process.argv[3]

  if sourcePath.endsWith('.bas')
    run = runBasic
  else if sourcePath.endsWith('.macro')
    run = runMacro
  else
    console.error "Unsupported source code extension"
    process.exit 1

  Sphero.Discovery.findChannel(sourceId)
    .then (channel) ->
      recorder = new Sphero.ChannelRecorder channel, 'sphero.log'
      recorder.open().then -> recorder
    .then (recorder) ->
      robot = new Sphero.Robot recorder
      robot.on 'error', (error) ->
        console.error error
      robot.on 'macro', (event) ->
        console.log "macro marker: #{event.markerId} macro #{event.macroId} " +
                    "command: #{event.commandId}"
      robot.on 'basicPrint', (event) ->
        console.log "orbBasic print: #{event.message}"
      robot.on 'basicError', (event) ->
        console.log "orbBasic error: #{event.message}"

      run robot, sourcePath
