import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/common/widgets/alert_dialog.dart';
import 'package:truklynk/pages/Auth/bloc/auth_bloc.dart';
import 'package:truklynk/pages/Auth/bloc/auth_event.dart';
import 'package:truklynk/pages/Auth/bloc/auth_state.dart';
import 'package:truklynk/pages/Auth/presentation/constants/auth_theme.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:truklynk/utils/helper_functions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _keyboardVisible = false;
  String _code = "";
  final TextEditingController _controllerPhNo = TextEditingController();
  AuthBloc authBloc = AuthBloc();
  bool showVerification = false;
  bool phoneNumberValid = false;
  int counter = 0;
  int count = 0;

  @override
  void initState() {
    _listenSmsCode();
    super.initState();
  }

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check keyboard visibility
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return BlocProvider(
        create: (context) => authBloc,
        child: SafeArea(
            child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {

            if (state is Message) {
              print('state${state.code}');
              toast(message: "${state.message}");
              if (state.code == 1) {
                showVerification = true;
              }
              if (state.code == 2) {
                showCustomAlertDialog(
                  context: context,
                  content: "Number not found. Create a new account?",
                  contentColor: AuthTheme.whiteColor,
                  onConfirm: () {
                    Navigator.pushReplacementNamed(context, '/RegisterScreen',
                        arguments: _controllerPhNo.text);
                  },
                  onCancel: () {},
                  confirmButtonColor: AuthTheme.whiteColor,
                  cancelButtonColor: AuthTheme.secondaryColor,
                  confirmText: "Proceed",
                );
              }
            }
            if (state is PhoneNumberValid) {
              phoneNumberValid = state.verifyNow;
            }
            if (state is OTP) {
              _code = state.otp;
              setState(() {});
            }
            if (state is LoginSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/BottomBar', (Route route) => false);
            }
            if (state is ResentOTP) {
              counter = state.attempt;
              count = state.count;
            }
          }, builder: (context, state) {
            return Stack(
              children: <Widget>[
                // Background image
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/Background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Main content area
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 25),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () => {},
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AuthTheme.secondaryColor,
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/RegisterScreen',
                                            arguments: null);
                                      },
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.transparent,
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 130),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 204,
                                  height: 54,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Phone number',
                                      style: TextStyle(
                                        color: AuthTheme.secondaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AuthTheme.primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/india.png',
                                                width: 24,
                                                height: 24,
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                '+91',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 13),
                                        Expanded(
                                          child: TextField(
                                            controller: _controllerPhNo,
                                            onChanged: (value) {
                                              authBloc.add(PhoneNumberChanged(
                                                  phoneNumber: value));
                                            },
                                            maxLength: 10,
                                            keyboardType: TextInputType.phone,
                                            style: const TextStyle(
                                                color: AuthTheme.whiteColor),
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Enter your phone number',
                                              errorText:
                                                  state is PhoneNumberInvalid
                                                      ? state.errorMessage
                                                      : null,
                                              counterText: '',
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AuthTheme.primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AuthTheme
                                                      .primaryColor, // Optional: Different color or opacity for the unfocused border
                                                  width:
                                                      2, // Optional: Thickness for the unfocused border
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 25),
                                      ],
                                    ),
                                    if (phoneNumberValid &&
                                        (counter == 3 && count == 0
                                            ? false
                                            : true))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 24),
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                                onPressed: () async {
                                                  authBloc.add(GenerateOTP(
                                                      page: 'login',
                                                      countryCode: '91',
                                                      deviceId:
                                                          await getDeviceId(),
                                                      otpHashCode:
                                                          await SmsAutoFill()
                                                              .getAppSignature,
                                                      role: 'Customer'));
                                                },
                                                child: Text(
                                                    showVerification
                                                        ? counter >= 1 &&
                                                                count > 0
                                                            ? "00:${count < 10 ? '0$count' : count}"
                                                            : " now"
                                                        : "Verify now",
                                                    style: TextStyle(
                                                        color: counter >= 1 &&
                                                                count > 0
                                                            ? AuthTheme
                                                                .secondaryColor
                                                            : AuthTheme
                                                                .whiteColor)))),
                                      ),
                                    if (showVerification) ...[
                                      SizedBox(
                                          height: (counter == 3 && count == 0
                                                  ? false
                                                  : true)
                                              ? 5
                                              : 24),
                                      const Text(
                                        'Verification',
                                        style: TextStyle(
                                          color: AuthTheme.secondaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: PinFieldAutoFill(
                                          currentCode: _code,
                                          codeLength: 6,
                                          decoration: UnderlineDecoration(
                                            textStyle: const TextStyle(
                                                color: AuthTheme.whiteColor),
                                            hintText: '••••••',
                                            colorBuilder: PinListenColorBuilder(
                                              AuthTheme.secondaryColor,
                                              AuthTheme.primaryColor,
                                            ),
                                          ),
                                          onCodeChanged: (code) {
                                            authBloc
                                                .add(EnterOTP(otp: code ?? ''));
                                          },
                                          onCodeSubmitted: (code) {},
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!_keyboardVisible) ...[
                        // Bottom section only when keyboard is not visible
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // ElevatedButton(
                              //   onPressed: () => {},
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: AuthTheme.primaryColor,
                              //     shape: const CircleBorder(),
                              //     padding: const EdgeInsets.all(18),
                              //   ),
                              //   child: Image.asset(
                              //     'assets/images/Apple.png',
                              //     color: Colors.white,
                              //     width: 18,
                              //     height: 18,
                              //   ),
                              // ),
                              // ElevatedButton(
                              //   onPressed: () async {},
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: AuthTheme.primaryColor,
                              //     shape: const CircleBorder(),
                              //     padding: const EdgeInsets.all(18),
                              //   ),
                              //   child: Image.asset(
                              //     'assets/images/Google.png',
                              //     color: Colors.white,
                              //     width: 18,
                              //     height: 18,
                              //   ),
                              // ),
                              Expanded(child: Container()),
                              TextButton(
                                onPressed: () async {
                                  authBloc.add(LoginUser(
                                    deviceId: await getDeviceId(),
                                    OTP: _code,
                                  ));
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: _code.length == 6
                                      ? Colors.white
                                      : Colors.white24,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset(
                                        'assets/images/right-arrow.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          }),
        )));
  }
}
