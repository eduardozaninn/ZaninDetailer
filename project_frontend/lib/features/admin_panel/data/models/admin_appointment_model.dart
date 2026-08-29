class AdminAppointmentModel {
  final String id;
  final String vehicle;
  final String licensePlate;
  final String clientName;
  final String phone;
  final int serviceId;
  final String serviceLabel;
  final String status;

  final DateTime? scheduledStart;
  final double? totalPrice;

  AdminAppointmentModel({
    required this.id,
    required this.vehicle,
    required this.licensePlate,
    required this.clientName,
    required this.phone,
    required this.serviceId,
    required this.serviceLabel,
    required this.status,
    this.scheduledStart,
    this.totalPrice,
  });

  factory AdminAppointmentModel.fromJson(Map<String, dynamic> json) {
    final clientMap = json['client'] ?? {};

    return AdminAppointmentModel(
      id: json['id']?.toString() ?? '',
      vehicle: clientMap['vehicle_brand_model'] ?? 'Veículo não informado',
      licensePlate: clientMap['license_plate'] ?? 'Sem placa',
      clientName: clientMap['full_name'] ?? 'Cliente não informado',
      phone: clientMap['phone'] ?? '',
      serviceId: json['service_id'] ?? 0,
      serviceLabel: 'Serviço #${json['service_id'] ?? '?'}',
      status: json['status'] ?? 'pendente',
      scheduledStart: json['scheduled_start'] != null
          ? DateTime.tryParse(json['scheduled_start'])
          : null,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : 0.0,
    );
  }
}
