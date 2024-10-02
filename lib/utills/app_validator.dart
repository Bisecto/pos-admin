


class AppValidator{


  static String? validateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return 'Required.';
    }
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email.';
    } else {
      return null;
    }
  }


  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Required.';
    }
    if (password.length < 6) {
      return 'Password too short.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special \ncharacter.';
    }
    else {
      return null;
    }
  }
  static String? validateAccountNumberfield(String? text) {
    if (text == null) {
      return 'Account Number field is empty.';
    }else if (text.toString().length!=10) {
      return 'Account Number should be 10 characters.';
    }

    // if (!password.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password must contain at least one uppercase.';
    // }
    // if (!password.contains(RegExp(r'[a-z]'))) {
    //   return 'Password must contain at least one lowercase.';
    // }
    // if (!password.contains(RegExp(r'[0-9]'))) {
    //   return 'Password must contain at least one digit.';
    // }
    // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Password must contain at least one special \ncharacter.';
    // }
    else {
      return null;
    }
  }
  static String? validateTextfield(String? text) {
    if (text == null || text.isEmpty) {
      return 'Required.';
    }

    // if (!password.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password must contain at least one uppercase.';
    // }
    // if (!password.contains(RegExp(r'[a-z]'))) {
    //   return 'Password must contain at least one lowercase.';
    // }
    // if (!password.contains(RegExp(r'[0-9]'))) {
    //   return 'Password must contain at least one digit.';
    // }
    // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Password must contain at least one special \ncharacter.';
    // }
    else {
      return null;
    }
  }

}