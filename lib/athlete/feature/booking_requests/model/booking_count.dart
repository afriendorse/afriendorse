class BookingCount {
  int? pending;
  int? accepted;
  int? ongoing;
  int? completed;
  int? canceled;

  BookingCount(
      {this.pending,
        this.accepted,
        this.ongoing,
        this.completed,
        this.canceled});

  BookingCount.fromJson(Map<String, dynamic> json) {
    pending = int.tryParse(json['pending'].toString());
    accepted = int.tryParse(json['accepted'].toString());
    ongoing = int.tryParse(json['ongoing'].toString());
    completed = int.tryParse(json['completed'].toString());
    canceled = int.tryParse(json['canceled'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['ongoing'] = ongoing;
    data['completed'] = completed;
    data['canceled'] = canceled;
    return data;
  }
}