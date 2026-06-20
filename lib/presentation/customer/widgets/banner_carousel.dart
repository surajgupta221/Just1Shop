// lib/presentation/customer/widgets/banner_carousel.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/banner_model.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;

  const BannerCarousel({Key? key, required this.banners}) : super(key: key);

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/banner.webp',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.banners.map((banner) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      // Handle banner tap
                      if (banner.link != null && banner.link!.isNotEmpty) {
                        // Navigate based on banner type
                        switch (banner.type) {
                          case 'product':
                            // Navigate to product
                            break;
                          case 'category':
                            // Navigate to category
                            break;
                          case 'external':
                            // Open external link
                            break;
                        }
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildBannerContent(banner),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.banners.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerContent(BannerModel banner) {
    final animation = banner.animation;
    final isAnimated = animation?['enabled'] == true;
    if (isAnimated) {
      return _AnimatedPromoBanner(
        banner: banner,
        controller: _animationController,
      );
    }

    return CachedNetworkImage(
      imageUrl: banner.image,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      ),
    );
  }
}

class _AnimatedPromoBanner extends StatelessWidget {
  final BannerModel banner;
  final AnimationController controller;

  const _AnimatedPromoBanner({
    required this.banner,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final animation = banner.animation ?? {};
    final primary =
        _colorFromHex(animation['primaryColor'], const Color(0xFF0F46D9));
    final secondary =
        _colorFromHex(animation['secondaryColor'], const Color(0xFF3B82F6));
    final accent =
        _colorFromHex(animation['accentColor'], const Color(0xFFFACC15));
    final style = '${animation['style'] ?? 'slide'}';

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;
        final offset = style == 'float'
            ? Offset(0, -8 * value)
            : style == 'slide'
                ? Offset(10 * value, 0)
                : Offset.zero;
        final scale = style == 'pulse' ? 1 + (value * 0.025) : 1.0;

        return Transform.translate(
          offset: offset,
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -34 + (value * 22),
                    top: -28,
                    child:
                        _GlowCircle(color: accent.withOpacity(0.35), size: 150),
                  ),
                  Positioned(
                    left: -42,
                    bottom: -52 + (value * 16),
                    child: _GlowCircle(
                        color: Colors.white.withOpacity(0.18), size: 170),
                  ),
                  if (style == 'shine')
                    Positioned(
                      left: -80 + (value * 420),
                      top: -40,
                      bottom: -40,
                      child: Transform.rotate(
                        angle: 0.28,
                        child: Container(
                          width: 48,
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            banner.placement.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          banner.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            height: 0.98,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if ((banner.subtitle ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            banner.subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.86),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            banner.ctaText ?? 'Shop Now',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorFromHex(dynamic raw, Color fallback) {
    final text = '$raw'.replaceAll('#', '').trim();
    if (text.length != 6) return fallback;
    final value = int.tryParse('FF$text', radix: 16);
    return value == null ? fallback : Color(value);
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
