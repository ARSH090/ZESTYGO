import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddressItem {
  AddressItem({
    required this.id,
    required this.title,
    required this.addressLine,
    required this.tag,
    this.isDefault = false,
  });

  final String id;
  String title;
  String addressLine;
  String tag; // 'Home', 'Work', 'Other'
  bool isDefault;
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<AddressItem> _addresses = [
    AddressItem(
      id: 'addr_1',
      title: 'Home',
      addressLine: 'Flat 402, Sunshine Heights, 12th Main, Indiranagar, Bengaluru - 560038',
      tag: 'Home',
      isDefault: true,
    ),
    AddressItem(
      id: 'addr_2',
      title: 'Work / Office',
      addressLine: 'Desk 4B, 3rd Floor, WeWork Galaxy, Residency Road, Bengaluru - 560025',
      tag: 'Work',
      isDefault: false,
    ),
    AddressItem(
      id: 'addr_3',
      title: 'Gym & Fitness',
      addressLine: 'Cult.fit Indiranagar, 100ft Road, Defence Colony, Bengaluru - 560038',
      tag: 'Other',
      isDefault: false,
    ),
  ];

  void _showAddAddressDialog([AddressItem? existing]) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final lineController = TextEditingController(text: existing?.addressLine ?? '');
    String selectedTag = existing?.tag ?? 'Home';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZestyColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZestyRadius.sheet)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: ZestySpacing.lg,
                right: ZestySpacing.lg,
                top: ZestySpacing.lg,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + ZestySpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing == null ? 'Add Delivery Address' : 'Edit Address',
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: ZestyColors.textMuted),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Tag selector
                  Row(
                    children: ['Home', 'Work', 'Other'].map((tag) {
                      final isSelected = selectedTag == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: ZestyColors.primary,
                          backgroundColor: ZestyColors.glassPill,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : ZestyColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedTag = tag);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: ZestyColors.textLight),
                    decoration: InputDecoration(
                      labelText: 'Address Label (e.g. My Apartment, Mom\'s House)',
                      labelStyle: const TextStyle(color: ZestyColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFF1B171D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ZestyColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lineController,
                    maxLines: 3,
                    style: const TextStyle(color: ZestyColors.textLight),
                    decoration: InputDecoration(
                      labelText: 'Complete Address (Flat, Street, Landmark, Pincode)',
                      labelStyle: const TextStyle(color: ZestyColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFF1B171D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ZestyColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (lineController.text.trim().isEmpty) return;
                        setState(() {
                          if (existing != null) {
                            existing.title = titleController.text.trim().isEmpty
                                ? selectedTag
                                : titleController.text.trim();
                            existing.addressLine = lineController.text.trim();
                            existing.tag = selectedTag;
                          } else {
                            _addresses.add(
                              AddressItem(
                                id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                                title: titleController.text.trim().isEmpty
                                    ? selectedTag
                                    : titleController.text.trim(),
                                addressLine: lineController.text.trim(),
                                tag: selectedTag,
                                isDefault: _addresses.isEmpty,
                              ),
                            );
                          }
                        });
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existing == null
                                  ? 'New address saved successfully!'
                                  : 'Address updated!',
                            ),
                          ),
                        );
                      },
                      child: Text(existing == null ? 'Save Address' : 'Update Address'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _setDefault(String id) {
    setState(() {
      for (final a in _addresses) {
        a.isDefault = (a.id == id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default delivery address updated')),
    );
  }

  void _deleteAddress(String id) {
    setState(() {
      _addresses.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        children: [
          // Add address button
          InkWell(
            onTap: () => _showAddAddressDialog(),
            borderRadius: BorderRadius.circular(ZestyRadius.card),
            child: Container(
              padding: const EdgeInsets.all(ZestySpacing.md),
              decoration: BoxDecoration(
                color: ZestyColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(ZestyRadius.card),
                border: Border.all(color: ZestyColors.primary.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_location_alt_rounded, color: ZestyColors.primary),
                  SizedBox(width: 8),
                  Text(
                    '+ Add New Delivery Address',
                    style: TextStyle(
                      color: ZestyColors.primaryAmber,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_addresses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No saved addresses. Add your home or office address to proceed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ZestyColors.textMuted),
                ),
              ),
            )
          else
            ..._addresses.map((addr) {
              IconData tagIcon = Icons.home_rounded;
              if (addr.tag == 'Work') tagIcon = Icons.work_rounded;
              if (addr.tag == 'Other') tagIcon = Icons.place_rounded;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ZestyGlassCard(
                  borderColor: addr.isDefault
                      ? ZestyColors.primary.withValues(alpha: 0.6)
                      : ZestyColors.glassBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(tagIcon, color: ZestyColors.primaryAmber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            addr.title,
                            style: const TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (addr.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ZestyColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: ZestyColors.primaryAmber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        addr.addressLine,
                        style: const TextStyle(
                          color: ZestyColors.textMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!addr.isDefault)
                            TextButton(
                              onPressed: () => _setDefault(addr.id),
                              child: const Text(
                                'Set as Default',
                                style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 12),
                              ),
                            ),
                          TextButton(
                            onPressed: () => _showAddAddressDialog(addr),
                            child: const Text('Edit', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: () => _deleteAddress(addr.id),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
