part of 'auth_card_builder.dart';

class _ConfirmSignupCard extends StatefulWidget {
  const _ConfirmSignupCard({
    super.key,
    required this.onBack,
    required this.onBackButtonTapped,
    required this.onSubmitCompleted,
    this.loginAfterSignUp = true,
    required this.loadingController,
    required this.keyboardType,
    required this.initialIsoCode,
    required this.intlPhoneSelectorType,
    required this.autoValidateMode,
    required this.loginTheme,
  });

  final bool loginAfterSignUp;
  final VoidCallback onBack;
  final VoidCallback onBackButtonTapped;
  final VoidCallback onSubmitCompleted;
  final AnimationController loadingController;
  final TextInputType? keyboardType;
  final String? initialIsoCode;
  final IntlPhoneSelectorType intlPhoneSelectorType;
  final AutovalidateMode autoValidateMode;
  final LoginTheme? loginTheme;

  @override
  _ConfirmSignupCardState createState() => _ConfirmSignupCardState();
}

class _ConfirmSignupCardState extends State<_ConfirmSignupCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  // List of animation controller for every field
  late AnimationController _fieldSubmitController;

  late final Timer? _timer;
  int _resendCodeTimer = 60 * 5;

  var _isSubmitting = false;
  var _code = '';

  @override
  void initState() {
    super.initState();

    _fieldSubmitController = AnimationController(
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
    _fieldSubmitController.dispose();
    _timer?.cancel();
    super.dispose();
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

  Future<bool> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _fieldSubmitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onConfirmSignup!(
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
      await _fieldSubmitController.reverse();
      return false;
    }

    if (context.mounted) {
      showSuccessToast(
        context,
        messages.flushbarTitleSuccess,
        messages.confirmSignupSuccess,
      );
    }

    setState(() => _isSubmitting = false);
    await _fieldSubmitController.reverse();

    if (!widget.loginAfterSignUp) {
      auth.mode = AuthMode.login;
      widget.onSubmitCompleted();
      return false;
    }

    widget.onSubmitCompleted();
    return true;
  }

  Future<bool> _resendCode() async {
    FocusScope.of(context).unfocus();
    _resendCodeTimer = 60 * 5;

    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    await _fieldSubmitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onResendCode!(
      SignupData.fromSignupForm(
        name: auth.email,
        password: auth.password,
        termsOfService: auth.getTermsOfServiceResults(),
      ),
    );

    if (error != null) {
      if (context.mounted) {
        showErrorToast(context, messages.flushbarTitleError, error);
      }

      setState(() => _isSubmitting = false);
      await _fieldSubmitController.reverse();
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
    await _fieldSubmitController.reverse();
    return true;
  }

  Widget _buildConfirmationCodeField(double width, LoginMessages messages) {
    return AnimatedTextFormField(
      loadingController: widget.loadingController,
      width: width,
      labelText: messages.confirmationCodeHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleCheck),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: (value) {
        if (value!.isEmpty) {
          return messages.confirmationCodeValidationError;
        }
        return null;
      },
      onSaved: (value) => _code = value!,
      keyboardType: widget.keyboardType,
      initialIsoCode: widget.initialIsoCode,
      intlPhoneSelectorType: widget.intlPhoneSelectorType,
      autoValidateMode: widget.autoValidateMode,
      intlPhoneSearchHint: messages.intlPhoneSearchHint,
    );
  }

  Widget _buildResendCode(ThemeData theme, LoginMessages messages) {
    return ScaleTransition(
      scale: widget.loadingController,
      child: MaterialButton(
        onPressed: !_isSubmitting && _resendCodeTimer == 0 ? _resendCode : null,
        child: Text(
          _resendCodeTimer != 0
              ? _resendCodeTimerMessage(messages: messages)
              : messages.resendCodeButton,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme, LoginMessages messages) {
    return ScaleTransition(
      scale: widget.loadingController,
      child: AnimatedButton(
        controller: _fieldSubmitController,
        text: messages.confirmSignupButton,
        onPressed: !_isSubmitting ? _submit : null,
      ),
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
    return ScaleTransition(
      scale: widget.loadingController,
      child: MaterialButton(
        onPressed: !_isSubmitting ? widget.onBackButtonTapped : null,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
        child: Text(messages.goBackButton),
      ),
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
                ScaleTransition(
                  scale: widget.loadingController,
                  child: Text(
                    messages.confirmSignupIntro,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
                _buildConfirmationCodeField(textFieldWidth, messages),
                const SizedBox(height: 10),
                _buildResendCode(theme, messages),
                _buildConfirmButton(theme, messages),
                _buildBackButton(theme, messages, widget.loginTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
