import 'dart:async';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/view/app_screens/auth/create_new_user.dart';
import 'package:pos_admin/view/app_screens/auth/reset_password_screen.dart';
import 'package:pos_admin/view/app_screens/auth/sign_up_user.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';
import 'package:provider/provider.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_images.dart';
import '../../../utills/app_navigator.dart';
import '../../../utills/app_utils.dart';
import '../../../utills/app_validator.dart';
import '../../important_pages/app_loading_page.dart';
import '../../important_pages/dialog_box.dart';
import '../../important_pages/no_internet.dart';
import '../../important_pages/update_screen.dart';
import '../../widgets/form_button.dart';
import '../../widgets/form_input.dart';
import '../landing_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  final AuthBloc authBloc = AuthBloc();

  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  String LatestVersion = '';
  String LatestBuildNumber = '';
  bool isAppUpdated = true;
  String appUrl = '';
  bool _connected = true;

  @override
  void initState() {
    // TODO: implement initState
    _checkConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivity);
    super.initState();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _handleConnectivity(connectivityResult);
  }

  void _handleConnectivity(ConnectivityStatus result) {
    if (result == ConnectivityStatus.none) {
      debugPrint("No network");
      setState(() {
        _connected = false;
      });
    } else {
      debugPrint("Network connected");
      Fetch_App_Details();
      CheckUpdate();
      setState(() {
        _connected = true;
      });
    }
  }

  Fetch_App_Details() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      debugPrint(version);
      debugPrint(buildNumber);
    });
  }

  CheckUpdate() async {
    ///'Hello1');
    if (Platform.isAndroid) {
      ///'Hello2');
      FirebaseFirestore.instance
          .collection('AppInfo')
          .where('dataKey', isEqualTo: 'admin') //.doc(userId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var data in querySnapshot.docs) {
          debugPrint(data.toString());
          setState(() {
            LatestVersion = data['version'];
            LatestBuildNumber = data['buildNumber'];
            appUrl = data['androidUrl'];

            ///LatestVersion);
          });
          if (LatestVersion == version) {
            isAppUpdated = true;
          } else if (LatestVersion != version) {
            if (data['isUpdate']) {
              isAppUpdated = false;
            } else {
              isAppUpdated = true;
            }
          } else if (LatestVersion.isEmpty) {
            isAppUpdated = true;
          } else if (LatestVersion.toString() == 'null') {
            isAppUpdated = true;
          } else {
            isAppUpdated = true;
          }
        }
      });
    } else if (Platform.isIOS) {
      await FirebaseFirestore.instance
          .collection('AppInfo')
          .doc('iOS-version-IOS')
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data()! as Map<String, dynamic>;

          setState(() {
            LatestVersion = data['version'];
            LatestBuildNumber = data['buildNumber'];
            appUrl = data['iosUrl'];
            debugPrint(LatestVersion);
            debugPrint(LatestBuildNumber);
          });
          if (LatestVersion == version) {
            isAppUpdated = true;
          } else if (LatestVersion != version) {
            if (data['isUpdate']) {
              isAppUpdated = false;
            } else {
              isAppUpdated = true;
            }
          } else if (LatestVersion.isEmpty) {
            isAppUpdated = true;
          } else if (LatestVersion.toString() == 'null') {
            isAppUpdated = true;
          } else {
            isAppUpdated = true;
          }
        } else {
          isAppUpdated = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _connected
        ? (isAppUpdated
            ? Scaffold(
                backgroundColor: AppColors.scaffoldBackgroundColor,
                body: BlocConsumer<AuthBloc, AuthState>(
                    bloc: authBloc,
                    listenWhen: (previous, current) => current is! AuthInitial,
                    buildWhen: (previous, current) => current is! AuthInitial,
                    listener: (context, state) {
                      if (state is SuccessState) {
                        MSG.snackBar(context, state.msg);

                        AppNavigator.pushAndRemovePreviousPages(context,
                            page: LandingPage(
                              tenantModel: state.tenantModel!,
                              userModel: state.userModel!,
                              plans:state.plans!,
                            ));
                      } else if (state is ErrorState) {
                        MSG.warningSnackBar(context, state.error);
                      }
                    },
                    builder: (context, state) {
                      switch (state.runtimeType) {
                        // case PostsFetchingState:
                        //   return const Center(
                        //     child: CircularProgressIndicator(),
                        //   );
                        case AuthInitial || ErrorState:
                          return SafeArea(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        //TextStyles.textSubHeadings(textValue: "Login to your account",textColor:AppColors.white,textSize: 20 ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Image.asset(
                                          AppImages.companyLogo,
                                          height: 150,
                                          width: 150,
                                        ),
                                        const SizedBox(
                                          height: 0,
                                        ),
                                        Form(
                                            key: _formKey,
                                            child: Column(
                                              children: [
                                                CustomTextFormField(
                                                  hint: 'Please enter Email',
                                                  label: 'Email',
                                                  borderColor:
                                                      AppColors.darkYellow,
                                                  controller: _emailController,
                                                  backgroundColor: AppColors
                                                      .darkModeBackgroundContainerColor,
                                                  validator: AppValidator
                                                      .validateTextfield,
                                                  widget: const Icon(
                                                      Icons.person_2_outlined),
                                                  width: 250,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                CustomTextFormField(
                                                  label: 'Password',
                                                  isPasswordField: true,
                                                  borderColor:
                                                      AppColors.darkYellow,
                                                  backgroundColor: AppColors
                                                      .darkModeBackgroundContainerColor,
                                                  validator: AppValidator
                                                      .validateTextfield,
                                                  controller:
                                                      _passwordController,
                                                  hint: 'Enter your password',
                                                  widget: const Icon(
                                                      Icons.lock_outline),
                                                  width: 250,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          AppNavigator
                                                              .pushAndStackPage(
                                                                  context,
                                                                  page:
                                                                      const ResetPassword());
                                                        },
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: CustomText(
                                                            text:
                                                                "Forgot password ?",
                                                            color:
                                                                AppColors.white,
                                                            size: 16,
                                                            weight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                      // GestureDetector(
                                                      //   onTap: () {
                                                      //     AppNavigator.pushAndStackPage(
                                                      //         context,
                                                      //         page:
                                                      //              SignUpUser());
                                                      //   },
                                                      //   child: const Align(
                                                      //     alignment: Alignment.topRight,
                                                      //     child: CustomText(
                                                      //       text: "Account setup",
                                                      //       color: AppColors.white,
                                                      //       size: 16,
                                                      //       weight: FontWeight.w400,
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                                FormButton(
                                                  onPressed: () async {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      authBloc.add(
                                                          SignInEventClick(
                                                              _emailController
                                                                  .text
                                                                  .toLowerCase()
                                                                  .trim(),
                                                              _passwordController
                                                                  .text));
                                                    }
                                                  },
                                                  text: 'Login',
                                                  borderColor:
                                                      AppColors.darkYellow,
                                                  bgColor: AppColors.darkYellow,
                                                  textColor: AppColors.white,
                                                  borderRadius: 10,
                                                  width: 250,
                                                  height: 50,
                                                )
                                              ],
                                            )),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      children: [
                                        const CustomText(
                                            text: 'Powered by',
                                            size: 14,
                                            color: AppColors.white),
                                        TextStyles.textHeadings(
                                            textValue: "nextack".toUpperCase(),
                                            textSize: 20,
                                            textColor: AppColors.orange)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );

                        case LoadingState:
                          return const Center(
                            child: AppLoadingPage("Signing user in..."),
                          );
                        default:
                          return const Center(
                            child: AppLoadingPage("Signing user in..."),
                          );
                      }
                    }),
              )
            : Center(
                child: UpdateApp(
                  appUrl: appUrl,
                ),
              ))
        : No_internet_Page(onRetry: _checkConnectivity);
  }
}
