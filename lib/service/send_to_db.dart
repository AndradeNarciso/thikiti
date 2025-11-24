import 'package:cloud_firestore/cloud_firestore.dart';

class SendToDb {
  static Future<void> saveSms({
    required String remetente,
    required String corpo,
    required String data,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios_teste_thikiti')
          .add({
        'Remetente': remetente,
        'Corpo da mensagem': corpo,
        'Data Emissao': data,
        'usado': false,
      });
      
    // ignore: empty_catches
    } catch (e) {
    }
  }
}
