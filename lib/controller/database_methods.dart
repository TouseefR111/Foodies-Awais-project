import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add category food
  Future getSendingCategoryFood(
      Map<String, dynamic> userInfo, String category) async {
    await _firestore.collection(category).add(userInfo);
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection("users").doc(userId).get();
  }

  // Get products from category
  Future<Stream<QuerySnapshot>> getDataFromDb(String category) async {
    return _firestore.collection(category).snapshots();
  }

  // Save user data
  Future usersData(
      Map<String, dynamic> userInfoAuth, String id) async {
    await _firestore
        .collection("users")
        .doc(id)
        .set(userInfoAuth);
  }

  // Add item to cart
  Future cartData(
      Map<String, dynamic> userInfoAuth) async {
    await _firestore
        .collection("cart")
        .add(userInfoAuth);
  }

  // Get cart items ONLY for the current user
  Future<Stream<QuerySnapshot>> getDataFromCartDb(
      String id) async {
    return _firestore
        .collection("cart")
        .where("id", isEqualTo: id)
        .snapshots();
  }

  // Add order
  Future bookOrderData(
      Map<String, dynamic> userInfoAuth) async {
    await _firestore
        .collection("orders")
        .add(userInfoAuth);
  }

  // Get user's orders
  Future<Stream<QuerySnapshot>> getDataFromOrderDb(
      String id) async {
    return _firestore
        .collection("orders")
        .where("orderId", isEqualTo: id)
        .snapshots();
  }

  // Delete cart item
  Future deleteCart(String id) async {
    await _firestore
        .collection("cart")
        .doc(id)
        .delete();
  }

  // Get all orders for admin
  Future<Stream<QuerySnapshot>> getOrderForAdmin() async {
    return _firestore
        .collection("orders")
        .snapshots();
  }

  // Update order status
  Future updateStatus(String id) async {
    return await _firestore
        .collection("orders")
        .doc(id)
        .update({
      "Status": "Delivered",
    });
  }
}

