import 'package:adaptive_theme/adaptive_theme.dart';
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

  final AuthBloc authBloc = AuthBloc();

  @override
  void initState() {
    // TODO: implement initState
    //authBloc.add(InitialEvent());
    //AppUtils().logout(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
          bloc: authBloc,
          listenWhen: (previous, current) => current is! AuthInitial,
          buildWhen: (previous, current) => current is! AuthInitial,
          listener: (context, state) {
            if (state is SuccessState) {
              MSG.snackBar(context, state.msg);

              AppNavigator.pushAndRemovePreviousPages(context,
                  page:  LandingPage(tenantModel: state.tenantModel!, userModel: state.userModel!,));
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                height: 100,
                                width: 100,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      CustomTextFormField(
                                        hint:
                                            'Please enter Email',
                                        label: 'Email',
                                        borderColor: AppColors.purple,
                                        controller: _emailController,
                                        backgroundColor: AppColors
                                            .darkModeBackgroundContainerColor,
                                        validator:
                                            AppValidator.validateTextfield,
                                        widget: const Icon(Icons.person_2_outlined),
                                        width: 250,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextFormField(
                                        label: 'Password',
                                        isPasswordField: true,
                                        borderColor: AppColors.purple,
                                        backgroundColor: AppColors
                                            .darkModeBackgroundContainerColor,
                                        validator:
                                            AppValidator.validateTextfield,
                                        controller: _passwordController,
                                        hint: 'Enter your password',
                                        widget: const Icon(Icons.lock_outline),
                                        width: 250,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 250,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                AppNavigator.pushAndStackPage(
                                                    context,
                                                    page:
                                                        const ResetPassword());
                                              },
                                              child: const Align(
                                                alignment: Alignment.topRight,
                                                child: CustomText(
                                                  text: "Forgot password ?",
                                                  color: AppColors.white,
                                                  size: 16,
                                                  weight: FontWeight.w400,
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

                                            authBloc.add(SignInEventClick(

                                                _emailController.text
                                                    .toLowerCase()
                                                    .trim(),
                                                _passwordController.text));
                                          }
                                        },
                                        text: 'Login',
                                        borderColor: AppColors.purple,
                                        bgColor: AppColors.purple,
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
                                  textValue: "Checkpoint Abuja",
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
    );
  }
}
