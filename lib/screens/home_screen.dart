import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/pin.dart';
import '../services/pin_api.dart';
import '../widgets/pin_card.dart';
import '../widgets/state_views.dart';
import 'pin_detail_screen.dart';

/// Home feed: Pinterest-style masonry grid loaded from the API.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = PinApi();
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();

  List<Pin> _pins = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Initial load / retry / pull-to-refresh.
  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final pins = await _api.fetchPins(page: 1);
      if (!mounted) return;
      setState(() {
        _pins = pins;
        _page = 1;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  /// Infinite scroll: loads the next page of pins.
  Future<void> _loadMore() async {
    if (_loadingMore || _loading || _query.isNotEmpty || _error != null) return;
    setState(() => _loadingMore = true);
    try {
      final more = await _api.fetchPins(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _pins = [..._pins, ...more];
        _page++;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  List<Pin> get _filtered {
    if (_query.isEmpty) return _pins;
    final q = _query.toLowerCase();
    return _pins
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.author.toLowerCase().contains(q))
        .toList();
  }

  int _columnsFor(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  void _openDetail(Pin pin) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PinDetailScreen(pin: pin, heroTag: 'home_${pin.id}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.push_pin, color: Color(0xFFE60023)),
            SizedBox(width: 8),
            Text('Pinly'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search pins or photographers',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();

    if (_error != null && _pins.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    final pins = _filtered;
    if (pins.isEmpty) {
      return EmptyView(
        icon: Icons.search_off,
        title: 'No pins found',
        subtitle: _query.isEmpty
            ? 'Pull down to refresh.'
            : 'Nothing matches "$_query". Try another search.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () => _load(silent: true),
          child: MasonryGridView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columnsFor(constraints.maxWidth),
            ),
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
            itemCount: pins.length + (_loadingMore ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= pins.length) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final pin = pins[i];
              return PinCard(
                pin: pin,
                heroTag: 'home_${pin.id}',
                onTap: () => _openDetail(pin),
              );
            },
          ),
        );
      },
    );
  }
}
