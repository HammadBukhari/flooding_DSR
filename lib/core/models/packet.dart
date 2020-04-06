import 'dart:convert';

class Packet {
  String uid;
  String message;
  String destinationNid;
  String sourceNid;
  Packet(
    this.uid,
    this.message,
    this.sourceNid,
    this.destinationNid,
  );

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Packet && o.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode ^ message.hashCode ^ destinationNid.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'message': message,
      'destinationNid': destinationNid,
      'sourceNid': sourceNid,
    };
  }

  static Packet fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Packet(
      map['uid'],
      map['message'],
      map['sourceNid'],
      map['destinationNid'],
    );
  }

  String toJson() => json.encode(toMap());

  static Packet fromJson(String source) => fromMap(json.decode(source));
}
