import 'package:cast/cast.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';

class CastService {
  Future<List<CastDevice>> searchForDevices() {
    Future<List<CastDevice>> devices = CastDiscoveryService().search();
    return devices;
  }

  Future<void> connectToChromecast(CastDevice object) async {
    final session = await CastSessionManager().startSession(object);

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        _sendMessageToYourApp(session);
      }
    });

    session.messageStream.listen((message) {
      printMessageInDebugMode('receive message: $message');
    });

    // session.sendMessage(CastSession.kNamespaceReceiver, {
    //   'type': 'LAUNCH',
    //   'appId': 'Youtube', // set the appId of your app here
    // });
  }

  void _sendMessageToYourApp(CastSession session) {
    printMessageInDebugMode('_sendMessageToYourApp');

    session.sendMessage('urn:x-cast:namespace-of-the-app', {
      'type': 'sample',
    });
  }

  Future<void> connectAndPlayMedia(CastDevice object, Audio? audio) async {
    final session = await CastSessionManager().startSession(object);

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        printMessageInDebugMode('Connected to session');
      }
    });

    var index = 0;

    session.messageStream.listen((message) {
      index += 1;

      printMessageInDebugMode('receive message: $message');

      if (index == 2) {
        Future.delayed(const Duration(seconds: 5)).then((x) {
          if (audio != null) {
            _sendMessagePlayVideo(session, audio);
          }
        });
      }
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      // 'appId': 'CC1AD845', // set the appId of your app here
    });
  }

  void _sendMessagePlayVideo(CastSession session, Audio audio) {
    var message = {
      // Here you can plug an URL to any mp4, webm, mp3 or jpg file with the proper contentType.
      'contentId': audio.url,
      'contentType': 'audio/mpeg',
      'streamType': 'LIVE', // LIVE or BUFFERED

      // Title and cover displayed while buffering
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': audio.title,
        'images': [
          {'url': audio.imageUrl ?? ''},
        ],
      },
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': 0,
      'media': message,
    });
  }

  void dispose() {
    final session = CastSessionManager();
    List<CastSession> connectedSessions = session.sessions;
    for (CastSession ses in connectedSessions) {
      session.endSession(ses.sessionId);
    }
  }
}
