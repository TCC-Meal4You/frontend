String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

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
    return '${date.day}/${date.month}/${date.year}';
  }
}
