import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/product_model.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedPrompt = 'Build my Rs 399 smart basket';

  @override
  void initState() {
    super.initState();
    final productBloc = context.read<ProductBloc>();
    productBloc.add(LoadProducts());
    productBloc.add(LoadCategories());
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => context.go(RouteConstants.home),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Just1Shop AI',
          style: UITextStyles.headlineLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAiModeSheet(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final products = _productsFromState(state);
          final plan = _buildPlan(_selectedPrompt, products);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              _buildHero(plan),
              const SizedBox(height: 14),
              _buildPromptBox(products),
              const SizedBox(height: 14),
              _buildPromptChips(),
              const SizedBox(height: 18),
              _buildPlanCard(plan),
              const SizedBox(height: 16),
              _buildFeatureGrid(),
              const SizedBox(height: 18),
              _buildSmartCart(plan),
              const SizedBox(height: 18),
              _buildTrustPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(_AiPlan plan) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF07111F), Color(0xFF0A5B87), Color(0xFF0AA36D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A5B87).withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child:
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ShopGPT for local grocery',
                  style: UITextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _AiStatusPill(label: 'Live'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            plan.title,
            style: UITextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.summary,
            style: UITextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.86),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.badges.map((badge) => _HeroBadge(badge)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptBox(List<ProductModel> products) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Column(
        children: [
          TextField(
            controller: _promptController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ask: dinner for 4, monthly kirana, diabetes-safe...',
              prefixIcon: const Icon(Icons.psychology_alt_rounded),
              suffixIcon: IconButton(
                onPressed: () => _applyPrompt(products),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFFF4F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _applyPrompt(products),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TinyAction(
                icon: Icons.mic_none_rounded,
                label: 'Voice',
                onTap: () => _snack('Voice AI can be connected next.'),
              ),
              const SizedBox(width: 8),
              _TinyAction(
                icon: Icons.translate_rounded,
                label: 'Hindi',
                onTap: () => _snack('Hindi grocery prompts are ready for AI.'),
              ),
              const Spacer(),
              Text(
                'Private by design',
                style: UITextStyles.labelSmall.copyWith(
                  color: UIConstants.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChips() {
    const prompts = [
      'Build my Rs 399 smart basket',
      'Restock my weekly fruits',
      'Plan a healthy breakfast',
      'Best kirana for family',
      'Find maximum savings',
      'Festival pooja basket',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: prompts.map((prompt) {
        final selected = prompt == _selectedPrompt;
        return ChoiceChip(
          selected: selected,
          label: Text(prompt),
          onSelected: (_) {
            setState(() {
              _selectedPrompt = prompt;
              _promptController.text = prompt;
            });
          },
          selectedColor: const Color(0xFFE8F0FF),
          backgroundColor: Colors.white,
          side: BorderSide(
            color:
                selected ? const Color(0xFF2546D8) : UIConstants.dividerColor,
          ),
          labelStyle: UITextStyles.labelMedium.copyWith(
            color: selected ? const Color(0xFF2546D8) : Colors.black,
            fontWeight: FontWeight.w900,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanCard(_AiPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF0AA36D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI action plan',
                  style: UITextStyles.headlineMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${plan.savingsPercent}% savings',
                style: UITextStyles.labelLarge.copyWith(
                  color: const Color(0xFF0AA36D),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final insight in plan.insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: Color(0xFFFFA000), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: UITextStyles.bodyMedium.copyWith(
                        color: UIConstants.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    const features = [
      _AiFeature(
        title: 'Smart Cart Builder',
        body: 'Creates baskets by budget, occasion, family size, and diet.',
        icon: Icons.shopping_bag_outlined,
        color: Color(0xFFE8F0FF),
      ),
      _AiFeature(
        title: 'Predictive Restock',
        body: 'Detects weekly milk, fruits, rice, dal, and snack habits.',
        icon: Icons.history_toggle_off_rounded,
        color: Color(0xFFE8FFF4),
      ),
      _AiFeature(
        title: 'Freshness Score',
        body: 'Ranks produce by delivery freshness and best-use timing.',
        icon: Icons.eco_outlined,
        color: Color(0xFFFFF3D6),
      ),
      _AiFeature(
        title: 'Offer Optimizer',
        body: 'Combines offers to reduce delivery, handling, and item cost.',
        icon: Icons.percent_rounded,
        color: Color(0xFFFFE9EC),
      ),
      _AiFeature(
        title: 'Diet Guard',
        body: 'Flags high-sugar, allergy, baby-safe, and wellness concerns.',
        icon: Icons.health_and_safety_outlined,
        color: Color(0xFFEAF7FF),
      ),
      _AiFeature(
        title: 'Store ETA Brain',
        body:
            'Chooses the nearest open store with the best fulfillment chance.',
        icon: Icons.storefront_outlined,
        color: Color(0xFFF1ECFF),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.96,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _AiFeatureCard(feature: features[index]),
    );
  }

  Widget _buildSmartCart(_AiPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recommended smart cart',
                  style: UITextStyles.headlineMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _addAll(plan.products),
                child: const Text('Add all'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final product in plan.products)
            _AiProductTile(
              product: product,
              reason: _reasonForProduct(product),
              onAdd: () => _addProduct(product),
            ),
        ],
      ),
    );
  }

  Widget _buildTrustPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outstanding AI roadmap',
            style: UITextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const _RoadmapLine('Voice grocery ordering in Hindi and English'),
          const _RoadmapLine('Personalized reorder reminders'),
          const _RoadmapLine('AI substitutions when an item is out of stock'),
          const _RoadmapLine('Smart delivery promise by store and distance'),
          const _RoadmapLine('Owner AI dashboard for demand forecasting'),
        ],
      ),
    );
  }

  void _applyPrompt(List<ProductModel> products) {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    setState(() => _selectedPrompt = prompt);
    _snack('AI basket updated for "$prompt"');
  }

  void _addProduct(ProductModel product) {
    context.read<CartBloc>().add(AddToCart(product, 1));
    _snack('${product.name} added to cart');
  }

  void _addAll(List<ProductModel> products) {
    for (final product in products.take(4)) {
      context.read<CartBloc>().add(AddToCart(product, 1));
    }
    _snack('AI smart cart added');
  }

  void _showAiModeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI modes',
                style: UITextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _ModeTile(
                icon: Icons.savings_outlined,
                title: 'Savings first',
                onTap: () => _chooseMode('Find maximum savings'),
              ),
              _ModeTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Healthy basket',
                onTap: () => _chooseMode('Plan a healthy breakfast'),
              ),
              _ModeTile(
                icon: Icons.family_restroom_rounded,
                title: 'Family kirana',
                onTap: () => _chooseMode('Best kirana for family'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _chooseMode(String prompt) {
    Navigator.pop(context);
    setState(() {
      _selectedPrompt = prompt;
      _promptController.text = prompt;
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  _AiPlan _buildPlan(String prompt, List<ProductModel> products) {
    final source = products.isEmpty ? _aiFallbackProducts : products;
    final lower = prompt.toLowerCase();
    final keywords = _keywordsForPrompt(lower);
    final matches = source.where((product) {
      final text =
          '${product.name} ${product.description} ${product.categoryId} ${product.tags.join(' ')}'
              .toLowerCase();
      return keywords.any(text.contains);
    }).toList();
    final selected = (matches.isEmpty ? source : matches).take(5).toList();
    final savings = selected.isEmpty
        ? 0
        : selected
                .map((product) => product.discountPercentage)
                .fold<double>(0, (sum, value) => sum + value)
                .round() ~/
            selected.length;

    if (lower.contains('healthy') || lower.contains('breakfast')) {
      return _AiPlan(
        title: 'Healthy breakfast basket ready',
        summary:
            'Balanced dairy, fruit, grains, and spreads selected for a quick morning order.',
        badges: const ['High freshness', 'Family safe', 'Morning delivery'],
        insights: const [
          'Prioritized dairy and fruit items for breakfast use.',
          'Added shelf-stable staples so the basket lasts longer.',
          'Use Diet Guard for low-sugar or baby-safe filtering.',
        ],
        savingsPercent: savings,
        products: selected,
      );
    }
    if (lower.contains('saving') ||
        lower.contains('offer') ||
        lower.contains('399') ||
        lower.contains('budget')) {
      return _AiPlan(
        title: 'Budget basket optimized',
        summary:
            'AI is grouping essentials to cross useful cart thresholds and reduce fees.',
        badges: const ['Offer stacking', 'Rs 399 target', 'Low fee path'],
        insights: const [
          'Selected discounted essentials first.',
          'Basket is tuned for free-delivery style thresholds.',
          'Swap suggestions can keep the basket under budget.',
        ],
        savingsPercent: savings,
        products: selected,
      );
    }
    if (lower.contains('fruit') || lower.contains('fresh')) {
      return _AiPlan(
        title: 'Fresh restock predicted',
        summary:
            'A weekly fresh basket with fruits, dairy, and vegetables for fast repeat ordering.',
        badges: const ['Freshness score', 'Weekly habit', 'Fast add'],
        insights: const [
          'Fresh items are ranked before packaged grocery.',
          'AI can remind customers before weekly items run out.',
          'Best-use timing can be shown after store inventory sync.',
        ],
        savingsPercent: savings,
        products: selected,
      );
    }
    if (lower.contains('kirana') ||
        lower.contains('rice') ||
        lower.contains('family')) {
      return _AiPlan(
        title: 'Family kirana basket built',
        summary:
            'Rice, dal, atta, oil, and daily staples selected for a practical home basket.',
        badges: const ['Assured quality', 'Staple basket', 'Easy returns'],
        insights: const [
          'Long-life staples are grouped for fewer repeat orders.',
          'AI can recommend substitutions for unavailable rice or dal.',
          'Owner demand forecasting can stock these items ahead.',
        ],
        savingsPercent: savings,
        products: selected,
      );
    }
    return _AiPlan(
      title: 'Smart basket generated',
      summary:
          'Just1Shop AI selected useful products, savings opportunities, and delivery-friendly items.',
      badges: const ['Personalized', 'Cart ready', 'Store aware'],
      insights: const [
        'AI matched the prompt against product names, tags, and categories.',
        'Recommended items can be added in one tap.',
        'This local AI layer is ready to connect with a cloud model later.',
      ],
      savingsPercent: savings,
      products: selected,
    );
  }

  List<String> _keywordsForPrompt(String prompt) {
    if (prompt.contains('healthy') || prompt.contains('breakfast')) {
      return const ['milk', 'dairy', 'fruit', 'bread', 'breakfast', 'yogurt'];
    }
    if (prompt.contains('saving') ||
        prompt.contains('offer') ||
        prompt.contains('399') ||
        prompt.contains('budget')) {
      return const ['deals', 'grocery', 'rice', 'sugar', 'discount'];
    }
    if (prompt.contains('fruit') || prompt.contains('fresh')) {
      return const ['fruit', 'fresh', 'vegetable', 'dairy'];
    }
    if (prompt.contains('kirana') ||
        prompt.contains('rice') ||
        prompt.contains('family')) {
      return const ['rice', 'grain', 'atta', 'dal', 'pulses', 'kirana'];
    }
    if (prompt.contains('festival') || prompt.contains('pooja')) {
      return const ['grocery', 'rice', 'sugar', 'fresh'];
    }
    return const ['grocery', 'fresh', 'deals', 'daily'];
  }

  String _reasonForProduct(ProductModel product) {
    if (product.hasDiscount) {
      return '${product.discountPercentage.toStringAsFixed(0)}% off detected';
    }
    final tags = product.tags.join(', ');
    if (tags.isNotEmpty) return 'Matched tags: $tags';
    return 'Good fit for this AI basket';
  }

  List<ProductModel> _productsFromState(ProductState state) {
    if (state is ProductLoaded) return state.products;
    if (state is ProductSearchResults) return state.products;
    if (state is CategoryProductsLoaded) return state.products;
    return const [];
  }
}

class _AiProductTile extends StatelessWidget {
  final ProductModel product;
  final String reason;
  final VoidCallback onAdd;

  const _AiProductTile({
    required this.product,
    required this.reason,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: const Color(0xFFF0F4F8),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.shopping_bag_outlined)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UITextStyles.labelLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(reason, style: UITextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'Rs ${product.finalPrice.toStringAsFixed(0)} | ${product.unit}',
                  style: UITextStyles.labelLarge.copyWith(
                    color: const Color(0xFF0AA36D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF2546D8),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFeatureCard extends StatelessWidget {
  final _AiFeature feature;

  const _AiFeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: feature.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(feature.icon, color: Colors.black, size: 28),
          const SizedBox(height: 10),
          Text(
            feature.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UITextStyles.labelLarge.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              feature.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: UITextStyles.bodySmall.copyWith(
                color: UIConstants.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TinyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2546D8)),
            const SizedBox(width: 5),
            Text(
              label,
              style: UITextStyles.labelSmall.copyWith(
                color: const Color(0xFF2546D8),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiStatusPill extends StatelessWidget {
  final String label;

  const _AiStatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF32FF7E),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: UITextStyles.labelSmall.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String label;

  const _HeroBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: UITextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RoadmapLine extends StatelessWidget {
  final String text;

  const _RoadmapLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Color(0xFF32FF7E), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: UITextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.86),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ModeTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _AiPlan {
  final String title;
  final String summary;
  final List<String> badges;
  final List<String> insights;
  final int savingsPercent;
  final List<ProductModel> products;

  const _AiPlan({
    required this.title,
    required this.summary,
    required this.badges,
    required this.insights,
    required this.savingsPercent,
    required this.products,
  });
}

class _AiFeature {
  final String title;
  final String body;
  final IconData icon;
  final Color color;

  const _AiFeature({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });
}

final DateTime _aiNow = DateTime(2026, 1, 1);

final List<ProductModel> _aiFallbackProducts = [
  ProductModel(
    id: 'ai-rice',
    name: 'Premium Usna Loose Rice 1Kg',
    description: 'Assured quality rice for daily family meals.',
    price: 100,
    discountPrice: 39,
    images: const [
      'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'rice',
    unit: '1 kg',
    stock: 80,
    isActive: true,
    tags: const ['rice', 'grain', 'kirana', 'grocery'],
    createdAt: _aiNow,
    updatedAt: _aiNow,
  ),
  ProductModel(
    id: 'ai-milk',
    name: 'Fresh Milk',
    description: 'Daily breakfast dairy essential.',
    price: 70,
    discountPrice: 59,
    images: const [
      'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'milk-dairy',
    unit: '1 ltr',
    stock: 50,
    isActive: true,
    tags: const ['milk', 'dairy', 'breakfast', 'fresh'],
    createdAt: _aiNow,
    updatedAt: _aiNow,
  ),
  ProductModel(
    id: 'ai-banana',
    name: 'Kela Banana Robusta',
    description: 'Fresh fruit for breakfast and snacks.',
    price: 49,
    discountPrice: 21,
    images: const [
      'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'fruits-veg',
    unit: '3 pcs',
    stock: 120,
    isActive: true,
    tags: const ['fruit', 'fresh', 'breakfast'],
    createdAt: _aiNow,
    updatedAt: _aiNow,
  ),
  ProductModel(
    id: 'ai-sugar',
    name: 'White Crystal Sugar Loose - 1Kg',
    description: 'Daily grocery staple for tea and sweets.',
    price: 60,
    discountPrice: 48,
    images: const [
      'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'grocery',
    unit: '1 kg',
    stock: 100,
    isActive: true,
    tags: const ['grocery', 'sugar', 'deals'],
    createdAt: _aiNow,
    updatedAt: _aiNow,
  ),
  ProductModel(
    id: 'ai-paneer',
    name: 'Malai Paneer - 200g',
    description: 'Protein rich fresh dairy for dinner.',
    price: 95,
    discountPrice: 92,
    images: const [
      'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'milk-dairy',
    unit: '200 g',
    stock: 40,
    isActive: true,
    tags: const ['fresh', 'dairy', 'paneer', 'healthy'],
    createdAt: _aiNow,
    updatedAt: _aiNow,
  ),
];
