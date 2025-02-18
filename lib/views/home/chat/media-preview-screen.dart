import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:redux/redux.dart';
import 'package:syphon/domain/index.dart';
import 'package:syphon/domain/rooms/room/model.dart';
import 'package:syphon/domain/rooms/selectors.dart';
import 'package:syphon/global/assets.dart';
import 'package:syphon/global/colors.dart';
import 'package:syphon/global/dimensions.dart';
import 'package:syphon/global/print.dart';
import 'package:syphon/global/strings.dart';
import 'package:syphon/views/navigation.dart';
import 'package:syphon/views/widgets/appbars/appbar-normal.dart';
import 'package:syphon/views/widgets/lifecycle.dart';

class MediaPreviewArguments {
  final String? roomId;
  final List<File> mediaList;
  final Function onConfirmSend;

  MediaPreviewArguments({
    this.roomId,
    this.mediaList = const [],
    required this.onConfirmSend,
  });
}

class MediaPreviewScreen extends StatefulWidget {
  const MediaPreviewScreen({
    super.key,
  });

  @override
  MediaPreviewState createState() => MediaPreviewState();
}

class MediaPreviewState extends State<MediaPreviewScreen> with Lifecycle<MediaPreviewScreen> {
  MediaPreviewState() : super();

  File? currentImage;

  @override
  onMounted() async {
    final params = useScreenArguments<MediaPreviewArguments>(
      context,
      MediaPreviewArguments(onConfirmSend: () {}),
    );

    try {
      final firstImage = params?.mediaList.first;

      setState(() {
        currentImage = firstImage;
      });
    } catch (error) {
      console.error(error.toString());
    }
  }

  onConfirm(_Props props) async {
    final params = useScreenArguments<MediaPreviewArguments>(
      context,
      MediaPreviewArguments(onConfirmSend: () {}),
    );

    await params.onConfirmSend();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Props>(
        distinct: true,
        converter: (Store<AppState> store) => _Props.mapStateToProps(
            store,
            useScreenArguments<MediaPreviewArguments>(
              context,
              MediaPreviewArguments(onConfirmSend: () {}),
            ).roomId),
        builder: (context, props) {
          final encryptionEnabled = props.room.encryptionEnabled;
          final height = MediaQuery.of(context).size.height;
          final imageHeight = height * 0.7;
          final sending = props.sending;

          return Scaffold(
            appBar: AppBarNormal(
              title: Strings.titleDialogDraftPreview,
              actions: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context, false),
                  tooltip: Strings.buttonCancel.capitalize(),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 24),
                    child: currentImage == null
                        ? Container()
                        : Image.file(
                            currentImage!,
                            height: imageHeight,
                            fit: BoxFit.contain,
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24, right: 12, bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            encryptionEnabled
                                ? Strings.titleSendMediaMessage
                                : Strings.titleSendMediaMessageUnencrypted,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                        Container(
                          width: Dimensions.buttonSendSize * 1.15,
                          height: Dimensions.buttonSendSize * 1.15,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Semantics(
                            button: true,
                            enabled: true,
                            label: Strings.labelSendEncrypted,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(48),
                              onTap: sending ? null : () => onConfirm(props),
                              child: CircleAvatar(
                                backgroundColor: sending
                                    ? Color(AppColors.greyDisabled)
                                    : Theme.of(context).colorScheme.primary,
                                child: sending
                                    ? Padding(
                                        padding: EdgeInsets.all(4),
                                        child: CircularProgressIndicator(
                                          strokeWidth: Dimensions.strokeWidthThin * 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).colorScheme.secondary.computeLuminance() > 0.6
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          value: null,
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(left: 2, top: 3),
                                        child: SvgPicture.asset(
                                          encryptionEnabled
                                              ? Assets.iconSendLockSolidBeing
                                              : Assets.iconSendUnlockBeing,
                                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                          semanticsLabel: Strings.labelSendEncrypted,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

class _Props extends Equatable {
  final bool sending;
  final Room room;
  final Map outbox;

  const _Props({
    required this.room,
    required this.outbox,
    required this.sending,
  });

  @override
  List<Object> get props => [
        room,
        outbox,
        sending,
      ];

  static _Props mapStateToProps(Store<AppState> store, String? roomId) => _Props(
        sending: selectRoom(id: roomId, state: store.state).sending,
        room: selectRoom(id: roomId, state: store.state),
        outbox: store.state.eventStore.outbox[roomId] ?? {},
      );
}
