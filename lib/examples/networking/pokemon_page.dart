import 'dart:async';
import 'dart:convert';
import 'package:android_course/examples/networking/pokemon_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PokemonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemons!')
      ),
      body: _PokemonList(),
    );
  }
}

class _PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<_PokemonList> {
  StreamController<Pokemon> _streamController;
  List<Pokemon> _pokemons = [];
  List<Pokemon> _liked = [];

  @override
  void initState() {
    super.initState();
    this._getLiked();
    _streamController = StreamController.broadcast();
    _streamController.stream.listen((p) => setState(() => _pokemons.add(p)));
    _load(_streamController);
  }

  _load(StreamController<Pokemon> streamController) async {
    PokemonServices.pokemons.pipe(streamController);
  }

  @override
  void dispose() {
    super.dispose();
    _streamController?.close();
    _streamController = null;
  }

  void _getLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this._liked =
      (json.decode(prefs.getString('liked_pokemon') ?? '[]') as List)
        .map((entry) => Pokemon.fromJson(entry))
        .toList();
  }

  void _saveLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('liked_pokemon', json.encode(this._liked));
    debugDumpRenderTree();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        if (index >= _pokemons.length) {
          return null;
        }
        return _listElement(_pokemons[index]);
      }
    );
  }

  Widget _listElement(Pokemon pokemon) {
    final liked = _liked.contains(pokemon);
    return ListTile(
      title: Text('${pokemon.name[0].toUpperCase()+pokemon.name.substring(1).toLowerCase()}',
        style: TextStyle(fontSize: 22),
      ),
      trailing: Icon(
        liked ? Icons.favorite : Icons.favorite_border,
        color: liked ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (liked) {
            _liked.remove(pokemon);
          } else {
            _liked.add(pokemon);
          }
          this._saveLiked();
        });
      },
    );
  }
}

