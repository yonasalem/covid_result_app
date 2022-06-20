import 'dart:io';

import 'package:covid_result_app/enums/Widgets/loading_view.dart';
import 'package:covid_result_app/enums/operation_status.dart';
import 'package:covid_result_app/methods/my_app_bar.dart';
import 'package:covid_result_app/utils/colors.dart';
import 'package:covid_result_app/views/home_view/widgets/header_card.dart';
import 'package:covid_result_app/views/patient_list_view.dart';
import 'package:covid_result_app/views/patient_register_view.dart';
import 'package:covid_result_app/views/patient_update_view.dart';
import 'package:covid_result_app/views/qr_scanner_view.dart';
import 'package:covid_result_app/widgets/home_view_widgets/qr_scanner_button.dart';
import 'package:covid_result_app/widgets/patient_form_field.dart';
import 'package:covid_result_app/widgets/text_widget_big.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../services/auth_services/auth_services.dart';
import '../../services/db_services/database_services.dart';
import '../../widgets/home_view_widgets/task_button.dart';
import '../../methods/warning_dialog.dart';
import '../login_view.dart';

class HomeView extends StatefulWidget {
  static const String routeName = '/homeview/';

  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

enum MenuAction { logOut, exit }

class _HomeViewState extends State<HomeView> {
  List<PopupMenuItem<MenuAction>> popUpMenuItemList = [
    PopupMenuItem(
      value: MenuAction.logOut,
      child: Row(
        children: [
          const Icon(Icons.logout, color: Colors.grey),
          const SizedBox(width: 5),
          Text(
            'Logout',
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: MenuAction.exit,
      child: Row(
        children: [
          const Icon(Icons.close, color: Colors.grey),
          const SizedBox(width: 5),
          Text(
            'Exit app',
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    ),
  ];

  final TextEditingController idNumber = TextEditingController();

  final qrKey = GlobalKey(debugLabel: "QR");

  QRViewController? controller;

  @override
  void dispose() {
    idNumber.clear();
    controller?.dispose();
    super.dispose();
  }

  navigateToPatientListView() {
    return Navigator.of(context).pushNamed(PatientListView.routeName);
  }

  navigateToPatientRegisterView() {
    return Navigator.of(context).pushNamed(PatientRegisterView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: gradient1,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar(
            elevation: 0,
            title: 'Home View',
            statusBarIconBrightness: Brightness.dark,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: PopupMenuButton<MenuAction>(
                  position: PopupMenuPosition.under,
                  color: Colors.white,
                  icon: Icon(
                    Icons.segment,
                    color: textColor,
                  ),
                  onSelected: popUpMenuHandler,
                  itemBuilder: (context) => popUpMenuItemList,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const HeaderCard(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  child: TextWidgetBig(
                    text: 'Tasks',
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TaskButton(
                        taskType: TaskType.register,
                        onTap: navigateToPatientRegisterView,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TaskButton(
                        taskType: TaskType.update,
                        onTap: updatePatient,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TaskButton(
                        taskType: TaskType.viewAll,
                        onTap: navigateToPatientListView,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TaskButton(
                        taskType: TaskType.delete,
                        onTap: deletePatient,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextWidgetBig(
                  text: 'Find Records Using',
                  color: textColor,
                ),
                const SizedBox(height: 20),
                QrScannerButton(
                  onTap: () {
                    Navigator.of(context).pushNamed(QrScannerView.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  updatePatient() async {
    var shouldUpdate = _displayTextInputDialog(context);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: PatientFormField(
              editingController: idNumber,
              hintText: 'Enter id number',
              activeBorderColor: const Color(0x55b774bd),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: secondaryColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await loadingWidget(LoadingType.onProgress, message: "Searching...");
                  var result = await DatabaseServices.mongoDb().singlePatientData(
                    idNumber: idNumber.text,
                  );

                  if (result != OperationStatus.failed) {
                    loadingWidget(LoadingType.dismiss);
                    var success = await warningDialog(
                      context: context,
                      boxTitle: "Record Found",
                      boxDescription: "Name: ${result.fullName.toString().toUpperCase()}",
                      cancleText: "Cancel",
                      okText: "Goto Update Page",
                    );

                    if (success && mounted) {
                      Navigator.of(context).pushReplacementNamed(
                        PatientUpdateView.routeName,
                        arguments: result,
                      );
                    }
                  } else {
                    await EasyLoading.showError('Patient not found!');
                  }
                },
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _deletePatientData(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: PatientFormField(
              editingController: idNumber,
              hintText: 'Enter id number',
              activeBorderColor: const Color(0x55b774bd),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: secondaryColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await EasyLoading.show(status: 'Finding patient');
                  var result = await DatabaseServices.mongoDb().singlePatientData(
                    idNumber: idNumber.text,
                  );

                  if (result != OperationStatus.failed) {
                    EasyLoading.dismiss();
                    if (mounted) Navigator.of(context).pop();
                    var success = await warningDialog(
                      context: context,
                      boxTitle: "Patinet found",
                      boxDescription: "Name: ${result.fullName}",
                      cancleText: "Cancel",
                      okText: "Delete Data",
                    );

                    if (success && mounted) {
                      await EasyLoading.show(status: 'Deleting patient');
                      var res =
                          await DatabaseServices.mongoDb().deletePatient(patientModel: result);

                      if (res == OperationStatus.succeed) {
                        await EasyLoading.showSuccess('Patient data deleted.');
                      }
                    }
                  } else {
                    await EasyLoading.showError('Patient not found!');
                  }
                },
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
          );
        });
  }

  deletePatient() {
    var shouldDelete = _deletePatientData(context);
  }

  scanQrData() {}

  Future<void> popUpMenuHandler(value) async {
    switch (value) {
      case MenuAction.logOut:
        final shouldLogout = await warningDialog(
          context: context,
          boxTitle: 'Logging out',
          boxDescription: 'Are you sure you want to logout?',
          cancleText: 'Cancel',
          okText: 'Logout',
        );
        if (shouldLogout) {
          await AuthServices.firebase().logout();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              LoginView.routeName,
              (route) => false,
            );
          }
        }
        break;
      case MenuAction.exit:
        final shouldExit = await warningDialog(
          context: context,
          boxTitle: 'Exit the app',
          boxDescription: 'Are you sure you want to quit the app?',
          cancleText: 'Cancel',
          okText: 'Exit',
        );
        if (shouldExit) exit(0);
    }
  }
}