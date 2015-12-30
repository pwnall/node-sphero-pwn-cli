fs = require 'fs-promise'
Sphero = require 'sphero-pwn'
macros = require 'sphero-pwn-macros'

runBasic = (robots, sourcePath) ->
  sourceCode = null
  fs.readFile(sourcePath, encoding: 'utf8')
    .then (data) ->
      console.log "Read orbBasic from #{sourcePath}"
      sourceCode = data
      robot.abortBasic()
    .then ->
      console.log 'Aborted current orbBasic programs'
      loadPromises = for robot in robots
        robot.loadBasic 'ram', sourceCode
      Promise.all loadPromises
    .then ->
      console.log 'Loaded orbBasic into Sphero RAM'
      runPromises = for robot in robots
        robot.runBasic 'ram', 10
      Promise.all runPromises
    .then ->
      console.log 'Started orbBasic at line 10 in Sphero RAM'
    .catch (error) ->
      console.error error
      robot.close()

runMacro = (robots, sourcePath) ->
  macro = null
  fs.readFile(sourcePath, encoding: 'utf8')
    .then (data) ->
      console.log "Read macro from #{sourcePath}"
      macro = macros.compile data
      console.log "Compiled macro: #{macro.bytes.length} bytes"
      resetPromises = for robot in robots
        robot.resetMacros()
      Promise.all resetPromises
    .then ->
      console.log "Reset Sphero macro executives"
      loadPromises = for robot in robots
        robot.loadMacro 0xFF, new Buffer(macro.bytes)
      Promise.all loadPromises
    .then ->
      console.log "Loaded macro into Spheros RAM"
      runPromises = for robot in robots
        robot.runMacro 0xFF
      Promise.all runPromises
    .then ->
      console.log "Started macro"
    .catch (error) ->
      console.error error
      robot.close()

module.exports.bootCli = ->
  sourceIds = process.argv[2].split(',')
  sourcePath = process.argv[3]

  if sourcePath.endsWith('.bas')
    run = runBasic
  else if sourcePath.endsWith('.macro')
    run = runMacro
  else
    console.error "Unsupported source code extension"
    process.exit 1

  Sphero.Discovery.findChannels(sourceIds)
    .then (channelsBySource) ->
      channels = []
      for _, channel of channelsBySource
        channels.push channel

      recorders = for channel, i in channels
        new Sphero.ChannelRecorder channel, "sphero#{i + 1}.log"

      openPromises = (recorder.open() for recorder in recorders)
      Promise.all(openPromises).then -> recorders
    .then (channels) ->
      robots = for channel in channels
        robot = new Sphero.Robot channel
        do ->
          sourceId = robot.channel().sourceId
          robot.on 'error', (error) ->
            console.log "Received error from #{sourceId}"
            console.error error
          robot.on 'macro', (event) ->
            console.log "#{sourceId} macro marker: #{event.markerId} macro " +
                        "#{event.macroId} command: #{event.commandId}"
          robot.on 'basic', (event) ->
            console.log "#{sourceId} orbBasic print: #{event.message}"
          robot.on 'basicError', (event) ->
            console.log "#{sourceId} orbBasic error: #{event.message}"
        robot

      run robots, sourcePath
    .catch (error) ->
      console.error error
