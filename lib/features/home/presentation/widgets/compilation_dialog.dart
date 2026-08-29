import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../core/utils/file_saver/file_saver.dart';
import '../../../../core/constants/app_strings.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  COMPILATION DIALOG CONTENT (HIGH-FIDELITY SCIFI TERMINAL DESIGN)
// ══════════════════════════════════════════════════════════════════════════════
class CompilationDialogContent extends StatefulWidget {
  final GlobalKey frontKey;
  final GlobalKey backKey;
  final Future<Uint8List?> Function(GlobalKey) captureFn;
  final String teeColor;

  final String frontQuote;
  final String backQuote;
  final String frontFont;
  final String backFont;
  final double frontRotation;
  final double backRotation;
  final double frontScale;
  final double backScale;
  final Offset frontOffset;
  final Offset backOffset;

  final List<Map<String, dynamic>> textColors;
  final int frontColorIdx;
  final int backColorIdx;
  final TextAlign frontAlign;
  final TextAlign backAlign;

  final double frontLetterSpacing;
  final double backLetterSpacing;
  final double frontLineHeight;
  final double backLineHeight;

  const CompilationDialogContent({
    super.key,
    required this.frontKey,
    required this.backKey,
    required this.captureFn,
    required this.teeColor,
    required this.frontQuote,
    required this.backQuote,
    required this.frontFont,
    required this.backFont,
    required this.frontRotation,
    required this.backRotation,
    required this.frontScale,
    required this.backScale,
    required this.frontOffset,
    required this.backOffset,
    required this.textColors,
    required this.frontColorIdx,
    required this.backColorIdx,
    required this.frontAlign,
    required this.backAlign,
    required this.frontLetterSpacing,
    required this.backLetterSpacing,
    required this.frontLineHeight,
    required this.backLineHeight,
  });

  @override
  State<CompilationDialogContent> createState() =>
      _CompilationDialogContentState();
}

class _CompilationDialogContentState extends State<CompilationDialogContent> {
  bool _isCompiling = true;
  double _progress = 0.0;
  final List<String> _logs = [];

  Uint8List? _frontBytes;
  Uint8List? _backBytes;
  bool _isFrontTab = true;
  bool _showJsonPayload = false;

  @override
  void initState() {
    super.initState();
    _isFrontTab = widget.frontQuote.isNotEmpty || widget.backQuote.isEmpty;
    _startCompilationSequence();
  }

  void _startCompilationSequence() async {
    final stages = [
      'INITIATING ARTWORK COMPILER MATRIX V1.0.8...',
      'ACQUIRING TYPOGRAPHY CANVAS INTERACTION NODES...',
      'SCANNING VECTOR GRAPHICS RESOLUTION SCALES...',
      'RASTERIZING DYNAMIC GOOGLE FONTS FOR DIRECT PRINT...',
      'DE-NOISING ALPHA TRANSPARENCY SHADOW BUFFERS...',
      'GENERATING FRONT-SIDE GRAPHIC STAGES...',
      'GENERATING BACK-SIDE GRAPHIC STAGES...',
      'RESOLVING 4.0X HIGH-DPI ARTWORK EXPORTS...',
      'ARTWORK COMPILATION COMPLETED SUCCESSFULLY!',
    ];

    for (int i = 0; i < stages.length; i++) {
      if (!mounted) return;
      setState(() {
        _progress = (i + 1) / stages.length;
        _logs.add('[${_getTimeString()}] ${stages[i]}');
      });

      // Asynchronously trigger canvas capturing at the right stages to avoid blocking UI
      if (i == 5 && widget.frontQuote.isNotEmpty) {
        final bytes = await widget.captureFn(widget.frontKey);
        if (mounted) setState(() => _frontBytes = bytes);
      } else if (i == 6 && widget.backQuote.isNotEmpty) {
        final bytes = await widget.captureFn(widget.backKey);
        if (mounted) setState(() => _backBytes = bytes);
      }

      await Future.delayed(const Duration(milliseconds: 320));
    }

    if (mounted) {
      setState(() {
        _isCompiling = false;
      });
    }
  }

  String _getTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${(now.millisecond ~/ 100)}';
  }

  String _generateJsonPayload() {
    final hasFront = widget.frontQuote.isNotEmpty;
    final hasBack = widget.backQuote.isNotEmpty;

    final frontBase64 = _frontBytes != null
        ? 'data:image/png;base64,${base64Encode(_frontBytes!)}'
        : 'null';
    final backBase64 = _backBytes != null
        ? 'data:image/png;base64,${base64Encode(_backBytes!)}'
        : 'null';

    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'garment': {
        'style': 'Premium Streetwear Heavy Oversized Tee',
        'color': widget.teeColor,
      },
      'print_settings': {
        'profile': 'DTG (Direct to Garment)',
        'dpi': 300,
        'resolution_px': '2400 x 2400',
      },
      'artwork': {
        if (hasFront)
          'front': {
            'text': widget.frontQuote,
            'font': widget.frontFont,
            'letter_spacing': widget.frontLetterSpacing,
            'line_height': widget.frontLineHeight,
            'rotation_deg': widget.frontRotation,
            'scale': widget.frontScale,
            'offset': [widget.frontOffset.dx, widget.frontOffset.dy],
            'alignment': widget.frontAlign.toString(),
            'bytes_base64_preview': _truncateBase64(frontBase64),
          },
        if (hasBack)
          'back': {
            'text': widget.backQuote,
            'font': widget.backFont,
            'letter_spacing': widget.backLetterSpacing,
            'line_height': widget.backLineHeight,
            'rotation_deg': widget.backRotation,
            'scale': widget.backScale,
            'offset': [widget.backOffset.dx, widget.backOffset.dy],
            'alignment': widget.backAlign.toString(),
            'bytes_base64_preview': _truncateBase64(backBase64),
          },
      },
    };

    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  String _truncateBase64(String base64) {
    if (base64.length > 50) {
      return '${base64.substring(0, 35)}... [TRUNCATED METADATA: ${base64.length} BYTES]';
    }
    return base64;
  }

  void _triggerDownload() async {
    final activeBytes = _isFrontTab ? _frontBytes : _backBytes;
    final sideName = _isFrontTab ? 'front' : 'back';
    if (activeBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.downloadNoArtwork.replaceFirst('%s', sideName))),
      );
      return;
    }

    try {
      final filename =
          'epod_artwork_${sideName}_${DateTime.now().millisecondsSinceEpoch}.png';
      await FileSaverService.savePng(activeBytes, filename);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF00FFCC),
          content: Text(
            AppStrings.downloadSuccess.replaceFirst('%s', filename),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(AppStrings.downloadError.replaceFirst('%s', e.toString())),
        ),
      );
    }
  }

  void _simulateApiUpload() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF00FFCC),
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 12),
            Text(
              AppStrings.apiSimulatePackaging,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          AppStrings.apiSimulateQueued,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateJsonPayload()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF00FFCC),
        content: Text(
          AppStrings.apiJsonCopied,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Center(
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 880,
        height: isMobile ? MediaQuery.of(context).size.height * 0.85 : 620,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C10).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00FFCC).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFCC).withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FFCC),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText.spaceMono(
                    AppStrings.artworkCompilingTitle,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white60,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isCompiling
                  ? _buildCompilerLoader()
                  : _buildCompilerOutputTerminal(isMobile),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompilerLoader() {
    return Padding(
      key: const ValueKey('compiling'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Futuristic Cyber Spinner
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 3.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00FFCC),
                  ),
                  backgroundColor: Colors.white10,
                ),
              ),
              AppText.spaceMono(
                '${(_progress * 100).toInt()}%',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00FFCC),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Technical Terminal Console Logs
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                reverse: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, idx) {
                  // Display standard compiler style logs
                  final log = _logs[_logs.length - 1 - idx];
                  final isSuccess = log.contains('SUCCESSFULLY');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: AppText.spaceMono(
                      log,
                      fontSize: 10,
                      color: isSuccess
                          ? const Color(0xFF00FFCC)
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompilerOutputTerminal(bool isMobile) {
    final hasFront = widget.frontQuote.isNotEmpty;
    final hasBack = widget.backQuote.isNotEmpty;
    final activeBytes = _isFrontTab ? _frontBytes : _backBytes;
    final activeFont = _isFrontTab ? widget.frontFont : widget.backFont;
    final activeQuote = _isFrontTab ? widget.frontQuote : widget.backQuote;

    final childWidget = isMobile
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: _buildArtworkSection(activeBytes, hasFront, hasBack),
                ),
                const SizedBox(height: 16),
                _buildDetailsAndDeveloperConsole(activeFont, activeQuote),
              ],
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column: Artwork Preview Tab Stack
              Expanded(
                flex: 4,
                child: _buildArtworkSection(activeBytes, hasFront, hasBack),
              ),
              const SizedBox(width: 20),
              // Right Column: Specs, Payload and Action triggers
              Expanded(
                flex: 5,
                child: _buildDetailsAndDeveloperConsole(
                  activeFont,
                  activeQuote,
                ),
              ),
            ],
          );

    return Padding(
      key: const ValueKey('terminal'),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: childWidget,
    );
  }

  Widget _buildArtworkSection(
    Uint8List? activeBytes,
    bool hasFront,
    bool hasBack,
  ) {
    final activeQuote = _isFrontTab ? widget.frontQuote : widget.backQuote;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tabs
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isFrontTab = true),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isFrontTab
                          ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isFrontTab
                            ? const Color(0xFF00FFCC)
                            : Colors.transparent,
                      ),
                    ),
                    child: AppText.spaceMono(
                      AppStrings.frontSideArt,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: _isFrontTab
                          ? const Color(0xFF00FFCC)
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isFrontTab = false),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_isFrontTab
                          ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !_isFrontTab
                            ? const Color(0xFF00FFCC)
                            : Colors.transparent,
                      ),
                    ),
                    child: AppText.spaceMono(
                      AppStrings.backSideArt,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: !_isFrontTab
                          ? const Color(0xFF00FFCC)
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Checkerboard Transparency Frame
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Checkerboard Grid Background
                  Positioned.fill(
                    child: CustomPaint(painter: CheckerboardPainter()),
                  ),
                  // Render graphic or Empty message
                  Positioned.fill(
                    child: Center(
                      child:
                          activeBytes != null && activeQuote.trim().isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(24),
                              child: Image.memory(
                                activeBytes,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.layers_clear_outlined,
                                  color: Colors.white.withValues(alpha: 0.25),
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                AppText.spaceMono(
                                  AppStrings.noArtworkOnSide,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // Label badge overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText.spaceMono(
                        _isFrontTab
                            ? 'TRANSPARENT_FRONT.PNG'
                            : 'TRANSPARENT_BACK.PNG',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00FFCC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsAndDeveloperConsole(
    String activeFont,
    String activeQuote,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation toggle spec vs payload
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.spaceMono(
              AppStrings.specControlPanel,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
            ),
            InkWell(
              onTap: () => setState(() => _showJsonPayload = !_showJsonPayload),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _showJsonPayload
                      ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _showJsonPayload
                        ? const Color(0xFF00FFCC)
                        : Colors.white12,
                  ),
                ),
                child: AppText.spaceMono(
                  _showJsonPayload
                      ? AppStrings.closeApiConsole
                      : AppStrings.previewApiPayload,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: _showJsonPayload
                      ? const Color(0xFF00FFCC)
                      : Colors.white70,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Expanded(
          child: _showJsonPayload
              ? _buildJsonDeveloperConsole()
              : _buildSpecificationDetailsPanel(activeFont, activeQuote),
        ),

        const SizedBox(height: 16),
        // Actions
        Row(
          children: [
            Expanded(
              flex: 5,
              child: InkWell(
                onTap: _triggerDownload,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFCC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText.bebas(
                    AppStrings.downloadPng,
                    fontSize: 15,
                    letterSpacing: 1.2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: _simulateApiUpload,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: AppText.bebas(
                    AppStrings.queuePrintApi,
                    fontSize: 15,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJsonDeveloperConsole() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFCC).withValues(alpha: 0.25),
        ),
      ),
      child: Stack(
        children: [
          // JSON Log
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _generateJsonPayload(),
                style: GoogleFonts.spaceMono(
                  fontSize: 10.5,
                  height: 1.5,
                  color: const Color(0xFFE0E0FF),
                ),
              ),
            ),
          ),
          // Copy Button
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: _copyToClipboard,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy, size: 10, color: Color(0xFF00FFCC)),
                    const SizedBox(width: 4),
                    AppText.spaceMono(
                      AppStrings.copyJson,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00FFCC),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationDetailsPanel(
    String activeFont,
    String activeQuote,
  ) {
    final specLines = [
      {'name': AppStrings.resolutionProfile, 'value': '2400 × 2400 PX (HD READY)'},
      {'name': AppStrings.exportStandard, 'value': 'PNG-32 (TRANSPARENT ALPHA)'},
      {'name': AppStrings.baseApparelStyle, 'value': 'STREETWEAR OVERSIZED BOX-TEE'},
      {'name': AppStrings.garmentColorway, 'value': widget.teeColor.toUpperCase()},
      {'name': AppStrings.dtgResolution, 'value': '300 DPI VECTOR GRAPHIC'},
      {'name': AppStrings.activeFontFamily, 'value': activeFont.toUpperCase()},
      {
        'name': AppStrings.printSideDesigned,
        'value': widget.frontQuote.isNotEmpty && widget.backQuote.isNotEmpty
            ? AppStrings.frontAndBack
            : widget.frontQuote.isNotEmpty
            ? AppStrings.frontOnly
            : AppStrings.backOnly,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.print_outlined,
                size: 14,
                color: Color(0xFF00FFCC),
              ),
              const SizedBox(width: 6),
              AppText.spaceMono(
                AppStrings.productionMetadata,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00FFCC),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: specLines.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, idx) => Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.04),
              ),
              itemBuilder: (context, idx) {
                final spec = specLines[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.spaceMono(
                        spec['name']!,
                        fontSize: 9,
                        color: Colors.white38,
                      ),
                      AppText.spaceMono(
                        spec['value']!,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CHECKERBOARD PAINTER FOR TRANSPARENCY VISUALIZATION
// ══════════════════════════════════════════════════════════════════════════════
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF1E1E24);
    final paint2 = Paint()..color = const Color(0xFF141418);
    const double squareSize = 8.0;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEven =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
