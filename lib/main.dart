import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_kullanimi/model/ogrenci.dart';

//flutter packages pub run build_runner build

void main() async {
  await Hive.initFlutter('uygulamaHive');
  WidgetsFlutterBinding
      .ensureInitialized(); // await işlemleri bittikten sonra gidip widgettreeyi oluşturuyor.

  //encrypted
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var containtsEncryptionKey = await secureStorage.containsKey(key: 'key');
  if (!containtsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  }

  var encryptionKey =
      base64Url.decode(await secureStorage.read(key: 'key') ?? 'null');
  print('Encryption key: $encryptionKey');

  var sifreliKutu = await Hive.openBox('ozel',
      encryptionCipher: HiveAesCipher(encryptionKey));
  await sifreliKutu.put('sifre', '123123123');
  print(sifreliKutu.get('sifre'));

  await Hive.openBox('test');

  Hive.registerAdapter(OgrenciAdapter());
  Hive.registerAdapter(GozRenkAdapter());
  await Hive.openBox<Ogrenci>('ogrenciler');

  await Hive.openLazyBox<int>('sayilar');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;

  // ignore: unused_element
  void _incrementCounter() async {
    var box = Hive.box('test');
    await box.clear();
    box.add('ahmet'); //index 0, key 0 - value ahmet
    box.add('ensar'); //index 1, key 1 - value ensar
    box.add(true);
    box.add(123); //index 3, key 3 - value 123

    // await box.addAll(['liste1', 'liste2', false, 3123]);

    await box.put('tc', '123123123');
    await box.put('tema', 'dark');
    /* await box.putAll({
      'araba': 'mercedes',
      'yil': 2012,
    }); */

    /* // ignore: avoid_function_literals_in_foreach_calls
    box.values.forEach((element) {
      debugPrint(element.toString());
    }); */

    debugPrint(box.toMap().toString());
    debugPrint(box.get('tema')); //key ile erişim
    debugPrint(box.getAt(1)); //index ile erişim
    debugPrint(box.getAt(4));
    debugPrint('****************');
    debugPrint(box.length.toString());

    await box.delete('tc');
    await box.deleteAt(4);
    debugPrint(box.toMap().toString());
    await box.putAt(2, 'besir');
    debugPrint(box.toMap().toString());
  }

  void _customData() async {
    var ahmet = Ogrenci(1, 'ahmet', GozRenk.MAVI);
    var hasan = Ogrenci(2, 'hasan', GozRenk.YESIL);

    var box = Hive.box<Ogrenci>('ogrenciler');
    await box.clear();
    box.add(ahmet);
    box.add(hasan);

    debugPrint(box.toMap().toString());
  }

  void _lazyAndEncryptedBox() async {
    var sayilar = Hive.lazyBox<int>('sayilar');

    for (int i = 0; i < 500; i++) {
      await sayilar.add(i * 50);
    }
    for (int i = 0; i < 500; i++) {
      debugPrint((await sayilar.getAt(i)).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _lazyAndEncryptedBox,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
