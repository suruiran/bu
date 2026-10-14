import 'dart:async';
import 'dart:collection';

import 'package:bu/utils/env.dart';
import 'package:bu/utils/int.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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

enum _EvtKind {
  mouse(0),
  accelerometer(1),
  userAccelerometer(2),
  gyroscope(3),
  magnetometer(4),
  barometer(5);

  final int val;

  const _EvtKind(this.val);
}

class UserBehaviorEntropySourceController extends ChangeNotifier {
  final _reqs = Queue<_Request>();

  (Stream<List<int>>, void Function()) request() {
    final sc = StreamController<List<int>>();
    final req = _Request(sc);
    _reqs.add(req);
    notifyListeners();
    return (sc.stream, req.cancel);
  }
}

class UserBehaviorEntropySource extends StatefulWidget {
  final Widget child;
  final UserBehaviorEntropySourceController _ctrl;
  final int debounce;

  const UserBehaviorEntropySource({
    super.key,
    required this.child,
    required this._ctrl,
    this.debounce = 1, // in mill
  });

  @override
  State<StatefulWidget> createState() => _UserBehaviorEntropySourceState();
}

typedef _SensorEvtData = ({
  _EvtKind kind,
  double x,
  double y,
  double z,
  int at,
});

class _UserBehaviorEntropySourceState extends State<UserBehaviorEntropySource> {
  Set<_Request> _reqs = {};
  late final int _debounce = widget.debounce * 1000;
  int _lastMouseEvtAt = 0;
  late final List<Stream<_SensorEvtData>>? _streams;
  void Function()? _unsubscribeSensors;

  @override
  void initState() {
    super.initState();
    widget._ctrl.addListener(_onRequest);
    if (Env.isMobile) {
      _streams = [
        accelerometerEventStream().map(
          (v) => (
            kind: .accelerometer,
            x: v.x,
            y: v.y,
            z: v.z,
            at: DateTime.now().microsecondsSinceEpoch,
          ),
        ),
        userAccelerometerEventStream().map(
          (v) => (
            kind: .userAccelerometer,
            x: v.x,
            y: v.y,
            z: v.z,
            at: DateTime.now().microsecondsSinceEpoch,
          ),
        ),
        gyroscopeEventStream().map(
          (v) => (
            kind: .gyroscope,
            x: v.x,
            y: v.y,
            z: v.z,
            at: DateTime.now().microsecondsSinceEpoch,
          ),
        ),
        magnetometerEventStream().map(
          (v) => (
            kind: .magnetometer,
            x: v.x,
            y: v.y,
            z: v.z,
            at: DateTime.now().microsecondsSinceEpoch,
          ),
        ),
        barometerEventStream().map(
          (v) => (
            kind: .barometer,
            x: v.pressure,
            y: 0,
            z: 0,
            at: DateTime.now().microsecondsSinceEpoch,
          ),
        ),
      ];
    } else {
      _streams = null;
    }
  }

  void _subscribeSensors() {
    if (_streams == null) return;
    if (_unsubscribeSensors != null) return;
    final List<StreamSubscription<_SensorEvtData>> subs = [];
    final prevAts = List.filled(_streams.length, 0);
    for (var stream in _streams) {
      subs.add(
        stream.listen((evt) {
          if (evt.x == 0 && evt.y == 0 && evt.z == 0) return;
          final prev = prevAts[evt.kind.val - 1];
          if (_debounce > 0 && evt.at - prev < _debounce) return;
          prevAts[evt.kind.val - 1] = evt.at;

          final List<int> bytes = [_EvtKind.mouse.val];
          addInt(bytes, evt.at);
          addDouble(bytes, evt.x);
          if (evt.kind != .barometer) {
            addDouble(bytes, evt.y);
            addDouble(bytes, evt.z);
          }
          _emit(bytes);
        }),
      );
    }
    _unsubscribeSensors = () {
      for (var ele in subs) {
        ele.cancel().ignore();
      }
    };
  }

  @override
  void dispose() {
    widget._ctrl.removeListener(_onRequest);
    if (_unsubscribeSensors != null) {
      _unsubscribeSensors!();
    }
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
      req._sc.add(bytes);
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

    final List<int> bytes = [_EvtKind.mouse.val];
    addInt(bytes, at);
    addInt(bytes, evt.device);
    addInt(bytes, evt.buttons);
    addDouble(bytes, evt.position.dx);
    addDouble(bytes, evt.position.dy);
    _emit(bytes);
  }

  void _delReqs(Iterable<_Request> reqs) {
    _reqs.removeAll(reqs);
    if (reqs.isEmpty) {
      if (_unsubscribeSensors != null) {
        _unsubscribeSensors!();
        _unsubscribeSensors = null;
      }
    }
  }

  void _addReq(_Request req) {
    _subscribeSensors();

    req._oncancel = () {
      req._sc.close().ignore();
      _delReqs([req]);
    };
    _reqs.add(req);
  }

  void _onRequest() {
    final reqqueue = widget._ctrl._reqs;
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
      child: widget.child,
    );
  }
}
