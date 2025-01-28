class Appointment {
  final String? id;
  final String? doctorId;
  final String? patientId;
  final String? appointmentDate;
  final String? status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
  return Appointment(
    id: json['id']?.toString() ?? 'Unknown',
    doctorId: json['doctor_name'] ?? 'No doctor assigned',  // Check this field name
    patientId: json['customer_name'] ?? 'No patient assigned',  // Check this field name
    appointmentDate: json['appointment_date'] ?? 'Unknown',
    status: json['status'] ?? 'No status available',
  );
}

}
