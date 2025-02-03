class Driver {
  late final String firstName;
  late final String lastName;
  late final String regNumber;
  late final String idNumber;
  late final String carType;
  late final String carModel;
  late String? driverId;
  late final String phoneNumber;

  Driver();

  Driver.New({
    required this.firstName,
    required this.lastName,
    required this.regNumber,
    required this.idNumber,
    required this.carType,
    required this.carModel,
    required this.phoneNumber,
    required this.driverId

  });


  // Convert a map to a Driver object
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver.New(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      regNumber: map['regNumber'] ?? '',
      idNumber: map['idNumber'] ?? '',
      carType: map['carType'] ?? '',
      carModel: map['carModel'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      driverId: '' ?? '',
    );
  }

  // Convert a Driver object to a map
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'regNumber': regNumber,
      'idNumber': idNumber,
      'carType': carType,
      'carModel': carModel,
      'phoneNumber' : phoneNumber
    };
  }
}