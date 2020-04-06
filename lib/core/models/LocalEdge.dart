import "dart:convert";
import 'Edge.dart';

class LocalEdge extends Edge {
  LocalEdge(String nid) : super(nid);
  String toString() => "$nid";
  @override
  bool operator ==(Object o) {
    return o is LocalEdge && o.nid == nid;
  }

  @override
  int get hashCode {
    return nid.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'nid': nid,
    };
  }

  static LocalEdge fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return LocalEdge(
      map['nid'],
    );
  }
}
