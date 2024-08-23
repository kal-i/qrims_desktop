extension ExtString on String {

  bool get isValidName {
    final nameRegExp = RegExp(r'^[a-zA-Z\s]{2,}$');
    return nameRegExp.hasMatch(this);
  }

  bool get isValidEmail {
    /// define with r"" to say it is a reg exp
    /// this means the current [the one uses] instance of String
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(this);
  }
}