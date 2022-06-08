import 'package:covid_result_app/enums/hero_tags.dart';
import 'package:covid_result_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';

import '../enums/loading_type.dart';
import '../methods/save_image_to_gallery.dart';
import '../methods/share_image_to_others.dart';
import '../widgets/big_button.dart';
import '../widgets/small_button.dart';

class FullScreenQRView extends StatefulWidget {
  static const String routeName = '/fullscreenimage/';
  const FullScreenQRView({Key? key}) : super(key: key);

  @override
  State<FullScreenQRView> createState() => _FullScreenQRViewState();
}

class _FullScreenQRViewState extends State<FullScreenQRView> {
  Enum? loadingType;

  final ScreenshotController screenshotController = ScreenshotController();

  late final List args;

  @override
  void initState() {
    args = ModalRoute.of(context)!.settings.arguments as List;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: textColor),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: Hero(
                      tag: 'qr',
                      child: PrettyQr(
                        data: args[0],
                        size: 320,
                        roundEdges: true,
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text(
                      'FULL NAME:  ',
                      style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1),
                    ),
                    Text(
                      args[1].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 1,
                        color: textColor,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        fontFamily: 'Bold',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: saveAndShareButtons(),
          ),
          const SizedBox(height: 15),
          const Hero(
            tag: 'warn',
            child: Text(
              'Make sure you shared it before saving it to the server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Hero(
              tag: HeroTags.bigButton,
              child: BigButton(
                onPressed: () {},
                buttonColor: const Color(0xFF628ec5),
                text: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, letterSpacing: 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Row saveAndShareButtons() {
    return Row(
      key: const Key('2'),
      children: [
        Expanded(
          child: Hero(
            tag: HeroTags.saveFileButton,
            child: SmallButton(
              onPressed: () => saveImageToGallery(
                loadingOn: () {
                  setState(() => loadingType = LoadingType.saveFileButton);
                },
                loadingOff: () {
                  setState(() => loadingType = null);
                },
                qrDataHolder: args[0].toString(),
                firstName: args[1].toString().toUpperCase(),
                lastName: args[2].toString().toUpperCase(),
              ),
              icon: loadingType == LoadingType.saveFileButton
                  ? const SpinKitCircle(color: Colors.white, size: 30)
                  : const Icon(Icons.save),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Hero(
            tag: HeroTags.shareFileButton,
            child: SmallButton(
              onPressed: () => shareImageToOthers(
                loadingOn: () {
                  setState(() => loadingType = LoadingType.shareFileButton);
                },
                loadingOff: () {
                  setState(() => loadingType = null);
                },
                qrDataHolder: args[0].toString(),
                firstName: args[1].toString().toUpperCase(),
                lastName: args[2].toString().toUpperCase(),
              ),
              icon: loadingType == LoadingType.shareFileButton
                  ? const SpinKitCircle(color: Colors.white, size: 30)
                  : const Icon(Icons.share),
            ),
          ),
        ),
      ],
    );
  }
}
