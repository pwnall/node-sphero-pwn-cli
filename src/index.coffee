fs = require 'fs-promise'
Sphero = require 'sphero-pwn'

module.exports.bootCli = ->
  rfconnPath = process.argv[2]
  channel = new Sphero.Channel rfconnPath
  recorder = new Sphero.ChannelRecorder channel, 'sphero.log'
  robot = new Sphero.Robot recorder
  robot.on 'error', (error) ->
    console.error error
  robot.on 'basicPrint', (message) ->
    console.log "orbBasic print: #{message}"
  robot.on 'basicError', (message) ->
    console.log "orbBasic error: #{message}"

  basicPath = process.argv[3]
  basicCode = null

  fs.readFile(basicPath, encoding: 'utf8')
    .then (data) ->
      console.log "Read orBasic from #{basicPath}"
      basicCode = data
      robot.abortBasic()
    .then ->
      console.log "Reset Spehro at #{rfconnPath}"
      robot.loadBasic 'ram', basicCode
    .then ->
      console.log "Loaded orBasic into Sphero RAM"
      robot.executeBasic 'ram', 10
    .then ->
      console.log "Started orBasic at line 10 in Sphero RAM"
    .catch (error) ->
      console.error error
      robot.close()
