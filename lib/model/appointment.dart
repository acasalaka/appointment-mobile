import 'dart:convert';

Appointment appointmentFromJson(String str) => Appointment.fromJson(json.decode(str));

String appointmentToJson(Appointment data) => json.encode(data.toJson());

class Appointment {
  String id;
  String doctorName;
  String patientName;
  DateTime date;
  String diagnosis;
  List<String> treatments;
  int totalFee;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  String updatedBy;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.diagnosis,
    required this.treatments,
    required this.totalFee,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json["id"],
    doctorName: json["doctorName"],
    patientName: json["patientName"],
    date: DateTime.parse(json["date"]),
    diagnosis: json["diagnosis"],
    treatments: List<String>.from(json["treatments"].map((x) => x)),
    totalFee: json["totalFee"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "doctorName": doctorName,
    "patientName": patientName,
    "date": date.toIso8601String(),
    "diagnosis": diagnosis,
    "treatments": List<dynamic>.from(treatments.map((x) => x)),
    "totalFee": totalFee,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "createdBy": createdBy,
    "updatedBy": updatedBy
  };
}
