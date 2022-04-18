import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final BannerAd myBannerads = BannerAd(
    adUnitId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  );

  TextEditingController _controller = TextEditingController();
  TextEditingController _updatecontroller = TextEditingController();
  List mylist = ['0170198741', '01721548745', '01471020141'];

  Box? mycontactbox;

  // @override
  // void initState() {
  //   mycontactbox = Hive.box("contactlist");
  //   myBanner.load();

  //   super.initState();
  // }

  @override
  void initState() {
    myBannerads.load();
    mycontactbox = Hive.box("contactlist");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Database"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
          ),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () async {
                final userdata = _controller.text;
                print(userdata);
                await mycontactbox?.add(userdata);
                _controller.clear();
              },
              child: Text("Add data"),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: Hive.box("contactlist").listenable(),
                builder: (context, box, widget) {
                  return ListView.builder(
                    itemCount: mycontactbox!.keys.toList().length,
                    itemBuilder: (_, index) {
                      return Card(
                        child: ListTile(
                          dense: true,
                          title: Text(mycontactbox!.getAt(index).toString()),
                          trailing: Container(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: Text("Edit data"),
                                            content: Container(
                                              height: 400,
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _updatecontroller,
                                                  ),
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        mycontactbox!.putAt(
                                                            index,
                                                            _updatecontroller
                                                                .text);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Update"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    mycontactbox!.deleteAt(index);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey,
            child: AdWidget(ad: myBannerads),
          ),
        ],
      ),
    );
  }
}
