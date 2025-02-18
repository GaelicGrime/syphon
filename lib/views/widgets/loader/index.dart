import 'package:flutter/material.dart';

import 'package:syphon/global/dimensions.dart';

class Loader extends StatelessWidget {
  const Loader({
    super.key,
    this.loading = false,
  });

  final bool loading;

  @override
  Widget build(BuildContext context) => Visibility(
        visible: loading,
        child: Container(
          margin: EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RefreshProgressIndicator(
                strokeWidth: Dimensions.strokeWidthDefault,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                value: null,
              ),
            ],
          ),
        ),
      );
}
