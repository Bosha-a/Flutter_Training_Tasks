// Abstract Base Class
abstract class Employee {
  String name;
  double baseSalary;

  Employee(this.name, this.baseSalary);

  double calculatePay();
  String generateReport();
}

class Designer extends Employee with Creative {
  String designTool;

  Designer(String name, double baseSalary, this.designTool): super(name, baseSalary);

  @override
  double calculatePay() => baseSalary * 1.2;

  @override
  String generateReport() {
    return "$name is a Designer using $designTool. Salary: \$${calculatePay()}";
  }
}

// Developer Subclass
class Developer extends Employee with Programmer {
  String framework;

  Developer(String name, double baseSalary, this.framework)
      : super(name, baseSalary);

  void displayFramework() {
    print("Framework Used: $framework");
  }

  @override
  double calculatePay() => baseSalary * 1.5;

  @override
  String generateReport() {
    return "$name is a Developer using $framework. Salary: \$${calculatePay()}";
  }
}

// Manager Subclass
class Manager extends Employee with Leadership {
  String department;

  Manager(String name, double baseSalary, this.department)
      : super(name, baseSalary);

  void display() {
    print("Department: $department");
  }

  @override
  double calculatePay() => baseSalary * 1.8;

  @override
  String generateReport() {
    return "$name is a Manager of $department. Salary: \$${calculatePay()}";
  }
}

class EmployeeManager {
  final List<Employee> _employees = [];

  void addEmployee(Employee employee) {
    _employees.add(employee);
    print("Added: ${employee.name}");
  }

  void removeEmployee(String name) {
    _employees.removeWhere((e) => e.name == name);
    print("Removed: $name");
  }

  void listEmployees() {
    print("\nCurrent Employees:");
    if (_employees.isEmpty) {
      print("No employees found.");
    } else {
      for (var e in _employees) {
        print(e.generateReport());
      }
    }
  }

  double getTotalPayroll() {
    return _employees.fold(0, (sum, e) => sum + e.calculatePay());
  }

  void showTotalPayroll() {
    print("\nTotal Payroll: \$${getTotalPayroll().toStringAsFixed(2)}");
  }
}

// Mixins
mixin Programmer {
  void writeCode() => print("Writing efficient code...");
}

mixin Creative {
  void designUI() => print("Designing intuitive user interface...");
}

mixin Leadership {
  void leadTeam() => print("Leading team and assigning tasks...");
}

void main() {
  var dev = Developer("Ahmed", 5000, "Flutter")..writeCode(); // mixin
  var designer = Designer("Sarah", 4500, "Figma")..designUI(); // mixin
  var manager = Manager("Omar", 7000, "Engineering")..leadTeam(); // mixin

  print(dev.generateReport());
  print(designer.generateReport());
  print(manager.generateReport());
  print('--' * 20);
  var manager_employees = EmployeeManager();

  manager_employees.addEmployee(Developer("Ahmed", 5000, "Flutter"));
  manager_employees.addEmployee(Designer("Sara", 4500, "Figma"));
  manager_employees.addEmployee(Manager("Omar", 7000, "Engineering"));

  manager_employees.listEmployees();
  manager_employees.showTotalPayroll();

  manager_employees.removeEmployee("Sara");

  manager_employees.listEmployees();
  manager_employees.showTotalPayroll();

}
