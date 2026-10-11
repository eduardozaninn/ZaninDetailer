import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/string_utils.dart';
import '../../data/models/service_model.dart';
import '../providers/booking_provider.dart';

class BookingConfirmationStep extends StatelessWidget {
  final ServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final VoidCallback onBack;

  const BookingConfirmationStep({
    super.key,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final textTheme = Theme.of(context).textTheme;

    final day = DateFormat('d').format(selectedDate);
    final weekday = StringUtils.capitalize(
        DateFormat('E', 'pt_BR').format(selectedDate).replaceAll('.', ''));

    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryRed.withValues(alpha: 0.20)),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent)),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text("Resumo do Agendamento",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("🚗", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(service.title,
                              style: textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[300]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("📅", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Text("Dia $day, $weekday às $selectedTime",
                            style: textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("💵", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${StringUtils.formatCurrency(service.price + _currentSurcharge(provider))}  •  Duração: ~${service.duration}",
                            style: textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[300]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (_currentSurcharge(provider) > 0) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Text(
                          "Inclui adicional de porte: ${StringUtils.formatCurrency(_currentSurcharge(provider))}",
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ),
                    ],
                    if (service.description != null &&
                        service.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.07),
                          height: 1),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("📋", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service.description!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text("Seus Dados",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInputField("Nome completo", provider.nameController),
              const SizedBox(height: 16),
              _buildInputField(
                  "WhatsApp (com DDD)", provider.whatsappController,
                  isPhone: true),
              const SizedBox(height: 16),
              _buildInputField(
                  "Placa (Ex: ABC-1234)", provider.plateController),
              const SizedBox(height: 8),
              Text(
                "Informe a marca e o modelo do seu veículo",
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              _buildInputField("Marca e Modelo (Ex: Chevrolet Onix)",
                  provider.vehicleController),
              const SizedBox(height: 24),
              Text("Porte do Veículo",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Selecione o que mais se aproxima do seu carro",
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              _VehicleSizeTrack(
                selectedValue: provider.selectedVehicleSize,
                onSelected: provider.selectVehicleSize,
              ),
              const SizedBox(height: 12),
              Text(
                "Em caso de sujeira pesada (barro, lama incrustada), pode haver "
                "acréscimo avaliado no local.",
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: provider.isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppTheme.primaryRed.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isLoading
                        ? const Color(0xFF1A1A1A)
                        : AppTheme.primaryRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final success = await provider.confirmBooking(
                              service, selectedDate, selectedTime);
                          if (success && context.mounted) {
                            _showSuccessModal(
                                context, selectedDate, selectedTime);
                          } else if (context.mounted) {
                            _showErrorSnackBar(
                              context,
                              provider.errorMessage ??
                                  'Não foi possível confirmar o agendamento.',
                            );
                          }
                        },
                  child: provider.isLoading
                      ? const CircularProgressIndicator(
                          color: AppTheme.primaryRed)
                      : const Text("Confirmar Agendamento",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  double _currentSurcharge(BookingProvider provider) {
    return VehicleSizes.options
        .firstWhere((o) => o.value == provider.selectedVehicleSize,
            orElse: () => VehicleSizes.options.first)
        .surcharge;
  }

  Widget _buildInputField(String hint, TextEditingController controller,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                BorderSide(color: AppTheme.primaryRed.withValues(alpha: 0.4))),
        content: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.primaryRed, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String message) async {
    final uri = Uri.parse(
      'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(message)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      _showErrorSnackBar(context, 'Não foi possível abrir o WhatsApp.');
    }
  }

  void _showSuccessModal(BuildContext context, DateTime date, String time) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final contactMessage =
        'Olá! Acabei de agendar o serviço *${service.title}* para o dia '
        '$formattedDate às $time. Qualquer dúvida, estou à disposição!';
    final rescheduleMessage =
        'Olá! Gostaria de reagendar meu agendamento do serviço '
        '*${service.title}*, marcado para o dia $formattedDate às $time. '
        'Poderia me ajudar com isso?';
    final cancelMessage =
        'Olá! Gostaria de cancelar meu agendamento do serviço '
        '*${service.title}*, marcado para o dia $formattedDate às $time.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 64),
                ),
                const SizedBox(height: 24),
                const Text("Agendamento Confirmado!",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  "Sua vaga está garantida.\nTe esperamos lá!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _openWhatsApp(context, contactMessage),
                    icon: const Icon(Icons.chat_bubble_rounded,
                        color: Colors.white, size: 20),
                    label: const Text("Falar no WhatsApp",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () =>
                              _openWhatsApp(context, rescheduleMessage),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("Reagendar",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppTheme.primaryRed
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () =>
                              _openWhatsApp(context, cancelMessage),
                          child: Text("Cancelar",
                              style: TextStyle(
                                  color: AppTheme.primaryRed.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.go(AppRouter.home);
                  },
                  child: Text("Voltar ao Início",
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleSizeTrack extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _VehicleSizeTrack({
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const options = VehicleSizes.options;
    const spacing = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - spacing * (options.length - 1);
        final expandedWidth = available * 0.50;
        final collapsedWidth = (available - expandedWidth) / (options.length - 1);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: spacing),
              _VehicleSizeCard(
                option: options[i],
                isSelected: options[i].value == selectedValue,
                width: options[i].value == selectedValue
                    ? expandedWidth
                    : collapsedWidth,
                onTap: () => onSelected(options[i].value),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _VehicleSizeCard extends StatelessWidget {
  final VehicleSizeOption option;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  const _VehicleSizeCard({
    required this.option,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
        width: width,
        height: 128,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.primaryRed.withValues(alpha: 0.75),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFF121212),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryRed
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryRed.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: isSelected
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeOutBack,
                  scale: isSelected ? 1.15 : 0.85,
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.6,
                    child: Text(option.emoji,
                        style: const TextStyle(fontSize: 30)),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                option.shortLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                option.surcharge > 0
                                    ? "+${StringUtils.formatCurrency(option.surcharge)}"
                                    : "Sem adicional",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: AppTheme.primaryRed, size: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
