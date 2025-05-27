import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_card.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Bouton de toggle thème
          Consumer<SettingsService>(
            builder: (context, settings, child) {
              return IconButton(
                onPressed: () {
                  final newMode =
                      settings.isDarkMode ? ThemeMode.light : ThemeMode.dark;
                  settings.setThemeMode(newMode);
                },
                icon: Icon(
                  settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: settings.isDarkMode ? 'Mode clair' : 'Mode sombre',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.paddingXLarge),
                  _buildHeader(),
                  const SizedBox(height: AppSizes.paddingXLarge),
                  _buildAuthForm(),
                  const SizedBox(height: AppSizes.paddingLarge),
                  _buildToggleButton(),
                  const SizedBox(height: AppSizes.paddingMedium),
                  _buildGuestButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo ou icône de l'app
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ThemeHelper.getPrimaryColor(context),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ThemeHelper.getPrimaryColor(
                  context,
                ).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.quiz,
            size: 50,
            color: ThemeHelper.getOnPrimaryColor(context),
          ),
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        Text(
          'Quiz App',
          style: ThemeHelper.getHeadlineStyle(context).copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ThemeHelper.getPrimaryColor(context),
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          _isLogin
              ? AppLocalizations.of(context).welcomeBack
              : AppLocalizations.of(context).createAccount,
          style: ThemeHelper.getSecondaryTextStyle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isLogin
                  ? AppLocalizations.of(context).signIn
                  : AppLocalizations.of(context).signUp,
              style: ThemeHelper.getHeadlineStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Nom (seulement pour l'inscription)
            if (!_isLogin) ...[
              _buildNameField(),
              const SizedBox(height: AppSizes.paddingMedium),
            ],

            // Email
            _buildEmailField(),
            const SizedBox(height: AppSizes.paddingMedium),

            // Mot de passe
            _buildPasswordField(),

            // Confirmer mot de passe (seulement pour l'inscription)
            if (!_isLogin) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              _buildConfirmPasswordField(),
            ],

            const SizedBox(height: AppSizes.paddingLarge),

            // Bouton de connexion/inscription
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).fullName,
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      validator: (value) {
        if (!_isLogin && (value == null || value.trim().isEmpty)) {
          return AppLocalizations.of(context).pleaseEnterName;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).email,
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context).pleaseEnterEmail;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return AppLocalizations.of(context).pleaseEnterValidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).password,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterPassword;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context).passwordTooShort;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).confirmPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed:
              () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseConfirmPassword;
        }
        if (value != _passwordController.text) {
          return AppLocalizations.of(context).passwordsDoNotMatch;
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text:
          _isLogin
              ? AppLocalizations.of(context).signIn
              : AppLocalizations.of(context).signUp,
      icon: _isLogin ? Icons.login : Icons.person_add,
      onPressed: _isLoading ? null : _handleSubmit,
      backgroundColor: ThemeHelper.getPrimaryColor(context),
      isLoading: _isLoading,
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
          _formKey.currentState?.reset();
          _clearFields();
        });
      },
      child: RichText(
        text: TextSpan(
          style: ThemeHelper.getBodyStyle(context),
          children: [
            TextSpan(
              text:
                  _isLogin
                      ? AppLocalizations.of(context).dontHaveAccount
                      : AppLocalizations.of(context).alreadyHaveAccount,
            ),
            TextSpan(
              text:
                  _isLogin
                      ? ' ${AppLocalizations.of(context).signUp}'
                      : ' ${AppLocalizations.of(context).signIn}',
              style: TextStyle(
                color: ThemeHelper.getPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestButton() {
    return TextButton.icon(
      onPressed: _continueAsGuest,
      icon: const Icon(Icons.person_outline),
      label: Text(AppLocalizations.of(context).continueAsGuest),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (_isLogin) {
        // Connexion → aller directement à l'application
        await authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Inscription → retourner au mode connexion
        await authService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );

        // Déconnecter l'utilisateur après inscription
        await authService.signOut();

        if (mounted) {
          // Basculer vers le mode connexion
          setState(() {
            _isLogin = true;
            _clearFields();
          });

          // Message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).accountCreatedSuccess),
              backgroundColor: ThemeHelper.getCorrectAnswerColor(context),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: ThemeHelper.getErrorColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _continueAsGuest() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signInAsGuest();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
