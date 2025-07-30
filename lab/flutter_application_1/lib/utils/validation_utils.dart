class ValidationUtils {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*])').hasMatch(password)) {
      return 'Password must include uppercase, lowercase, number, and special character';
    }
    if (['123456', 'password', 'qwerty', 'abc123'].contains(password.toLowerCase())) {
      return 'Password is too common';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2 || name.length > 50) {
      return 'Name must be between 2 and 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name must contain only letters';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Optional field
    }
    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return null; // Optional field
    }
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    return null;
  }
}