class WorkerModel{
  String? uid;
  String? email;
  String? name;
  String? number;
  String? adhaar;
  String? role;
  String? profession;
  String? city;
  double? lat=0;
  double? long=0;
  bool? available=false;
  List<String>? requests;

  WorkerModel({this.uid,this.email,this.name,this.number,this.adhaar,this.role,this.profession,this.city,this.lat,this.long,this.available,this.requests});
//Receiving datafrom server
  factory WorkerModel.fromMap(map){
    return WorkerModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      number: map['email'],
      adhaar: map['email'],
      role: map['email'],
      profession: map['profession'],
      city: map['city'],
      lat: map['lat'],
      long:map['long'],
      available: map['available'],
      requests: map['requests'] != null
          ? List<String>.from(map['requests'])
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
    'profession':profession,
    'city': city,
    'lat':lat,
    'long':long,
    'available':available,
    'requests':requests
    
  };
}
  bool isWorker() {
    return role?.toLowerCase() == 'worker';
  }
}