import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class _Request {
  final StreamController<List<int>> _sc;
  void Function()? _oncancel;

  _Request(this._sc);

  void cancel() {
    if (_oncancel == null) return;
    _oncancel!();
    _oncancel = null;
  }
}

class UserBehaviorEntropySourceController extends ChangeNotifier {
  final _reqs = Queue<_Request>();

  Stream<List<int>> request() {
    late final _Request req;
    final sc = StreamController<List<int>>(
      onCancel: () {
        req.cancel();
      },
    );
    req = _Request(sc);
    _reqs.add(req);
    notifyListeners();
    return sc.stream;
  }

  @override
  void dispose() {
    for (var v in _reqs) {
      v._sc.close();
    }
    _reqs.clear();
    super.dispose();
  }
}

class UserBehaviorEntropySource extends StatefulWidget {
  final Widget child;
  final UserBehaviorEntropySourceController ctrl;
  final int debounce;

  const UserBehaviorEntropySource({
    super.key,
    required this.child,
    required this.ctrl,
    this.debounce = 1, // in mill
  });

  @override
  State<StatefulWidget> createState() => _UserBehaviorEntropySourceState();
}

class _UserBehaviorEntropySourceState extends State<UserBehaviorEntropySource> {
  Set<_Request> _reqs = {};
  late final int _debounce = widget.debounce * 1000;
  int _lastMouseEvtAt = 0;

  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_onRequest);
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_onRequest);

    final items = _reqs;
    _reqs = {};
    for (final item in items) {
      item._sc.close().ignore();
    }
    super.dispose();
  }

  void _emit(List<int> bytes) {
    final List<_Request> closed = [];
    for (var req in _reqs) {
      if (req._sc.isClosed) {
        closed.add(req);
        continue;
      }
      try {
        req._sc.add(bytes);
      } catch (_) {
        closed.add(req);
      }
    }
    if (closed.isNotEmpty) {
      _delReqs(closed);
    }
  }

  void _addMouseEvt(PointerEvent evt) {
    final at = DateTime.now().microsecondsSinceEpoch;
    if (_debounce > 0 && at - _lastMouseEvtAt < _debounce) {
      return;
    }
    _lastMouseEvtAt = at;

    final tmp = ByteData(40);
    tmp.setUint64(0, at);
    tmp.setUint64(8, evt.device);
    tmp.setUint64(16, evt.buttons);
    tmp.setFloat64(24, evt.position.dx);
    tmp.setFloat64(32, evt.position.dy);
    _emit(tmp.buffer.asUint8List());
  }

  void _delReqs(Iterable<_Request> reqs) {
    _reqs.removeAll(reqs);
  }

  void _addReq(_Request req) {
    req._oncancel = () {
      req._sc.close().ignore();
      _delReqs([req]);
    };
    _reqs.add(req);
  }

  void _onRequest() {
    final reqqueue = widget.ctrl._reqs;
    while (reqqueue.isNotEmpty) {
      _addReq(reqqueue.removeFirst());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: .translucent,
      onPointerHover: _addMouseEvt,
      onPointerMove: _addMouseEvt,
      onPointerDown: _addMouseEvt,
      child: widget.child,
    );
  }
}
