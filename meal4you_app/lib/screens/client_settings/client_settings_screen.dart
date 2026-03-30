import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/services/search_profile/search_client_profile_service.dart';
import 'package:meal4you_app/services/update_profile/update_client_profile_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_account_info_card/client_settings_account_info_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_delete_account_card/client_settings_delete_account_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_email_card/client_settings_email_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_header/client_settings_header.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_personal_info_card/client_settings_personal_info_card.dart';

class ClientSettingsScreen extends StatefulWidget {
  const ClientSettingsScreen({super.key});

  @override
  State<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends State<ClientSettingsScreen> {
  String _nome = 'Usuário';
  String _email = 'email@exemplo.com';
  String _senha = '';
  bool _isLoading = true;
  bool _mostrarSenha = false;
  bool _obscureSenha = true;
  bool _isSocialLogin = false;
  bool _isEditing = false;
  bool _isSaving = false;

  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    var nome = _nome;
    var email = _email;
    var senha = _senha;
    var isSocialLogin = false;

    try {
      final userData = await UserTokenSaving.getUserData().timeout(
        const Duration(seconds: 4),
      );
      final savedEmail = await UserTokenSaving.getUserEmail().timeout(
        const Duration(seconds: 4),
      );
      final savedPassword = await UserTokenSaving.getUserPassword().timeout(
        const Duration(seconds: 4),
      );

      Map<String, dynamic>? profileData;
      try {
        profileData = await SearchClientProfileService.buscarMeuPerfil()
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        profileData = null;
      }

      final localName = _extractName(userData);
      final profileName = _extractName(profileData);
      final localEmail = _extractEmail(userData, savedEmail);
      final profileEmail = _extractEmail(profileData, savedEmail);

      final extractedName = profileName.isNotEmpty ? profileName : localName;
      final extractedEmail = profileEmail.isNotEmpty
          ? profileEmail
          : localEmail;

      nome = extractedName.isNotEmpty ? extractedName : 'Usuário';
      email = extractedEmail.isNotEmpty
          ? extractedEmail
          : 'E-mail não encontrado';
      senha = (savedPassword ?? '').trim();
      isSocialLogin = _detectSocialLogin(userData, senha);
    } catch (e) {
      debugPrint('Erro ao carregar dados do cliente no settings: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _nome = nome;
        _email = email;
        _senha = senha;
        _isSocialLogin = isSocialLogin;
        _nomeController.text = nome;
        _isLoading = false;
      });
    }
  }

  bool _detectSocialLogin(Map<String, dynamic>? userData, String senha) {
    if (senha.isNotEmpty) return false;
    if (userData == null) return true;

    final provider = (userData['provider'] ?? userData['authProvider'] ?? '')
        .toString()
        .toLowerCase();

    final hasGoogleHints =
        provider.contains('google') ||
        userData['googleId'] != null ||
        userData['firebaseUid'] != null;

    return hasGoogleHints || senha.isEmpty;
  }

  String _extractName(Map<String, dynamic>? userData) {
    if (userData == null) return '';

    final topLevelName = (userData['nome'] ?? userData['name'] ?? '')
        .toString()
        .trim();
    if (topLevelName.isNotEmpty) return topLevelName;

    final user = userData['user'];
    if (user is Map<String, dynamic>) {
      final nestedName = (user['nome'] ?? user['name'] ?? '').toString().trim();
      if (nestedName.isNotEmpty) return nestedName;
    }

    return '';
  }

  String _extractEmail(Map<String, dynamic>? userData, String? savedEmail) {
    final fromSaved = (savedEmail ?? '').trim();
    if (fromSaved.isNotEmpty) return fromSaved;

    if (userData == null) return '';

    final topLevelEmail = (userData['email'] ?? '').toString().trim();
    if (topLevelEmail.isNotEmpty) return topLevelEmail;

    final user = userData['user'];
    if (user is Map<String, dynamic>) {
      final nestedEmail = (user['email'] ?? '').toString().trim();
      if (nestedEmail.isNotEmpty) return nestedEmail;
    }

    return '';
  }

  String _buildPasswordText() {
    if (_isSocialLogin) return 'Conta com login social';
    if (_senha.isEmpty) return 'Não definida';
    if (_mostrarSenha) return _senha;
    return '•' * _senha.length.clamp(6, 24);
  }

  String _getInitial() {
    if (_nome.trim().isEmpty) return 'U';
    return _nome.trim()[0].toUpperCase();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _nomeController.text = _nome;
        _senhaController.clear();
      } else {
        _nomeController.text = _nome;
        _senhaController.clear();
        _obscureSenha = true;
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    final novoNome = _nomeController.text.trim();
    final novaSenha = _senhaController.text.trim();

    if (novoNome.isEmpty && novaSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha pelo menos um campo para atualizar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (novoNome.isNotEmpty && novoNome.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome deve ter no mínimo 3 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (novaSenha.isNotEmpty && novaSenha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter no mínimo 6 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isSocialLogin && novaSenha.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contas Google não podem alterar senha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await UpdateClientProfileService.atualizarMeuPerfil(
        nome: novoNome.isNotEmpty ? novoNome : null,
        senha: novaSenha.isNotEmpty ? novaSenha : null,
      );

      if (novoNome.isNotEmpty) {
        final userData = await UserTokenSaving.getUserData();
        if (userData != null) {
          userData['nome'] = novoNome;
          if (userData['user'] is Map<String, dynamic>) {
            (userData['user'] as Map<String, dynamic>)['nome'] = novoNome;
          }
          await UserTokenSaving.saveUserData(userData);
        }
      }

      if (novaSenha.isNotEmpty) {
        await UserTokenSaving.saveUserPassword(novaSenha);
      }

      if (!mounted) return;
      setState(() {
        if (novoNome.isNotEmpty) {
          _nome = novoNome;
          _nomeController.text = novoNome;
        }
        if (novaSenha.isNotEmpty) {
          _senha = novaSenha;
          _mostrarSenha = false;
        }
        _isEditing = false;
        _isSaving = false;
        _senhaController.clear();
        _obscureSenha = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onDeleteAccountTap() {}

  @override
  Widget build(BuildContext context) {
    final clientLogoutHandler = ClientLogoutHandler();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClientSettingsHeader(
                initial: _getInitial(),
                onLogout: () => clientLogoutHandler.showLogoutDialog(context),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ClientSettingsPersonalInfoCard(
                      isLoading: _isLoading,
                      nome: _nome,
                      isSocialLogin: _isSocialLogin,
                      isEditing: _isEditing,
                      isSaving: _isSaving,
                      passwordText: _buildPasswordText(),
                      isPasswordVisible: _mostrarSenha,
                      hasPassword: _senha.isNotEmpty,
                      obscurePasswordField: _obscureSenha,
                      nomeController: _nomeController,
                      senhaController: _senhaController,
                      onEditTap: _toggleEditMode,
                      onTogglePassword: () {
                        setState(() => _mostrarSenha = !_mostrarSenha);
                      },
                      onTogglePasswordField: () {
                        setState(() => _obscureSenha = !_obscureSenha);
                      },
                      onSaveChanges: _saveChanges,
                    ),
                    const SizedBox(height: 20),
                    ClientSettingsEmailCard(
                      isLoading: _isLoading,
                      email: _email,
                      isSocialLogin: _isSocialLogin,
                    ),
                    const SizedBox(height: 20),
                    const ClientSettingsAccountInfoCard(),
                    const SizedBox(height: 20),
                    ClientSettingsDeleteAccountCard(
                      onDelete: _onDeleteAccountTap,
                    ),
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
