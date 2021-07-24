import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:synchronized/synchronized.dart';
import 'package:translator/translator.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = <WordPair>{};
  final _translated = Map<WordPair, String>();
  final translator = GoogleTranslator();
  Lock lock = Lock();

  @override
  Widget build(BuildContext context) {
    lock = Lock();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );

  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase + "  (${_translated[pair]})",
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
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
  
  Future<String> _waitAndTrans (WordPair str) async {
    String? t = _translated[str];
    if(t != null){
      return t;
    }
    
    var time = Duration(milliseconds: 1000);
    await lock.synchronized(() async {
      await Future.delayed(time);
    });

    String text;
    try{
      text = (await translator.translate(str.first + " " + str.second, from: 'en', to: 'ja', )).text;
    }catch(e){
      text = "Transration Error";
    }

    _translated[str] = text;
    return text;
  }

  Widget _buildRow(WordPair pair, index) {
    var trans = _waitAndTrans(pair);
    final alreadySaved = _saved.contains(pair);  // NEW

    return FutureBuilder<String>(
      future: trans,
      builder: (context, snapshot) {
        String str;
        if (snapshot.hasData) {
          str = "${pair.asPascalCase}  (${snapshot.data!})";
        } else {
          str = pair.asPascalCase + "  (...)";
        }
        return ListTile(

          title: Text(
            str,
            style: _biggerFont,
          ),

          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),

          onTap: () { 
            setState(() {
              if (alreadySaved) {
                _saved.remove(pair);
              } else {
                _saved.add(pair);
              }
            });
          },
        );
      },
    );
  }
}
