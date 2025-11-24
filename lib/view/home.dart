import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:thikiti/service/send_to_db.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool ativo = false;
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _pedirPermissoes();
  }

  void _pedirPermissoes() async {
    bool? permitido = await telephony.requestPhoneAndSmsPermissions;
    if (permitido == true) {
      print("Permissões concedidas");
    } else {
      print("Permissões negadas");
    }
  }

  void _iniciarListenerSMS() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        if (!ativo) return;

        final remetente = message.address ?? "Desconhecido";
        final corpo = message.body ?? "";
        final data = DateTime.fromMillisecondsSinceEpoch(message.date ?? 0).toIso8601String();

        await SendToDb.saveSms(
          remetente: remetente,
          corpo: corpo,
          data: data,
        );
      },
      onBackgroundMessage: backgroundMessageHandler,
      listenInBackground: true,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(SmsMessage message) async {
    final remetente = message.address ?? "Desconhecido";
    final corpo = message.body ?? "";
    final data = DateTime.fromMillisecondsSinceEpoch(message.date ?? 0).toIso8601String();

    await SendToDb.saveSms(
      remetente: remetente,
      corpo: corpo,
      data: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusCor = ativo ? const Color(0xFF16A34A) : const Color(0xFF2E4B66);
    final statusTexto = ativo ? "ACTIVO" : "INACTIVO";
    final mensagemAviso = ativo ? "Salvando o registro financeiro" : null;

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * 0.95,
          height: 350,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: statusCor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF8FAFC).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: statusCor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Thikiti",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      ativo ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 80,
                      color: statusCor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statusTexto,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (mensagemAviso != null) ...[
                      Text(
                        mensagemAviso,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            ativo = !ativo;
                            if (ativo) {
                              _iniciarListenerSMS();
                            }
                          });
                        },
                        icon: Icon(ativo ? Icons.cancel : Icons.sms),
                        label: Text(ativo ? "Desligar" : "Ligar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          shadowColor: statusCor.withOpacity(0.4),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
