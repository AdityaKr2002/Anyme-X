import 'package:anymex/components/android/helper/scroll_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:transformable_list_view/transformable_list_view.dart';

class CharacterCards extends StatelessWidget {
  final dynamic carouselData;
  final bool isManga;
  CharacterCards({super.key, this.carouselData, required this.isManga});

  final ScrollDirectionHelper _scrollDirectionHelper = ScrollDirectionHelper();

  @override
  Widget build(BuildContext context) {
    final bool usingSaikouCards =
        Hive.box('app-data').get('usingSaikouCards', defaultValue: true);
    if (carouselData == null || carouselData!.isEmpty) {
      return Container();
    }

    Matrix4 getTransformMatrix(TransformableListItem item) {
      const maxScale = 1;
      const minScale = 0.8;
      final viewportWidth = item.constraints.viewportMainAxisExtent;
      final itemLeftEdge = item.offset.dx;
      final itemRightEdge = item.offset.dx + item.size.width;

      bool isScrollingRight =
          _scrollDirectionHelper.isScrollingRight(item.offset);

      double visiblePortion;
      if (isScrollingRight) {
        visiblePortion = (viewportWidth - itemLeftEdge) / item.size.width;
      } else {
        visiblePortion = (itemRightEdge) / item.size.width;
      }

      if ((isScrollingRight && itemLeftEdge < viewportWidth) ||
          (!isScrollingRight && itemRightEdge > 0)) {
        const scaleRange = maxScale - minScale;
        final scale =
            minScale + (scaleRange * visiblePortion).clamp(0.0, scaleRange);

        return Matrix4.identity()
          ..translate(item.size.width / 2, 0, 0)
          ..scale(scale)
          ..translate(-item.size.width / 2, 0, 0);
      }

      return Matrix4.identity();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Characters',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 220,
              child: TransformableListView.builder(
                padding: const EdgeInsets.only(left: 20),
                physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast),
                getTransformMatrix: getTransformMatrix,
                scrollDirection: Axis.horizontal,
                itemCount: carouselData!.length,
                itemExtent: MediaQuery.of(context).size.width /
                    (usingSaikouCards ? 3.5 : 2.3),
                itemBuilder: (context, index) {
                  final itemData = carouselData![index]['node'];
                  final title = itemData['name']['full'].toString().length > 25
                      ? '${itemData['name']['full'].toString().substring(0, 25)}...'
                      : itemData['name']['full'];
                  final role = itemData['favourites'].toString();
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Column(
                      children: [
                        Stack(children: [
                          Container(
                              color: Colors.transparent,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  itemData['image']['large'],
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(12),
                                      topLeft: Radius.circular(12))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.heart5,
                                    size: 12,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Text(role,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7)),
                                      textAlign: TextAlign.right),
                                ],
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toString(),
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        if (!isManga)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Voice Actors',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 220,
                child: TransformableListView.builder(
                  padding: const EdgeInsets.only(left: 20),
                  physics: const BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast),
                  getTransformMatrix: getTransformMatrix,
                  scrollDirection: Axis.horizontal,
                  itemCount: carouselData!.length,
                  itemExtent: MediaQuery.of(context).size.width /
                      (usingSaikouCards ? 3.5 : 2.3),
                  itemBuilder: (context, index) {
                    // Check if voiceActors array is not empty
                    if (carouselData![index]['voiceActors'] != null &&
                        carouselData![index]['voiceActors'].isNotEmpty) {
                      final itemData = carouselData![index]['voiceActors'][0];
                      final title = itemData?['name']?['full'] ?? 'Unknown';
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 150,
                                child: Container(
                                  color: Colors.transparent,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      itemData['image']['large'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: 100,
                        margin: const EdgeInsets.only(right: 4),
                        alignment: Alignment.center,
                        child: const Text(
                          'No Voice Actor Data',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
