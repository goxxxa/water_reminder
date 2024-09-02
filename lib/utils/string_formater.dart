extension DateStringFormater on String {
  String dateFormatToDatabase() {
    return replaceAll('/', '_');
  }

  String dateFormaterFromDatabase() {
    return replaceAll('_', '/');
  }

  String toMinutes() {
    int hours = int.parse(toString().split(':')[0]);
    int minutes = int.parse(toString().split(':')[1]);
    return '${hours * 60 + minutes}';
  }

  String toChart() {
    return toString().substring(0, 5).replaceAll('_', '/');
  }
}
