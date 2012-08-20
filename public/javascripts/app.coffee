RECORD = "Record Videos"
RSTOP = "Stop Recording"
DOWNLOAD = "Process Video"
PROCESS = "Video Processing..."
READY = "Download"

interval = ""
key = $('#info').attr('key')
sessionId = $('#info').attr('session')
token = $('#info').attr('token')
downloadURL=""

TB.setLogLevel(TB.DEBUG)

filepicker.setKey( $('#info').attr('FPKey') )

parseArchiveResponse = (response) ->
  console.log response
  if response.status != "fail"
    window.clearInterval(interval)
    $('#startRecording').text(READY)
    downloadURL=response.url

getDownloadUrl = ->
  $.post "/archive/#{window.archive.archiveId}", {}, parseArchiveResponse

$('#startRecording').text(RECORD)

archiveClosedHandler = (event) ->
  console.log window.archive
  interval = window.setInterval(getDownloadUrl, 5000)

archiveCreatedHandler = (event) ->
  window.archive = event.archives[0]
  session.startRecording(window.archive)
  console.log window.archive

$('#startRecording').click ->
  console.log "button click"
  console.log window.archive
  switch $(@).text()
    when RECORD
      if window.archive==""
        session.createArchive( key, 'perSession', "#{Date.now()}")
      else
        session.startRecording(window.archive)
      $(@).text(RSTOP)
    when RSTOP
      session.stopRecording( window.archive )
      session.closeArchive( window.archive )
      $(@).text(PROCESS)
    when READY
      filepicker.saveAs downloadURL,'video/mp4', (url) ->
      $(@).remove()

archiveLoadedHandler = (event) ->
  window.archive = event.archives[0]
  window.archive.startPlayback()

subscribeStreams = (streams) ->
  for stream in streams
    if stream.connection.connectionId == session.connection.connectionId
      return
    divId = "stream#{stream.streamId}"
    div = $('<div />', {id:divId})
    $('#pubContainer').append(div)
    session.subscribe(stream, divId)
sessionConnectedHandler = (event) ->
  console.log event.archives
  if event.archives[0]
    window.archive=event.archives[0]
  session.publish( publisher )
  subscribeStreams(event.streams)
streamCreatedHandler = (event) ->
  subscribeStreams(event.streams)

window.archive = ""
publisher = TB.initPublisher( key, 'myPublisherDiv' )
session = TB.initSession(sessionId)
session.addEventListener( 'sessionConnected', sessionConnectedHandler )
session.addEventListener( 'streamCreated', streamCreatedHandler )
session.addEventListener( 'archiveCreated', archiveCreatedHandler )
session.addEventListener( 'archiveClosed', archiveClosedHandler )
session.addEventListener( 'archiveLoaded', archiveLoadedHandler )
session.connect( key, token )

