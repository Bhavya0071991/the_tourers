import '../../domain/entities/portrait_design.dart';

class PortraitRepository {
  static const String _pranshuBio = 
      'Pranxhu is the chief visual artist and printmaker behind our print lab. '
      'His work fuses historic colonial heritage, high-contrast streetwear halftones, '
      'and bold industrial aesthetics into premium tactile prints.';

  static const String _pranshuSign = 'assets/images/pranshu_signature.png';

  final List<PortraitDesign> _designs = const [
    PortraitDesign(
      id: 'port_1',
      name: 'SHIMLA HERITAGE PRINT',
      price: '₹999',
      originalPrice: '₹1,499',
      description: 'A striking screen-printed style tribute to the historic architectural landmarks of Shimla. Features high-contrast screen dot elements and clean brutalist layouts.',
      imageUrl: 'assets/images/Shimla_Heritage_PNG.png',
      designUrl: 'assets/images/Shimla_Heritage_PNG.png',
      designerName: 'Pranxhu',
      designerBio: _pranshuBio,
      designerSignatureUrl: _pranshuSign,
      category: 'Heritage',
    ),
    PortraitDesign(
      id: 'port_2',
      name: 'THE CHURCH COLOURED PRINT',
      price: '₹999',
      originalPrice: '₹1,499',
      description: 'Vibrant and retro-infused colored print of Christ Church, Shimla. Fuses Victorian architecture with bold street-level halftone print patterns.',
      imageUrl: 'assets/images/CHURCH_COLOURED.png',
      designUrl: 'assets/images/CHURCH_COLOURED.png',
      designerName: 'Pranxhu',
      designerBio: _pranshuBio,
      designerSignatureUrl: _pranshuSign,
      category: 'Heritage',
    ),
    PortraitDesign(
      id: 'port_3',
      name: 'GAIETY THEATRE POSTER',
      price: '₹999',
      originalPrice: '₹1,499',
      description: 'A minimalist bold graphic poster capturing the Victorian-Gothic heritage of the Gaiety Theatre. Rendered in clean monochrome line art.',
      imageUrl: 'assets/images/Gaiety_PNG.png',
      designUrl: 'assets/images/Gaiety_PNG.png',
      designerName: 'Pranxhu',
      designerBio: _pranshuBio,
      designerSignatureUrl: _pranshuSign,
      category: 'Heritage',
    ),
    PortraitDesign(
      id: 'port_4',
      name: 'CYBERPUNK NEON RUSH',
      price: '₹999',
      originalPrice: '₹1,499',
      description: 'High-contrast cybernetic neon street art print. Features neon pink highlights, rain reflection overlays, and kanji glyph textures.',
      imageUrl: 'https://images.pexels.com/photos/3262911/pexels-photo-3262911.jpeg',
      designUrl: 'https://images.pexels.com/photos/3262911/pexels-photo-3262911.jpeg',
      designerName: 'Pranxhu',
      designerBio: _pranshuBio,
      designerSignatureUrl: _pranshuSign,
      category: 'Cyberpunk',
    ),
    PortraitDesign(
      id: 'port_5',
      name: 'STREET BRUTALIST CONCRETE',
      price: '₹999',
      originalPrice: '₹1,499',
      description: 'Raw streetwear aesthetic featuring abstract concrete textures, glitching typography overlays, and neon yellow warning stripes.',
      imageUrl: 'https://images.pexels.com/photos/9775889/pexels-photo-9775889.jpeg',
      designUrl: 'https://images.pexels.com/photos/9775889/pexels-photo-9775889.jpeg',
      designerName: 'Pranxhu',
      designerBio: _pranshuBio,
      designerSignatureUrl: _pranshuSign,
      category: 'Street Art',
    ),
  ];

  Future<List<PortraitDesign>> getPortraitDesigns({String? category}) async {
    // Artificial delay to simulate network fetch
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (category == null || category == 'ALL' || category.isEmpty) {
      return _designs;
    }
    
    return _designs
        .where((d) => d.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<PortraitDesign?> getPortraitDesignById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _designs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
