part of 'auth_card_builder.dart';

class _ConfirmRecoverCard extends StatefulWidget {
  const _ConfirmRecoverCard({
    super.key,
    required this.passwordValidator,
    required this.onBack,
    required this.onSubmitCompleted,
    required this.initialIsoCode,
    required this.intlPhoneSelectorType,
    required this.autoValidateMode,
    required this.loginTheme,
  });

  final FormFieldValidator<String> passwordValidator;
  final VoidCallback onBack;
  final VoidCallback onSubmitCompleted;
  final String? initialIsoCode;
  final IntlPhoneSelectorType intlPhoneSelectorType;
  final AutovalidateMode autoValidateMode;
  final LoginTheme? loginTheme;

  @override
  _ConfirmRecoverCardState createState() => _ConfirmRecoverCardState();
}

class _ConfirmRecoverCardState extends State<_ConfirmRecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();

  late final Timer? _timer;
  int _resendCodeTimer = 60 * 5;

  var _isSubmitting = false;
  var _code = '';

  late AnimationController _submitController;

  @override
  void initState() {
    super.initState();

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _resendCodeTimerMathFunction(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _submitController.dispose();
    _timer?.cancel();
  }

  Future<bool> _submit() async {
    FocusScope.of(context).unfocus(); // close keyboard

    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onConfirmRecover!(
      _code,
      LoginData(
        name: auth.email,
        password: auth.password,
      ),
    );

    if (error != null) {
      if (context.mounted) {
        showErrorToast(context, messages.flushbarTitleError, error);
      }
      setState(() => _isSubmitting = false);
      if (context.mounted) {
        await _submitController.reverse();
      }
      return false;
    } else {
      if (context.mounted) {
        showSuccessToast(
          context,
          messages.flushbarTitleSuccess,
          messages.confirmRecoverSuccess,
        );
      }

      setState(() => _isSubmitting = false);
      widget.onSubmitCompleted();
      return true;
    }
  }

  Widget _buildVerificationCodeField(double width, LoginMessages messages) {
    return AnimatedTextFormField(
      width: width,
      labelText: messages.recoveryCodeHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleCheck),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: (value) {
        if (value!.isEmpty) {
          return messages.recoveryCodeValidationError;
        }
        return null;
      },
      onSaved: (value) => _code = value!,
      initialIsoCode: widget.initialIsoCode,
      intlPhoneSelectorType: widget.intlPhoneSelectorType,
      autoValidateMode: widget.autoValidateMode,
      intlPhoneSearchHint: messages.intlPhoneSearchHint,
    );
  }

  void _resendCodeTimerMathFunction() {
    if (_resendCodeTimer > 0) {
      setState(() {
        _resendCodeTimer--;
      });
    }
  }

  String _resendCodeTimerMessage({required LoginMessages messages}) {
    final minutes = Duration(seconds: _resendCodeTimer).inMinutes.remainder(60);
    final seconds = Duration(seconds: _resendCodeTimer).inSeconds.remainder(60);

    return '${messages.resendCodeTimerMessage} 0$minutes:${seconds < 10 ? '0' : ''}$seconds';
  }

  Future<bool> _resendCode() async {
    FocusScope.of(context).unfocus();
    _resendCodeTimer = 60 * 5;

    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    await _submitController.forward();
    setState(() => _isSubmitting = true);

    final error = await auth.onRecoverPassword!(auth.email);

    if (error != null) {
      if (context.mounted) {
        showErrorToast(context, messages.flushbarTitleError, error);
      }

      setState(() => _isSubmitting = false);
      await _submitController.reverse();
      return false;
    }

    if (context.mounted) {
      showSuccessToast(
        context,
        messages.flushbarTitleSuccess,
        messages.resendCodeSuccess,
      );
    }

    setState(() => _isSubmitting = false);
    await _submitController.reverse();
    return true;
  }

  Widget _buildResendCode(ThemeData theme, LoginMessages messages) {
    return MaterialButton(
      onPressed: !_isSubmitting && _resendCodeTimer == 0 ? _resendCode : null,
      child: Text(
        _resendCodeTimer != 0
            ? _resendCodeTimerMessage(messages: messages)
            : messages.resendCodeButton,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildPasswordField(double width, LoginMessages messages) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      labelText: messages.passwordHint,
      controller: _passwordController,
      textInputAction: TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      },
      validator: widget.passwordValidator,
      onSaved: (value) {
        final auth = Provider.of<Auth>(context, listen: false);
        auth.password = value!;
      },
      initialIsoCode: widget.initialIsoCode,
      intlPhoneSelectorType: widget.intlPhoneSelectorType,
      autoValidateMode: widget.autoValidateMode,
      intlPhoneSearchHint: messages.intlPhoneSearchHint,
    );
  }

  Widget _buildConfirmPasswordField(double width, LoginMessages messages) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      labelText: messages.confirmPasswordHint,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onFieldSubmitted: (value) => _submit(),
      validator: (value) {
        if (value != _passwordController.text) {
          return messages.confirmPasswordError;
        }
        return null;
      },
      initialIsoCode: widget.initialIsoCode,
      intlPhoneSelectorType: widget.intlPhoneSelectorType,
      autoValidateMode: widget.autoValidateMode,
      intlPhoneSearchHint: messages.intlPhoneSearchHint,
    );
  }

  Widget _buildSetPasswordButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.setPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(
    ThemeData theme,
    LoginMessages messages,
    LoginTheme? loginTheme,
  ) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed: !_isSubmitting ? widget.onBack : null,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
      child: Text(messages.goBackButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return FittedBox(
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: <Widget>[
                Text(
                  messages.confirmRecoverIntro,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _buildVerificationCodeField(textFieldWidth, messages),
                const SizedBox(height: 20),
                _buildPasswordField(textFieldWidth, messages),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(textFieldWidth, messages),
                const SizedBox(height: 26),
                _buildResendCode(theme, messages),
                _buildSetPasswordButton(theme, messages),
                _buildBackButton(theme, messages, widget.loginTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
