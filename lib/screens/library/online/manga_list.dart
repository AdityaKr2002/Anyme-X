import 'dart:math';

import 'package:anymex/controllers/service_handler/service_handler.dart';
import 'package:anymex/models/Anilist/anilist_media_user.dart';
import 'package:anymex/screens/library/online/widgets/items.dart';
import 'package:anymex/widgets/common/glow.dart';
import 'package:anymex/widgets/helper/platform_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AnilistMangaList extends StatefulWidget {
  const AnilistMangaList({super.key});

  @override
  State<AnilistMangaList> createState() => _AnilistMangaListState();
}

class _AnilistMangaListState extends State<AnilistMangaList> {
  final List<String> tabs = [
    'READING',
    'COMPLETED',
    'PAUSED',
    'DROPPED',
    'PLANNING',
    'ALL',
  ];

  bool isReversed = false;
  bool isItemsReversed = false;

  @override
  Widget build(BuildContext context) {
    final anilistAuth = Get.find<ServiceHandler>();
    final userName = anilistAuth.profileData.value.name;
    final mangaList = anilistAuth.mangaList.value;
    return Glow(
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isReversed
                          ? Theme.of(context).colorScheme.surfaceContainer
                          : Colors.transparent),
                  onPressed: () {
                    setState(() {
                      isReversed = !isReversed;
                    });
                  },
                  icon: const Icon(Iconsax.arrow_swap_horizontal)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      isItemsReversed = !isItemsReversed;
                    });
                  },
                  icon: Icon(isItemsReversed
                      ? Iconsax.arrow_up
                      : Iconsax.arrow_bottom)),
            ],
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new)),
            title: Text("$userName's Manga List",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary)),
            bottom: TabBar(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const BouncingScrollPhysics(),
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              tabs: isReversed
                  ? tabs.reversed
                      .toList()
                      .map((tab) => Tab(
                          child: Text(tab,
                              style: const TextStyle(
                                  fontFamily: 'Poppins-SemiBold'))))
                      .toList()
                  : tabs
                      .map((tab) => Tab(
                          child: Text(tab,
                              style: const TextStyle(
                                  fontFamily: 'Poppins-SemiBold'))))
                      .toList(),
            ),
          ),
          body: TabBarView(
            children: isReversed
                ? tabs.reversed
                    .toList()
                    .map((tab) => MangaListContent(
                          tabType: tab,
                          mangaData: isItemsReversed
                              ? mangaList.reversed.toList()
                              : mangaList,
                        ))
                    .toList()
                : tabs
                    .map((tab) => MangaListContent(
                          tabType: tab,
                          mangaData: isItemsReversed
                              ? mangaList.reversed.toList()
                              : mangaList,
                        ))
                    .toList(),
          ),
        ),
      ),
    );
  }
}

int getResponsiveCrossAxisCount(double screenWidth, {int itemWidth = 150}) {
  return (screenWidth / itemWidth).floor().clamp(1, 10);
}

class MangaListContent extends StatelessWidget {
  final String tabType;
  final List<TrackedMedia>? mangaData;

  const MangaListContent({
    super.key,
    required this.tabType,
    required this.mangaData,
  });

  int getResponsiveCrossAxisCount(double screenWidth, {int itemWidth = 150}) {
    return (screenWidth / itemWidth).floor().clamp(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    if (mangaData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredAnimeList = _filterMangaByStatus(mangaData!, tabType);

    if (filteredAnimeList.isEmpty) {
      return Center(child: Text('No Manga found for $tabType'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PlatformBuilder(
        androidBuilder: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisExtent: 260, crossAxisSpacing: 10),
          itemCount: filteredAnimeList.length,
          itemBuilder: (context, index) {
            final item = filteredAnimeList[index];
            final tag = '${Random().nextInt(100000)}$index';
            final posterUrl = item.poster ??
                'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx16498-73IhOXpJZiMF.jpg';
            return listItem(
                context, item, tag, posterUrl, filteredAnimeList, index, true);
          },
        ),
        desktopBuilder: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getResponsiveCrossAxisCount(
                  MediaQuery.of(context).size.width),
              mainAxisExtent: 270,
              crossAxisSpacing: 10),
          itemCount: filteredAnimeList.length,
          itemBuilder: (context, index) {
            final item = filteredAnimeList[index] as TrackedMedia;
            final tag = '${Random().nextInt(100000)}$index';
            final posterUrl = item.poster ??
                'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx16498-73IhOXpJZiMF.jpg';
            return listItemDesktop(
                context, item, tag, posterUrl, filteredAnimeList, index, true);
          },
        ),
      ),
    );
  }

  List<dynamic> _filterMangaByStatus(
      List<TrackedMedia> mangaList, String status) {
    switch (status) {
      case 'READING':
        return mangaList
            .where((manga) => manga.watchingStatus == 'CURRENT')
            .toList();
      case 'COMPLETED':
        return mangaList
            .where((manga) => manga.watchingStatus == 'COMPLETED')
            .toList();
      case 'PAUSED':
        return mangaList
            .where((manga) => manga.watchingStatus == 'PAUSED')
            .toList();
      case 'DROPPED':
        return mangaList
            .where((manga) => manga.watchingStatus == 'DROPPED')
            .toList();
      case 'PLANNING':
        return mangaList
            .where((manga) => manga.watchingStatus == 'PLANNING')
            .toList();
      case 'ALL':
        return mangaList;
      default:
        return [];
    }
  }
}
