// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../bloc/auth_bloc/auth_bloc.dart';
// import '../../../firebase_options.dart';
// import '../../../model/tenant_model.dart';
// import '../../../res/app_colors.dart';
// import '../../../res/app_images.dart';
// import '../../../utills/app_navigator.dart';
// import '../../../utills/app_validator.dart';
// import '../../important_pages/app_loading_page.dart';
// import '../../important_pages/dialog_box.dart';
// import '../../widgets/app_custom_text.dart';
// import '../../widgets/drop_down.dart';
// import '../../widgets/form_button.dart';
// import '../../widgets/form_input.dart';
// import '../landing_page.dart';
//
// class CreateNewUser extends StatefulWidget {
//   TenantModel tenantModel;
//
//    CreateNewUser({super.key,required this.tenantModel});
//
//   @override
//   State<CreateNewUser> createState() => _CreateNewUserState();
// }
//
// class _CreateNewUserState extends State<CreateNewUser> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final  fullNameController = TextEditingController();
//   final  phoneController = TextEditingController();
//   final  roleController = TextEditingController();
//   final AuthBloc authBloc = AuthBloc();
// @override
//   void initState() {
//     // TODO: implement initState
//    Firebase.initializeApp(
//     options: DefaultFirebaseOptions.android,
//   );
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       body: Center(
//         child: BlocConsumer<AuthBloc, AuthState>(
//             bloc: authBloc,
//             listenWhen: (previous, current) => current is! AuthInitial,
//             buildWhen: (previous, current) => current is! AuthInitial,
//             listener: (context, state) {
//               if (state is SuccessState) {
//                 MSG.snackBar(context, state.msg);
//
//                 AppNavigator.pushAndRemovePreviousPages(context,
//                     page:  LandingPage(tenantModel: state.tenantModel!,));
//               } else if (state is ErrorState) {
//                 MSG.warningSnackBar(context, state.error);
//               }
//             },
//             builder: (context, state) {
//               switch (state.runtimeType) {
//                 // case PostsFetchingState:
//                 //   return const Center(
//                 //     child: CircularProgressIndicator(),
//                 //   );
//                 case AuthInitial || ErrorState:
//                   return SafeArea(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               //mainAxisAlignment: MainAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 //Align(child: Icon(Icons.cancel,size: 35,),),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 TextStyles.textSubHeadings(
//                                     textValue: "Create users account",
//                                     textColor: AppColors.white,
//                                     textSize: 20),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 Form(
//                                   key: _formKey,
//                                   child: Column(
//                                     children: [
//                                       CustomTextFormField(
//                                         controller: _emailController,
//                                         label: 'Email Address',
//                                         width: 250,
//                                         hint: 'Enter email address',
//                                         validator: AppValidator.validateTextfield,
//                                       ),
//                                       SizedBox(height: 10),
//                                       CustomTextFormField(
//                                         controller: fullNameController,
//                                         label: 'Full name',
//                                         width: 250,
//                                         hint: 'Enter full name',
//                                         validator: AppValidator.validateTextfield,
//                                       ),
//                                       SizedBox(height: 10),
//                                       CustomTextFormField(
//                                         controller: phoneController,
//                                         label: 'Phone',
//                                         width: 250,
//                                         hint: 'Enter phone number of user',
//                                         textInputType: TextInputType.number,
//                                         validator: AppValidator.validateTextfield,
//                                       ),
//                                       SizedBox(height: 10),
//                                       DropDown(
//                                         width: 250,
//                                         borderColor: AppColors.white,
//                                         borderRadius: 10,
//                                         hint: "Select role of user",
//                                         selectedValue: roleController.text,
//                                         items: const ['Manager', "Admin", "Registerer"],
//                                         onChanged: (value) {
//                                           roleController.text = value;
//                                         },
//                                       ),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [FormButton(
//                                           onPressed: () {
//                                            // Navigator.of(context).pop();
//                                           },
//                                           bgColor: AppColors.red,
//                                           textColor: AppColors.white,
//                                           width: 120,
//                                           text: "Discard",
//                                           iconWidget: Icons.clear,
//                                           borderRadius: 20,
//                                         ),
//                                           SizedBox(width: 20,),
//                                           FormButton(
//                                             onPressed: () {
//                                               if (_formKey.currentState!.validate()) {
//                                                 setState(() {
//                                                   authBloc.add(SignUpEventClick(
//                                                       _emailController.text,
//                                                       '8V8YTiKWyObO7tppMHeP',
//                                                       phoneController.text,
//                                                       'imageUrl',
//                                                       fullNameController.text,
//                                                       roleController.text,'Qwerty123@',widget.tenantModel,
//                                                   ));
//                                                 });
//                                               }
//                                             },
//                                             text: "Add",
//                                             iconWidget: Icons.add,
//                                             bgColor: AppColors.green,
//                                             textColor: AppColors.white,
//                                             width: 120,
//                                             borderRadius: 20,
//                                           ),],
//                                       ),
//                                       SizedBox(height: 10),
//                                     ],
//                                   ),
//                                 ),                                const SizedBox(
//                                   height: 20,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//
//                 case LoadingState:
//                   return const Center(
//                     child: AppLoadingPage("Signing user in..."),
//                   );
//                 default:
//                   return const Center(
//                     child: AppLoadingPage("Signing user in..."),
//                   );
//               }
//             }),
//       ),
//     );
//   }
// }
