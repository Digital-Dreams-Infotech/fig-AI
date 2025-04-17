// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';  // Correct import
//
// class AboutUsPage extends StatefulWidget {
//   @override
//   _AboutUsPageState createState() => _AboutUsPageState();
// }
//
// class _AboutUsPageState extends State<AboutUsPage> {
//   late WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the WebView when the page is loaded
//     WebView.platform = SurfaceAndroidWebView();  // For Android platform
//
//     // Make sure the WebView is initialized
//     if (WebView.platform == null) {
//       WebView.platform = SurfaceAndroidWebView();  // For Android platform
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('About Us')),
//       body: WebView(
//         initialUrl: 'https://figpromptfinder.com/about',
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller = webViewController; // Initialize the controller
//         },
//       ),
//     );
//   }
// }