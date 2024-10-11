// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:webtoon_explorer_app/database/functions/favorites_box/favorites_db.dart';
import 'package:webtoon_explorer_app/database/models/hive_webtoon_model.dart';
import 'package:webtoon_explorer_app/models/webtoon_model.dart';
import 'package:webtoon_explorer_app/providers/favourite_webtoons_provider.dart';
import 'package:webtoon_explorer_app/router/route_constants.dart';
import 'package:webtoon_explorer_app/screens/detail_screen/detail_screen.dart';
import 'package:webtoon_explorer_app/screens/favorites_screen/favorites_screen.dart';
import 'package:webtoon_explorer_app/screens/home_screen/widgets/webtoon_display_card.dart';
import 'package:webtoon_explorer_app/services/webtoon_api_services.dart';
import 'package:webtoon_explorer_app/utils/app_fonts.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = RouteConstants.homeScreen;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    _fetchFavoriteWebtoonsFromHive();
    super.initState();
  }

  void _fetchFavoriteWebtoonsFromHive() async {
    final favoriteWebtoonsProvider = context.read<FavoriteWebtoonsProvider>();
    HiveFavoritesDb.instance.fetchFavoriteWebtoons().then(
      (hiveWebtoonModelList) {
        final webtoonIdList =
            hiveWebtoonModelList.map((element) => element.id).toList();
        favoriteWebtoonsProvider.setFavoritesWebtoonsIdList(webtoonIdList);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton.filled(
          color: Colors.yellow.shade100,
          icon: const Icon(Icons.favorite),
          onPressed: () {
            Navigator.pushNamed(context, FavoritesScreen.routeName);
          },
        ),
        // backgroundColor: Colors.white,
        title: Text(
          'WebToon Explorer',
          style: AppFonts.poppinsTextStyle(
              fontSize: 22,
              fontColor: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          //Base-container
          child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: WebtoonApiServices.instance.fetchWebtoons(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      color: Colors.yellow.shade700,
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return ListView.separated(
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          return WebToonDisplayCard(
                              webtoon: snapshot.data![index]);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: snapshot.data!.length);
                  }

                  return Center(
                    child: Text(
                      'Error fetching Webtoons!',
                      style: AppFonts.poppinsTextStyle(
                          fontSize: 20,
                          fontColor: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      )),
    );
  }
}



