import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/adm_logout_handler.dart';
import 'package:meal4you_app/services/delete_account/delete_adm_account_service.dart';
import 'package:meal4you_app/services/search_profile/search_adm_profile_service.dart';
import 'package:meal4you_app/services/update_email/request_email_change_service.dart';
import 'package:meal4you_app/services/update_profile/update_adm_profile_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class AdmProfileScreen extends StatefulWidget {
  const AdmProfileScreen({super.key});

  @override
  State<AdmProfileScreen> createState() => _AdmProfileScreenState();
}

class _AdmProfileScreenState extends State<AdmProfileScreen> {
  String _email = '';
  String _nome = '';
  String _senha = '';
  bool _isLoading = true;
  bool _obscureSenha = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isSocialLogin = false;

  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final profileData = await SearchAdmProfileService.buscarMeuPerfil();
      final senhaLocal = await UserTokenSaving.getUserPassword();

      if (mounted) {
        setState(() {
          _email = profileData['email'] ?? 'Sem email';
          _nome = profileData['nome'] ?? 'Sem nome';
          _senha = senhaLocal ?? '';
          _isSocialLogin = (senhaLocal == null || senhaLocal.isEmpty);
          _nomeController.text = _nome;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _nomeController.text = _nome;
        _senhaController.clear();
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nomeController.text = _nome;
      _senhaController.clear();
      _obscureSenha = true;
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

    if (novaSenha.isNotEmpty) {
      final confirmed = await _showPasswordChangeWarningDialog();
      if (confirmed != true) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await UpdateAdmProfileService.atualizarMeuPerfil(
        nome: novoNome.isNotEmpty ? novoNome : null,
        senha: novaSenha.isNotEmpty ? novaSenha : null,
      );

      if (novaSenha.isNotEmpty) {
        await UserTokenSaving.saveUserPassword(novaSenha);

        if (!mounted) return;
        await UserTokenSaving.clearAll();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha alterada com sucesso! Faça login novamente.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/admLogin', (_) => false);
        return;
      }

      if (mounted) {
        setState(() {
          if (novoNome.isNotEmpty) _nome = novoNome;
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showPasswordChangeWarningDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Atenção!'),
        content: const Text(
          'Ao alterar sua senha, você será desconectado de todos os dispositivos e precisará fazer login novamente.\n\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 15, 230, 135),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEmailChangeDialog() async {
    final emailController = TextEditingController();
    String? errorMessage;

    final novoEmail = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Alterar E-mail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digite o novo endereço de e-mail:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (errorMessage != null) {
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Novo Email',
                  hintText: 'exemplo@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();

                if (email.isEmpty) {
                  setState(() {
                    errorMessage = 'Digite um email';
                  });
                  return;
                }

                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(email)) {
                  setState(() {
                    errorMessage = 'Digite um e-mail válido';
                  });
                  return;
                }

                Navigator.pop(context, email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 230, 135),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );

    if (novoEmail != null && novoEmail.isNotEmpty) {
      await _requestEmailChange(novoEmail);
    }
  }

  Future<void> _requestEmailChange(String novoEmail) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 157, 0, 255),
        ),
      ),
    );

    try {
      await RequestEmailChangeService.solicitarAlteracaoEmail(novoEmail);

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.pushNamed(
        context,
        '/verifyEmailChange',
        arguments: {'novoEmail': novoEmail},
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final emailController = TextEditingController();
    String? errorMessage;

    final emailConfirmado = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Deletar Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para confirmar a exclusão da sua conta, digite seu email:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (errorMessage != null) {
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Digite seu email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();

                if (email.isEmpty) {
                  setState(() {
                    errorMessage = 'Digite seu email';
                  });
                  return;
                }

                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(email)) {
                  setState(() {
                    errorMessage = 'Digite um e-mail válido';
                  });
                  return;
                }

                Navigator.pop(context, email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );

    if (emailConfirmado != null && emailConfirmado.isNotEmpty) {
      await _showFinalDeleteWarning(emailConfirmado);
    }
  }

  Future<void> _showFinalDeleteWarning(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Atenção!'),
        content: const Text(
          'Tem certeza que deseja deletar sua conta permanentemente?\n\nEsta ação NÃO pode ser desfeita e irá deletar:\n\n• Sua conta de administrador\n• Seu restaurante\n• Todas as refeições cadastradas\n• Todos os ingredientes\n• Todas as avaliações\n• Todos os favoritos\n• Resumindo: TUDO!\n\nTodos os dados serão perdidos permanentemente.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deletar Permanentemente'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount(email);
    }
  }

  Future<void> _deleteAccount(String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    try {
      await DeleteAdmAccountService.deletarMinhaConta(email);

      if (!mounted) return;

      await UserTokenSaving.clearAll();

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta deletada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/profileChoice',
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admLogoutHandler = AdmLogoutHandler();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'MEAL4YOU',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 27,
                                  color: Colors.white,
                                ),
                              ),
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
                                admLogoutHandler.showLogoutDialog(context),
                            icon: const FaIcon(
                              FontAwesomeIcons.rightFromBracket,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          _nome.isNotEmpty ? _nome[0].toUpperCase() : '...',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Ubuntu',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Meu Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                    const Text(
                      'Gerencie suas informações',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 157, 0, 255),
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.person_outline,
                                      color: Color.fromARGB(255, 15, 230, 135),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Informações Pessoais',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _isEditing
                                      ? _cancelEdit
                                      : _toggleEditMode,
                                  icon: Icon(
                                    _isEditing
                                        ? Icons.close
                                        : Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _isEditing ? 'Cancelar' : 'Editar',
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nome',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isEditing)
                                  TextField(
                                    controller: _nomeController,
                                    decoration: InputDecoration(
                                      hintText: 'Digite seu nome',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            157,
                                            0,
                                            255,
                                          ),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  )
                                else
                                  Text(
                                    _nome,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Senha',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isSocialLogin)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Você entrou com o Google. Não é possível alterar a senha.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_isEditing)
                                  TextField(
                                    controller: _senhaController,
                                    obscureText: !_obscureSenha,
                                    decoration: InputDecoration(
                                      hintText: 'Digite a nova senha',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            157,
                                            0,
                                            255,
                                          ),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureSenha
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureSenha = !_obscureSenha;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _obscureSenha
                                            ? '•' *
                                                  (_senha.length > 0
                                                      ? _senha.length
                                                      : 8)
                                            : _senha.isNotEmpty
                                            ? _senha
                                            : '••••••••',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _obscureSenha
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureSenha = !_obscureSenha;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            if (_isEditing) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: Text(
                                    _isSaving
                                        ? 'Salvando...'
                                        : 'Salvar Alterações',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      15,
                                      230,
                                      135,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Color.fromARGB(255, 15, 230, 135),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_isSocialLogin)
                                  TextButton.icon(
                                    onPressed: _showEmailChangeDialog,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Alterar'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            if (_isSocialLogin) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Você entrou com o Google. Não é possível alterar o e-mail.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.account_circle_outlined,
                                  color: Color.fromARGB(255, 15, 230, 135),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Informações da Conta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Tipo de Conta',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Proprietário de Restaurante',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Status da Conta',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ativa',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Deletar Conta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Deletar sua conta irá remover permanentemente todos os seus dados, incluindo restaurante, refeições, ingredientes e avaliações.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: _showDeleteAccountDialog,
                                icon: const Icon(Icons.delete_forever_outlined),
                                label: const Text('Deletar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory_outlined),
              label: 'Restaurante',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
          currentIndex: 1,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushReplacementNamed(context, '/admProfile');
            } else if (index == 0) {
              Navigator.pushNamed(context, '/admRestaurantHome');
            }
          },
        ),
      ),
    );
  }
}
