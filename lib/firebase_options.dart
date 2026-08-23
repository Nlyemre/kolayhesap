import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platformı desteklenmiyor');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Desteklenmeyen platform: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARmfBUrmNtVmbHBjWMjbsHTISF5CFdplo',
    appId: '1:831534707030:android:7d0d64f1abbd709b2926f7',
    messagingSenderId: '831534707030',
    projectId: 'kolayhesappro-f8747',
    databaseURL:
        'https://kolayhesappro-f8747-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'kolayhesappro-f8747.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLJv5ZS3OWJYspDfTEzVjiv74EPSMgMGY',
    appId: '1:831534707030:ios:c3cb5fa15492e5622926f7',
    messagingSenderId: '831534707030',
    projectId: 'kolayhesappro-f8747',
    databaseURL:
        'https://kolayhesappro-f8747-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'kolayhesappro-f8747.appspot.com',
    iosBundleId: 'com.kolayhesap.app',
  );
}
