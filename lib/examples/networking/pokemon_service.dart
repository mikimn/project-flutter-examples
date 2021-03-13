import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class Pokemon {
  final String? name;
  final String? type;
  final int? id;

  const Pokemon(this.name, this.type, this.id);
  Pokemon.fromJson(Map json)
      : this(json['name'], json['types'][0]['type']['name'], json['id']);

  Map toJson() => {
        'name': this.name,
        'types': [
          {
            'type': {'name': this.name}
          }
        ],
        'id': this.id
      };

  bool operator ==(Object other) {
    return ((other is Pokemon) && (other.name == this.name));
  }

  int get hashCode => this.name.hashCode;
}

class PokemonService {
  Stream<Pokemon> get pokemons async* {
    for (var i = 1; i < 50; i++) {
      developer.debugger(when: i > 100, message: 'too much pokemon!!');

      try {
        var response =
            await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$i/'));
        if (response.statusCode != 200) {
          developer.log('Access to pokemon API returned error.',
              name: 'pokemonServices.pokemons', error: response.statusCode);
          continue;
        }
        var jsonPokemon = json.decode(response.body);
        yield Pokemon.fromJson(jsonPokemon);
      } catch (e) {
        developer.log('Exception during access to pokemon API.',
            level: 0, name: 'pokemonServices.pokemons', error: e);
        continue;
      }
    }
  }
}
