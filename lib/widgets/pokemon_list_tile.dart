import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon_project/models/pokemon.dart';
import 'package:pokemon_project/providers/pokemon_data_providers.dart';
import 'package:pokemon_project/widgets/pokemon_stats_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PokemonListTile extends ConsumerWidget {
  final String pokemonURL;

  late FavouritePokemonProvider _favouritePokemonProvider;
  late List<String> _favouritePokemons;

  PokemonListTile({
    required this.pokemonURL,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _favouritePokemonProvider = ref.watch(favouritePokemonProvider.notifier);
    _favouritePokemons = ref.watch(favouritePokemonProvider);
    final pokemon = ref.watch(pokemonDataProvider(pokemonURL));
    return pokemon.when(data: (data) {
      return _tile(context, false, data);
    }, error: (error, stackTrace) {
      return Text("Error: $error");
    }, loading: () {
      return _tile(context, true, null);
    });
  }

  Widget _tile(
    BuildContext context,
    bool isLoading,
    Pokemon? pokemon,
  ) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () {
          if (!isLoading) {
            showDialog(
                context: context,
                builder: (_) {
                  return PokemonStatsCard(pokemonURL: pokemonURL);
                });
          }
        },
        child: ListTile(
          leading: pokemon != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(pokemon.sprites!.frontDefault!),
                )
              : CircleAvatar(),
          title: Text(
            pokemon != null ? pokemon.name!.toUpperCase() : "",
          ),
          subtitle: Text("Has ${pokemon?.moves?.length.toString() ?? 0} moves"),
          trailing: IconButton(
            onPressed: () {
              if (_favouritePokemons.contains(pokemonURL)) {
                _favouritePokemonProvider.removeFavouritePokemon(pokemonURL);
              } else {
                _favouritePokemonProvider.addFavouritePokemon(pokemonURL);
              }
            },
            icon: Icon(_favouritePokemons.contains(pokemonURL)
                ? Icons.favorite
                : Icons.favorite_border),
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
