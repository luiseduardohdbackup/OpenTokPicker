// Generated by CoffeeScript 1.3.3
(function() {
  var archiveCreatedHandler, archiveLoadedHandler, idle, key, publisher, session, sessionConnectedHandler, sessionId, streamCreatedHandler, subscribeStreams, token;

  key = $('#info').attr('key');

  sessionId = $('#info').attr('session');

  token = $('#info').attr('token');

  idle = true;

  TB.setLogLevel(TB.DEBUG);

  archiveCreatedHandler = function(event) {
    window.archive = event.archives[0];
    session.startRecording(window.archive);
    return console.log(window.archive);
  };

  $('#loadArchiveButton').click(function() {
    return session.loadArchive('4f78d4e3-edb6-4d21-92da-dba0f4947202');
  });

  $('.recordButton').click(function() {
    console.log("button click");
    console.log(window.archive);
    if (idle) {
      if (window.archive === "") {
        session.createArchive(key, 'perSession', "" + (Date.now()));
      } else {
        session.startRecording(window.archive);
      }
      return idle = false;
    } else {
      session.stopRecording(window.archive);
      session.closeArchive(window.archive);
      return idle = true;
    }
  });

  archiveLoadedHandler = function(event) {
    window.archive = event.archives[0];
    return window.archive.startPlayback();
  };

  subscribeStreams = function(streams) {
    var div, divId, stream, _i, _len;
    for (_i = 0, _len = streams.length; _i < _len; _i++) {
      stream = streams[_i];
      if (stream.connection.connectionId === session.connection.connectionId) {
        return;
      }
      divId = "stream" + stream.streamId;
      div = $('<div />', {
        id: divId
      });
      $('#pubContainer').append(div);
      session.subscribe(stream, divId);
    }
  };

  sessionConnectedHandler = function(event) {
    console.log(event.archives);
    if (event.archives[0]) {
      window.archive = event.archives[0];
    }
    session.publish(publisher);
    return subscribeStreams(event.streams);
  };

  streamCreatedHandler = function(event) {
    return subscribeStreams(event.streams);
  };

  window.archive = "";

  publisher = TB.initPublisher(key, 'myPublisherDiv');

  session = TB.initSession(sessionId);

  session.addEventListener('sessionConnected', sessionConnectedHandler);

  session.addEventListener('streamCreated', streamCreatedHandler);

  session.addEventListener('archiveCreated', archiveCreatedHandler);

  session.addEventListener('archiveLoaded', archiveLoadedHandler);

  session.connect(key, token);

}).call(this);
