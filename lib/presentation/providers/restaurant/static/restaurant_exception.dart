class RestaurantException implements Exception {
  final String message;

  RestaurantException(this.message);

  @override
  String toString() => message;
}

String getUserFriendlyErrorMessage(Exception e) {
  if (e.toString().contains('SocketException') ||
      e.toString().contains('Network is unreachable')) {
    return 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
  } else if (e.toString().contains('TimeoutException')) {
    return 'Permintaan waktu habis. Silakan coba lagi.';
  } else if (e is RestaurantException) {
    return e.message;
  } else {
    return 'Terjadi kesalahan. Silakan coba lagi nanti.';
  }
}
