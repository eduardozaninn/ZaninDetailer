import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class WhatsAppHelpFab extends StatefulWidget {
  final String message;

  const WhatsAppHelpFab({
    super.key,
    this.message = 'Olá! Fiquei com uma dúvida antes de agendar um horário.',
  });

  @override
  State<WhatsAppHelpFab> createState() => _WhatsAppHelpFabState();
}

class _WhatsAppHelpFabState extends State<WhatsAppHelpFab>
    with TickerProviderStateMixin {
  static bool _hasIntroduced = false;

  static const List<String> _peekMessages = [
    'Ficou com alguma dúvida?',
    'Fale com a gente agora',
    'Tire suas dúvidas rapidinho',
  ];
  static const int _maxPeeks = 2;
  static const int _maxHeartbeats = 4;

  late final AnimationController _entranceController;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _entranceScale;

  late final AnimationController _expandController;
  late final Animation<double> _expandCurve;

  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;

  late final AnimationController _rippleController;
  late final AnimationController _waveController;

  Timer? _collapseTimer;
  Timer? _heartbeatTimer;

  bool _isExpanded = false;
  bool _showBadge = false;
  int _messageIndex = 0;
  int _peekCount = 0;
  int _heartbeatCount = 0;
  double _pressScale = 1.0;

  @override
  void initState() {
    super.initState();

    final isFirstIntroduction = !_hasIntroduced;
    _hasIntroduced = true;
    _isExpanded = isFirstIntroduction;

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceScale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _entranceController, curve: Curves.easeOutBack));

    _expandController = AnimationController(
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _expandCurve = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _badgeScale = Tween<double>(begin: 1.0, end: 1.22).animate(
        CurvedAnimation(parent: _badgeController, curve: Curves.easeInOut));

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _entranceController.forward();
    });

    if (isFirstIntroduction) {
      _collapseTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        _collapse();
        setState(() => _showBadge = true);
        _startHeartbeat();
      });
    } else {
      _showBadge = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) _startHeartbeat();
      });
    }
  }

  void _expand() {
    setState(() => _isExpanded = true);
    _expandController.forward();
  }

  void _collapse() {
    setState(() => _isExpanded = false);
    _expandController.reverse();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted) return;
      if (_isExpanded) return;
      if (_heartbeatCount >= _maxHeartbeats) {
        timer.cancel();
        return;
      }
      _heartbeatCount++;
      _rippleController.forward(from: 0);
      _waveController.forward(from: 0);

      if (_peekCount < _maxPeeks && _heartbeatCount.isEven) {
        _peekCount++;
        _messageIndex = (_messageIndex + 1) % _peekMessages.length;
        _expand();
        Timer(const Duration(milliseconds: 2600), () {
          if (mounted) _collapse();
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _expandController.dispose();
    _badgeController.dispose();
    _rippleController.dispose();
    _waveController.dispose();
    _collapseTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(widget.message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildRipple(Animation<double> parent, double delay) {
    return AnimatedBuilder(
      animation: parent,
      builder: (context, child) {
        final t = ((parent.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        if (t <= 0 || _isExpanded) return const SizedBox.shrink();
        final eased = Curves.easeOutExpo.transform(t);
        return Opacity(
          opacity: (1 - eased) * 0.45,
          child: Transform.scale(
            scale: 1.0 + eased * 1.3,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF25D366), width: 1.6),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _entranceSlide,
      child: ScaleTransition(
        scale: _entranceScale,
        child: SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  right: 16, child: _buildRipple(_rippleController, 0.0)),
              Positioned(
                  right: 16, child: _buildRipple(_rippleController, 0.25)),
              Positioned(
                right: 16,
                child: Tooltip(
                  message: 'Falar no WhatsApp',
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _pressScale = 0.92),
                    onTapUp: (_) => setState(() => _pressScale = 1.0),
                    onTapCancel: () => setState(() => _pressScale = 1.0),
                    onTap: _openWhatsApp,
                    child: AnimatedScale(
                      scale: _pressScale,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedBuilder(
                            animation: _expandCurve,
                            builder: (context, child) {
                              final t = _expandCurve.value;
                              return Container(
                                height: 52,
                                padding: EdgeInsets.only(
                                  left: 14,
                                  right: 14 + (4 * t),
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF33E378),
                                      Color(0xFF1FAE53)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _waveController,
                                      builder: (context, child) {
                                        final w = _waveController.value;
                                        final angle =
                                            math.sin(w * 4 * math.pi) *
                                                (1 - w) *
                                                0.18;
                                        return Transform.rotate(
                                            angle: angle, child: child);
                                      },
                                      child: const Icon(
                                          Icons.chat_bubble_rounded,
                                          color: Colors.white,
                                          size: 24),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: t,
                                      child: Opacity(
                                        opacity: t,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            _peekMessages[_messageIndex],
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.visible,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (_showBadge && !_isExpanded)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: ScaleTransition(
                                scale: _badgeScale,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
