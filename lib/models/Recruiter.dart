
class RecruiterModel{
  String? uid;
  String? email;
  String? name;
  String? number;
  String? adhaar;
  String? role;
  String? city;
  double? lat;
  double? long;
  List<String>? requested;
  
  RecruiterModel({this.uid,this.email,this.name,this.number,this.adhaar,this.role,this.city,this.lat,this.long,this.requested});
  factory RecruiterModel.fromMap(map){
    return RecruiterModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      number: map['email'],
      adhaar: map['email'],
      role: map['email'],
      city: map['city'],
      lat: map['lat'],
      long:map['long'],
      requested: map['requested'] != null
          ? List<String>.from(map['requested'])
          : [], // Parse notifications list
    );
  }

//sending data to our server
Map<String, dynamic> toMap(){
  return{
    'uid':uid,
    'email':email,
    'name':name,
    'number':number,
    'adhaar':adhaar,
    'role':role,
    'city': city,
    'lat':lat,
    'long':long,
    'request':requested
  };
}
  bool isRecruiter() {
    return role?.toLowerCase() == 'recruiter';
  }
}