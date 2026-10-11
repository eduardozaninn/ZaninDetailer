class StoreKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

class AppConstants {
  static const int apiTimeoutSeconds = 10;

  static const String whatsappNumber = '5544988286864';
}

class VehicleSizeOption {
  final String value;
  final String label;
  final String shortLabel;
  final String emoji;
  final double surcharge;

  const VehicleSizeOption({
    required this.value,
    required this.label,
    required this.shortLabel,
    required this.emoji,
    required this.surcharge,
  });
}

class VehicleSizes {
  static const List<VehicleSizeOption> options = [
    VehicleSizeOption(
      value: 'hatch_sedan',
      label: 'Hatch / Sedã',
      shortLabel: 'Hatch/Sedã',
      emoji: '🚗',
      surcharge: 0,
    ),
    VehicleSizeOption(
      value: 'suv_medio',
      label: 'SUV médio / Picape simples',
      shortLabel: 'SUV médio',
      emoji: '🚙',
      surcharge: 20,
    ),
    VehicleSizeOption(
      value: 'suv_grande',
      label: 'SUV grande / Picape dupla / Van',
      shortLabel: 'SUV grande',
      emoji: '🚐',
      surcharge: 35,
    ),
  ];
}
