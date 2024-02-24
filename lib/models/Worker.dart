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
  int? TotalWork=0;
  List<String>? requests;
  List<double>? ratings; // Updated to store a list of ratings
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
    this.TotalWork,
    this.requests,
    this.ratings, // Updated to accept a list of ratings
    this.profileImage,
  });

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
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
      TotalWork: map['TotalWork'],
      requests: map['requests'] != null ? List<String>.from(map['requests']) : [],
      ratings: map['ratings'] != null ? List<double>.from(map['ratings']) : [], // Updated to parse a list of ratings
      profileImage: map['profileImage'],
    );
  }

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
      'TotalWork':TotalWork,
      'requests': requests,
      'ratings': ratings, // Updated to include ratings in the map
      'profileImage': profileImage,
    };
  }

  bool isWorker() {
    return role?.toLowerCase() == 'worker';
  }

  double calculateAverageRating() {
    if (ratings == null || ratings!.isEmpty) {
      return 0.0; // If no ratings, return 0
    }
    double totalRating = ratings!.reduce((a, b) => a + b); // Sum of all ratings
    return totalRating / ratings!.length; // Average rating
  }
}
