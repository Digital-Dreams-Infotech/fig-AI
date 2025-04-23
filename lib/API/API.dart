import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://api.figpromptfinder.com";
  final String Category_baseUrl = "https://api.figpromptfinder.com/aichat";
  final String Sub_Category_baseUrl =
      "https://api.figpromptfinder.com/aichat/subcategories";
  final String PromptSub_Category_baseUrl =
      "https://api.figpromptfinder.com/aichat/prompt/subcategories";
  final String Get_Category =
      "https://api.figpromptfinder.com/aichat/categories/";
  final String Prompt_baseUrl =
      "https://api.figpromptfinder.com/aichat/prompts/";
  final String Get_celery_response =
      "https://api.figpromptfinder.com/aichat/tasks/status";
  final String Content_Generator =
      "https://api.figpromptfinder.com/aichat/content-generator";
  final String PromptCategory =
      "https://api.figpromptfinder.com/aichat/prompt/categories";
  final String SubPromptCategory =
      "https://api.figpromptfinder.com/aichat/prompt/subcategories";

  final String NewChatFig = "https://api.figpromptfinder.com/aichat/chats/";

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

  Future<http.Response> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
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

  Future<http.Response> confirmPasswordReset(
    String uid,
    String token,
    String newPassword,
  ) async {
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
  Future<http.Response> generateCategory(
    String token,
    String categoryName,
  ) async {
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

  Future<http.Response> updateCategory(
    String token,
    int categoryId,
    String categoryName,
  ) async {
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
  Future<http.Response> generateSubCategory(
    String token,
    String subCategoryName,
    int categoryId,
  ) async {
    final url = Uri.parse("$Sub_Category_baseUrl");

    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = subCategoryName;
    request.fields["category"] = categoryId.toString();

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getSubCategories(String token, int categoryId) async {
    final url = Uri.parse("$Sub_Category_baseUrl/?category=$categoryId");
    // final url = Uri.parse("https://api.figpromptfinder.com/aichat/prompt/subcategories/?prompt_category=6");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  Future<http.Response> getPromptSubCategories({
    required String token,
    required int categoryId,
    String searchQuery = '',
    int start = 0,
    int limit = 10,
  }) async {
    final url = Uri.parse(PromptSub_Category_baseUrl).replace(
      queryParameters: {
        'prompt_category': categoryId.toString(),
        'search': searchQuery,
        'start': start.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  Future<http.Response> updateSubCategory(
    String token,
    int subCategoryId,
    String subCategoryName,
  ) async {
    final url = Uri.parse("$Sub_Category_baseUrl/$subCategoryId/");

    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = subCategoryName;

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> deleteSubCategory(
    String token,
    int subCategoryId,
  ) async {
    final url = Uri.parse("$Sub_Category_baseUrl/$subCategoryId/");
    return await http.delete(url, headers: {"Authorization": "Bearer $token"});
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------

  // -----------------(AI_Chat) Generate new chat -----------------------
  Future<http.Response> generateChat(
    String token,
    int userId,
    int categoryId,
  ) async {
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
    return await http.get(url, headers: {"Authorization": "Bearer $token"});
  }

  Future<http.Response> deletChat(String token, int chatId) async {
    final url = Uri.parse("${Category_baseUrl}/chats/$chatId/");
    return await http.delete(url, headers: {"Authorization": "Bearer $token"});
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
  // ---------------- (AI-Chat) Get Prompt -------------------------
  Future<http.Response> getPrompt(String token, int chatId) async {
    final url = Uri.parse("$Prompt_baseUrl/?chat=$chatId");

    return await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<http.Response> createPrompt(
    String token,
    int chatId,
    String requestText,
    int categoryId, {
    int? subCategoryId,
  }) async {
    final url = Uri.parse(Prompt_baseUrl);
    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["chat"] = chatId.toString();
    request.fields["request_text"] = requestText;
    request.fields["category"] = categoryId.toString();

    if (subCategoryId != null) {
      request.fields["sub_category"] = subCategoryId.toString();
    }
    // request.fields["sub_category"] = subCategoryId.toString();

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updatePrompt(
    String token,
    int promptId,
    String requestText,
  ) async {
    final url = Uri.parse("$Prompt_baseUrl/$promptId/");
    var request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["request_text"] = requestText;

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------

  // ----------  (AI-Chat) Delete Prompt ----------------------------
  Future<http.Response> deletePropmt(String token, int promptId) async {
    final url = Uri.parse("$Prompt_baseUrl/$promptId");
    return await http.delete(url, headers: {"Authorization": "Bearer $token"});
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
  // ----------  (AI-Chat) Get celery response ----------------------------
  Future<http.Response> deletePropmtgetCeleryResponse(
    String token,
    int taskId,
  ) async {
    final url = Uri.parse("$Get_celery_response/$taskId");
    return await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
  // ----------  (AI-Chat) Get celery response ----------------------------
  Future<http.Response> generateContent(
    String category,
    String inputText,
  ) async {
    final url = Uri.parse(baseUrl);

    var request = http.MultipartRequest("POST", url);
    request.fields['category'] = category;
    request.fields['input_text'] = inputText;

    return await http.Response.fromStream(await request.send());
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------
  // ----------  (AI-Chat) PromptCategory ----------------------------

  // Future<http.Response> getPromptCategory(String token, {String? prompt, String? category,}) async {
  //   final url = Uri.parse(PromptCategory);
  //
  //   final headers = {"Authorization": "Bearer $token"};
  //
  //   final response = await http.get(url, headers: headers);
  //   return response;
  // }

  Future<http.Response> getPromptCategory(
    String token, {
    String? prompt,
    String? category,
  }) async {
    final url = Uri.parse(PromptCategory);
    final headers = {"Authorization": "Bearer $token"};

    return await http.get(url, headers: headers);
  }

  Future<http.Response> createPromptCategory(
    String token,
    String name,
    String index,
  ) async {
    final url = Uri.parse(PromptCategory);

    var request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['index'] = index;

    var res = await request.send();
    return await http.Response.fromStream(res);

    // -----Example ---------
    // var response = await createPromptCategory(
    //   'your_token_here',
    //   'Sports',
    //   '12',
    // );
  }

  Future<http.Response> updatePromptCategory(
    String token,
    int catId,
    String newName,
  ) async {
    final url = Uri.parse("$PromptCategory/$catId");
    var request = http.MultipartRequest("PUT", url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = newName;

    var res = await request.send();
    return await http.Response.fromStream(res);
  }

  Future<http.Response> deletePromptCategory(String token, int catId) async {
    final url = Uri.parse("$PromptCategory/$catId");

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response;

    // final response = await deletePromptCategory("your_token_here", 100);
  }

  // ----------------- XXXXXXXXXXXXXXXXXXXX -------------------------

  // ------------ Prompt Sub Category ------------------
  Future<http.Response> getSubPromptCategory(
    String token,
    int categoryId,
  ) async {
    final url = Uri.parse("$SubPromptCategory?prompt_category=$categoryId");

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response;
  }

  Future<http.Response> createPromptSubCategory(
    String token,
    String name,
    String promptCategoryId,
  ) async {
    final url = Uri.parse(SubPromptCategory);

    var request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['prompt_category'] = promptCategoryId;

    return await http.Response.fromStream(await request.send());
  }

  Future<http.Response> updatePromptSubCategory(
    String token,
    int subCtaId,
    String newName,
  ) async {
    final url = Uri.parse("$SubPromptCategory/$subCtaId");

    var request = http.MultipartRequest("PUT", url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = newName;

    return await http.Response.fromStream(await request.send());
  }

  Future<http.Response> deletePromptSubCategory(
    String token,
    int subCatId,
  ) async {
    final url = Uri.parse("$SubPromptCategory/$subCatId");

    var res = http.delete(url, headers: {"Authorization": "Bearer $token"});

    return res;
  }

  // --------- XXXXXXXXXXXXXXX -----------------------

  // ---------- ChatBot ---------------
  Future<http.Response> chatWithBot(String prompt) async {
    final url = Uri.parse(Category_baseUrl);

    var request = http.MultipartRequest("POST", url);
    request.fields['prompt'] = prompt;

    // pacher thi enable karva nu category/sub_category, aave to chalse
    // request.fields['category'] = '1';
    // request.fields['sub_category'] = '1';

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);

    // --- used aa rite karvo ----
    // void sendPrompt() async {
    //   var response = await chatWithBot("please give me python code in odd even");
    //   print("Bot Response: ${response.body}");
    // }
  }

  // ---------- XXXXXXX ---------------

  // -------- New Request -------------
  Future<http.Response> generateOptimizedContent({
    required String category,
    required String subCategory,
    required String prompt,
  }) async {
    final url = Uri.parse(Category_baseUrl);

    var request = http.MultipartRequest("POST", url);

    request.fields['category'] = category;
    request.fields['sub_category'] = subCategory;
    request.fields['prompt'] = prompt;

    request.headers.addAll({
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'Origin': 'http://localhost:3000',
      'Referer': 'http://localhost:3000/',
      'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
    });

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // -------- XXXXXXXXXXX -------------

  // ----------------- New Chat -----------------
  Future<http.Response> createNewChat(String token, String userId) async {
    final url = Uri.parse(NewChatFig);

    var request = http.MultipartRequest("POST", url);
    request.fields['user'] = userId;
    request.headers['Authorization'] = "Bearer $token";

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getAllChats(String token) async {
    final url = Uri.parse(NewChatFig);

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return res;
  }

  Future<http.Response> deleteChat(String token, int chatId) async {
    final url = Uri.parse("$NewChatFig/$chatId/");

    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return res;
  }

  // ------- XXXXXXXXXXXXXX -----------

  // ------------- HISTORY ---------
  Future<http.Response> getPromptHistoryBySlug(
    String token,
    String slug,
  ) async {
    final url = Uri.parse(
      'https://api.figpromptfinder.com/aichat/chats/prompt-history/$slug/',
    );
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json", // Optional, but good practice
    };

    return await http.get(url, headers: headers);
  }

  // -------- XXXXXXXXXXXXXXX __________

  // ---------- Delete Account ----------
  Future<http.Response> deleteAccount(String token) async {
    final url = Uri.parse("$baseUrl/account-delete/");
    final header = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    try {
      final response = await http.post(url, headers: header);
      return response;
    } catch (e) {
      print("Error while deleting account: $e");
      rethrow;
    }
  }

  // -------- XXXXXXXXXXXXXXX __________
}
