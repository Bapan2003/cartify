import 'package:flutter/material.dart';

import '../../../widgets/my_wish.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageList;
  final String productId;
  const ImageCarousel({required this.imageList,required this.productId});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    if (widget.imageList.isEmpty) {
      return const AspectRatio(
        aspectRatio: 1,
        child: Center(child: Icon(Icons.image_not_supported, size: 60)),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.imageList.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.imageList[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 60),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageList.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 10 : 6,
                  height: _currentIndex == index ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.blueAccent
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
          ],
        ),
        Positioned(
          top: 8,
          right: 8,
          child: WishButton(id: widget.productId),
        ),
      ],
    );
  }
}