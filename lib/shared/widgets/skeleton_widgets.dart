import 'package:flutter/material.dart';

class SkeletonWidget extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonWidget({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest
                .withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SkeletonWidget(
        width: 40,
        height: 40,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: const SkeletonWidget(width: double.infinity, height: 16),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SkeletonWidget(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class SkeletonRepMaxTable extends StatelessWidget {
  const SkeletonRepMaxTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.08),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 1,
                child: SkeletonWidget(width: 40, height: 16),
              ),
              ...List.generate(
                3,
                (index) => const Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SkeletonWidget(width: double.infinity, height: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Data rows skeleton
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: index % 2 == 1
                      ? Theme.of(context).colorScheme.surfaceContainerLowest
                      : null,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: SkeletonWidget(width: 20, height: 20),
                    ),
                    ...List.generate(
                      3,
                      (index) => const Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SkeletonWidget(
                            width: double.infinity,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonCard({super.key, this.width, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonWidget(width: double.infinity, height: 20),
            const SizedBox(height: 12),
            SkeletonWidget(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 16,
            ),
            const SizedBox(height: 8),
            SkeletonWidget(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}
