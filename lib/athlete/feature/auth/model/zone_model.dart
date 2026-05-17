class ZoneData {
  String? id;
  String? name;

  ZoneData(
      {this.id,
        this.name,
      });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

