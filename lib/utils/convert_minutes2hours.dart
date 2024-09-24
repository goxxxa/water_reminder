extension Minutes2Hours on int {
  String toHours() {
    var duration = Duration(minutes: this);
    List<String> parts = duration.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String toMinutes() {
    var hours = toString().split(':')[0];
    var minutes = toString().split(':')[1];
    return hours * 60 + minutes;
  }
}

