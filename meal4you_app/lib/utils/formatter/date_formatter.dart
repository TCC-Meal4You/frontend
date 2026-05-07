String formatDate(DateTime date) {
  final now = DateTime.now();
  final localDate = date.toLocal();
  final difference = now.difference(localDate);
  if (difference.isNegative) {
    return 'Agora';
  }
  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return 'Agora';
      }
      return '${difference.inMinutes}m atrás';
    }
    return '${difference.inHours}h atrás';
  } else if (difference.inDays == 1) {
    return 'Ontem';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d atrás';
  } else {
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  }
}
String formatExactDateTime(DateTime date) {
  final localDate = date.toLocal();
  return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year} '
      '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
}
String formatExactDateOrDateOnly(DateTime date, {bool? hasTime}) {
  final localDate = date.toLocal();
  final datePart =
      '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  final showTime = hasTime ?? true;
  if (!showTime) return datePart;
  return '$datePart ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
}