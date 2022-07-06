import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:modern_form_esys_flutter_share/modern_form_esys_flutter_share.dart';

void main() {
  runApp(const RandomMemes());
}

class Button extends StatelessWidget {
  const Button(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.color = const Color(0xff362222),
      this.disabled = false})
      : super(key: key);

  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: disabled ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              side: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class RandomMemes extends StatefulWidget {
  const RandomMemes({Key? key}) : super(key: key);

  @override
  State<RandomMemes> createState() => _RandomMemesState();
}

class _RandomMemesState extends State<RandomMemes> {
  String memeURL = "";
  bool isLoading = true;

  void fetchMeme() async {
    setState(() {
      isLoading = true;
    });

    final response =
        await get(Uri.parse('https://meme-api.herokuapp.com/gimme'));
    final data = jsonDecode(response.body);

    setState(() {
      memeURL = data['url'];
      isLoading = false;
    });
  }

  void handleShare() async {
    var request = await HttpClient().getUrl(Uri.parse(memeURL));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    final fileName = memeURL.substring(memeURL.lastIndexOf('/') + 1);
    final extension = memeURL.substring(memeURL.lastIndexOf('.') + 1);
    await Share.file('Share this image', fileName, bytes, 'image/$extension');
  }

  @override
  void initState() {
    super.initState();
    fetchMeme();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Random Memes',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
          ),
          backgroundColor: const Color(0xffFFCCD2),
          centerTitle: true,
          elevation: 0.2,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://www.transparenttextures.com/patterns/crisp-paper-ruffles.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: isLoading && memeURL == ""
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: Image.network(
                        memeURL,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Button(
                              text: "Share",
                              onPressed: handleShare,
                              color: const Color(0xffB3541E)),
                          const SizedBox(width: 16),
                          Button(
                            text: "Next",
                            onPressed: fetchMeme,
                            disabled: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
