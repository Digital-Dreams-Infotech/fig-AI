import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://api.figpromptfinder.com";
  final String Category_baseUrl = "http://api.figpromptfinder.com/aichat";
  final String Sub_Category_baseUrl =
      "http://api.figpromptfinder.com/aichat/subcategories";

  // ----------------- User APIs -------------------------
  Future<http.Response> loginWithGoogle(String authToken) async {
    final url = Uri.parse("$baseUrl/login-with-google/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"auth_token": authToken}),
    );
  }

  Future<http.Response> registerUser(String email, String password) async {
    final url = Uri.parse("$baseUrl/user/register/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  Future<http.Response> loginUser(String email, String password) async {
    final url = Uri.parse("$baseUrl/user/login/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"email": email, "password": password},
    );
  }

  Future<http.Response> changePassword(String token,String oldPassword,String newPassword,) async {
    final url = Uri.parse("$baseUrl/user/password/change/");
    return await http.put(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $token",
      },
      body: {
        "old_password": oldPassword,
        "new_password": newPassword,
        "confirm_new_password": newPassword,
      },
    );
  }

  Future<http.Response> resetPassword(String email) async {
    final url = Uri.parse("$baseUrl/user/password-reset/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"email": email},
    );
  }

  Future<http.Response> confirmPasswordReset(String uid,String token,String newPassword,) async {
    final url = Uri.parse("$baseUrl/user/password-reset-confirm/$uid/$token/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"new_password": newPassword, "confirm_new_password": newPassword},
    );
  }

  Future<http.Response> deleteUser(String token, int userId) async {
    final url = Uri.parse("$baseUrl/user/delete/$userId/");
    return await http.delete(url, headers: {"Authorization": "Bearer $token"});
  }

  Future<http.Response> uploadProfile(String token, String imagePath) async {
    final url = Uri.parse("$baseUrl/user/profile/");
    var request = http.MultipartRequest("PATCH", url);
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("image", imagePath));
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getUser(String token) async {
    final url = Uri.parse("$baseUrl/user/");
    return await http.get(url, headers: {"Authorization": "Bearer $token"});
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------

  // -------------------- AI-chat -------------------------------------
  Future<http.Response> generateCategory(String token,String categoryName,) async {
    final url = Uri.parse("${Category_baseUrl}/categories/");

    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = categoryName;

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getCategories() async {
    final url = Uri.parse("$Category_baseUrl/categories/");
    return await http.get(url);
  }

  Future<http.Response> updateCategory(String token,int categoryId,String categoryName,) async {
    final url = Uri.parse("${Category_baseUrl}/categories/$categoryId/");

    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = categoryName;

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> deleteCategory(String token, int categoryId) async {
    final url = Uri.parse("$Category_baseUrl/categories/$categoryId/");
    return await http.delete(url, headers: {"Authorization": "Bearer $token"});
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
  // ---------------(AI-Chat) Sub Category -------------------------- (Doute)
  Future<http.Response> generateSubCategory(String token,String subCategoryName,int categoryId,) async {
    final url = Uri.parse("$Sub_Category_baseUrl");

    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = subCategoryName;
    request.fields["category"] = categoryId.toString();

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getSubCategories(int categoryId) async {
    final url = Uri.parse("$Sub_Category_baseUrl/?category=$categoryId");
    return await http.get(url);
  }

  Future<http.Response> updateSubCategory(String token,int subCategoryId,String subCategoryName,) async {
    final url = Uri.parse("$Sub_Category_baseUrl/$subCategoryId/");

    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = subCategoryName;

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> deleteSubCategory(String token,int subCategoryId,) async {
    final url = Uri.parse("$Sub_Category_baseUrl/$subCategoryId/");
    return await http.delete(url, headers: {"Authorization": "Bearer $token"});
  }
  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------

  // -----------------(AI_Chat) Generate new chat -----------------------
  Future<http.Response> generateChat(String token, int userId, int categoryId) async {
    final url = Uri.parse("${Category_baseUrl}/chats/");
    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["user"] = userId.toString();
    request.fields["category"] = categoryId.toString();
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getAllOwnChats(String token) async {
    final url = Uri.parse("${Category_baseUrl}/chats/");
    return await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<http.Response> deleteChat(String token, int chatId) async {
    final url = Uri.parse("${Category_baseUrl}/chats/$chatId/");
    return await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
  }
  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
  // ---------------- (AI-Chat) Get Prompt -------------------------
  Future<http.Response> getPrompt(String token, int chatId) async {
    final url = Uri.parse("$baseUrl/?chat=$chatId");

    return await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }
  Future<http.Response> createPrompt(String token,int chatId,String requestText,int categoryId,int subCategoryId,) async {
    final url = Uri.parse(baseUrl);
    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["chat"] = chatId.toString();
    request.fields["request_text"] = requestText;
    request.fields["category"] = categoryId.toString();
    request.fields["sub_category"] = subCategoryId.toString();

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
  Future<http.Response> updatePrompt(String token,int promptId,String requestText,) async {
    final url = Uri.parse("$baseUrl/$promptId/");
    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["request_text"] = requestText;

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------

  // ----------  (AI-Chat) Delete Prompt ----------------------------

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
}
