import 'package:flutter/material.dart';
import 'package:SwimCoach/constants.dart';
import 'package:SwimCoach/data/db.dart';

import '../widgets/add_champ.dart';
import 'champ_profile_screen.dart';

class ChampPage extends StatefulWidget {
  const ChampPage({super.key});

  @override
  State<ChampPage> createState() => _ChampPageState();
}

class _ChampPageState extends State<ChampPage> {
  SqlDb sqlDb = SqlDb();
  Future<List<Map>> readData() async {
    List<Map> response = await sqlDb.readData("SELECT * FROM 'champ'");
    return response;
  }
  Future<void> _refreshData() async {
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const CustomText(text: 'البطولات', fontWeight: FontWeight.bold),
                centerTitle: true,
                // backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
                // foregroundColor: Colors.white,
                expandedHeight: screenHeight * 0.2,
                pinned: true,
                floating: false,
              ),
              FutureBuilder<List<Map>>(
                future: readData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CustomText(text: 'حدث خطأ أثناء جلب البيانات', fontWeight: FontWeight.bold),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    List<Map>? data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CustomText(text: 'لا يوجد بطولات', fontWeight: FontWeight.normal),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          Map champData = data[index];
                          return Card(
                            child: ListTile(
                              title: Text(champData['name'].toString()), // عرض اسم السباح
                              subtitle: Text("${champData['start'].toString()} - ${champData['end'].toString()}"), // عرض الوقت
                              leading: const Icon(Icons.circle),
                              onTap: () async{
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return ChampProfile(champName: champData['name'].toString(), startChamp: champData['start'].toString(), endChamp: champData['end'].toString(),);
                                    },
                                  ),
                                ).then((_) {
                                  _refreshData();
                                });
                              },
                            ),
                          );
                        },
                        childCount: data.length,
                      ),
                    );
                  } else {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CustomText(text: 'لا يوجد بطولات', fontWeight: FontWeight.normal),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
          right: MediaQuery.of(context).padding.right + 16.0,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const AddChampScreen();
                  },
                ),
              ).then((_) {
                _refreshData();
              });
            },
            // backgroundColor: Colors.blue,// لون خلفية الزر
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
