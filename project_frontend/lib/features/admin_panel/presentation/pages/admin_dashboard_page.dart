import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/admin_appointment_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../../../../core/router/app_router.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showLoginToast = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAppointments();
      _showLoginSuccessIfNeeded();
    });
  }

  void _showLoginSuccessIfNeeded() {
    final extra = GoRouterState.of(context).extra;
    if (extra is! Map || extra['showLoginSuccess'] != true) return;

    setState(() => _showLoginToast = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showLoginToast = false);
    });
  }

  Widget _buildLoginToast(TextTheme textTheme) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            offset: _showLoginToast ? Offset.zero : const Offset(0, -1.5),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _showLoginToast ? 1 : 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Login realizado com sucesso!',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Admin';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final textTheme = Theme.of(context).textTheme;

    final firstName = _getFirstName(
        provider.currentUser?.fullName ?? provider.currentUser?.email);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryRed.withValues(alpha: 0.15)),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people_alt_outlined,
                            color: AppTheme.primaryRed, size: 28),
                        onPressed: () => context.push(AppRouter.adminUsers),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app,
                            color: AppTheme.primaryRed, size: 28),
                        onPressed: () {
                          context.go(AppRouter.home);
                        },
                      ),
                    ],
                  ),
                  Text('Painel de Controle', style: textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    provider.isLoading && provider.currentUser == null
                        ? 'Carregando perfil...'
                        : 'Olá, $firstName',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                          child: _buildMetricCard(
                              value: provider.totalAppointments,
                              label: 'Agendamentos',
                              textTheme: textTheme)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildMetricCard(
                              value: provider.projectedRevenue,
                              label: 'Previsto',
                              textTheme: textTheme)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Agenda do Dia', style: textTheme.titleLarge),
                      _buildDateSelector(context, provider, textTheme),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryRed))
                        : provider.appointmentsErrorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.wifi_off_rounded,
                                          color: Colors.white38, size: 40),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Não foi possível carregar a agenda.\n${provider.appointmentsErrorMessage}',
                                        textAlign: TextAlign.center,
                                        style: textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed:
                                            provider.fetchAppointments,
                                        child:
                                            const Text('Tentar novamente'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : provider.activeAppointments.isEmpty
                                ? Center(
                                    child: Text(
                                        'Nenhum agendamento para essa data.',
                                        style: textTheme.bodyMedium))
                                : ListView.builder(
                                    itemCount:
                                        provider.activeAppointments.length,
                                    itemBuilder: (context, index) {
                                      return _buildAppointmentCard(
                                          context,
                                          provider.activeAppointments[index],
                                          textTheme);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
          _buildLoginToast(textTheme),
        ],
      ),
      floatingActionButton: const CustomSpeedDial(),
    );
  }

  Widget _buildDateSelector(
      BuildContext context, AdminProvider provider, TextTheme textTheme) {
    final today = DateTime.now();
    final selected = provider.selectedDate;
    final isToday = selected.year == today.year &&
        selected.month == today.month &&
        selected.day == today.day;

    final label = isToday
        ? 'Hoje'
        : DateFormat('dd/MM/yyyy').format(selected);

    return Material(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final newDate = await showDatePicker(
            context: context,
            initialDate: selected,
            firstDate: DateTime(2024),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.primaryRed,
                  onPrimary: Colors.white,
                  surface: AppTheme.dialogBackground,
                ),
              ),
              child: child!,
            ),
          );
          if (newDate != null && context.mounted) {
            await context.read<AdminProvider>().selectDate(newDate);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppTheme.primaryRed),
              const SizedBox(width: 8),
              Text(label,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      {required String value,
      required String label,
      required TextTheme textTheme}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: textTheme.headlineLarge
                    ?.copyWith(color: AppTheme.primaryRed, fontSize: 32)),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel')) return AppTheme.dangerRed;
    if (normalized.contains('complet') || normalized.contains('conclu')) {
      return AppTheme.successGreen;
    }
    return AppTheme.warningYellow;
  }

  Color _statusTextColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel') ||
        normalized.contains('complet') ||
        normalized.contains('conclu')) {
      return Colors.white;
    }
    return Colors.black;
  }

  Widget _buildAppointmentCard(BuildContext context,
      AdminAppointmentModel appointment, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAppointmentActionsSheet(context, appointment),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appointment.vehicle, style: textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: _statusColor(appointment.status),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(appointment.status,
                          style: textTheme.labelLarge?.copyWith(
                              color: _statusTextColor(appointment.status),
                              fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                    'Placa: ${appointment.licensePlate} | Cliente: ${appointment.clientName}',
                    style: textTheme.bodyMedium),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        context
                            .read<AdminProvider>()
                            .serviceName(appointment.serviceId),
                        style: textTheme.titleLarge?.copyWith(fontSize: 17)),
                    Icon(Icons.more_horiz,
                        color: Colors.white.withValues(alpha: 0.4)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppointmentActionsSheet(
      BuildContext context, AdminAppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.dialogBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(appointment.clientName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.event_repeat_rounded,
                      color: AppTheme.primaryRed),
                  title: const Text('Reagendar',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showRescheduleDialog(context, appointment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined,
                      color: AppTheme.primaryRed),
                  title: const Text('Editar dados do cliente',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditClientDialog(context, appointment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: AppTheme.successGreen),
                  title: const Text('Concluir agendamento',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showCompleteDialog(context, appointment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined,
                      color: Colors.redAccent),
                  title: const Text('Cancelar agendamento',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showCancelDialog(context, appointment);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showActionResult(
      BuildContext context, bool success, String successMessage) {
    final provider = context.read<AdminProvider>();
    final message = success
        ? successMessage
        : (provider.appointmentActionErrorMessage ??
            'Não foi possível concluir a ação.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? AppTheme.successGreen : AppTheme.primaryRed,
      ),
    );
  }

  int? _parseAppointmentId(
      BuildContext context, AdminAppointmentModel appointment) {
    final id = int.tryParse(appointment.id);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do agendamento inválido.')),
      );
    }
    return id;
  }

  Future<void> _showRescheduleDialog(
      BuildContext context, AdminAppointmentModel appointment) async {
    final now = DateTime.now();
    final currentDateTime = appointment.scheduledStart ?? now;

    Widget pickerTheme(BuildContext ctx, Widget? child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
                primary: AppTheme.primaryRed,
                onPrimary: Colors.white,
                surface: AppTheme.surface,
                onSurface: Colors.white),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          child: child!,
        );

    final newDate = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate:
          currentDateTime.isBefore(now) ? now : currentDateTime,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: pickerTheme,
    );
    if (newDate == null || !context.mounted) return;

    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
      builder: pickerTheme,
    );
    if (newTime == null || !context.mounted) return;

    final newDateTime = DateTime(
        newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);

    final appointmentId = _parseAppointmentId(context, appointment);
    if (appointmentId == null) return;

    final success = await context
        .read<AdminProvider>()
        .rescheduleAppointment(appointmentId, newDateTime);

    if (!context.mounted) return;
    _showActionResult(
        context, success, 'Agendamento reagendado com sucesso!');
  }

  Future<void> _showCancelDialog(
      BuildContext context, AdminAppointmentModel appointment) async {
    final motivoController = TextEditingController();

    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.dialogBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancelar agendamento?',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${appointment.clientName}',
                  style: TextStyle(color: Colors.grey[400])),
              const SizedBox(height: 16),
              AdminCustomInput(
                hint: 'Motivo do cancelamento',
                controller: motivoController,
                prefixIcon: Icons.notes_rounded,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white38),
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancelar agendamento',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirm != true || !context.mounted) return;

      final reason = motivoController.text.trim().isEmpty
          ? 'Cancelado pelo administrador.'
          : motivoController.text.trim();

      final appointmentId = _parseAppointmentId(context, appointment);
      if (appointmentId == null) return;

      final success = await context
          .read<AdminProvider>()
          .cancelAppointment(appointmentId, reason);

      if (!context.mounted) return;
      _showActionResult(
          context, success, 'Agendamento cancelado com sucesso.');
    } finally {
      motivoController.dispose();
    }
  }

  Future<void> _showCompleteDialog(
      BuildContext context, AdminAppointmentModel appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.dialogBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Concluir agendamento?',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'O agendamento de ${appointment.clientName} será marcado como concluído.',
            style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white38),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Concluir',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final appointmentId = _parseAppointmentId(context, appointment);
    if (appointmentId == null) return;

    final success = await context
        .read<AdminProvider>()
        .completeAppointment(appointmentId);

    if (!context.mounted) return;
    _showActionResult(
        context, success, 'Agendamento concluído com sucesso.');
  }

  Future<void> _showEditClientDialog(
      BuildContext context, AdminAppointmentModel appointment) async {
    final nomeController = TextEditingController(text: appointment.clientName);
    final telefoneController = TextEditingController(text: appointment.phone);
    final placaController = TextEditingController(text: appointment.licensePlate);
    final veiculoController = TextEditingController(text: appointment.vehicle);

    try {
      final salvar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.dialogBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar dados do cliente',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminCustomInput(
                    hint: 'Nome completo',
                    controller: nomeController,
                    prefixIcon: Icons.person_outline),
                const SizedBox(height: 12),
                AdminCustomInput(
                    hint: 'WhatsApp',
                    controller: telefoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                AdminCustomInput(
                    hint: 'Placa',
                    controller: placaController,
                    prefixIcon: Icons.confirmation_number_outlined),
                const SizedBox(height: 12),
                AdminCustomInput(
                    hint: 'Marca/Modelo do veículo',
                    controller: veiculoController,
                    prefixIcon: Icons.directions_car_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar',
                  style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (salvar != true || !context.mounted) return;

      final appointmentId = _parseAppointmentId(context, appointment);
      if (appointmentId == null) return;

      final success =
          await context.read<AdminProvider>().updateClientData(
                appointmentId: appointmentId,
                fullName: nomeController.text.trim(),
                phone: telefoneController.text.trim(),
                licensePlate: placaController.text.trim(),
                vehicleBrandModel: veiculoController.text.trim(),
              );

      if (!context.mounted) return;
      _showActionResult(
          context, success, 'Dados do cliente atualizados com sucesso.');
    } finally {
      nomeController.dispose();
      telefoneController.dispose();
      placaController.dispose();
      veiculoController.dispose();
    }
  }
}

class CustomSpeedDial extends StatefulWidget {
  const CustomSpeedDial({super.key});

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAnimatedButton(
          title: "Vitrine",
          icon: Icons.photo_library_outlined,
          onTap: () => context.push(AppRouter.adminShowcases),
          index: 3,
        ),
        _buildAnimatedButton(
          title: "Marcas",
          icon: Icons.branding_watermark,
          onTap: () => context.push(AppRouter.adminBrandsList),
          index: 2,
        ),
        _buildAnimatedButton(
          title: "Catálogo",
          icon: Icons.list_alt,
          onTap: () => context.push(AppRouter.adminServicesList),
          index: 1,
        ),
        FloatingActionButton(
          backgroundColor: AppTheme.primaryRed,
          onPressed: _toggle,
          child: RotationTransition(
            turns:
                Tween<double>(begin: 0.0, end: 0.125).animate(_expandAnimation),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required int index}) {
    final animationInterval = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 1.0 - (index * 0.2), curve: Curves.easeOutBack),
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
            .animate(animationInterval);

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: animationInterval,
        child: FadeTransition(
          opacity: animationInterval,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _toggle();
                  onTap();
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppTheme.primaryRed.withValues(alpha: 0.15),
                        child: Icon(icon, color: AppTheme.primaryRed, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
