// lib/models/jeepney_model.dart

class Jeepney {
  final String routeNumber;
  final int seats;
  final String nickname;
  final String? imagePath;

  Jeepney({
    required this.routeNumber,
    required this.seats,
    required this.nickname,
    this.imagePath,
  });

  @override
  String toString() {
    return 'Jeepney(routeNumber: $routeNumber, seats: $seats, nickname: $nickname, imagePath: $imagePath)';
  }
}
