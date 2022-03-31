import 'package:flutter/material.dart';
import 'package:myapp/aspects/widgets/AppBarPretty.dart';

class ShowQRCode extends StatelessWidget {
  final String token;

  static String route = '/showQRCode';
  const ShowQRCode(this.token, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBarPretty(MediaQuery.of(context).size.width),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 120),
              Text(
                "QRCode",
                maxLines: 2,
                style:
                    TextStyle(color: Theme.of(context).hintColor, fontSize: 36),
              ),
              SizedBox(height: 50),
              //TODO put qrcode generator here with token
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
