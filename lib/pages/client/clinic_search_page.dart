import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/clinic.dart';
import 'package:clinicflow/services/firestore_service.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

enum ClinicViewMode { mapAndList, fullList, mapOnly }

class AddClinicPage extends StatefulWidget {
  const AddClinicPage({super.key});

  @override
  State<AddClinicPage> createState() => _AddClinicPageState();
}

class _AddClinicPageState extends State<AddClinicPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Ephemeral search area: only used for searching/filtering, never saved to account/profile.
  ClinicSearchArea _searchArea = presetSearchAreas.first;
  ClinicViewMode _viewMode = ClinicViewMode.mapAndList;
  String _selectedSpecialty = 'All clinics';
  double _minRating = 0.0;
  bool _sortByRating = false;
  Clinic? _selectedPreviewClinic;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Clinic> get _filteredClinics {
    final query = _searchController.text.trim().toLowerCase();

    final items = sampleClinics.where((clinic) {
      if (currentAccount.activeProfile.hasClinic(clinic.id)) {
        return false;
      }

      final matchesQuery = query.isEmpty ||
          clinic.name.toLowerCase().contains(query) ||
          clinic.specialty.toLowerCase().contains(query) ||
          clinic.address.toLowerCase().contains(query);

      final matchesType =
          _selectedSpecialty == 'All clinics' || clinic.specialty == _selectedSpecialty;

      final matchesRating = clinic.rating >= _minRating;
      final withinRadius = clinic.distanceKmFrom(_searchArea.center) <= _searchArea.radiusKm;

      return matchesQuery && matchesType && matchesRating && withinRadius;
    }).toList();

    items.sort((a, b) {
      if (_sortByRating) {
        final ratingCmp = b.rating.compareTo(a.rating);
        if (ratingCmp != 0) return ratingCmp;
      }
      return a.distanceKmFrom(_searchArea.center).compareTo(b.distanceKmFrom(_searchArea.center));
    });

    return items;
  }

  Future<void> _openSearchArea() async {
    final updated = await Navigator.push<ClinicSearchArea>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchAreaPage(initialArea: _searchArea),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _searchArea = updated;
        _selectedPreviewClinic = null;
      });
      _mapController.move(_searchArea.center, 13.0);
    }
  }

  Future<void> _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterClinicsPage(
          initialSpecialty: _selectedSpecialty,
          initialMinRating: _minRating,
          initialSortByRating: _sortByRating,
          searchArea: _searchArea,
          matchingCount: _filteredClinics.length,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedSpecialty = result['specialty'] as String? ?? 'All clinics';
        _minRating = (result['minRating'] as double?) ?? 0.0;
        _sortByRating = (result['sortByRating'] as bool?) ?? false;
      });
    }
  }

  void _openDetails(Clinic clinic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicDetailsPage(
          clinic: clinic,
          searchArea: _searchArea,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildMapWidget(List<Clinic> clinics, {double? height}) {
    final palette = currentAccount.palette;

    final mapWidget = RepaintBoundary(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _searchArea.center,
          initialZoom: 13.0,
          minZoom: 10.5,
          maxZoom: 16.0,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          onTap: (_, _) {
            if (_selectedPreviewClinic != null) {
              setState(() => _selectedPreviewClinic = null);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.clinicflow',
          ),
          CircleLayer(
            circles: buildRadiusCircles(
              center: _searchArea.center,
              radiusKm: _searchArea.radiusKm,
              palette: palette,
            ),
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _searchArea.center,
                width: 34,
                height: 34,
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.primary, width: 3),
                  ),
                  child: Icon(Icons.my_location, size: 16, color: palette.primary),
                ),
              ),
              for (int i = 0; i < clinics.length; i++)
                Marker(
                  point: clinics[i].location,
                  width: 34,
                  height: 34,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedPreviewClinic = clinics[i]),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedPreviewClinic?.id == clinics[i].id
                            ? palette.textPrimary
                            : palette.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: BetterText(
                        text: '${i + 1}',
                        size: 12.0,
                        weight: 700,
                        colour: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    final previewCard = _selectedPreviewClinic == null
        ? null
        : Positioned(
            left: 12,
            right: 12,
            bottom: 72,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              color: palette.background,
              child: ListTile(
                onTap: () => _openDetails(_selectedPreviewClinic!),
                title: BetterText(
                  text: _selectedPreviewClinic!.name,
                  weight: 600,
                  size: 15.0,
                  colour: palette.textPrimary,
                ),
                subtitle: BetterText(
                  text:
                      '${_selectedPreviewClinic!.specialty} · ${_selectedPreviewClinic!.distanceKmFrom(_searchArea.center).toStringAsFixed(1)} km · ★ ${_selectedPreviewClinic!.rating}',
                  size: 12.0,
                  colour: palette.textSecondary,
                ),
                trailing: Icon(Icons.chevron_right, color: palette.primary),
              ),
            ),
          );

    if (height == null) {
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(child: mapWidget),
            ?previewCard,
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: mapWidget),
          ?previewCard,
        ],
      ),
    );
  }

  Widget _buildClinicRow(int index, Clinic clinic) {
    final palette = currentAccount.palette;
    final distKm = clinic.distanceKmFrom(_searchArea.center).toStringAsFixed(1);

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          onTap: () => _openDetails(clinic),
          leading: CircleAvatar(
            radius: 15,
            backgroundColor: palette.secondary,
            child: BetterText(
              text: '${index + 1}',
              size: 12.0,
              weight: 700,
              colour: palette.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: BetterText(
                  text: clinic.name,
                  size: 15.0,
                  weight: 600,
                  colour: palette.textPrimary,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              BetterText(
                text: '${clinic.specialty} · $distKm km away',
                size: 12.0,
                colour: palette.textSecondary,
              ),
              BetterText(
                text: '★ ${clinic.rating} (${clinic.reviewCount} reviews)',
                size: 12.0,
                colour: palette.textSecondary,
              ),
              BetterText(
                text: clinic.hoursStatus,
                size: 12.0,
                weight: 500,
                colour: palette.primary,
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: palette.textSecondary),
        ),
        Divider(height: 1, color: palette.smoke),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;
    final clinics = _filteredClinics;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BetterText(
          text: 'Add a clinic',
          size: 20.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search clinics',
                      prefixIcon: Icon(Icons.search, color: palette.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: palette.smoke),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _openSearchArea,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: palette.smoke),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Icon(Icons.location_on_outlined, color: palette.textPrimary),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: _openFilters,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: palette.smoke),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Icon(Icons.tune, color: palette.textPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: BetterText(
              text:
                  '${_searchArea.label} · Within ${_searchArea.radiusKm.toStringAsFixed(0)} km · Profile: ${currentAccount.activeProfile.name}',
              size: 12.0,
              colour: palette.textSecondary,
            ),
          ),
          if (_viewMode == ClinicViewMode.mapOnly)
            Expanded(
              child: Stack(
                children: [
                  _buildMapWidget(clinics),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _viewMode = ClinicViewMode.mapAndList),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.background,
                          foregroundColor: palette.textPrimary,
                        ),
                        icon: const Icon(Icons.format_list_bulleted, size: 18),
                        label: const Text('Show list'),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_viewMode == ClinicViewMode.fullList)
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 72),
                    itemCount: clinics.length + 1,
                    itemBuilder: (context, idx) {
                      if (idx == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BetterText(
                                    text: '${clinics.length} clinics nearby',
                                    size: 16.0,
                                    weight: 600,
                                    colour: palette.textPrimary,
                                  ),
                                  BetterText(
                                    text: _sortByRating ? 'Highest rated first' : 'Nearest first',
                                    size: 12.0,
                                    colour: palette.textSecondary,
                                  ),
                                ],
                              ),
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _viewMode = ClinicViewMode.mapAndList),
                                icon: const Icon(Icons.map_outlined, size: 16),
                                label: const Text('Map & list'),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildClinicRow(idx - 1, clinics[idx - 1]);
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _viewMode = ClinicViewMode.mapOnly),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.background,
                          foregroundColor: palette.textPrimary,
                        ),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Show map'),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Stack(
                    children: [
                      _buildMapWidget(clinics, height: 220),
                      Positioned(
                        top: 10,
                        right: 12,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _viewMode = ClinicViewMode.mapOnly),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.background,
                            foregroundColor: palette.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: const Text('Map only', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BetterText(
                              text: '${clinics.length} clinics nearby',
                              size: 16.0,
                              weight: 600,
                              colour: palette.textPrimary,
                            ),
                            BetterText(
                              text: _sortByRating ? 'Highest rated first' : 'Nearest first',
                              size: 12.0,
                              colour: palette.textSecondary,
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _viewMode = ClinicViewMode.fullList),
                          icon: const Icon(Icons.unfold_more, size: 16),
                          label: const Text('Full list'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: clinics.isEmpty
                        ? Center(
                            child: BetterText(
                              text: 'No clinics match this area or filter.',
                              size: 14.0,
                              colour: palette.textSecondary,
                            ),
                          )
                        : ListView.builder(
                            itemCount: clinics.length,
                            itemBuilder: (context, idx) => _buildClinicRow(idx, clinics[idx]),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SearchAreaPage extends StatefulWidget {
  final ClinicSearchArea initialArea;

  const SearchAreaPage({super.key, required this.initialArea});

  @override
  State<SearchAreaPage> createState() => _SearchAreaPageState();
}

class _SearchAreaPageState extends State<SearchAreaPage> {
  late ClinicSearchArea _draftArea;
  late TextEditingController _areaController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _draftArea = widget.initialArea;
    _areaController = TextEditingController(text: _draftArea.label);
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _selectPreset(ClinicSearchArea preset) {
    setState(() {
      _draftArea = _draftArea.copyWith(label: preset.label, center: preset.center);
      _areaController.text = preset.label;
    });
    _mapController.move(preset.center, 13.0);
  }

  void _onMapTap(LatLng point) {
    setState(() {
      final customLabel = _areaController.text.trim().isEmpty
          ? 'Custom area (${point.latitude.toStringAsFixed(2)}, ${point.longitude.toStringAsFixed(2)})'
          : _areaController.text.trim();
      _draftArea = _draftArea.copyWith(label: customLabel, center: point);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BetterText(
          text: 'Search area',
          size: 20.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BetterText(
              text: 'Choose a search area, not your exact location.',
              size: 15.0,
              weight: 600,
              colour: palette.textPrimary,
            ),
            const SizedBox(height: 4),
            BetterText(
              text: 'Tap the map or pick a general area to place your search pin.',
              size: 13.0,
              colour: palette.textSecondary,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaController,
              onChanged: (val) => _draftArea = _draftArea.copyWith(label: val.trim().isEmpty ? 'Selected area' : val.trim()),
              decoration: InputDecoration(
                hintText: 'General area or neighbourhood',
                prefixIcon: Icon(Icons.search, color: palette.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final preset in presetSearchAreas)
                  ChoiceChip(
                    label: Text(preset.label),
                    selected: _draftArea.label == preset.label,
                    onSelected: (_) => _selectPreset(preset),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _draftArea.center,
                    initialZoom: 13.0,
                    onTap: (_, point) => _onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.clinicflow',
                    ),
                    CircleLayer(
                      circles: buildRadiusCircles(
                        center: _draftArea.center,
                        radiusKm: _draftArea.radiusKm,
                        palette: palette,
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _draftArea.center,
                          width: 38,
                          height: 38,
                          child: Icon(Icons.location_pin, size: 38, color: palette.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(text: 'Search radius', size: 15.0, weight: 600, colour: palette.textPrimary),
                BetterText(
                  text: '${_draftArea.radiusKm.toStringAsFixed(0)} km',
                  size: 15.0,
                  weight: 700,
                  colour: palette.primary,
                ),
              ],
            ),
            Slider(
              value: _draftArea.radiusKm,
              min: 1,
              max: 25,
              divisions: 24,
              activeColor: palette.primary,
              onChanged: (val) => setState(() => _draftArea = _draftArea.copyWith(radiusKm: val)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(text: '1 km', size: 11.0, colour: palette.textSecondary),
                BetterText(text: '5 km', size: 11.0, colour: palette.textSecondary),
                BetterText(text: '10 km', size: 11.0, colour: palette.textSecondary),
                BetterText(text: '25 km', size: 11.0, colour: palette.textSecondary),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(
                    text: 'Your exact location stays private.',
                    size: 13.0,
                    weight: 600,
                    colour: palette.primary,
                  ),
                  BetterText(
                    text: 'Search area is temporary and only used for finding clinics.',
                    size: 12.0,
                    colour: palette.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _draftArea),
                style: FilledButton.styleFrom(backgroundColor: palette.primary),
                child: BetterText(
                  text: 'Use this area · ${_draftArea.radiusKm.toStringAsFixed(0)} km',
                  size: 15.0,
                  weight: 600,
                  colour: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterClinicsPage extends StatefulWidget {
  final String initialSpecialty;
  final double initialMinRating;
  final bool initialSortByRating;
  final ClinicSearchArea searchArea;
  final int matchingCount;

  const FilterClinicsPage({
    super.key,
    required this.initialSpecialty,
    required this.initialMinRating,
    required this.initialSortByRating,
    required this.searchArea,
    required this.matchingCount,
  });

  @override
  State<FilterClinicsPage> createState() => _FilterClinicsPageState();
}

class _FilterClinicsPageState extends State<FilterClinicsPage> {
  late String _specialty;
  late double _minRating;
  late bool _sortByRating;

  static const List<String> _specialties = [
    'All clinics',
    'General practice',
    'Dental',
    'Physiotherapy',
    'Paediatrics',
    'Dermatology',
  ];

  @override
  void initState() {
    super.initState();
    _specialty = widget.initialSpecialty;
    _minRating = widget.initialMinRating;
    _sortByRating = widget.initialSortByRating;
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BetterText(
          text: 'Filter clinics',
          size: 20.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BetterText(text: 'Clinic type', size: 15.0, weight: 600, colour: palette.textPrimary),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _specialties)
                  ChoiceChip(
                    label: Text(item),
                    selected: _specialty == item,
                    selectedColor: palette.primary,
                    labelStyle: TextStyle(
                      color: _specialty == item ? Colors.white : palette.textPrimary,
                    ),
                    onSelected: (_) => setState(() => _specialty = item),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            BetterText(text: 'Minimum rating', size: 15.0, weight: 600, colour: palette.textPrimary),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final entry in const [
                  ('Any rating', 0.0),
                  ('4.0+', 4.0),
                  ('4.5+', 4.5),
                ]) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _minRating = entry.$2),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _minRating == entry.$2 ? palette.primary : palette.background,
                        foregroundColor: _minRating == entry.$2 ? Colors.white : palette.textPrimary,
                      ),
                      child: Text(entry.$1),
                    ),
                  ),
                  if (entry.$2 != 4.5) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 20),
            BetterText(text: 'Sort results', size: 15.0, weight: 600, colour: palette.textPrimary),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _sortByRating = false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_sortByRating ? palette.primary : palette.background,
                      foregroundColor: !_sortByRating ? Colors.white : palette.textPrimary,
                    ),
                    child: const Text('Nearest first'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _sortByRating = true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _sortByRating ? palette.primary : palette.background,
                      foregroundColor: _sortByRating ? Colors.white : palette.textPrimary,
                    ),
                    child: const Text('Highest rated'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: BetterText(
                text: 'Searching within ${widget.searchArea.radiusKm.toStringAsFixed(0)} km of ${widget.searchArea.label}',
                size: 13.0,
                colour: palette.textPrimary,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, {
                  'specialty': _specialty,
                  'minRating': _minRating,
                  'sortByRating': _sortByRating,
                }),
                style: FilledButton.styleFrom(backgroundColor: palette.primary),
                child: BetterText(
                  text: 'Apply filters',
                  size: 15.0,
                  weight: 600,
                  colour: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClinicDetailsPage extends StatefulWidget {
  final Clinic clinic;
  final ClinicSearchArea searchArea;

  const ClinicDetailsPage({
    super.key,
    required this.clinic,
    required this.searchArea,
  });

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  Future<void> _addToSelectedProfile() async {
    final profile = currentAccount.activeProfile;
    if (!profile.hasClinic(widget.clinic.id)) {
      profile.clinicIds.add(widget.clinic.id);
    }
    for (final p in currentAccount.profiles) {
      if (p.id == profile.id && !p.clinicIds.contains(widget.clinic.id)) {
        p.clinicIds.add(widget.clinic.id);
      }
    }

    if (currentAccount.id.isNotEmpty) {
      await FirestoreService.saveProfile(currentAccount.id, profile);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.clinic.name} to ${profile.name}'),
      ),
    );
    Navigator.of(context)
      ..pop()
      ..pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;
    final distKm = widget.clinic.distanceKmFrom(widget.searchArea.center).toStringAsFixed(1);
    final isAdded = currentAccount.activeProfile.hasClinic(widget.clinic.id);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BetterText(
          text: 'Clinic details',
          size: 20.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 180,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: widget.clinic.location,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.clinicflow',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.clinic.location,
                      width: 36,
                      height: 36,
                      child: Icon(Icons.location_pin, size: 36, color: palette.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(
                    text: widget.clinic.name,
                    size: 20.0,
                    weight: 700,
                    colour: palette.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  BetterText(
                    text: '${widget.clinic.specialty} · $distKm km away',
                    size: 13.0,
                    colour: palette.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  BetterText(
                    text: '★ ${widget.clinic.rating} (${widget.clinic.reviewCount} reviews)',
                    size: 13.0,
                    colour: palette.textSecondary,
                  ),
                  BetterText(
                    text: widget.clinic.hoursStatus,
                    size: 13.0,
                    weight: 600,
                    colour: palette.primary,
                  ),
                  const SizedBox(height: 16),
                  BetterText(text: 'Listed doctor', size: 12.0, colour: palette.textSecondary),
                  BetterText(text: widget.clinic.doctorName, size: 14.0, weight: 500, colour: palette.textPrimary),
                  const SizedBox(height: 12),
                  BetterText(text: 'Address', size: 12.0, colour: palette.textSecondary),
                  BetterText(text: widget.clinic.address, size: 14.0, weight: 500, colour: palette.textPrimary),
                  const SizedBox(height: 12),
                  BetterText(text: 'Contact', size: 12.0, colour: palette.textSecondary),
                  BetterText(text: widget.clinic.phone, size: 14.0, colour: palette.textPrimary),
                  BetterText(text: widget.clinic.email, size: 14.0, colour: palette.textPrimary),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _addToSelectedProfile,
                      style: FilledButton.styleFrom(backgroundColor: palette.primary),
                      child: BetterText(
                        text: isAdded
                            ? 'Added to ${currentAccount.activeProfile.name}'
                            : 'Add clinic to ${currentAccount.activeProfile.name}',
                        size: 15.0,
                        weight: 600,
                        colour: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}