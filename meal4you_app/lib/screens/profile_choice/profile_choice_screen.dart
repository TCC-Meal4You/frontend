import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:meal4you_app/screens/descriptions_client_adm/descriptions_client_adm_screen.dart';

class ProfileChoiceScreen extends StatefulWidget {
  const ProfileChoiceScreen({super.key});

  @override
  State<ProfileChoiceScreen> createState() => _ProfileChoiceScreenState();
}

class _ProfileChoiceScreenState extends State<ProfileChoiceScreen> {
  final SuperTooltipController tooltipController = SuperTooltipController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tooltipController.showTooltip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        tooltipController.hideTooltip();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DescriptionsClientAdm(dados: {}),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/client.jpg"),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SuperTooltip(
                    controller: tooltipController,
                    popupDirection: TooltipDirection.up,
                    showCloseButton: true,
                    closeButtonColor: Colors.white,
                    barrierColor: Colors.black38,
                    backgroundColor: Color.fromARGB(255, 136, 0, 255),
                    borderRadius: 12,
                    content: const Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "ESCOLHA SEU PERFIL",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    child: const Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        tooltipController.hideTooltip();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DescriptionsClientAdm(dados: {}),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/adm.jpg"),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
