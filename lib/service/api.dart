// import 'dart:convert';

// import 'package:http/http.dart' as http;

// class PexelApi {
//   final String api = "https://api.pexels.com/v1/curated?page=2&per_page=10";
//   final String auth =
//       "563492ad6f91700001000001b6db29ebe1e0450bb881d9d19d7f5e75";

//   apiCall() async {
//     var response = await http.get(
//       Uri.parse(api),
//       headers: {
//         "Authorization": auth,
//       },
//     );
//     var res = jsonDecode(response.body);
//     return res;
//   }
// }
