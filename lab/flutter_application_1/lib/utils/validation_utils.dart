class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Add at least 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Add at least 1 lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Add at least 1 number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Add at least 1 special character';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length < 2) return 'Minimum 2 characters required';
    if (!RegExp(r'^[a-zA-Z]+(?: [a-zA-Z]+)*$').hasMatch(value)) {
      return 'Only letters allowed';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? validateAge(DateTime? dob) {
    if (dob == null) return null;
    final today = DateTime.now();
    final age = today.year - dob.year;
    if (age < 13) return 'You must be at least 13 years old';
    return null;
  }
}
