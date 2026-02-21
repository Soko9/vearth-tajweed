String toArabicDigits(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  var result = input;
  for (var i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], arabic[i]);
  }
  return result;
}

String arabicInt(int value) => toArabicDigits(value.toString());

String arabicFixed(double value, {int digits = 1}) =>
    toArabicDigits(value.toStringAsFixed(digits));
