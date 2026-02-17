import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/data_insights_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/landing_app_bar.dart';

/// Landing Page profesional de FutBase 3.0
///
/// Diseño moderno y responsive con:
/// - Hero section impactante
/// - Sección de características
/// - Estadísticas animadas
/// - Call to action
/// - Footer completo
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Mostrar fondo del AppBar al hacer scroll
    if (_scrollController.offset > 100 && !_showAppBarBackground) {
      setState(() => _showAppBarBackground = true);
    } else if (_scrollController.offset <= 100 && _showAppBarBackground) {
      setState(() => _showAppBarBackground = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: LandingAppBar(showBackground: _showAppBarBackground),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ========== HERO SECTION ==========
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: const HeroSection(),
            ),

            // ========== FEATURES SECTION ==========
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: const FeaturesSection(),
            ),

            // ========== DATA INSIGHTS SECTION ==========
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: const DataInsightsSection(),
            ),

            // ========== STATS SECTION ==========
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: const StatsSection(),
            ),

            // ========== CTA SECTION ==========
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 600),
              child: const CtaSection(),
            ),

            // ========== FOOTER ==========
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
