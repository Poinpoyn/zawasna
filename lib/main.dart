import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zawasna_project/controllers/auth_controller.dart';
import 'package:zawasna_project/controllers/facture_controller.dart';
import 'package:zawasna_project/controllers/layout_controller.dart';
import 'package:zawasna_project/controllers/printManagementController.dart';
import 'package:zawasna_project/controllers/products_controller.dart';
import 'package:zawasna_project/screens/splash_screen/splash_screen.dart';
import 'package:zawasna_project/shared/constant.dart';
import 'package:zawasna_project/shared/local/cash_helper.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MarketDbHelper.db.init().then((value) async {
  //   await getDatabasesPath().then((value) {
  //     print(value + "/Market.db");
  //     databasepath = value + "/Market.db";
  //   });
  // });

  await Firebase.initializeApp();

  await CashHelper.init();

  currentuser = await CashHelper.getUser() ?? null;

  device_mac = await CashHelper.getData(key: "device_mac") ?? null;
  print("device_mac " + device_mac.toString());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<LayoutController>(
          create: (_) => LayoutController()),
      ChangeNotifierProvider<ProductsController>(
          create: (_) => ProductsController()),
      ChangeNotifierProvider<FactureController>(
          create: (_) => FactureController()),
      ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
      ChangeNotifierProvider<PrintManagementController>(
          create: (_) => PrintManagementController()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
