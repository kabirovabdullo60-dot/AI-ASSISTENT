/// The API accepts phones matching `^\+?[0-9]{7,15}$`.
final _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');

/// Removes spaces, dashes and brackets: `+992 90 123-45-67` →
/// `+992901234567`.
String normalizePhone(String input) =>
    input.replaceAll(RegExp(r'[\s\-()]'), '');

/// Whether [input] (after [normalizePhone]) is a phone the API accepts.
bool isValidPhone(String input) =>
    _phonePattern.hasMatch(normalizePhone(input));
