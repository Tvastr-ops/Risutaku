import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/security/app_lock_service.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/util/theming.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  DateTime? _pausedAt;
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final appLock = ref.read(persistenceProvider).options.appLock;
    if (appLock) {
      _isLocked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final options = ref.read(persistenceProvider).options;
    if (!options.appLock) {
      if (_isLocked) setState(() => _isLocked = false);
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final elapsed = DateTime.now().difference(_pausedAt!);
        if (elapsed >= options.lockTimeout.duration) {
          setState(() => _isLocked = true);
          _authenticate();
        }
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !_isLocked) return;
    _isAuthenticating = true;

    final authenticated = await AppLockService.authenticate(
      localizedReason: 'Authenticate to unlock Risutaku',
    );

    if (mounted) {
      _isAuthenticating = false;
      if (authenticated) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isLocked = false;
          _pausedAt = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLock = ref.watch(persistenceProvider.select((s) => s.options.appLock));

    if (!appLock || !_isLocked) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Material(
            color: colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.lock,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Risutaku is Locked',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock using your fingerprint, face, or device PIN',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 36),
                    FilledButton.icon(
                      onPressed: _authenticate,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: const RoundedRectangleBorder(
                          borderRadius: Theming.borderRadiusBig,
                        ),
                      ),
                      icon: const Icon(LucideIcons.fingerprint, size: 20),
                      label: const Text(
                        'Unlock',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
