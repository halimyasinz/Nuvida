class CourseSchedule {
  final String id;
  final String courseName;
  final String instructor;
  final String day;
  final String startTime;
  final String endTime;
  final String location;

  const CourseSchedule({
    required this.id,
    required this.courseName,
    required this.instructor,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.location,
  });
}
