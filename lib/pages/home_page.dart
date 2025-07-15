import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon_project/controllers/home_page_controller.dart';
import 'package:pokemon_project/models/page_data.dart';
import 'package:pokemon_project/models/pokemon.dart';
import 'package:pokemon_project/providers/pokemon_data_providers.dart';
import 'package:pokemon_project/widgets/pokemon_card.dart';
import 'package:pokemon_project/widgets/pokemon_list_tile.dart';

final homePageControllerProvider =
    StateNotifierProvider<HomePageController, HomePageData>((ref) {
  return HomePageController(HomePageData.initial());
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _allPokemonListScrollController = ScrollController();

  late HomePageController _homePageController;
  late HomePageData _homePageData;

  late List<String> _favouritePokemons;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _allPokemonListScrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    print(
        "_allPokemonListScrollController.offset= ${_allPokemonListScrollController.offset}");
    print(
        "_allPokemonListScrollController.position.maxScrollExtent: ${_allPokemonListScrollController.position.maxScrollExtent}");
    print(
        "_allPokemonListScrollController.position.outOfRange: ${_allPokemonListScrollController.position.outOfRange}");
    if (_allPokemonListScrollController.offset >=
        _allPokemonListScrollController.position.maxScrollExtent *
            1 /*&& _allPokemonListScrollController.position.outOfRange*/) {
      print("Reached end of list");
      _homePageController.loadData();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _allPokemonListScrollController.removeListener(_scrollListener);
    _allPokemonListScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _homePageController = ref.watch(
      homePageControllerProvider.notifier,
    );
    _homePageData = ref.watch(
      homePageControllerProvider,
    );

    _favouritePokemons = ref.watch(
      favouritePokemonProvider,
    );

    // TODO: implement build
    return Scaffold(
      body: _buildUI(
        context,
      ),
    );
  }

  Widget _buildUI(
    BuildContext context,
  ) {
    return SafeArea(
        child: SingleChildScrollView(
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _favouritePokemonsList(context),
            _allPokemonList(
              context,
            )
          ],
        ),
      ),
    ));
  }

  Widget _favouritePokemonsList(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Favorites",
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                _favouritePokemons.isEmpty
                    ? const Text("No favorite pokemon yet!!")
                    : SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.48,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: _favouritePokemons.length,
                          itemBuilder: (context, index) {
                            String pokemonURL = _favouritePokemons[index];
                            return PokemonCard(
                              pokemonURL: pokemonURL,
                            );
                          },
                        ),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _allPokemonList(
    BuildContext context,
  ) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "All Pokemon",
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).width * 0.60,
            child: ListView.builder(
              controller: _allPokemonListScrollController,
              itemCount: _homePageData.data?.results?.length ?? 0,
              itemBuilder: (context, index) {
                PokemonListResult pokemonListResult =
                    _homePageData.data!.results![index];
                return PokemonListTile(pokemonURL: pokemonListResult.url!);
              },
            ),
          )
        ],
      ),
    );
  }
}
