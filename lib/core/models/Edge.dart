import "dart:convert";

class Edge {
  String nid;
  Edge(
    this.nid,
  );

  Map<String, dynamic> toMap() {
    return {
      'nid': nid,
    };
  }

  static Edge fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Edge(
      map['nid'],
    );
  }

  @override
  String toString() => 'Edge(nid: $nid)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Edge && o.nid == nid;
  }

  @override
  int get hashCode => nid.hashCode;

  String toJson() => json.encode(toMap());

  static Edge fromJson(String source) => fromMap(json.decode(source));
}
