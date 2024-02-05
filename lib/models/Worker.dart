class WorkerModel {
  String? uid;
  String? email;
  String? name;
  String? number;
  String? adhaar;
  String? role;
  String? profession;
  String? city;
  double? lat = 0;
  double? long = 0;
  bool? available = false;
  List<String>? requests;
  double? rating = 0;
  String? profileImage; // New field for profile image URL

  WorkerModel({
    this.uid,
    this.email,
    this.name,
    this.number,
    this.adhaar,
    this.role,
    this.profession,
    this.city,
    this.lat,
    this.long,
    this.available,
    this.requests,
    this.rating,
    this.profileImage, // Initialize the new field
  });

  // Receiving data from server
  factory WorkerModel.fromMap(map) {
    return WorkerModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      number: map['number'],
      adhaar: map['adhaar'],
      role: map['role'],
      profession: map['profession'],
      city: map['city'],
      lat: map['lat'],
      long: map['long'],
      available: map['available'],
      requests: map['requests'] != null ? List<String>.from(map['requests']) : [],
      rating: map['rating'],
      profileImage: map['profileImage'], // Populate the new field
    );
  }

  // Sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'number': number,
      'adhaar': adhaar,
      'role': role,
      'profession': profession,
      'city': city,
      'lat': lat,
      'long': long,
      'available': available,
      'requests': requests,
      'rating': rating,
      'profileImage': profileImage, // Include the new field
    };
  }

  bool isWorker() {
    return role?.toLowerCase() == 'worker';
  }
}
