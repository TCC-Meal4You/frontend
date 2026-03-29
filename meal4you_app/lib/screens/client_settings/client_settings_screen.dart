import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/services/search_profile/search_client_profile_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

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
  bool _isSocialLogin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  @override
  Widget build(BuildContext context) {
    final clientLogoutHandler = ClientLogoutHandler();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3F8),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(clientLogoutHandler),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),
                    _buildEmailCard(),
                    const SizedBox(height: 16),
                    _buildAccountInfoCard(),
                    const SizedBox(height: 16),
                    _buildDeleteAccountCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ClientLogoutHandler clientLogoutHandler) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 157, 0, 255),
            Color.fromARGB(255, 15, 230, 135),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'MEAL4YOU',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'c  o  m  i  d  a    c  o  n  s  c  i  e  n  t  e',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () =>
                      clientLogoutHandler.showLogoutDialog(context),
                  icon: const FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                _getInitial(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Meu Perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Gerencie suas informações',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF17C783),
            title: 'Informações Pessoais',
            actionLabel: 'Editar',
          ),
          const SizedBox(height: 18),
          _buildInfoLabel('Nome'),
          const SizedBox(height: 6),
          Text(
            _isLoading ? 'Carregando...' : _nome,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoLabel('Senha'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isLoading ? 'Carregando...' : _buildPasswordText(),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: (_senha.isEmpty || _isSocialLogin)
                    ? null
                    : () {
                        setState(() => _mostrarSenha = !_mostrarSenha);
                      },
                icon: Icon(
                  _mostrarSenha
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.mail_outline,
            iconColor: const Color(0xFF17C783),
            title: 'Email',
            actionLabel: 'Alterar',
          ),
          const SizedBox(height: 18),
          Text(
            _isLoading ? 'Carregando...' : _email,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.account_circle_outlined,
            iconColor: const Color(0xFF17C783),
            title: 'Informações da Conta',
          ),
          const SizedBox(height: 18),
          _buildInfoLabel('Tipo de Conta'),
          const SizedBox(height: 6),
          const Text(
            'Cliente',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.delete_outline, color: Color(0xFFF04438), size: 20),
              SizedBox(width: 8),
              Text(
                'Deletar Conta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Deletar sua conta irá remover permanentemente todos os seus dados.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7A7A7A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF04438)),
                foregroundColor: const Color(0xFFF04438),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text(
                'Deletar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? actionLabel,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
        ),
        if (actionLabel != null)
          Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF222222),
              ),
              const SizedBox(width: 6),
              Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBaseCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2DDE7)),
      ),
      child: child,
    );
  }

  Widget _buildInfoLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF7A7A7A),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
