import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:translator/translator.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup Name Generator')),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(1.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], index);
        });
  }

  Widget _buildRow(WordPair pair, index) {
    final translator = GoogleTranslator();
    var input = pair.first + " " + pair.second;
    var trans = translator.translate(input, from: 'en', to: 'ja');

    return FutureBuilder<Translation>(
      future: trans,
      builder: (context, snapshot) {
        String str;
        if (snapshot.hasData) {
          str = "${snapshot.data!.text}  ($input)";
        } else {
          str = input;
        }
        return Text(
          str,
          style: _biggerFont,
        );
      },
    );
  }
}
