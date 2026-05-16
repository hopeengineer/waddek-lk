import 'dart:async';

import 'package:flutter/material.dart';

import '../services/places_service.dart';
import '../theme/app_colors.dart';

/// Text field with Google-Places-backed address suggestions. Drops
/// the chosen prediction's coordinates back to the parent via
/// [onSelected] so the caller can stash them alongside the address
/// string. Suggestions render inline below the field (no overlay)
/// so it composes cleanly inside bottom sheets and scroll views.
class AddressLookupField extends StatefulWidget {
  const AddressLookupField({
    super.key,
    required this.controller,
    required this.onSelected,
    this.label = 'Address',
    this.hint = 'Start typing your address',
    this.enabled = true,
  });

  final TextEditingController controller;
  final void Function(String address, double lat, double lng) onSelected;
  final String label;
  final String hint;
  final bool enabled;

  @override
  State<AddressLookupField> createState() => _AddressLookupFieldState();
}

class _AddressLookupFieldState extends State<AddressLookupField> {
  Timer? _debounce;
  List<PlacePrediction> _suggestions = const [];
  bool _loading = false;
  // Set whenever we write to the controller programmatically (after
  // a prediction is picked or after Detect-location pre-fills the
  // address) so the keystroke listener doesn't kick off another
  // search against the just-injected text.
  bool _suppressNext = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged() {
    if (_suppressNext) {
      _suppressNext = false;
      return;
    }
    _debounce?.cancel();
    final q = widget.controller.text.trim();
    if (q.length < 2) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = const []);
      }
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (!mounted) return;
    setState(() => _loading = true);
    List<PlacePrediction> results = const [];
    String? err;
    try {
      results = await PlacesService.autocomplete(q);
    } on PlacesException catch (e) {
      err = e.message;
    } catch (e) {
      err = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _loading = false;
    });
    // Surface autocomplete failures only on the first attempt
    // (i.e. when no results were already showing) so we don't
    // spam the user with a snackbar on every keystroke.
    if (err != null && results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address lookup failed: $err')),
      );
    }
  }

  Future<void> _pick(PlacePrediction p) async {
    try {
      final details = await PlacesService.details(p.placeId);
      if (details == null || !mounted) return;
      _suppressNext = true;
      widget.controller.text = details.formattedAddress;
      widget.controller.selection = TextSelection.collapsed(
          offset: details.formattedAddress.length);
      setState(() => _suggestions = const []);
      widget.onSelected(details.formattedAddress, details.lat, details.lng);
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t resolve that address: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          style: const TextStyle(color: AppColors.textPrimary),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon:
                const Icon(Icons.home, color: AppColors.neonCyan),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.neonCyan),
                    ),
                  )
                : null,
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.neonCyan.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _suggestions.length; i++) ...[
                  if (i > 0)
                    const Divider(
                        height: 1, color: Color(0x22FFFFFF), thickness: 0.5),
                  InkWell(
                    onTap: () => _pick(_suggestions[i]),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.neonCyan, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _suggestions[i].description,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
