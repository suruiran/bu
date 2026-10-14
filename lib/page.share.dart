part of 'page.dart';

final _sharei18ns = (
  GeneratedPictureFailed: i18n.add("Generated picture failed"),
  GeneratedPictureSuccess: i18n.add("Generated picture success, {path}"),
  OpenPicFailed: i18n.add("Open picture failed"),
  SharePicFailed: i18n.add("Share picture failed"),
  SharePic: i18n.add("Share Picture"),
);
final SharePictureI18ns = _sharei18ns;

extension _PageShare on _HomePageState {
  void _on_share_failed() {
    if (!mounted) return;
    notify(
      context,
      FlutterI18n.translate(
        context,
        Env.isDesktop ? _sharei18ns.OpenPicFailed : _sharei18ns.SharePicFailed,
      ),
      kind: NotifyKind.Error,
    );
  }

  Future<void> _sharePic() async {
    if (_temp_gua == null) return;

    String? fp;
    try {
      final boundary =
          _rbKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final pngdata = await image.toByteData(format: ImageByteFormat.png);
      if (pngdata == null) return;
      final rawdata = pngdata.buffer.asUint8List();
      final nameparts = [fmttime(layout: "YYYYMMDDHHmm"), _temp_gua!.raw.name];
      if (_temp_gua!.changed != null) {
        nameparts.add(_temp_gua!.changed!.name);
      }
      fp = await Fs.savePic("${nameparts.join("_")}.png", rawdata);
    } catch (_) {}

    if (!mounted) return;

    if (fp == null) {
      notify(
        context,
        FlutterI18n.translate(context, _sharei18ns.GeneratedPictureFailed),
        kind: NotifyKind.Error,
      );
      return;
    }

    if (Env.isMobile) {
      if (!await _share_for_mobile(fp)) {
        _on_share_failed();
      }
      return;
    }

    notify(
      context,
      "",
      kind: NotifyKind.Success,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              FlutterI18n.translate(
                context,
                _sharei18ns.GeneratedPictureSuccess,
                translationParams: {"path": fp},
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              if (fp == null) return;
              final ok = await _share_for_desktop(fp);
              if (!ok) {
                _on_share_failed();
                return;
              }
            },
            icon: const Icon(Icons.file_open_outlined),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _share_for_desktop(String fp) async {
    final uri = Uri.file(fp);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> _share_for_mobile(String fp) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(fp)]),
    );
    return result.status != ShareResultStatus.unavailable;
  }

  Widget _sharePicBtn() {
    return IconButton(
      onPressed: _sharePic,
      icon: const Icon(Icons.ios_share, size: 36),
      tooltip: FlutterI18n.translate(context, _sharei18ns.SharePic),
    );
  }
}
