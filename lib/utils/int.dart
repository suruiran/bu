import 'dart:typed_data';

List<int> intToBytes(int v) {
  final bd = ByteData(8);
  bd.setInt64(0, v);
  return bd.buffer.asUint8List();
}

List<int> doubleToBytes(double v) {
  final bd = ByteData(8);
  bd.setFloat64(0, v);
  return bd.buffer.asUint8List();
}

void addInt(List<int> out, int v) {
  out.addAll(intToBytes(v));
}

void addDouble(List<int> out, double v) {
  out.addAll(doubleToBytes(v));
}
