import 'dart:convert';
import 'dart:io';

class Student {
  String name;
  int age;
  String city;
  List<String> hobbies;
  Set<String> subjects;

  Student(this.name, this.age, this.city, this.hobbies, this.subjects);

  void greet() {
    print("Hello, $name from $city!");
  }

  int ageSquared() => age * age;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'city': city,
      'hobbies': hobbies,
      'subjects': subjects.toList(),
    };
  }
}

void main() {
  List<Student> students = [];

  while (true) {
    print("\n--- Student Menu ---");
    print("1. Add Student");
    print("2. Show All Students");
    print("3. Search Student by Name");
    print("4. Export Data as JSON");
    print("5. Filter Subjects or Hobbies");
    print("6. Exit");
    stdout.write("Choose an option: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
      // --- Error Handling with try-catch ---
        try {
          stdout.write("Enter name: ");
          String name = stdin.readLineSync() ?? "";

          stdout.write("Enter age: ");
          int age = int.parse(stdin.readLineSync() ?? "0");

          stdout.write("Enter city: ");
          String city = stdin.readLineSync() ?? "";

          stdout.write("Enter hobbies (comma separated): ");
          List<String> hobbies =
          (stdin.readLineSync() ?? "").split(",").map((e) => e.trim()).toList();

          stdout.write("Enter subjects (comma separated): ");
          Set<String> subjects =
          (stdin.readLineSync() ?? "").split(",").map((e) => e.trim()).toSet();

          Student student = Student(name, age, city, hobbies, subjects);
          students.add(student);

          print("✅ Student added successfully!");
          student.greet();
          print("Age squared: ${student.ageSquared()}");
        } catch (e) {
          print("❌ Invalid input! Age must be an integer.");
        }
        break;

      case '2':
        if (students.isEmpty) {
          print("No students available.");
        } else {
          for (var s in students) {
            print(s.toMap());
          }
        }
        break;

      case '3':
        stdout.write("Enter name to search: ");
        String searchName = stdin.readLineSync() ?? "";
        var result = students.where((s) => s.name.toLowerCase() == searchName.toLowerCase());
        if (result.isEmpty) {
          print("No student found with name $searchName.");
        } else {
          for (var s in result) {
            print(s.toMap());
          }
        }
        break;

      case '4':
        if (students.isEmpty) {
          print("No data to export.");
        } else {
          List<Map<String, dynamic>> data =
          students.map((s) => s.toMap()).toList();
          String jsonData = jsonEncode(data);
          print("\n📦 Exported JSON Data:\n$jsonData");
        }
        break;

      case '5':
        if (students.isEmpty) {
          print("No students available for filtering.");
        } else {
          stdout.write("Filter by hobby/subject keyword: ");
          String keyword = stdin.readLineSync() ?? "";
          var filtered = students.where((s) =>
          s.hobbies.contains(keyword) || s.subjects.contains(keyword));
          if (filtered.isEmpty) {
            print("No match found for $keyword.");
          } else {
            for (var s in filtered) {
              print(s.toMap());
            }
          }
        }
        break;

      case '6':
        print("Exiting program. Goodbye!");
        return;

      default:
        print("❌ Invalid option, try again.");
    }
  }
}
