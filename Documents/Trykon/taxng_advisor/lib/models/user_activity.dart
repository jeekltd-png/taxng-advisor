
/// User Activity Tracking Model
class UserActivity {
  final String id;
  final String userId;
  final String username;
  final String email;
  final String activityType; // 'login', 'logout', 'calculator_use', 'feedback', 'rating', 'download'
  final String? calculatorType; // 'vat', 'pit', 'cit', 'wht', 'payroll', 'stamp_duty'
  final String? details; // Additional details
  final int? rating; // 1-5 stars
  final DateTime timestamp;
  final String? deviceInfo; // Device/platform information
  final String? appVersion; // App version when activity occurred

  UserActivity({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.activityType,
    this.calculatorType,
    this.details,
    this.rating,
    required this.timestamp,
    this.deviceInfo,
    this.appVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'activityType': activityType,
      'calculatorType': calculatorType,
      'details': details,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      activityType: map['activityType'] as String,
      calculatorType: map['calculatorType'] as String?,
      details: map['details'] as String?,
      rating: map['rating'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      deviceInfo: map['deviceInfo'] as String?,
      appVersion: map['appVersion'] as String?,
    );
  }
}
