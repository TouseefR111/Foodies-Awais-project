import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getSendingCategoryFood(Map<String,dynamic> userInfo, String category) async{
    await FirebaseFirestore.instance.collection(category).add(userInfo);
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection("users").doc(userId).get();
  }

  Future <Stream<QuerySnapshot>> getDataFromDb(String category) async{
    return await FirebaseFirestore.instance.collection(category).snapshots();
  }

  Future usersData(Map<String,dynamic> userInfoAuth, String id) async{
    await FirebaseFirestore.instance.collection("users").doc(id).set(userInfoAuth);
  }


  Future cartData(Map<String,dynamic> userInfoAuth) async{
    await FirebaseFirestore.instance.collection("cart").add(userInfoAuth);
  }

  Future <Stream<QuerySnapshot>> getDataFromCartDb(String id) async{
    return await FirebaseFirestore.instance.collection("cart").where("Id",isEqualTo:id).snapshots();
  }

  Future bookOrderData(Map<String,dynamic> userInfoAuth) async{
    await FirebaseFirestore.instance.collection("orders").add(userInfoAuth);
  }

  Future <Stream<QuerySnapshot>> getDataFromOrderDb(String id) async{
    return await FirebaseFirestore.instance.collection("orders").where("orderId",isEqualTo:id).snapshots();
  }

  Future deleteCart(String id) async{
    await FirebaseFirestore.instance.collection("cart").doc(id).delete();
  }

  Future <Stream<QuerySnapshot>> getOrderForAdmin() async{
    return await FirebaseFirestore.instance.collection("orders").snapshots();
  }

   updateStatus(String id) async{
    return await FirebaseFirestore.instance.collection("orders").doc(id).update({"Status":"Delivered"});
  }




}