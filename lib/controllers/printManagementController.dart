import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zawasna_project/models/printermodel.dart';
import 'package:zawasna_project/models/product.dart';
import 'package:zawasna_project/screens/printer_settings/printer_settings_screen.dart';
import 'package:zawasna_project/services/printer/printer_api.dart';
import 'package:zawasna_project/shared/constant.dart';
import 'package:zawasna_project/shared/local/cash_helper.dart';
import 'package:zawasna_project/shared/toast_message.dart';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class PrintManagementController extends ChangeNotifier {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';
  bool isConnected = false; // Added variable to track connection status

  bool isprintautomatically = false;
  PrintManagementController() {
    isprintautomatically =
        CashHelper.getData(key: 'isprintautomatically') ?? false;
    bluetoothPrint.state.listen((state) {
      _connected = state == BluetoothPrint.CONNECTED;
      isConnected = _connected; // Update isConnected based on state
      notifyListeners();
    });
    notifyListeners();
  }

  PageSize pageSize = PageSize.mm58; // default
  void onchagePageSize(value) {
    pageSize = value;
    notifyListeners();
  }

  // for printin on cash
  onsetprintautomatically(bool value) {
    isprintautomatically = value;
    CashHelper.saveData(key: "isprintautomatically", value: value);
    if (value) {
      showToast(message: "enabled", status: ToastStatus.Success);
    } else {
      showToast(message: "disabled", status: ToastStatus.Success);
    }
    notifyListeners();
  }

  List<PrinterModel> availableBluetoothDevices = [];

  bool isloadingsearch_for_device = false;
  Future<void> getBluetooth() async {
    availableBluetoothDevices = [];
    isloadingsearch_for_device = true;
    notifyListeners();
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bluetoothPrint.scanResults.listen((results) {
      results.forEach((device) {
        String name = device.name ?? '';
        String mac = device.address ?? '';
        bool isconnected = _connected;

        availableBluetoothDevices.add(
          PrinterModel(name: name, macAddress: mac, isconnected: isconnected),
        );
      });

      isloadingsearch_for_device = false;
      notifyListeners();
    });

    bluetoothPrint.isScanning.listen((isScanning) {
      if (!isScanning) {
        isloadingsearch_for_device = false;
        notifyListeners();
      }
    });
  }

  bool isloadingconnect = false;
  Future<void> setConnect(String? mac) async {
    print("mac :" + mac.toString());
    if (mac != null) {
      isloadingconnect = true;
      notifyListeners();

      if (_connected) {
        // change text to connected when this device is connected
        if (availableBluetoothDevices.length > 0)
          availableBluetoothDevices.forEach((element) {
            if (element.macAddress == mac) {
              element.isconnected = true;
            }
          });

        CashHelper.saveData(key: "device_mac", value: mac);
      }
    }
  }

  Future<void> printTicket(List<ProductModel> products,
      {String? cash, String? change}) async {
    Map<String, dynamic> config = Map();
    if (_connected) {
      // List<int> bytes = await PrintApi.getTicket(products,
      //     cash: cash, change: change, pageSize: pageSize);
      List<LineText> list = [];

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '**********************************************',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '打印单据头',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          fontZoom: 2,
          linefeed: 1));
      list.add(LineText(linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '----------------------明细---------------------',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '物资名称规格型号',
          weight: 1,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 0));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '单位',
          weight: 1,
          align: LineText.ALIGN_LEFT,
          x: 350,
          relativeX: 0,
          linefeed: 0));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '数量',
          weight: 1,
          align: LineText.ALIGN_LEFT,
          x: 500,
          relativeX: 0,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '混凝土C30',
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 0));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '吨',
          align: LineText.ALIGN_LEFT,
          x: 350,
          relativeX: 0,
          linefeed: 0));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '12.0',
          align: LineText.ALIGN_LEFT,
          x: 500,
          relativeX: 0,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '**********************************************',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(linefeed: 1));

      ByteData data =
          await rootBundle.load("assets/images/bluetooth_print.png");
      List<int> imageBytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      String base64Image = base64Encode(imageBytes);

      final result = await bluetoothPrint.printReceipt(config, list);
      print("Print $result");
    } else {
      if (isprintautomatically == true)
        showToast(message: "Printer not connected", status: ToastStatus.Error);
    }
  }
}

enum PageSize { mm58, mm80 }
