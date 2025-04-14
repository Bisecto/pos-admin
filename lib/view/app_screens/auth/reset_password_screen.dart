import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final AuthBloc authBloc = AuthBloc();

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

              Navigator.pop(context);
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              TextStyles.textSubHeadings(
                                  textValue: "Reset password",
                                  textColor: AppColors.white,
                                  textSize: 20),
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
                                        hint: 'Please enter Email',
                                        label: 'Email',
                                        borderColor: AppColors.darkYellow,
                                        controller: _emailController,
                                        backgroundColor: AppColors
                                            .darkModeBackgroundContainerColor,
                                        validator:
                                            AppValidator.validateTextfield,
                                        widget: Icon(Icons.person_2_outlined),
                                        width: 250,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      FormButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            authBloc.add(ResetPasswordEvent(
                                                _emailController.text
                                                    .toLowerCase()
                                                    .trim()));
                                          }
                                        },
                                        text: 'Request',
                                        borderColor: AppColors.darkYellow,
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
    );
  }
}
