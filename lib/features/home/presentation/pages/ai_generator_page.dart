import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../cart/providers/cart_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/footer_section.dart';
import '../widgets/compilation_dialog.dart';
import '../../../admin/providers/storage_provider.dart';

class AIGeneratorPage extends ConsumerStatefulWidget {
  const AIGeneratorPage({super.key});

  @override
  ConsumerState<AIGeneratorPage> createState() => _AIGeneratorPageState();
}

class _AIGeneratorPageState extends ConsumerState<AIGeneratorPage>
    with SingleTickerProviderStateMixin {
  // ── Ambient Animation ──
  late AnimationController _glowController;

  // ── Front / Back side ──
  bool _isFrontSide = true;
  bool _showLineLimitWarning = false;

  // ── Keys for RepaintBoundaries (Transparent captures) ──
  final GlobalKey _frontCanvasKey = GlobalKey();
  final GlobalKey _backCanvasKey = GlobalKey();
  final GlobalKey _frontMockupKey = GlobalKey();
  final GlobalKey _backMockupKey = GlobalKey();

  // ── Per-side state storage ──
  // Front side state
  final TextEditingController _frontQuoteController = TextEditingController(
    text: 'COMPILE\nEXPLORE\nDISRUPT',
  );
  int _frontFontIndex = 0;
  double _frontFontSize = 32.0;
  double _frontLetterSpacing = 2.0;
  double _frontLineHeight = 1.3;
  TextAlign _frontTextAlign = TextAlign.center;
  int _frontTextColorIndex = 0;
  int _frontTextTransform = 0;
  double _frontRotation = 0.0;
  bool _frontHasShadow = false;
  bool _frontHasStroke = false;
  final Map<int, int> _frontWordColors = {};
  final Map<int, int> _frontWordFonts = {};
  final Map<int, double> _frontWordFontSizes = {};
  int? _frontSelectedWordIndex;
  double _frontScale = 1.0;
  Offset _frontOffset = Offset.zero;
  double? _frontPresetDx;
  double? _frontPresetDy;

  // Back side state
  final TextEditingController _backQuoteController = TextEditingController(
    text: '',
  );
  int _backFontIndex = 0;
  double _backFontSize = 28.0;
  double _backLetterSpacing = 2.0;
  double _backLineHeight = 1.3;
  TextAlign _backTextAlign = TextAlign.center;
  int _backTextColorIndex = 0;
  int _backTextTransform = 0;
  double _backRotation = 0.0;
  bool _backHasShadow = false;
  bool _backHasStroke = false;
  final Map<int, int> _backWordColors = {};
  final Map<int, int> _backWordFonts = {};
  final Map<int, double> _backWordFontSizes = {};
  int? _backSelectedWordIndex;
  double _backScale = 1.0;
  Offset _backOffset = Offset.zero;
  double? _backPresetDx;
  double? _backPresetDy;

  // ── Active side accessors ──
  TextEditingController get _quoteController =>
      _isFrontSide ? _frontQuoteController : _backQuoteController;
  int get _selectedFontIndex => _isFrontSide ? _frontFontIndex : _backFontIndex;
  set _selectedFontIndex(int v) {
    if (_isFrontSide) {
      _frontFontIndex = v;
    } else {
      _backFontIndex = v;
    }
  }

  double get _fontSize => _isFrontSide ? _frontFontSize : _backFontSize;
  set _fontSize(double v) {
    if (_isFrontSide) {
      _frontFontSize = v;
    } else {
      _backFontSize = v;
    }
  }

  double get _letterSpacing =>
      _isFrontSide ? _frontLetterSpacing : _backLetterSpacing;
  set _letterSpacing(double v) {
    if (_isFrontSide) {
      _frontLetterSpacing = v;
    } else {
      _backLetterSpacing = v;
    }
  }

  double get _lineHeight => _isFrontSide ? _frontLineHeight : _backLineHeight;
  set _lineHeight(double v) {
    if (_isFrontSide) {
      _frontLineHeight = v;
    } else {
      _backLineHeight = v;
    }
  }

  TextAlign get _selectedTextAlign =>
      _isFrontSide ? _frontTextAlign : _backTextAlign;
  set _selectedTextAlign(TextAlign v) {
    if (_isFrontSide) {
      _frontTextAlign = v;
    } else {
      _backTextAlign = v;
    }
  }

  int get _selectedTextColorIndex =>
      _isFrontSide ? _frontTextColorIndex : _backTextColorIndex;
  set _selectedTextColorIndex(int v) {
    if (_isFrontSide) {
      _frontTextColorIndex = v;
    } else {
      _backTextColorIndex = v;
    }
  }

  int get _textTransform =>
      _isFrontSide ? _frontTextTransform : _backTextTransform;
  set _textTransform(int v) {
    if (_isFrontSide) {
      _frontTextTransform = v;
    } else {
      _backTextTransform = v;
    }
  }

  double get _rotation => _isFrontSide ? _frontRotation : _backRotation;
  set _rotation(double v) {
    if (_isFrontSide) {
      _frontRotation = v;
    } else {
      _backRotation = v;
    }
  }

  bool get _hasShadow => _isFrontSide ? _frontHasShadow : _backHasShadow;
  set _hasShadow(bool v) {
    if (_isFrontSide) {
      _frontHasShadow = v;
    } else {
      _backHasShadow = v;
    }
  }

  bool get _hasStroke => _isFrontSide ? _frontHasStroke : _backHasStroke;
  set _hasStroke(bool v) {
    if (_isFrontSide) {
      _frontHasStroke = v;
    } else {
      _backHasStroke = v;
    }
  }

  Map<int, int> get _wordColors =>
      _isFrontSide ? _frontWordColors : _backWordColors;

  Map<int, int> get _wordFonts =>
      _isFrontSide ? _frontWordFonts : _backWordFonts;

  Map<int, double> get _wordFontSizes =>
      _isFrontSide ? _frontWordFontSizes : _backWordFontSizes;

  int? get _selectedWordIndex =>
      _isFrontSide ? _frontSelectedWordIndex : _backSelectedWordIndex;
  set _selectedWordIndex(int? v) {
    if (_isFrontSide) {
      _frontSelectedWordIndex = v;
    } else {
      _backSelectedWordIndex = v;
    }
  }

  double get _currentScale => _isFrontSide ? _frontScale : _backScale;
  set _currentScale(double v) {
    if (_isFrontSide) {
      _frontScale = v;
    } else {
      _backScale = v;
    }
  }

  Offset get _currentOffset => _isFrontSide ? _frontOffset : _backOffset;
  set _currentOffset(Offset v) {
    if (_isFrontSide) {
      _frontOffset = v;
    } else {
      _backOffset = v;
    }
  }

  String _selectedTeeColor = 'Washed Black';
  int _selectedCategoryIndex = 0;

  // ── Fabric map ──
  final Map<String, String> _teeColorImages = {
    'Washed Black': 'assets/images/plain_black_tee.png',
    'Heather Grey': 'assets/images/plain_grey_tee.png',
    'Optic White': 'assets/images/plain_white_tee.png',
  };

  // ── Quick Quote Templates ──
  final List<Map<String, String>> _quickQuotes = [
    {'label': '💻 Dev Flow', 'text': 'EAT\nSLEEP\nCODE\nREPEAT'},
    {'label': '🏔️ Explorer', 'text': 'NOT ALL WHO\nWANDER\nARE LOST'},
    {'label': '🚀 Founder', 'text': 'MOVE FAST\nBREAK THINGS\nBUILD EMPIRES'},
    {'label': '✈️ Nomad', 'text': 'WORK FROM\nANYWHERE'},
    {'label': '⚡ Hustle', 'text': 'STAY HUNGRY\nSTAY FOOLISH'},
    {'label': '🎯 Focus', 'text': 'LESS TALK\nMORE CODE'},
    {'label': '🌊 Chill', 'text': 'GO WITH\nTHE FLOW'},
    {'label': '🔥 Bold', 'text': 'BE THE\nDISRUPTOR'},
  ];

  // ── Position Presets ──
  final List<Map<String, dynamic>> _positionPresets = [
    {
      'label': 'CENTER',
      'icon': Icons.center_focus_strong,
      'scale': 0.7,
      'dx': 0.0,
      'dy': 0.0,
    },
    {
      'label': 'CENTER TOP',
      'icon': Icons.vertical_align_top,
      'scale': 0.7,
      'dx': 0.0,
      'dy': -1.0,
    },
    {
      'label': 'POCKET',
      'icon': Icons.crop_square,
      'scale': 0.45,
      'dx': 1.0,
      'dy': -1.0,
    },
    {
      'label': 'FULL',
      'icon': Icons.fullscreen,
      'scale': 1.0,
      'dx': 0.0,
      'dy': 0.0,
    },
    {
      'label': 'BOTTOM',
      'icon': Icons.vertical_align_bottom,
      'scale': 0.7,
      'dx': 0.0,
      'dy': 1.0,
    },
  ];

  // ── Text color palette ──
  final List<Map<String, dynamic>> _textColors = [
    {'name': 'White', 'color': const Color(0xFFFFFFFF)},
    {'name': 'Black', 'color': const Color(0xFF0A0A0A)},
    {'name': 'Cream', 'color': const Color(0xFFF5F0E1)},
    {'name': 'Neon Cyan', 'color': const Color(0xFF00FFCC)},
    {'name': 'Coral', 'color': const Color(0xFFFF6B6B)},
    {'name': 'Gold', 'color': const Color(0xFFD4AF37)},
    {'name': 'Lavender', 'color': const Color(0xFFB8A9E8)},
    {'name': 'Mint', 'color': const Color(0xFF98DFAF)},
  ];

  // ── Font categories ──
  final List<String> _fontCategories = [
    'ALL',
    'BOLD',
    'CLEAN',
    'MONO',
    'SERIF',
    'CREATIVE',
  ];

  // ── 30 Curated Google Fonts ──
  // Each entry: { name, googleFontsMethod, category }
  // The googleFontsMethod string maps to GoogleFonts.xxx()
  final List<Map<String, String>> _fonts = [
    // Bold Display
    {'name': 'Bebas Neue', 'method': 'bebasNeue', 'category': 'BOLD'},
    {'name': 'Anton', 'method': 'anton', 'category': 'BOLD'},
    {'name': 'Oswald', 'method': 'oswald', 'category': 'BOLD'},
    {'name': 'Staatliches', 'method': 'staatliches', 'category': 'BOLD'},
    {'name': 'Black Ops One', 'method': 'blackOpsOne', 'category': 'BOLD'},
    {'name': 'Bungee', 'method': 'bungee', 'category': 'BOLD'},
    {'name': 'Bungee Outline', 'method': 'bungeeOutline', 'category': 'BOLD'},
    {
      'name': 'Kumar One Outline',
      'method': 'kumarOneOutline',
      'category': 'BOLD',
    },

    // Clean Sans
    {'name': 'Outfit', 'method': 'outfit', 'category': 'CLEAN'},
    {'name': 'Montserrat', 'method': 'montserrat', 'category': 'CLEAN'},
    {'name': 'Raleway', 'method': 'raleway', 'category': 'CLEAN'},
    {'name': 'Urbanist', 'method': 'urbanist', 'category': 'CLEAN'},
    {'name': 'Syncopate', 'method': 'syncopate', 'category': 'CLEAN'},

    // Mono / Tech
    {'name': 'Fira Code', 'method': 'firaCode', 'category': 'MONO'},
    {'name': 'IBM Plex Mono', 'method': 'ibmPlexMono', 'category': 'MONO'},

    // Serif / Editorial
    {
      'name': 'Playfair Display',
      'method': 'playfairDisplay',
      'category': 'SERIF',
    },
    {
      'name': 'Cormorant Garamond',
      'method': 'cormorantGaramond',
      'category': 'SERIF',
    },
    {'name': 'Lora', 'method': 'lora', 'category': 'SERIF'},
    {'name': 'Merriweather', 'method': 'merriweather', 'category': 'SERIF'},
    {
      'name': 'DM Serif Display',
      'method': 'dmSerifDisplay',
      'category': 'SERIF',
    },
    {'name': 'Cinzel', 'method': 'cinzel', 'category': 'SERIF'},

    // Creative / Unique
    {
      'name': 'Permanent Marker',
      'method': 'permanentMarker',
      'category': 'CREATIVE',
    },
    {'name': 'Orbitron', 'method': 'orbitron', 'category': 'CREATIVE'},
    {'name': 'Righteous', 'method': 'righteous', 'category': 'CREATIVE'},
    {'name': 'Audiowide', 'method': 'audiowide', 'category': 'CREATIVE'},
    {'name': 'Sacramento', 'method': 'sacramento', 'category': 'CREATIVE'},
    {
      'name': 'Cinzel Decorative',
      'method': 'cinzelDecorative',
      'category': 'CREATIVE',
    },
    {'name': 'Monoton', 'method': 'monoton', 'category': 'CREATIVE'},
    {'name': 'Lacquer', 'method': 'lacquer', 'category': 'CREATIVE'},
    {'name': 'Megrim', 'method': 'megrim', 'category': 'CREATIVE'},
    {'name': 'Rubik Glitch', 'method': 'rubikGlitch', 'category': 'CREATIVE'},
    {
      'name': 'Fredericka the Great',
      'method': 'frederickaTheGreat',
      'category': 'CREATIVE',
    },

    // Local Custom Fonts
    {
      'name': 'Halloween Witch',
      'method': 'local_halloween_witch',
      'category': 'CREATIVE',
    },
    {'name': 'Osnabrug', 'method': 'local_osnabrug', 'category': 'CREATIVE'},
    {'name': 'Tarantula', 'method': 'local_tarantula', 'category': 'CREATIVE'},
    {
      'name': 'Terexmalsunday',
      'method': 'local_terexmalsunday',
      'category': 'CREATIVE',
    },
  ];

  /// Returns the appropriate TextStyle from GoogleFonts for the given font index.
  TextStyle _getFontStyle(
    int index, {
    double? size,
    Color? color,
    double? spacing,
    FontWeight? weight,
  }) {
    final method = _fonts[index]['method']!;
    final effectiveSize = size ?? _fontSize;
    final effectiveColor =
        color ?? (_textColors[_selectedTextColorIndex]['color'] as Color);
    final effectiveSpacing = spacing ?? _letterSpacing;
    final effectiveWeight = weight ?? FontWeight.w700;

    switch (method) {
      case 'bebasNeue':
        return GoogleFonts.bebasNeue(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'anton':
        return GoogleFonts.anton(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'oswald':
        return GoogleFonts.oswald(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'staatliches':
        return GoogleFonts.staatliches(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'blackOpsOne':
        return GoogleFonts.blackOpsOne(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'bungee':
        return GoogleFonts.bungee(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'outfit':
        return GoogleFonts.outfit(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'montserrat':
        return GoogleFonts.montserrat(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'raleway':
        return GoogleFonts.raleway(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'urbanist':
        return GoogleFonts.urbanist(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'firaCode':
        return GoogleFonts.firaCode(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'ibmPlexMono':
        return GoogleFonts.ibmPlexMono(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'playfairDisplay':
        return GoogleFonts.playfairDisplay(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'cormorantGaramond':
        return GoogleFonts.cormorantGaramond(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'lora':
        return GoogleFonts.lora(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'merriweather':
        return GoogleFonts.merriweather(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'dmSerifDisplay':
        return GoogleFonts.dmSerifDisplay(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'permanentMarker':
        return GoogleFonts.permanentMarker(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'orbitron':
        return GoogleFonts.orbitron(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'righteous':
        return GoogleFonts.righteous(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'audiowide':
        return GoogleFonts.audiowide(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'sacramento':
        return GoogleFonts.sacramento(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'cinzelDecorative':
        return GoogleFonts.cinzelDecorative(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'monoton':
        return GoogleFonts.monoton(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'lacquer':
        return GoogleFonts.lacquer(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'syncopate':
        return GoogleFonts.syncopate(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'bungeeOutline':
        return GoogleFonts.bungeeOutline(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'megrim':
        return GoogleFonts.megrim(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'cinzel':
        return GoogleFonts.cinzel(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'rubikGlitch':
        return GoogleFonts.rubikGlitch(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'kumarOneOutline':
        return GoogleFonts.kumarOneOutline(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'frederickaTheGreat':
        return GoogleFonts.frederickaTheGreat(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'local_halloween_witch':
        return TextStyle(
          fontFamily: 'halloween_witch',
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'local_osnabrug':
        return TextStyle(
          fontFamily: 'osnabrug',
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'local_tarantula':
        return TextStyle(
          fontFamily: 'tarantula',
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      case 'local_terexmalsunday':
        return TextStyle(
          fontFamily: 'terexmalsunday',
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
      default:
        return GoogleFonts.bebasNeue(
          fontSize: effectiveSize,
          color: effectiveColor,
          letterSpacing: effectiveSpacing,
          fontWeight: effectiveWeight,
        );
    }
  }

  /// Get all words from the current quote, split by whitespace and newlines.
  List<String> get _words {
    return _quoteController.text
        .split(RegExp(r'[\s\n]+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Apply text transform to a single word.
  String _applyTransform(String word) {
    switch (_textTransform) {
      case 0:
        return word.toUpperCase();
      case 1:
        return word.toLowerCase();
      case 2:
        return word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      default:
        return word.toUpperCase();
    }
  }

  /// Get the color for a specific word index.
  Color _getWordColor(int wordIndex) {
    final colorIdx = _wordColors[wordIndex] ?? _selectedTextColorIndex;
    return _textColors[colorIdx]['color'] as Color;
  }

  /// Build a RichText widget with per-word colors, preserving newlines.
  Widget _buildRichQuoteText() {
    return _buildRichQuoteTextForSide(_isFrontSide);
  }

  /// Build a RichText widget for a specific side (front or back) to capture independent transparent PNGs.
  Widget _buildRichQuoteTextForSide(bool isFront) {
    final quoteController = isFront
        ? _frontQuoteController
        : _backQuoteController;
    final fontIndex = isFront ? _frontFontIndex : _backFontIndex;
    final fontSize = isFront ? _frontFontSize : _backFontSize;
    final letterSpacing = isFront ? _frontLetterSpacing : _backLetterSpacing;
    final lineHeight = isFront ? _frontLineHeight : _backLineHeight;
    final textAlign = isFront ? _frontTextAlign : _backTextAlign;
    final textColorIndex = isFront ? _frontTextColorIndex : _backTextColorIndex;
    final textTransform = isFront ? _frontTextTransform : _backTextTransform;
    final hasShadow = isFront ? _frontHasShadow : _backHasShadow;
    final hasStroke = isFront ? _frontHasStroke : _backHasStroke;
    final wordColors = isFront ? _frontWordColors : _backWordColors;
    final wordFonts = isFront ? _frontWordFonts : _backWordFonts;
    final wordFontSizes = isFront ? _frontWordFontSizes : _backWordFontSizes;

    final lines = quoteController.text.split('\n');
    final spans = <InlineSpan>[];
    int globalWordIndex = 0;

    for (int li = 0; li < lines.length; li++) {
      if (li > 0) spans.add(const TextSpan(text: '\n'));

      final matches = RegExp(r'\S+|\s+').allMatches(lines[li]);
      for (final match in matches) {
        String chunk = match.group(0)!;

        if (chunk.trim().isEmpty) {
          // It's whitespace, just add it with default font styling so letter spacing applies
          final color = _textColors[textColorIndex]['color'] as Color;
          final style = _getFontStyle(
            fontIndex,
            size: fontSize,
            color: color,
            spacing: letterSpacing,
          ).copyWith(height: lineHeight);
          spans.add(TextSpan(text: chunk, style: style));
        } else {
          // It's a word
          String word = chunk;
          switch (textTransform) {
            case 0:
              word = word.toUpperCase();
              break;
            case 1:
              word = word.toLowerCase();
              break;
            case 2:
              word = word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
              break;
          }

          // Fetch styles dynamically
          final colorIdx = wordColors[globalWordIndex] ?? textColorIndex;
          final color = _textColors[colorIdx]['color'] as Color;

          final wordFontIdx = wordFonts[globalWordIndex] ?? fontIndex;
          final wordFontSize = wordFontSizes[globalWordIndex] ?? fontSize;

          final baseStyle =
              _getFontStyle(
                wordFontIdx,
                size: wordFontSize,
                color: color,
                spacing: letterSpacing,
              ).copyWith(
                height: lineHeight,
                shadows: hasShadow
                    ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ]
                    : null,
              );

          // For stroke effect, we use paint with stroke style
          final effectiveStyle = hasStroke
              ? baseStyle.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.5
                    ..color = color,
                )
              : baseStyle;

          spans.add(TextSpan(text: word, style: effectiveStyle));
          globalWordIndex++;
        }
      }
    }

    return RichText(
      textAlign: textAlign,
      overflow: TextOverflow.visible,
      softWrap: true,
      text: TextSpan(children: spans),
    );
  }

  /// Calculates the exact size of the rendered RichText quote for boundary clamping.
  Size _measureTextSize(bool isFront) {
    final quoteController = isFront
        ? _frontQuoteController
        : _backQuoteController;
    final fontIndex = isFront ? _frontFontIndex : _backFontIndex;
    final fontSize = isFront ? _frontFontSize : _backFontSize;
    final letterSpacing = isFront ? _frontLetterSpacing : _backLetterSpacing;
    final lineHeight = isFront ? _frontLineHeight : _backLineHeight;
    final textAlign = isFront ? _frontTextAlign : _backTextAlign;
    final textColorIndex = isFront ? _frontTextColorIndex : _backTextColorIndex;
    final textTransform = isFront ? _frontTextTransform : _backTextTransform;
    final wordColors = isFront ? _frontWordColors : _backWordColors;
    final wordFonts = isFront ? _frontWordFonts : _backWordFonts;
    final wordFontSizes = isFront ? _frontWordFontSizes : _backWordFontSizes;

    final lines = quoteController.text.split('\n');
    final spans = <InlineSpan>[];
    int globalWordIndex = 0;

    for (int li = 0; li < lines.length; li++) {
      if (li > 0) spans.add(const TextSpan(text: '\n'));

      final matches = RegExp(r'\S+|\s+').allMatches(lines[li]);
      for (final match in matches) {
        String chunk = match.group(0)!;

        if (chunk.trim().isEmpty) {
          final color = _textColors[textColorIndex]['color'] as Color;
          final style = _getFontStyle(
            fontIndex,
            size: fontSize,
            color: color,
            spacing: letterSpacing,
          ).copyWith(height: lineHeight);
          spans.add(TextSpan(text: chunk, style: style));
        } else {
          String word = chunk;
          switch (textTransform) {
            case 0:
              word = word.toUpperCase();
              break;
            case 1:
              word = word.toLowerCase();
              break;
            case 2:
              word = word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
              break;
          }

          final colorIdx = wordColors[globalWordIndex] ?? textColorIndex;
          final color = _textColors[colorIdx]['color'] as Color;

          final wordFontIdx = wordFonts[globalWordIndex] ?? fontIndex;
          final wordFontSize = wordFontSizes[globalWordIndex] ?? fontSize;

          final baseStyle = _getFontStyle(
            wordFontIdx,
            size: wordFontSize,
            color: color,
            spacing: letterSpacing,
          ).copyWith(height: lineHeight);

          spans.add(TextSpan(text: word, style: baseStyle));
          globalWordIndex++;
        }
      }
    }

    final textPainter = TextPainter(
      text: TextSpan(children: spans),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: double.infinity);
    return textPainter.size;
  }

  List<Map<String, String>> get _filteredFonts {
    List<Map<String, String>> list;
    if (_selectedCategoryIndex == 0) {
      list = List.from(_fonts);
    } else {
      final cat = _fontCategories[_selectedCategoryIndex];
      list = _fonts.where((f) => f['category'] == cat).toList();
    }
    // Sort alphabetically by name
    list.sort((a, b) => a['name']!.compareTo(b['name']!));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _frontQuoteController.addListener(() {
      if (_isFrontSide && mounted) setState(() {});
    });
    _backQuoteController.addListener(() {
      if (!_isFrontSide && mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload all t-shirt mockup images so they render instantly when the screen is opened or color changes.
    for (var imagePath in _teeColorImages.values) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _frontQuoteController.dispose();
    _backQuoteController.dispose();
    super.dispose();
  }

  // ── Snackbar ──
  void _showSnackbar({
    required String title,
    required String message,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        duration: const Duration(seconds: 3),
        content: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSuccess
                    ? const Color(0xFF00FFCC).withValues(alpha: 0.4)
                    : const Color(0xFFFF0055).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSuccess
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  color: isSuccess
                      ? const Color(0xFF00FFCC)
                      : const Color(0xFFFF0055),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bebas(
                        title,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 2),
                      AppText.spaceMono(
                        message,
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Add to Bag Modal ──
  void _showAddToBagModal() {
    String selectedSize = 'L (Oversized)';
    bool isUploading = false;
    final sizes = [
      'S (Boxy)',
      'M (Boxy)',
      'L (Oversized)',
      'XL (Oversized)',
      'XXL (Extreme)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D11).withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppText.bebas(
                      'CUSTOM TYPOGRAPHY TEE',
                      fontSize: 28,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    AppText.spaceMono(
                      '${_fonts[_selectedFontIndex]['name']} • ${_quoteController.text.split('\n').first}',
                      fontSize: 12,
                      color: Colors.white54,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    AppText.spaceMono(
                      '₹2,499.00',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00FFCC),
                    ),
                    const SizedBox(height: 28),
                    AppText.spaceMono(
                      'SELECT FIT:',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sizes.map((size) {
                        final isSelected = size == selectedSize;
                        return InkWell(
                          onTap: () => setModalState(() => selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: AppText.spaceMono(
                              size,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: BrutalistHoverWidget(
                        onTap: () async {
                          final Map<String, String> product = {
                            'id':
                                'ai_custom_${_selectedTeeColor.replaceAll(' ', '_')}',
                            'name':
                                'AI LAB CUSTOM TEE - ${_selectedTeeColor.toUpperCase()}',
                            'price': '₹2,499',
                            'oldPrice': '₹3,499',
                            'image':
                                _teeColorImages[_selectedTeeColor] ??
                                'assets/images/plain_black_tee.png',
                            'description':
                                'AI generated custom typography tee. Custom print on demand.',
                            'category': 'custom',
                            'tag': 'LAB_CUSTOM',
                          };

                          final frontClean = _frontQuoteController.text
                              .trim()
                              .replaceAll('\n', ' ');
                          final backClean = _backQuoteController.text
                              .trim()
                              .replaceAll('\n', ' ');
                          final customText =
                              "FRONT: '$frontClean' | BACK: '$backClean'";

                          if (isUploading) return;

                          setModalState(() {
                            isUploading = true;
                          });

                          // Capture visual typography canvas designs (Print Files)
                          final frontPrintBytes = await _captureCanvas(
                            _frontCanvasKey,
                          );
                          final backPrintBytes = await _captureCanvas(
                            _backCanvasKey,
                          );

                          // Capture full Mockups
                          final frontMockupBytes = await _captureCanvas(
                            _frontMockupKey,
                          );
                          final backMockupBytes = await _captureCanvas(
                            _backMockupKey,
                          );

                          // Upload to Supabase Storage
                          final storage = ref.read(storageRepositoryProvider);
                          final timestamp =
                              DateTime.now().millisecondsSinceEpoch;
                          final random = math.Random().nextInt(10000);
                          final baseFileName =
                              'custom_tee_${timestamp}_$random';

                          String? frontPrintUrl;
                          String? backPrintUrl;
                          String? frontMockupUrl;
                          String? backMockupUrl;

                          try {
                            if (frontPrintBytes != null) {
                              frontPrintUrl = await storage.uploadBinary(
                                'custom_designs',
                                '${baseFileName}_front_print.png',
                                frontPrintBytes,
                              );
                            }
                            if (backPrintBytes != null) {
                              backPrintUrl = await storage.uploadBinary(
                                'custom_designs',
                                '${baseFileName}_back_print.png',
                                backPrintBytes,
                              );
                            }
                            if (frontMockupBytes != null) {
                              frontMockupUrl = await storage.uploadBinary(
                                'custom_designs',
                                '${baseFileName}_front_mockup.png',
                                frontMockupBytes,
                              );
                            }
                            if (backMockupBytes != null) {
                              backMockupUrl = await storage.uploadBinary(
                                'custom_designs',
                                '${baseFileName}_back_mockup.png',
                                backMockupBytes,
                              );
                            }

                            // Write custom product to cart!
                            // We use AWAIT so if it fails, it gets caught!
                            await ref
                                .read(cartProvider.notifier)
                                .addItem(
                                  product,
                                  selectedSize,
                                  customText: customText,
                                  frontDesignPreview: frontMockupUrl,
                                  backDesignPreview: backMockupUrl,
                                  frontPrintUrl: frontPrintUrl,
                                  backPrintUrl: backPrintUrl,
                                );

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _showSnackbar(
                              title: 'ADDED TO BAG',
                              message:
                                  'Custom Typography Tee ($selectedSize) — ₹2,499.00',
                            );
                          } catch (e) {
                            if (kDebugMode) {
                              print('Operation failed: $e');
                            }
                            if (!context.mounted) return;
                            setModalState(() {
                              isUploading = false;
                            });
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('OPERATION FAILED'),
                                content: SingleChildScrollView(
                                  child: Text(
                                    'There was an error processing your request.\n\nDetails: $e',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        shadowColor: AppTheme.neonAccent,
                        offset: const Offset(5, 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isUploading
                                ? Colors.grey.shade800
                                : AppTheme.neonAccent,
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: AppTheme.pureBlack,
                              width: 2,
                            ),
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : AppText.bebas(
                                  'ADD TO BAG — ₹2,499 ↗',
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                  color: AppTheme.pureBlack,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Offscreen Canvases for Transparent High-Res PNG Capture ──
            Positioned(
              left: 0,
              top: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.01,
                  child: TickerMode(
                    enabled: true,
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: _frontCanvasKey,
                          child: Container(
                            width: 600,
                            height: 600,
                            padding: const EdgeInsets.all(48),
                            color: Colors.transparent,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Transform.rotate(
                                  angle: _frontRotation * (math.pi / 180),
                                  child: _buildRichQuoteTextForSide(true),
                                ),
                              ),
                            ),
                          ),
                        ),
                        RepaintBoundary(
                          key: _backCanvasKey,
                          child: Container(
                            width: 600,
                            height: 600,
                            padding: const EdgeInsets.all(48),
                            color: Colors.transparent,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Transform.rotate(
                                  angle: _backRotation * (math.pi / 180),
                                  child: _buildRichQuoteTextForSide(false),
                                ),
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

            // ── Ambient glow blobs ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final angle = _glowController.value * 2 * math.pi;
                  final x1 = math.sin(angle) * 150;
                  final y1 = math.cos(angle) * 100;
                  final x2 = math.cos(angle + math.pi) * 180;
                  final y2 = math.sin(angle + math.pi) * 120;
                  return Stack(
                    children: [
                      Positioned(
                        left: (screenWidth / 3) + x1 - 150,
                        top: 200 + y1,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00FFCC).withValues(alpha: 0.10),
                                const Color(0xFF00FFFF).withValues(alpha: 0.03),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: (screenWidth / 4) + x2 - 150,
                        top: 450 + y2,
                        child: Container(
                          width: 450,
                          height: 450,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFF00AA).withValues(alpha: 0.08),
                                const Color(0xFF9000FF).withValues(alpha: 0.02),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Main Content ──
            Column(
              children: [
                const WebConstrainedBox(
                  child: CustomAppBar(isTransparent: true),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeroSection(isDesktop),
                        const SizedBox(height: 10),
                        _buildEditorSection(isDesktop, screenWidth),
                        const SizedBox(height: 80),
                        const FooterSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  HERO
  // ══════════════════════════════════════
  Widget _buildHeroSection(bool isDesktop) {
    return WebConstrainedBox(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 64.0 : 40.0,
      ),
      child: Column(
        children: [
          // Pill tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: AppText.spaceMono(
              'TYPOGRAPHY STUDIO • 30 PREMIUM FONTS',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFF00FFCC),
            ),
          ),
          const SizedBox(height: 20),
          AppText.bebas(
            'DESIGN YOUR STATEMENT',
            fontSize: isDesktop ? 72 : 36,
            letterSpacing: 3.0,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppText.spaceMono(
              'Type your quote, pick a font, adjust the style — see it live on your tee. What you see is what gets printed.',
              fontSize: isDesktop ? 13 : 11,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  MAIN EDITOR SECTION
  // ══════════════════════════════════════
  Widget _buildEditorSection(bool isDesktop, double screenWidth) {
    final preview = _buildTShirtPreview(isDesktop);
    final controls = _buildControlsPanel(isDesktop);

    return WebConstrainedBox(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 50.0 : 16.0),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: preview),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: controls),
              ],
            )
          : Column(children: [preview, const SizedBox(height: 32), controls]),
    );
  }

  // ══════════════════════════════════════
  //  T-SHIRT PREVIEW
  // ══════════════════════════════════════
  Widget _buildTShirtPreview(bool isDesktop) {
    return Column(
      children: [
        // FRONT / BACK toggle
        _buildSideToggle(),
        const SizedBox(height: 16),

        // Preview card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F13),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final cardHeight = cardWidth * 1;

                // Define standard DTG print zone boundaries (tighter centered chest grid)
                final zoneWidth = cardWidth * 0.26;
                final zoneLeft = (cardWidth - zoneWidth) / 2;
                final zoneHeight = cardHeight * 0.35;
                final zoneTop = cardHeight * 0.32;

                // Dynamically measure the actual text dimension inside the zone width
                final baseTextSize = _measureTextSize(_isFrontSide);

                // Dynamically calculate the maximum scale that keeps the text within the DTG zone
                final maxScaleX = zoneWidth / baseTextSize.width;
                final maxScaleY = zoneHeight / baseTextSize.height;
                final dynamicMaxScale = math
                    .min(maxScaleX, maxScaleY)
                    .clamp(0.2, 5.0);

                // Clamp the current scale dynamically so it never exceeds the boundaries
                final effectiveScale = _currentScale.clamp(
                  0.2,
                  dynamicMaxScale,
                );

                final containerWidth = baseTextSize.width * effectiveScale;
                final containerHeight = baseTextSize.height * effectiveScale;

                // Mathematically calculate safe margins to keep container 100% inside the DTG zone
                final maxDx =
                    (zoneWidth - containerWidth).clamp(0.0, double.infinity) /
                    2;
                final maxDy =
                    (zoneHeight - containerHeight).clamp(0.0, double.infinity) /
                    2;

                // Apply preset offsets dynamically if they were set
                final presetDx = _isFrontSide ? _frontPresetDx : _backPresetDx;
                final presetDy = _isFrontSide ? _frontPresetDy : _backPresetDy;
                if (presetDx != null && presetDy != null) {
                  final calculatedOffset = Offset(
                    presetDx * maxDx,
                    presetDy * maxDy,
                  );
                  if (_isFrontSide) {
                    _frontOffset = calculatedOffset;
                    _frontPresetDx = null;
                    _frontPresetDy = null;
                  } else {
                    _backOffset = calculatedOffset;
                    _backPresetDx = null;
                    _backPresetDy = null;
                  }
                }

                final clampedOffset = Offset(
                  _currentOffset.dx.clamp(-maxDx, maxDx),
                  _currentOffset.dy.clamp(-maxDy, maxDy),
                );

                return SizedBox(
                  height: cardHeight,
                  child: Stack(
                    children: [
                      // The captured mockup (T-shirt + Text only)
                      Positioned.fill(
                        child: RepaintBoundary(
                          key: _isFrontSide ? _frontMockupKey : _backMockupKey,
                          child: Stack(
                            children: [
                              // T-shirt base image
                              Positioned.fill(
                                child: Image.asset(
                                  _teeColorImages[_selectedTeeColor]!,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Text overlay on chest — draggable, scalable, and fully clamped
                              Positioned(
                                left:
                                    zoneLeft +
                                    zoneWidth / 2 -
                                    containerWidth / 2 +
                                    clampedOffset.dx,
                                top:
                                    zoneTop +
                                    zoneHeight / 2 -
                                    containerHeight / 2 +
                                    clampedOffset.dy,
                                width: containerWidth,
                                height: containerHeight,
                                child: GestureDetector(
                                  onScaleStart: (details) {
                                    // Store baseline for computing deltas
                                  },
                                  onScaleUpdate: (details) {
                                    setState(() {
                                      final currentBaseTextSize =
                                          _measureTextSize(_isFrontSide);
                                      final limitScaleX =
                                          zoneWidth / currentBaseTextSize.width;
                                      final limitScaleY =
                                          zoneHeight /
                                          currentBaseTextSize.height;
                                      final dynamicMaxScale = math
                                          .min(limitScaleX, limitScaleY)
                                          .clamp(0.2, 5.0);

                                      if (details.scale != 1.0) {
                                        _currentScale =
                                            (_currentScale * details.scale)
                                                .clamp(0.2, dynamicMaxScale);
                                      }

                                      final newContainerWidth =
                                          currentBaseTextSize.width *
                                          _currentScale;
                                      final newContainerHeight =
                                          currentBaseTextSize.height *
                                          _currentScale;
                                      final newMaxDx =
                                          (zoneWidth - newContainerWidth).clamp(
                                            0.0,
                                            double.infinity,
                                          ) /
                                          2;
                                      final newMaxDy =
                                          (zoneHeight - newContainerHeight)
                                              .clamp(0.0, double.infinity) /
                                          2;

                                      final rawOffset =
                                          _currentOffset +
                                          details.focalPointDelta;
                                      _currentOffset = Offset(
                                        rawOffset.dx.clamp(-newMaxDx, newMaxDx),
                                        rawOffset.dy.clamp(-newMaxDy, newMaxDy),
                                      );
                                    });
                                  },
                                  child: Transform.rotate(
                                    angle: _rotation * (math.pi / 180),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: _buildRichQuoteText(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // DTG LIVE PRINT ZONE Bounding Guideline Box (Visual Tech Blueprint Grid)
                      Positioned(
                        left: zoneLeft,
                        top: zoneTop,
                        width: zoneWidth,
                        height: zoneHeight,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(
                                  0xFF00FFCC,
                                ).withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                              color: const Color(
                                0xFF00FFCC,
                              ).withValues(alpha: 0.02),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AppText.spaceMono(
                                  "/// DTG_LIVE_PRINT_ZONE",
                                  fontSize: 8,
                                  color: const Color(
                                    0xFF00FFCC,
                                  ).withValues(alpha: 0.35),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom gradient vignette
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: cardHeight * 0.3,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Top-left side + font label
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00FFCC,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: AppText.spaceMono(
                                  _isFrontSide ? 'FRONT' : 'BACK',
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00FFCC),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppText.spaceMono(
                                _fonts[_selectedFontIndex]['name']!
                                    .toUpperCase(),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00FFCC),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top-right reset button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: InkWell(
                          onTap: () => setState(() {
                            _currentScale = 1.0;
                            _currentOffset = Offset.zero;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.center_focus_strong,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),

                      // Bottom info bar
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText.spaceMono(
                              '30.48 × 30.48 CM • DTG PRINT',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            AppText.spaceMono(
                              '₹2,499.00',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Position presets
        _buildPositionPresets(),

        const SizedBox(height: 16),

        // Fabric color selector
        _buildFabricToggle(),

        const SizedBox(height: 20),

        // Finalize & Compile Button
        SizedBox(
          width: double.infinity,
          child: BrutalistHoverWidget(
            shadowColor: AppTheme.pureBlack.withValues(alpha: 0.1),
            offset: const Offset(5, 5),
            child: InkWell(
              onTap: _finalizeDesign,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.pureBlack,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      color: AppTheme.neonAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    AppText.bebas(
                      'FINALIZE & DOWNLOAD ARTWORK',
                      fontSize: 18,
                      letterSpacing: 1.5,
                      color: AppTheme.neonAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Add to Bag button
        SizedBox(
          width: double.infinity,
          child: BrutalistHoverWidget(
            shadowColor: AppTheme.neonAccent,
            offset: const Offset(5, 5),
            child: InkWell(
              onTap: _showAddToBagModal,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.neonAccent,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: AppTheme.pureBlack, width: 2),
                ),
                child: AppText.bebas(
                  'ADD TO BAG — ₹2,499 ↗',
                  fontSize: 18,
                  letterSpacing: 1.5,
                  color: AppTheme.pureBlack,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  //  FABRIC COLOR TOGGLE
  // ══════════════════════════════════════
  Widget _buildFabricToggle() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: ['Washed Black', 'Heather Grey', 'Optic White'].map((
        colorName,
      ) {
        final isSelected = _selectedTeeColor == colorName;
        Color dot;
        switch (colorName) {
          case 'Heather Grey':
            dot = const Color(0xFF888896);
            break;
          case 'Optic White':
            dot = const Color(0xFFF0F0FA);
            break;
          default:
            dot = const Color(0xFF1F1F27);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: InkWell(
            onTap: () => setState(() => _selectedTeeColor = colorName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00FFCC)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText.spaceMono(
                    colorName.toUpperCase(),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════
  //  CONTROLS PANEL
  // ══════════════════════════════════════
  Widget _buildControlsPanel(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F13).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppText.bebas(
            'DESIGN CONTROLS',
            fontSize: 22,
            letterSpacing: 2,
            color: Colors.white,
          ),
          AppText.spaceMono(
            'Real-time typography editor',
            fontSize: 9,
            color: Colors.white38,
          ),
          const SizedBox(height: 28),

          // ── 0. Quick Quote Templates ──
          _sectionLabel('QUICK TEMPLATES'),
          const SizedBox(height: 8),
          _buildQuickQuoteStrip(),
          const SizedBox(height: 24),

          // ── 1. Text Input ──
          _sectionLabel('YOUR QUOTE TEXT'),
          const SizedBox(height: 8),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: !_showLineLimitWarning
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0055).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF0055).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF0055,
                            ).withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Color(0xFFFF0055),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText.spaceMono(
                              'LINE LIMIT REACHED! Press Enter to add a new line.',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF0055),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.2,
              ),
            ),
            child: TextField(
              controller: _quoteController,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final lines = newValue.text.split('\n');
                  if (lines.any((line) => line.length > 15)) {
                    if (!_showLineLimitWarning) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _showLineLimitWarning = true);
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() => _showLineLimitWarning = false);
                            }
                          });
                        }
                      });
                    }
                    return oldValue;
                  }
                  return newValue;
                }),
              ],
              onChanged: (_) {
                // Clear word overrides for words that no longer exist
                final wordCount = _words.length;
                _wordColors.removeWhere((key, _) => key >= wordCount);
                _wordFonts.removeWhere((key, _) => key >= wordCount);
                _wordFontSizes.removeWhere((key, _) => key >= wordCount);
                if (_selectedWordIndex != null &&
                    _selectedWordIndex! >= wordCount) {
                  _selectedWordIndex = null;
                }
                setState(() {});
              },
              maxLines: 3,
              style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: 'TYPE YOUR QUOTE HERE...',
                hintStyle: GoogleFonts.spaceMono(
                  color: Colors.white24,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1b. Text Transform ──
          _sectionLabel('TEXT TRANSFORM'),
          const SizedBox(height: 8),
          _buildTextTransformSelector(),
          const SizedBox(height: 28),

          // ── 2. Font Category Filter ──
          _sectionLabel('FONT CATEGORY'),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_fontCategories.length, (idx) {
                final isSelected = _selectedCategoryIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategoryIndex = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00FFCC)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: AppText.spaceMono(
                        _fontCategories[idx],
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF00FFCC)
                            : Colors.white54,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // ── 3. Font Selection ──
          _sectionLabel('SELECT FONT (${_filteredFonts.length})'),
          const SizedBox(height: 10),
          _buildFontDropdown(),
          const SizedBox(height: 28),

          // ── 4. Text Size ──
          _sectionLabel('TEXT SIZE: ${_fontSize.toInt()}'),
          Slider(
            value: _fontSize,
            min: 12,
            max: 72,
            activeColor: const Color(0xFF00FFCC),
            inactiveColor: Colors.white10,
            onChanged: (v) => setState(() => _fontSize = v),
          ),
          const SizedBox(height: 16),

          // ── 5. Letter Spacing ──
          _sectionLabel('LETTER SPACING: ${_letterSpacing.toStringAsFixed(1)}'),
          Slider(
            value: _letterSpacing,
            min: 0,
            max: 16,
            activeColor: const Color(0xFF00FFCC),
            inactiveColor: Colors.white10,
            onChanged: (v) => setState(() => _letterSpacing = v),
          ),
          const SizedBox(height: 16),

          // ── 5b. Line Height ──
          _sectionLabel('LINE HEIGHT: ${_lineHeight.toStringAsFixed(1)}'),
          Slider(
            value: _lineHeight,
            min: 0.8,
            max: 3.0,
            activeColor: const Color(0xFF00FFCC),
            inactiveColor: Colors.white10,
            onChanged: (v) => setState(() => _lineHeight = v),
          ),
          const SizedBox(height: 16),

          // ── 5c. Text Rotation ──
          _sectionLabel('ROTATION: ${_rotation.toInt()}°'),
          Slider(
            value: _rotation,
            min: -45,
            max: 45,
            activeColor: const Color(0xFF00FFCC),
            inactiveColor: Colors.white10,
            onChanged: (v) => setState(() => _rotation = v),
          ),
          const SizedBox(height: 16),

          // ── 5d. Text Effects ──
          _sectionLabel('TEXT EFFECTS'),
          const SizedBox(height: 8),
          _buildTextEffectsToggle(),
          const SizedBox(height: 24),

          // ── 6. Global Text Color ──
          _sectionLabel('GLOBAL TEXT COLOR'),
          const SizedBox(height: 4),
          AppText.spaceMono(
            'Applies to all words without custom color',
            fontSize: 8,
            color: Colors.white24,
          ),
          const SizedBox(height: 8),
          _buildColorSwatches(),
          const SizedBox(height: 24),

          // ── 7. Per-Word Styling ──
          _sectionLabel('PER-WORD STYLING'),
          const SizedBox(height: 4),
          AppText.spaceMono(
            'Tap a word to customize its color, font, and size',
            fontSize: 8,
            color: Colors.white24,
          ),
          const SizedBox(height: 10),
          _buildWordColorPicker(),
          const SizedBox(height: 24),

          // ── 8. Text Alignment ──
          _sectionLabel('ALIGNMENT'),
          const SizedBox(height: 10),
          _buildAlignmentSelector(),
        ],
      ),
    );
  }

  // ── Section label helper ──
  Widget _sectionLabel(String text) {
    return AppText.spaceMono(
      text,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
      color: Colors.white.withValues(alpha: 0.7),
    );
  }

  // ══════════════════════════════════════
  //  FONT DROPDOWN
  // ══════════════════════════════════════
  Widget _buildFontDropdown() {
    final fonts = _filteredFonts;
    final bool hasSelected = fonts.any(
      (f) => _fonts.indexOf(f) == _selectedFontIndex,
    );
    final value = hasSelected ? _selectedFontIndex : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          dropdownColor: const Color(0xFF15151A),
          icon: const Icon(Icons.unfold_more_rounded, color: Colors.white54),
          menuMaxHeight: 400,
          hint: AppText.spaceMono(
            'SELECT FROM ${_fontCategories[_selectedCategoryIndex]}...',
            fontSize: 11,
            color: Colors.white54,
          ),
          value: value,
          items: List.generate(fonts.length, (idx) {
            final font = fonts[idx];
            final globalIndex = _fonts.indexOf(font);
            return DropdownMenuItem<int>(
              value: globalIndex,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    font['name']!,
                    style: _getFontStyle(
                      globalIndex,
                      size: 15,
                      color: Colors.white,
                      spacing: 0.5,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText.spaceMono(
                      font['category']!,
                      fontSize: 8,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          }),
          onChanged: (int? newIndex) {
            if (newIndex != null) {
              setState(() {
                _selectedFontIndex = newIndex;
              });
            }
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  WORD FONT DROPDOWN
  // ══════════════════════════════════════
  Widget _buildWordFontDropdown() {
    final fonts = _fonts; // Use all fonts for simplicity or keep it same
    final currentValue = _wordFonts[_selectedWordIndex!] ?? _selectedFontIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          dropdownColor: const Color(0xFF15151A),
          icon: const Icon(Icons.unfold_more_rounded, color: Colors.white54),
          menuMaxHeight: 400,
          value: currentValue,
          items: List.generate(fonts.length, (idx) {
            final font = fonts[idx];
            return DropdownMenuItem<int>(
              value: idx,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    font['name']!,
                    style: _getFontStyle(
                      idx,
                      size: 15,
                      color: Colors.white,
                      spacing: 0.5,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText.spaceMono(
                      font['category']!,
                      fontSize: 8,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          }),
          onChanged: (int? newIndex) {
            if (newIndex != null) {
              setState(() {
                _wordFonts[_selectedWordIndex!] = newIndex;
              });
            }
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  TEXT COLOR SWATCHES
  // ══════════════════════════════════════
  Widget _buildColorSwatches() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_textColors.length, (idx) {
        final isSelected = _selectedTextColorIndex == idx;
        final color = _textColors[idx]['color'] as Color;
        final name = _textColors[idx]['name'] as String;

        return InkWell(
          onTap: () => setState(() => _selectedTextColorIndex = idx),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00FFCC)
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 4),
              AppText.spaceMono(
                name.toUpperCase(),
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF00FFCC) : Colors.white38,
              ),
            ],
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════
  //  TEXT ALIGNMENT
  // ══════════════════════════════════════
  Widget _buildAlignmentSelector() {
    final options = [
      {
        'icon': Icons.format_align_left,
        'align': TextAlign.left,
        'label': 'LEFT',
      },
      {
        'icon': Icons.format_align_center,
        'align': TextAlign.center,
        'label': 'CENTER',
      },
      {
        'icon': Icons.format_align_right,
        'align': TextAlign.right,
        'label': 'RIGHT',
      },
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final align = opt['align'] as TextAlign;
        final isSelected = _selectedTextAlign == align;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => setState(() => _selectedTextAlign = align),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00FFCC).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00FFCC)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? const Color(0xFF00FFCC)
                        : Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  AppText.spaceMono(
                    opt['label'] as String,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF00FFCC)
                        : Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════
  //  TEXT TRANSFORM SELECTOR
  // ══════════════════════════════════════
  Widget _buildTextTransformSelector() {
    final options = [
      {'label': 'UPPER', 'value': 0},
      {'label': 'lower', 'value': 1},
      {'label': 'Title', 'value': 2},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final value = opt['value'] as int;
        final isSelected = _textTransform == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => setState(() => _textTransform = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00FFCC).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00FFCC)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: AppText.spaceMono(
                opt['label'] as String,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF00FFCC) : Colors.white54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════
  //  PER-WORD COLOR PICKER
  // ══════════════════════════════════════
  Widget _buildWordColorPicker() {
    final words = _words;
    if (words.isEmpty) {
      return AppText.spaceMono(
        'Type some text above...',
        fontSize: 10,
        color: Colors.white24,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word chips — tap to select
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(words.length, (idx) {
            final isSelected = _selectedWordIndex == idx;
            final wordColor = _getWordColor(idx);
            final hasCustomStyle =
                _wordColors.containsKey(idx) ||
                _wordFonts.containsKey(idx) ||
                _wordFontSizes.containsKey(idx);
            final currentWordFont = _wordFonts[idx] ?? _selectedFontIndex;

            return InkWell(
              onTap: () => setState(() {
                _selectedWordIndex = isSelected ? null : idx;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00FFCC).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00FFCC)
                        : hasCustomStyle
                        ? wordColor.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color indicator dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: wordColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _applyTransform(words[idx]),
                      style: _getFontStyle(
                        currentWordFont,
                        size: 11,
                        color: wordColor,
                        spacing: 0.5,
                        weight: FontWeight.w600,
                      ),
                    ),
                    if (hasCustomStyle) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => setState(() {
                          _wordColors.remove(idx);
                          _wordFonts.remove(idx);
                          _wordFontSizes.remove(idx);
                          if (_selectedWordIndex == idx) {
                            _selectedWordIndex = null;
                          }
                        }),
                        child: Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),

        // Show styling options when a word is selected
        if (_selectedWordIndex != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, size: 14, color: const Color(0xFF00FFCC)),
                    const SizedBox(width: 6),
                    AppText.spaceMono(
                      'STYLING FOR: "${_applyTransform(words[_selectedWordIndex!])}"',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00FFCC),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => setState(() {
                        _wordColors.remove(_selectedWordIndex);
                        _wordFonts.remove(_selectedWordIndex);
                        _wordFontSizes.remove(_selectedWordIndex);
                      }),
                      child: AppText.spaceMono(
                        'RESET',
                        fontSize: 9,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Color Picker
                AppText.spaceMono('COLOR', fontSize: 9, color: Colors.white54),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_textColors.length, (colorIdx) {
                    final color = _textColors[colorIdx]['color'] as Color;
                    final currentColorIdx =
                        _wordColors[_selectedWordIndex!] ??
                        _selectedTextColorIndex;
                    final isActive = currentColorIdx == colorIdx;
                    return InkWell(
                      onTap: () => setState(() {
                        _wordColors[_selectedWordIndex!] = colorIdx;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF00FFCC)
                                : Colors.white.withValues(alpha: 0.15),
                            width: isActive ? 2.5 : 1.0,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Font Picker
                AppText.spaceMono('FONT', fontSize: 9, color: Colors.white54),
                const SizedBox(height: 6),
                _buildWordFontDropdown(),

                const SizedBox(height: 16),

                // Size Picker
                AppText.spaceMono(
                  'SIZE: ${(_wordFontSizes[_selectedWordIndex!] ?? _fontSize).toInt()}',
                  fontSize: 9,
                  color: Colors.white54,
                ),
                Slider(
                  value: _wordFontSizes[_selectedWordIndex!] ?? _fontSize,
                  min: 12,
                  max: 72,
                  activeColor: const Color(0xFF00FFCC),
                  inactiveColor: Colors.white10,
                  onChanged: (v) =>
                      setState(() => _wordFontSizes[_selectedWordIndex!] = v),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════
  //  FRONT / BACK TOGGLE
  // ══════════════════════════════════════
  Widget _buildSideToggle() {
    // If the state was stuck on the back side before we commented the button, reset it.
    if (!_isFrontSide) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isFrontSide = true);
      });
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _buildSideButton('FRONT', Icons.style, true),
          // const SizedBox(width: 4),
          // _buildSideButton('BACK', Icons.flip_to_back, false),
        ],
      ),
    );
  }

  Widget _buildSideButton(String label, IconData icon, bool isFront) {
    final isSelected = _isFrontSide == isFront;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _isFrontSide = isFront),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF00FFCC) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? const Color(0xFF00FFCC) : Colors.white38,
              ),
              const SizedBox(width: 6),
              AppText.spaceMono(
                label,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF00FFCC) : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  POSITION PRESETS
  // ══════════════════════════════════════
  Widget _buildPositionPresets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _positionPresets.map((preset) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {
              setState(() {
                _currentScale = (preset['scale'] as double);
                if (_isFrontSide) {
                  _frontPresetDx = (preset['dx'] as double);
                  _frontPresetDy = (preset['dy'] as double);
                } else {
                  _backPresetDx = (preset['dx'] as double);
                  _backPresetDy = (preset['dy'] as double);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    preset['icon'] as IconData,
                    size: 16,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 4),
                  AppText.spaceMono(
                    preset['label'] as String,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════
  //  QUICK QUOTE TEMPLATES
  // ══════════════════════════════════════
  Widget _buildQuickQuoteStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickQuotes.map((q) {
          final isActive = _quoteController.text == q['text'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _quoteController.text = q['text']!;
                _wordColors.clear();
                _wordFonts.clear();
                _wordFontSizes.clear();
                _selectedWordIndex = null;
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF00FFCC)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: AppText.spaceMono(
                  q['label']!,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF00FFCC) : Colors.white54,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════
  //  TEXT EFFECTS TOGGLES
  // ══════════════════════════════════════
  Widget _buildTextEffectsToggle() {
    return Row(
      children: [
        _buildEffectChip(
          'SHADOW',
          Icons.blur_on,
          _hasShadow,
          (v) => setState(() => _hasShadow = v),
        ),
        const SizedBox(width: 8),
        _buildEffectChip(
          'OUTLINE',
          Icons.border_style,
          _hasStroke,
          (v) => setState(() => _hasStroke = v),
        ),
      ],
    );
  }

  Widget _buildEffectChip(
    String label,
    IconData icon,
    bool isOn,
    ValueChanged<bool> onToggle,
  ) {
    return InkWell(
      onTap: () => onToggle(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isOn
              ? const Color(0xFF00FFCC).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOn
                ? const Color(0xFF00FFCC)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isOn ? const Color(0xFF00FFCC) : Colors.white54,
            ),
            const SizedBox(width: 6),
            AppText.spaceMono(
              label,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isOn ? const Color(0xFF00FFCC) : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  // ── ARTWORK CAPTURE AND FINALIZATION UTILITIES ──

  /// Captures the typography design from the given GlobalKey as a high-resolution transparent PNG.
  Future<Uint8List?> _captureCanvas(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) {
        print('EPOD ERROR: Canvas capture failed: $e');
      }
      return null;
    }
  }

  void _finalizeDesign() {
    _showCompilationModal();
  }

  void _showCompilationModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Compilation Modal',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return CompilationDialogContent(
          frontKey: _frontCanvasKey,
          backKey: _backCanvasKey,
          captureFn: _captureCanvas,
          teeColor: _selectedTeeColor,
          frontQuote: _frontQuoteController.text,
          backQuote: _backQuoteController.text,
          frontFont: _fonts[_frontFontIndex]['name']!,
          backFont: _fonts[_backFontIndex]['name']!,
          frontRotation: _frontRotation,
          backRotation: _backRotation,
          frontScale: _frontScale,
          backScale: _backScale,
          frontOffset: _frontOffset,
          backOffset: _backOffset,
          textColors: _textColors,
          frontColorIdx: _frontTextColorIndex,
          backColorIdx: _backTextColorIndex,
          frontAlign: _frontTextAlign,
          backAlign: _backTextAlign,
          frontLetterSpacing: _frontLetterSpacing,
          backLetterSpacing: _backLetterSpacing,
          frontLineHeight: _frontLineHeight,
          backLineHeight: _backLineHeight,
        );
      },
    );
  }
}
