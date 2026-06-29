import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

// ==========================================
// KHOPKHUA THEME COLORS (ຈາກໂລໂກ້)
// ==========================================
class KhopkhuaColors {
  static const navy     = Color(0xFF0D1B3E);   // Navy Blue ເຂັ້ມ
  static const navyMid  = Color(0xFF1A2F5E);   // Navy ກາງ
  static const navyLight= Color(0xFF243B73);   // Navy ອ່ອນ
  static const emerald  = Color(0xFF0F6E56);   // Emerald Green
  static const emeraldL = Color(0xFF1D9E75);   // Emerald ອ່ອນ
  static const gold     = Color(0xFFD4AF37);   // Gold ຕົ້ນຕໍ
  static const goldL    = Color(0xFFF0C040);   // Gold ສະຫວ່າງ
  static const goldD    = Color(0xFFA88820);   // Gold ເຂັ້ມ
  static const cream    = Color(0xFFFFF8E7);   // Cream ສຳລັບ text
  static const white    = Color(0xFFFFFFFF);
}

// ==========================================
// KHOPKHUA SCREEN
// ==========================================
class KhopkhuaScreen extends StatefulWidget {
  const KhopkhuaScreen({super.key});
  @override
  State<KhopkhuaScreen> createState() => _KhopkhuaScreenState();
}

class _KhopkhuaScreenState extends State<KhopkhuaScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabCtrl;
  final List<PropertyListing> _listings = [];
  final _formKey = GlobalKey<FormState>();
  final _shareKey = GlobalKey();

  // Form controllers
  final _titleCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _areaCtrl     = TextEditingController();
  final _villageCtrl  = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();

  String _propType = 'ດິນ';
  String _priceUnit = 'ລ້ານກີບ';
  XFile? _pickedImage;
  bool _sharing = false;

  final _types = ['ດິນ', 'ເຮືອນ', 'ຕຶກແຖວ', 'ອາພາດເມັ້ນ', 'ຄອນໂດ', 'ສວນ'];
  final _units = ['ລ້ານກີບ', 'ພັນລ້ານກີບ', 'ລ້ານບາດ', 'USD'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadSampleListings();
  }

  void _loadSampleListings() {
    _listings.addAll([
      PropertyListing(
        id: '1', title: 'ດິນ ໂນນທອງ', type: 'ດິນ',
        location: 'ເມືອງໄຊທານີ', village: 'ບ້ານໂນນທອງ',
        price: '850', unit: 'ລ້ານກີບ', area: '500 ຕ.ມ.',
        phone: '+856 20 777 77421', description: 'ດິນ 2 ໜ້າ ຕິດຖະໜົນໃຫຍ່',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PropertyListing(
        id: '2', title: 'ເຮືອນ 2 ຊັ້ນ', type: 'ເຮືອນ',
        location: 'ເມືອງໄຊເສດຖາ', village: 'ບ້ານສີສ່ວນ',
        price: '1.2', unit: 'ພັນລ້ານກີບ', area: '200 ຕ.ວ.',
        phone: '+856 20 555 12345', description: '3 ຫ້ອງນອນ 2 ຫ້ອງນ້ຳ ຕົບແຕ່ງໃໝ່',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KhopkhuaColors.navy,
      body: Column(children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [_buildListingsTab(), _buildAddTab(), _buildStatsTab()],
          ),
        ),
      ]),
    );
  }

  // ── HEADER ──────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: KhopkhuaColors.navyMid,
        border: Border(bottom: BorderSide(color: KhopkhuaColors.gold, width: 1.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            // Logo
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: KhopkhuaColors.gold, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/khopkhua_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: KhopkhuaColors.navy,
                    child: const Icon(Icons.home, color: KhopkhuaColors.gold, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ຄອບຄົວ ອະສັງຫາ', style: TextStyle(
                  color: KhopkhuaColors.gold, fontSize: 16, fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                )),
                const Text('Khopkhua Real Estate', style: TextStyle(
                  color: KhopkhuaColors.emeraldL, fontSize: 11,
                )),
              ]),
            ),
            // Online badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: KhopkhuaColors.emerald.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KhopkhuaColors.emeraldL, width: 0.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(
                  color: KhopkhuaColors.emeraldL, shape: BoxShape.circle,
                )),
                const SizedBox(width: 4),
                const Text('Online', style: TextStyle(color: KhopkhuaColors.emeraldL, fontSize: 10)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── TABS ────────────────────────────────
  Widget _buildTabs() {
    return Container(
      color: KhopkhuaColors.navyMid,
      child: TabBar(
        controller: _tabCtrl,
        labelColor: KhopkhuaColors.gold,
        unselectedLabelColor: KhopkhuaColors.white.withOpacity(0.4),
        indicatorColor: KhopkhuaColors.gold,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: 'ຊັບທັງໝົດ (${_listings.length})'),
          const Tab(text: '+ ເພີ່ມຊັບ'),
          const Tab(text: 'ສະຖິຕິ'),
        ],
      ),
    );
  }

  // ── LISTINGS TAB ────────────────────────
  Widget _buildListingsTab() {
    if (_listings.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.home_outlined, color: KhopkhuaColors.gold.withOpacity(0.4), size: 64),
        const SizedBox(height: 12),
        Text('ຍັງບໍ່ມີຊັບ', style: TextStyle(color: KhopkhuaColors.white.withOpacity(0.5), fontSize: 16)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _tabCtrl.animateTo(1),
          child: const Text('+ ເພີ່ມຊັບໃໝ່', style: TextStyle(color: KhopkhuaColors.gold)),
        ),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _listings.length,
      itemBuilder: (ctx, i) => _buildListingCard(_listings[i]),
    );
  }

  Widget _buildListingCard(PropertyListing p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: KhopkhuaColors.navyMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KhopkhuaColors.gold.withOpacity(0.3), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Card header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KhopkhuaColors.navyLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: KhopkhuaColors.emerald,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(p.type, style: const TextStyle(color: KhopkhuaColors.cream, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(p.title, style: const TextStyle(
              color: KhopkhuaColors.gold, fontSize: 15, fontWeight: FontWeight.w600,
            ))),
          ]),
        ),
        // Card body
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _infoRow(Icons.location_on_outlined, p.location + ' · ' + p.village),
            const SizedBox(height: 6),
            _infoRow(Icons.straighten, p.area),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, p.phone),
            if (p.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.notes, p.description),
            ],
            const SizedBox(height: 10),
            Row(children: [
              // Price
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KhopkhuaColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${p.price} ${p.unit}', style: const TextStyle(
                  color: KhopkhuaColors.navy, fontSize: 13, fontWeight: FontWeight.w700,
                )),
              ),
              const Spacer(),
              // Share to Facebook
              _shareButton(p),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: KhopkhuaColors.gold.withOpacity(0.7), size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(color: KhopkhuaColors.white.withOpacity(0.75), fontSize: 12))),
    ]);
  }

  Widget _shareButton(PropertyListing p) {
    return GestureDetector(
      onTap: () => _shareToFacebook(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1877F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.share, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          const Text('ໂພສ FB', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ── ADD PROPERTY TAB ────────────────────
  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('ປະເພດຊັບ'),
          _typeSelector(),
          const SizedBox(height: 16),
          _sectionLabel('ຊື່ຊັບ / ຫົວຂໍ້'),
          _goldField(_titleCtrl, 'ເຊັ່ນ: ດິນ ໂນນທອງ ໄຊທານີ', required: true),
          const SizedBox(height: 12),
          _sectionLabel('ທີ່ຕັ້ງ (ເມືອງ)'),
          _goldField(_locationCtrl, 'ເຊັ່ນ: ເມືອງໄຊທານີ ນະຄອນຫຼວງ', required: true),
          const SizedBox(height: 12),
          _sectionLabel('ບ້ານ'),
          _goldField(_villageCtrl, 'ເຊັ່ນ: ບ້ານໂນນທອງ'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('ລາຄາ'),
              _goldField(_priceCtrl, '850', keyboardType: TextInputType.number, required: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('ໜ່ວຍ'),
              _unitSelector(),
            ])),
          ]),
          const SizedBox(height: 12),
          _sectionLabel('ເນື້ອທີ່'),
          _goldField(_areaCtrl, 'ເຊັ່ນ: 500 ຕ.ມ. ຫຼື 2 ໜ້າ'),
          const SizedBox(height: 12),
          _sectionLabel('ເບີໂທຕິດຕໍ່'),
          _goldField(_phoneCtrl, '+856 20 xxx xxx xx', keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _sectionLabel('ລາຍລະອຽດ'),
          _goldField(_descCtrl, 'ລາຍລະອຽດຊັບ...', maxLines: 3),
          const SizedBox(height: 12),
          _sectionLabel('ຮູບຊັບ (ສຳລັບ Watermark)'),
          _imagePickerButton(),
          const SizedBox(height: 24),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: KhopkhuaColors.gold,
                foregroundColor: KhopkhuaColors.navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('ບັນທຶກ + ໂພສ Facebook', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
              )),
            ),
          ),
          const SizedBox(height: 8),
          // Note about watermark
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KhopkhuaColors.emerald.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: KhopkhuaColors.emeraldL.withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.branding_watermark, color: KhopkhuaColors.emeraldL, size: 14),
              SizedBox(width: 6),
              Expanded(child: Text(
                'Watermark ໂລໂກ້ Khopkhua ຈະຖືກໃສ່ອັດຕະໂນມັດ',
                style: TextStyle(color: KhopkhuaColors.emeraldL, fontSize: 11),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(
        color: KhopkhuaColors.gold, fontSize: 12, fontWeight: FontWeight.w500,
      )),
    );
  }

  Widget _goldField(TextEditingController ctrl, String hint, {
    int maxLines = 1, TextInputType? keyboardType, bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: KhopkhuaColors.cream, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: KhopkhuaColors.white.withOpacity(0.3), fontSize: 13),
        filled: true,
        fillColor: KhopkhuaColors.navyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: KhopkhuaColors.gold.withOpacity(0.3), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: KhopkhuaColors.gold.withOpacity(0.3), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: KhopkhuaColors.gold, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'ກະລຸນາໃສ່ຂໍ້ມູນ' : null : null,
    );
  }

  Widget _typeSelector() {
    return Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
      final sel = t == _propType;
      return GestureDetector(
        onTap: () => setState(() => _propType = t),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? KhopkhuaColors.gold : KhopkhuaColors.navyLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? KhopkhuaColors.gold : KhopkhuaColors.gold.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(t, style: TextStyle(
            color: sel ? KhopkhuaColors.navy : KhopkhuaColors.white.withOpacity(0.7),
            fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
          )),
        ),
      );
    }).toList());
  }

  Widget _unitSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: KhopkhuaColors.navyLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KhopkhuaColors.gold.withOpacity(0.3), width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _priceUnit,
          dropdownColor: KhopkhuaColors.navyMid,
          style: const TextStyle(color: KhopkhuaColors.cream, fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          isExpanded: true,
          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
          onChanged: (v) => setState(() => _priceUnit = v!),
        ),
      ),
    );
  }

  Widget _imagePickerButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: KhopkhuaColors.navyLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: KhopkhuaColors.gold.withOpacity(0.4),
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
        child: _pickedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover, width: double.infinity),
              )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_outlined, color: KhopkhuaColors.gold.withOpacity(0.5), size: 32),
                const SizedBox(height: 6),
                Text('ເລືອກຮູບຊັບ', style: TextStyle(color: KhopkhuaColors.white.withOpacity(0.4), fontSize: 12)),
              ]),
      ),
    );
  }

  // ── STATS TAB ───────────────────────────
  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _statGrid(),
        const SizedBox(height: 16),
        _recentActivity(),
      ]),
    );
  }

  Widget _statGrid() {
    final stats = [
      ('ຊັບທັງໝົດ', '${_listings.length}', KhopkhuaColors.gold),
      ('ດິນ', '${_listings.where((l)=>l.type=='ດິນ').length}', KhopkhuaColors.emeraldL),
      ('ເຮືອນ', '${_listings.where((l)=>l.type=='ເຮືອນ').length}', KhopkhuaColors.goldL),
      ('ອື່ນໆ', '${_listings.where((l)=>l.type!='ດິນ'&&l.type!='ເຮືອນ').length}', KhopkhuaColors.emerald),
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2,
      children: stats.map((s) => Container(
        decoration: BoxDecoration(
          color: KhopkhuaColors.navyMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: s.$3.withOpacity(0.3), width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(s.$2, style: TextStyle(color: s.$3, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(s.$1, style: TextStyle(color: KhopkhuaColors.white.withOpacity(0.5), fontSize: 11)),
        ]),
      )).toList(),
    );
  }

  Widget _recentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: KhopkhuaColors.navyMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KhopkhuaColors.gold.withOpacity(0.2), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: const Text('ກິດຈະກຳລ່າສຸດ', style: TextStyle(
            color: KhopkhuaColors.gold, fontSize: 13, fontWeight: FontWeight.w500,
          )),
        ),
        const Divider(color: Color(0x1AFFD700), height: 1),
        ..._listings.take(5).map((p) => ListTile(
          dense: true,
          leading: Container(
            width: 32, height: 32, decoration: BoxDecoration(
              color: KhopkhuaColors.emerald.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_outlined, color: KhopkhuaColors.emeraldL, size: 16),
          ),
          title: Text(p.title, style: const TextStyle(color: KhopkhuaColors.cream, fontSize: 12)),
          subtitle: Text('${p.price} ${p.unit}', style: const TextStyle(color: KhopkhuaColors.gold, fontSize: 11)),
          trailing: Text(_timeAgo(p.createdAt), style: TextStyle(color: KhopkhuaColors.white.withOpacity(0.4), fontSize: 10)),
        )),
      ]),
    );
  }

  // ── ACTIONS ─────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) setState(() => _pickedImage = img);
  }

  void _submitProperty() {
    if (!_formKey.currentState!.validate()) return;
    final prop = PropertyListing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text,
      type: _propType,
      location: _locationCtrl.text,
      village: _villageCtrl.text,
      price: _priceCtrl.text,
      unit: _priceUnit,
      area: _areaCtrl.text,
      phone: _phoneCtrl.text,
      description: _descCtrl.text,
      createdAt: DateTime.now(),
    );
    setState(() => _listings.insert(0, prop));
    _shareToFacebook(prop);
    _tabCtrl.animateTo(0);
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('ບັນທຶກ + ສ້າງໂພສ Facebook ສຳເລັດ ✅'),
      backgroundColor: KhopkhuaColors.emerald,
    ));
  }

  void _clearForm() {
    _titleCtrl.clear(); _locationCtrl.clear(); _priceCtrl.clear();
    _areaCtrl.clear(); _villageCtrl.clear(); _phoneCtrl.clear();
    _descCtrl.clear();
    setState(() { _pickedImage = null; _propType = 'ດິນ'; });
  }

  Future<void> _shareToFacebook(PropertyListing p) async {
    // ສ້າງ caption ພ້ອມ watermark text ສຳລັບ Facebook
    final caption = '''
🏠 ${p.type.toUpperCase()} — ຂາຍດ່ວນ!

📍 ທີ່ຕັ້ງ: ${p.location}${p.village.isNotEmpty ? ' · ${p.village}' : ''}
📐 ເນື້ອທີ່: ${p.area.isNotEmpty ? p.area : 'ຕ້ອງການລາຍລະອຽດ'}
💰 ລາຄາ: ${p.price} ${p.unit}
📞 ຕິດຕໍ່: ${p.phone.isNotEmpty ? p.phone : 'ຕ້ອງການໂທຫາ'}

${p.description.isNotEmpty ? '📝 ${p.description}\n\n' : ''}🏢 ຄອບຄົວ ອະສັງຫາ | Khopkhua Real Estate
📲 ຕິດຕໍ່ທີມງານ 24/7
#KhopkhuaRealEstate #ຄອບຄົວອະສັງຫາ #ຂາຍດິນ #ຂາຍບ້ານ #ອະສັງຫາລາວ
''';

    if (_pickedImage != null) {
      // ໂພສຮູບ + text
      await Share.shareXFiles(
        [XFile(_pickedImage!.path)],
        text: caption,
        subject: 'ຂາຍ ${p.type} — Khopkhua Real Estate',
      );
    } else {
      // ໂພສ text ເທົ່ານັ້ນ
      await Share.share(caption, subject: 'ຂາຍ ${p.type} — Khopkhua Real Estate');
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} ນາທີ';
    if (diff.inHours < 24) return '${diff.inHours} ຊົ່ວໂມງ';
    return '${diff.inDays} ວັນ';
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose(); _locationCtrl.dispose(); _priceCtrl.dispose();
    _areaCtrl.dispose(); _villageCtrl.dispose(); _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}

// ==========================================
// DATA MODEL
// ==========================================
class PropertyListing {
  final String id, title, type, location, village, price, unit, area, phone, description;
  final DateTime createdAt;
  final String? imagePath;

  const PropertyListing({
    required this.id, required this.title, required this.type,
    required this.location, required this.village, required this.price,
    required this.unit, required this.area, required this.phone,
    required this.description, required this.createdAt, this.imagePath,
  });
}
