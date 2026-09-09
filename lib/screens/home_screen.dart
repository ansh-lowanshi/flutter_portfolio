// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../project_model.dart';

// ─── Colour tokens ────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0E1A);
const _sidebar = Color(0xFF060C18);
const _card = Color(0xFF111827);
const _cardBorder = Color(0xFF1E2D40);
const _accent = Color(0xFF38BDF8);
const _accentAlt = Color(0xFF818CF8);
const _accentGlow = Color(0x3038BDF8);

// ─── App ──────────────────────────────────────────────────────────────────────
class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ansh Lowanshi | Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: _accent,
        scaffoldBackgroundColor: _bg,
        textTheme:
            GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          secondary: _accentAlt,
          surface: _card,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        if (name.startsWith('/project/')) {
          final id = name.replaceFirst('/project/', '');
          final project = myProjects.firstWhere(
            (p) => p.id == id,
            orElse: () => myProjects.first,
          );
          return MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(project: project),
          );
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final List<GlobalKey> _keys = List.generate(6, (_) => GlobalKey());
  final _sectionNames = ['Home', 'About', 'Skills', 'Resume', 'Projects', 'Contact'];
  int _activeSection = 0;
  Project? _selectedProject;

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
    for (int i = _keys.length - 1; i >= 0; i--) {
      final ctx = _keys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final pos = box.localToGlobal(Offset.zero);
      if (pos.dy <= 150) {
        if (_activeSection != i) setState(() => _activeSection = i);
        break;
      }
    }
  }

  void _scrollTo(int i) {
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    if (MediaQuery.of(context).size.width < 1000) Navigator.pop(context);
    setState(() => _activeSection = i);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: _bg,
      drawer: isDesktop ? null : Drawer(child: _Sidebar(active: _activeSection, onTap: _scrollTo)),
      body: Stack(
        children: [
          Row(
            children: [
              if (isDesktop)
                SizedBox(
                  width: 280,
                  child: _Sidebar(active: _activeSection, onTap: _scrollTo),
                ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (!isDesktop)
                      SliverAppBar(
                        floating: true,
                        backgroundColor: _sidebar,
                        title: Text('Ansh Lowanshi',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                        iconTheme: const IconThemeData(color: _accent),
                      ),
                    SliverToBoxAdapter(child: SizedBox(key: _keys[0], child: const _HeroSection())),
                    SliverToBoxAdapter(child: SizedBox(key: _keys[1], child: const _AboutSection())),
                    SliverToBoxAdapter(child: SizedBox(key: _keys[2], child: const _SkillsSection())),
                    SliverToBoxAdapter(child: SizedBox(key: _keys[3], child: const _ResumeSection())),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        key: _keys[4],
                        child: _ProjectsSection(
                          onTryNow: (p) => setState(() => _selectedProject = p),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(key: _keys[5], child: const _ContactSection())),
                    const SliverToBoxAdapter(child: _Footer()),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedProject != null)
            _AppRunnerOverlay(
              project: _selectedProject!,
              onClose: () => setState(() => _selectedProject = null),
            ),
        ],
      ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final int active;
  final void Function(int) onTap;
  const _Sidebar({required this.active, required this.onTap});

  static const _icons = [
    Icons.home_outlined,
    Icons.person_outline,
    Icons.bar_chart_outlined,
    Icons.description_outlined,
    Icons.apps_outlined,
    Icons.mail_outline,
  ];
  static const _names = ['Home', 'About', 'Skills', 'Resume', 'Projects', 'Contact'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _sidebar,
        border: Border(right: BorderSide(color: _cardBorder)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          // Profile avatar with glow ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 2)],
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: _cardBorder,
              child: ClipOval(
                child: Image.asset(
                  'assets/img/my-profile-img.jpg',
                  width: 108,
                  height: 108,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: _accent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ansh Lowanshi',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_accent, _accentAlt],
            ).createShader(bounds),
            child: Text('Flutter Developer',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialBtn(icon: FontAwesomeIcons.github, url: 'https://github.com/ansh-lowanshi'),
              _SocialBtn(icon: FontAwesomeIcons.linkedin, url: 'https://www.linkedin.com/in/ansh-lowanshi/'),
              _SocialBtn(icon: FontAwesomeIcons.instagram, url: 'https://www.instagram.com/ansh_lowanshi/'),
              _SocialBtn(icon: FontAwesomeIcons.envelope, url: 'mailto:lowanshiansh@gmail.com'),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: _cardBorder, indent: 24, endIndent: 24),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _names.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (ctx, i) {
                final isActive = i == active;
                return _NavItem(
                  icon: _icons[i],
                  label: _names[i],
                  isActive: isActive,
                  onTap: () => onTap(i),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final highlight = widget.isActive || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: highlight ? _accentGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive ? _accent : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: highlight ? _accent : Colors.grey),
              const SizedBox(width: 12),
              Text(widget.label,
                  style: TextStyle(
                    color: highlight ? _accent : Colors.grey,
                    fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  )),
              if (widget.isActive) ...[
                const Spacer(),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final dynamic icon;
  final String url;
  const _SocialBtn({required this.icon, required this.url});
  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered ? _accentGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _hovered ? _accent : Colors.transparent),
          ),
          child: FaIcon(widget.icon, size: 16, color: _hovered ? _accent : Colors.grey),
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1000;

    return Container(
      height: h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF070D1C), Color(0xFF0D1830), Color(0xFF091220)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative glowing orbs
          Positioned(top: h * 0.15, right: w * 0.1, child: _GlowOrb(size: 300, color: _accent.withValues(alpha: 0.08))),
          Positioned(bottom: h * 0.2, left: w * 0.05, child: _GlowOrb(size: 200, color: _accentAlt.withValues(alpha: 0.07))),
          Positioned(top: h * 0.5, right: w * 0.3, child: _GlowOrb(size: 150, color: _accent.withValues(alpha: 0.05))),

          // Grid pattern overlay
          CustomPaint(size: Size(w, h), painter: _GridPainter()),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: isDesktop
                  ? _HeroText()
                  : _HeroText(centered: true),
            ),
          ),

          // Scroll hint
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('Scroll Down', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                const SizedBox(height: 8),
                const _ScrollIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final bool centered;
  const _HeroText({this.centered = false});

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.left;
    final cross = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        // Greeting badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _accentGlow,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Available for freelance', style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Name with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFCBD5E1)],
          ).createShader(bounds),
          child: Text(
            'Ansh Lowanshi',
            textAlign: align,
            style: GoogleFonts.poppins(
              fontSize: centered ? 40 : 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Animated roles
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_accent, _accentAlt],
              ).createShader(bounds),
              child: Text("I'm a ", style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TyperAnimatedText(
                  'Flutter Developer',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
                TyperAnimatedText(
                  'Mobile App Engineer',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _accentAlt,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
                TyperAnimatedText(
                  'Software Engineer Intern',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'B.Tech CS student at IIIT Kota. Building beautiful, high-performance\nmobile & web apps with Flutter & Firebase.',
          textAlign: align,
          style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 36),
        // CTA buttons
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _GradientButton(
              label: 'View Projects',
              icon: Icons.apps_rounded,
              onPressed: () => launchUrl(Uri.parse('#projects')),
            ),
            _OutlineButton(
              label: 'Download CV',
              icon: Icons.download_rounded,
              onPressed: () => html.window.open('assets/resume/ANSH_LOWANSHI.pdf', '_blank'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 290,
          height: 290,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [_accent.withValues(alpha: 0.2), Colors.transparent]),
          ),
        ),
        // Border ring
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _accent.withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
          ),
        ),
        // Actual image
        ClipOval(
          child: Image.asset(
            'assets/img/my-profile-img.jpg',
            width: 240,
            height: 240,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 240,
              height: 240,
              color: _card,
              child: const Icon(Icons.person, size: 80, color: _accent),
            ),
          ),
        ),
        // Floating tech badge
        Positioned(
          bottom: 20,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withValues(alpha: 0.5)),
              boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flutter_dash, color: _accent, size: 18),
                const SizedBox(width: 6),
                Text('Flutter Dev', style: GoogleFonts.poppins(fontSize: 11, color: _accent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator();
  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: 0.3 + _anim.value * 0.7,
        child: Transform.translate(
          offset: Offset(0, _anim.value * 6),
          child: const Icon(Icons.keyboard_arrow_down, color: _accent, size: 28),
        ),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.icon, required this.onPressed});
  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered ? [_accentAlt, _accent] : [_accent, _accentAlt],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (_hovered ? _accentAlt : _accent).withValues(alpha: _hovered ? 0.5 : 0.3),
                blurRadius: _hovered ? 20 : 10,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _OutlineButton({required this.label, required this.icon, required this.onPressed});
  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? _accentGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _hovered ? _accent : Colors.white38, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: _hovered ? _accent : Colors.white70),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(color: _hovered ? _accent : Colors.white70, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── About Section ────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'About Me', subtitle: 'Get to know me'),
          const SizedBox(height: 48),
          const _AboutContent(),
          // const SizedBox(height: 60),
          // const _StatsRow(),
        ],
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Intro ────────────────────────────────────────────────
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [_accent, _accentAlt]).createShader(b),
          child: Text('Flutter Developer & Software Engineer',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 16),
        Text(
          "I'm Ansh Lowanshi, a passionate Software Engineer specialising in Flutter mobile development, "
          "REST APIs, and building responsive user-centric apps. B.Tech Computer Science student at "
          "IIIT Kota (CGPA 7.36) — turning ideas into polished, scalable products.",
          style: TextStyle(color: Colors.grey[400], height: 1.8, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _InfoItem(icon: Icons.phone_outlined, label: '+91 7828479491'),
            _InfoItem(icon: Icons.email_outlined, label: 'lowanshiansh@gmail.com'),
            _InfoItem(icon: Icons.location_on_outlined, label: 'Bhopal, MP, India'),
            _InfoItem(icon: Icons.school_outlined, label: 'B.Tech Computer Science'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _GradientButton(
              label: 'View Resume',
              icon: Icons.open_in_new_rounded,
              onPressed: () => html.window.open('assets/resume/ANSH_LOWANSHI.pdf', '_blank'),
            ),
            const SizedBox(width: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final anchor = html.AnchorElement(href: 'assets/resume/ANSH_LOWANSHI.pdf')
                    ..setAttribute('download', 'ANSH_LOWANSHI_Resume.pdf')
                    ..click();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded, color: _accent, size: 18),
                      SizedBox(width: 8),
                      Text('Download', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: _accentGlow, borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: _accent, size: 16),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(number: '9+', label: 'Projects\nCompleted', icon: Icons.folder_outlined),
        const SizedBox(width: 20),
        _StatCard(number: '1', label: 'Internship\nCompleted', icon: Icons.work_outline),
        const SizedBox(width: 20),
        _StatCard(number: '5+', label: 'Clubs &\nActivities', icon: Icons.group_outlined),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final String number, label;
  final IconData icon;
  const _StatCard({required this.number, required this.label, required this.icon});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? _card : _card.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _hovered ? _accent : _cardBorder),
          boxShadow: _hovered ? [BoxShadow(color: _accent.withValues(alpha: 0.2), blurRadius: 20)] : [],
        ),
        child: Column(
          children: [
            Icon(widget.icon, color: _accent, size: 28),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [_accent, _accentAlt]).createShader(b),
              child: Text(widget.number,
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Text(widget.label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Skills Section ───────────────────────────────────────────────────────────
class _SkillsSection extends StatelessWidget {
  const _SkillsSection();

  static const _skills = [
    ('Dart', 0.85, _accent),
    ('Flutter', 0.80, _accent),
    ('Firebase', 0.75, _accentAlt),
    ('C/C++', 0.65, _accentAlt),
    ('Python', 0.50, Color(0xFF34D399)),
    ('SQL', 0.30, Color(0xFFFBBF24)),
  ];

  static const _tools = [
    'Android Studio', 'VS Code', 'Git & GitHub', 'Postman',
    'Figma', 'REST APIs', 'Riverpod', 'Provider', 'GetX', 'Hive',
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    return _SectionWrapper(
      isDark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Skills', subtitle: 'My core proficiencies'),
          const SizedBox(height: 48),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _SkillBarsColumn(skills: _skills)),
                    const SizedBox(width: 60),
                    Expanded(child: _ToolsColumn(tools: _tools)),
                  ],
                )
              : Column(
                  children: [
                    _SkillBarsColumn(skills: _skills),
                    const SizedBox(height: 40),
                    _ToolsColumn(tools: _tools),
                  ],
                ),
        ],
      ),
    );
  }
}

class _SkillBarsColumn extends StatelessWidget {
  final List<(String, double, Color)> skills;
  const _SkillBarsColumn({required this.skills});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Technical Skills', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        ...skills.map((s) => _AnimatedSkillBar(label: s.$1, percentage: s.$2, color: s.$3)),
      ],
    );
  }
}

class _AnimatedSkillBar extends StatefulWidget {
  final String label;
  final double percentage;
  final Color color;
  const _AnimatedSkillBar({required this.label, required this.percentage, required this.color});
  @override
  State<_AnimatedSkillBar> createState() => _AnimatedSkillBarState();
}

class _AnimatedSkillBarState extends State<_AnimatedSkillBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => Text(
                  '${(widget.percentage * _anim.value * 100).toInt()}%',
                  style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => LinearProgressIndicator(
                value: widget.percentage * _anim.value,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(widget.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsColumn extends StatelessWidget {
  final List<String> tools;
  const _ToolsColumn({required this.tools});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tools & Technologies', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tools.map((t) => _TechChip(label: t)).toList(),
        ),
      ],
    );
  }
}

class _TechChip extends StatefulWidget {
  final String label;
  const _TechChip({required this.label});
  @override
  State<_TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<_TechChip> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _hovered ? _accentGlow : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _hovered ? _accent : Colors.white12),
        ),
        child: Text(widget.label,
            style: TextStyle(color: _hovered ? _accent : Colors.grey[300], fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ─── Resume Section ───────────────────────────────────────────────────────────
class _ResumeSection extends StatelessWidget {
  const _ResumeSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    return _SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Resume', subtitle: 'My journey'),
          const SizedBox(height: 48),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _EducationColumn()),
                    const SizedBox(width: 60),
                    Expanded(child: _ExperienceColumn()),
                  ],
                )
              : Column(
                  children: [
                    _EducationColumn(),
                    const SizedBox(height: 40),
                    _ExperienceColumn(),
                  ],
                ),
        ],
      ),
    );
  }
}

class _EducationColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.school_outlined, color: _accent),
          const SizedBox(width: 10),
          Text('Education', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 24),
        _TimelineItem(
          title: 'Bachelor of Technology in Computer Science',
          subtitle: 'IIIT Kota, Rajasthan',
          date: '2022 – 2026',
          detail: 'Currently pursuing B.Tech with a CGPA of 7.36',
          isActive: true,
        ),
        _TimelineItem(
          title: 'Higher Secondary Education',
          subtitle: 'Narmada Valley Academy, Seoni-Malwa, MP',
          date: '2021',
          detail: 'Completed with 85% score',
        ),
      ],
    );
  }
}

class _ExperienceColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.work_outline, color: _accentAlt),
          const SizedBox(width: 10),
          Text('Experience', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 24),
        _TimelineItem(
          title: 'Software Engineer Intern',
          subtitle: 'Sentient Digital Pvt. Ltd., Indore, MP',
          date: 'Mar 2025 – Jun 2025',
          detail: '• Built field-force management apps using Flutter & REST APIs\n'
              '• Implemented state management with Riverpod\n'
              '• Integrated real-time location tracking\n'
              '• Designing, coding, testing & documenting new features in agile teams',
          color: _accentAlt,
          isActive: true,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title, subtitle, date, detail;
  final Color color;
  final bool isActive;
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.detail,
    this.color = _accent,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                  boxShadow: isActive ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)] : [],
                ),
              ),
              Container(width: 2, height: 100, color: color.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(date, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  Text(detail, style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Projects Section ─────────────────────────────────────────────────────────
class _ProjectsSection extends StatelessWidget {
  final void Function(Project) onTryNow;
  const _ProjectsSection({required this.onTryNow});

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      isDark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Projects', subtitle: 'Some highlights'),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (ctx, constraints) {
            final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: myProjects.map((p) {
                final width = (constraints.maxWidth - (cols - 1) * 24) / cols;
                return SizedBox(width: width, child: _ProjectCard(project: p, onTryNow: onTryNow));
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final void Function(Project) onTryNow;
  const _ProjectCard({required this.project, required this.onTryNow});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/project/${p.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: _hovered ? (Matrix4.identity()..translate(0.0, -6.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _hovered ? _accent : _cardBorder),
            boxShadow: [
              BoxShadow(
                color: _hovered ? _accent.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.3),
                blurRadius: _hovered ? 24 : 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: Stack(
                  children: [
                    Image.asset(
                      p.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: _cardBorder,
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _accent.withValues(alpha: 0.5)),
                        ),
                        child: Text(p.category, style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Hover overlay
                    if (_hovered)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: Text('View Details →',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(p.description,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 14),
                    // Tech chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: p.techStack.take(3).map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _accentGlow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(t, style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SmallGradientBtn(
                            label: 'Try Now',
                            icon: Icons.play_arrow_rounded,
                            onTap: () => widget.onTryNow(p),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _IconOutlineBtn(
                          icon: Icons.open_in_new_rounded,
                          tooltip: 'View Details',
                          onTap: () => Navigator.pushNamed(context, '/project/${p.id}'),
                        ),
                        const SizedBox(width: 8),
                        _IconOutlineBtn(
                          icon: Icons.download_rounded,
                          tooltip: 'Download APK',
                          onTap: () => html.window.open(p.apkUrl, '_blank'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallGradientBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SmallGradientBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_accent, _accentAlt]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconOutlineBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconOutlineBtn({required this.icon, required this.tooltip, required this.onTap});
  @override
  State<_IconOutlineBtn> createState() => _IconOutlineBtnState();
}

class _IconOutlineBtnState extends State<_IconOutlineBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _hovered ? _accentGlow : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _hovered ? _accent : _cardBorder),
            ),
            child: Icon(widget.icon, size: 16, color: _hovered ? _accent : Colors.grey),
          ),
        ),
      ),
    );
  }
}

// ─── Contact Section ──────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Contact', subtitle: "Let's work together"),
          const SizedBox(height: 48),
          // Contact info cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _ContactInfoCard(icon: Icons.location_on_outlined, title: 'Location', value: 'Bhopal, MP, India'),
              _ContactInfoCard(icon: Icons.email_outlined, title: 'Email', value: 'lowanshiansh@gmail.com'),
              _ContactInfoCard(icon: Icons.phone_android_outlined, title: 'Phone', value: '+91 7828479491'),
            ],
          ),
          const SizedBox(height: 48),
          _ContactSideInfo(),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatefulWidget {
  final IconData icon;
  final String title, value;
  const _ContactInfoCard({required this.icon, required this.title, required this.value});
  @override
  State<_ContactInfoCard> createState() => _ContactInfoCardState();
}

class _ContactInfoCardState extends State<_ContactInfoCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? _accent : _cardBorder),
          boxShadow: _hovered ? [BoxShadow(color: _accent.withValues(alpha: 0.2), blurRadius: 16)] : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentGlow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: _accent, size: 24),
            ),
            const SizedBox(height: 12),
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(widget.value, style: TextStyle(color: Colors.grey[400], fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


class _ContactSideInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Let's Connect", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          "I'm always open to discussing new projects, creative ideas or opportunities to be part of your vision.",
          style: TextStyle(color: Colors.grey[400], height: 1.7),
        ),
        const SizedBox(height: 32),
        Text('Follow me on', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        const SizedBox(height: 16),
        Row(
          children: [
            _SocialLargeBtn(icon: FontAwesomeIcons.github, label: 'GitHub', url: 'https://github.com/ansh-lowanshi'),
            const SizedBox(width: 12),
            _SocialLargeBtn(icon: FontAwesomeIcons.linkedin, label: 'LinkedIn', url: 'https://www.linkedin.com/in/ansh-lowanshi/'),
            const SizedBox(width: 12),
            _SocialLargeBtn(icon: FontAwesomeIcons.instagram, label: 'Instagram', url: 'https://www.instagram.com/ansh_lowanshi/'),
          ],
        ),
      ],
    );
  }
}

class _SocialLargeBtn extends StatefulWidget {
  final dynamic icon;
  final String label, url;
  const _SocialLargeBtn({required this.icon, required this.label, required this.url});
  @override
  State<_SocialLargeBtn> createState() => _SocialLargeBtnState();
}

class _SocialLargeBtnState extends State<_SocialLargeBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? _accentGlow : _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? _accent : _cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(widget.icon, size: 14, color: _hovered ? _accent : Colors.grey),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(color: _hovered ? _accent : Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: _sidebar,
        border: Border(top: BorderSide(color: _cardBorder)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [_accent, _accentAlt]).createShader(b),
            child: Text('Ansh Lowanshi', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          Text('Flutter Developer & Software Engineer',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialBtn(icon: FontAwesomeIcons.github, url: 'https://github.com/ansh-lowanshi'),
              _SocialBtn(icon: FontAwesomeIcons.linkedin, url: 'https://www.linkedin.com/in/ansh-lowanshi/'),
              _SocialBtn(icon: FontAwesomeIcons.instagram, url: 'https://www.instagram.com/ansh_lowanshi/'),
              _SocialBtn(icon: FontAwesomeIcons.envelope, url: 'mailto:lowanshiansh@gmail.com'),
            ],
          ),
          const SizedBox(height: 20),
          Text('© 2026 Ansh Lowanshi. All Rights Reserved.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text('Built with Flutter ❤️', style: TextStyle(color: Colors.grey[700], fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── App Runner Overlay ───────────────────────────────────────────────────────
class _AppRunnerOverlay extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  const _AppRunnerOverlay({required this.project, required this.onClose});
  @override
  State<_AppRunnerOverlay> createState() => _AppRunnerOverlayState();
}

class _AppRunnerOverlayState extends State<_AppRunnerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  final _registered = <String>{};

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _registerIframe();
  }

  void _registerIframe() {
    final viewType = 'iframe-${widget.project.id}';
    if (!_registered.contains(viewType)) {
      _registered.add(viewType);
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) => html.IFrameElement()
          ..src = widget.project.webUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'fullscreen',
      );
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: child,
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _accent, width: 1.5),
              boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 40)],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: _sidebar,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(27)),
                    border: const Border(bottom: BorderSide(color: _cardBorder)),
                  ),
                  child: Row(
                    children: [
                      // Traffic light dots
                      Row(children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF5F57), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF28CA41), shape: BoxShape.circle)),
                      ]),
                      const SizedBox(width: 20),
                      // URL bar
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 12, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(p.webUrl, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(p.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 16),
                      // External link
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
                        tooltip: 'Open in new tab',
                        onPressed: () => html.window.open(p.webUrl, '_blank'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        tooltip: 'Close',
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
                // iFrame
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(27)),
                    child: HtmlElementView(viewType: 'iframe-${p.id}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _SectionWrapper extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SectionWrapper({required this.child, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      color: isDark ? const Color(0xFF0D1425) : _bg,
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle.toUpperCase(),
            style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Color(0xFF94A3B8)]).createShader(bounds),
          child: Text(title,
              style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_accent, _accentAlt]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─── Project Detail Screen ────────────────────────────────────────────────────
class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
              // Simple pinned AppBar — no hero image
              SliverAppBar(
                pinned: true,
                backgroundColor: _sidebar,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: _accent),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentGlow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p.category,
                          style: const TextStyle(
                              color: _accent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(p.title,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              // ── Main content: screenshots left 60%, about right 40% (desktop) ──
              SliverToBoxAdapter(
                child: isDesktop
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left 60% — screenshot gallery
                            Expanded(
                              flex: 6,
                              child: _ScreenshotGallerySection(project: p),
                            ),
                            const SizedBox(width: 40),
                            // Right 40% — about + sidebar
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ProjectDetailContent(project: p),
                                  const SizedBox(height: 36),
                                  _ProjectSidebar(project: p),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          _ScreenshotGallerySection(project: p),
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                _ProjectSidebar(project: p),
                                const SizedBox(height: 32),
                                _ProjectDetailContent(project: p),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
  }
}

// ─── Screenshot Gallery (top of detail page) ────────────────────────────────
class _ScreenshotGallerySection extends StatefulWidget {
  final Project project;
  const _ScreenshotGallerySection({required this.project});
  @override
  State<_ScreenshotGallerySection> createState() => _ScreenshotGallerySectionState();
}

class _ScreenshotGallerySectionState extends State<_ScreenshotGallerySection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final shots = widget.project.screenshots;
    if (shots.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1425),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) =>
                    const LinearGradient(colors: [_accent, _accentAlt]).createShader(b),
                child: Text('Screenshots',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentGlow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${shots.length} images',
                    style: const TextStyle(
                        color: _accent, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${_selected + 1} of ${shots.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 16),
          // Single image viewer with prev/next buttons
          Stack(
            alignment: Alignment.center,
            children: [
              // Image with crossfade animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: ClipRRect(
                  key: ValueKey(_selected),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _accent, width: 1.5),
                      boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.25), blurRadius: 24, spreadRadius: 2)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        shots[_selected],
                        height: 460,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 460,
                          color: _card,
                          child: const Center(
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey, size: 48)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Prev button
              Positioned(
                left: 10,
                child: _NavButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: _selected > 0,
                  onTap: () => setState(() => _selected--),
                ),
              ),
              // Next button
              Positioned(
                right: 10,
                child: _NavButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: _selected < shots.length - 1,
                  onTap: () => setState(() => _selected++),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(shots.length, (i) {
              final isSelected = i == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? _accent : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isSelected
                        ? [BoxShadow(color: _accent.withValues(alpha: 0.5), blurRadius: 6)]
                        : [],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Project Detail Content (description only) ───────────────────────────────
class _ProjectDetailContent extends StatelessWidget {
  final Project project;
  const _ProjectDetailContent({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (b) =>
              const LinearGradient(colors: [_accent, _accentAlt]).createShader(b),
          child: Text('About This Project',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 20),
        Text(project.longDescription,
            style: TextStyle(color: Colors.grey[300], height: 1.85, fontSize: 15)),
      ],
    );
  }
}

class _ProjectSidebar extends StatelessWidget {
  final Project project;
  const _ProjectSidebar({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Download APK (primary CTA)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => html.window.open(p.apkUrl, '_blank'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFF34D399).withValues(alpha: 0.4), blurRadius: 20)],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.android, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Download APK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // GitHub
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => launchUrl(Uri.parse(p.githubUrl)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.github, color: Colors.white54, size: 18),
                  SizedBox(width: 10),
                  Text('View on GitHub', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Project info card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Info', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _InfoRow(label: 'Category', value: p.category),
              const Divider(color: _cardBorder, height: 24),
              Text('Tech Stack', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.techStack.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accentGlow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(t, style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w500)),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Nav Button (prev / next for screenshot gallery) ─────────────────────────
class _NavButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.enabled, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered && widget.enabled
                ? _accent.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.55),
            border: Border.all(
              color: widget.enabled ? _accent : _cardBorder,
              width: 1.5,
            ),
            boxShadow: widget.enabled
                ? [BoxShadow(color: _accent.withValues(alpha: 0.3), blurRadius: 12)]
                : [],
          ),
          child: Icon(
            widget.icon,
            color: widget.enabled ? _accent : Colors.white24,
            size: 26,
          ),
        ),
      ),
    );
  }
}
