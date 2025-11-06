import 'package:flutter/material.dart';
import 'package:meal4you_app/provider/restaurant_provider.dart';
import 'package:meal4you_app/services/logout/adm_logout/adm_global_logout_service.dart';
import 'package:meal4you_app/services/logout/adm_logout/adm_logout_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:provider/provider.dart';

class AdmLogoutHandler {
  final AdmLogoutService _admLogoutService;
  final AdmGlobalLogoutService _admGlobalLogoutService;

  AdmLogoutHandler({
    AdmLogoutService? admLogoutService,
    AdmGlobalLogoutService? admGlobalLogoutService,
  })  : _admLogoutService = admLogoutService ?? AdmLogoutService(),
        _admGlobalLogoutService =
            admGlobalLogoutService ?? AdmGlobalLogoutService();

  Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja sair desta conta neste dispositivo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _handleLogout(context, onlyThisDevice: true);
              },
              child: const Text('Sair neste dispositivo'),
            ),
            // TextButton(
            //   onPressed: () async {
            //     Navigator.of(dialogContext).pop();
            //     await _handleLogout(context, onlyThisDevice: false);
            //   },
            //   child: const Text('Todos os dispositivos'),
            // ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(
    BuildContext context, {
    required bool onlyThisDevice,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (onlyThisDevice) {
        await _admLogoutService.logout();
      } else {
        await _admGlobalLogoutService.logoutGlobal();
      }

      await UserTokenSaving.clearAllUserData();

      final restaurantProvider =
          Provider.of<RestaurantProvider>(context, listen: false);
      restaurantProvider.updateRestaurant(
        name: '',
        description: '',
        location: '',
        isActive: false,
        foodTypes: [],
      );

      if (!context.mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            onlyThisDevice
                ? 'Sessão encerrada neste dispositivo.'
                : 'Sessões encerradas em todos os dispositivos.',
          ),
        ),
      );

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/admLogin', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao deslogar: $e')));
    }
  }
}
