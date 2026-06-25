// lib/screens/owner/owner_products_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';

const Color _kPlaceholderIconColor = Color(0xFF81C784);

class OwnerProductsScreen extends StatefulWidget {
  const OwnerProductsScreen({super.key});

  @override
  State<OwnerProductsScreen> createState() => _OwnerProductsScreenState();
}

class _OwnerProductsScreenState extends State<OwnerProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      _products = await MockDataService.instance.getProducts();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '📦 Inventory Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.price_change_rounded, color: Colors.green),
            onPressed: () => _showBulkPriceDialog(context),
            tooltip: 'Bulk Price Update',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProductList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Product List ──────────────────────────────────────────────────────────

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No products found',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Tap the + button to add your first product',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _ProductCard(
          product: _products[index],
          onRefresh: _loadProducts,
          onDelete: _deleteProduct,
        );
      },
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await MockDataService.instance.deleteProduct(product.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ "${product.name}" deleted'),
          backgroundColor: Colors.green,
        ));
        _loadProducts();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Add Product Dialog ────────────────────────────────────────────────────

  void _showAddProductDialog(BuildContext context) {
    final nameController    = TextEditingController();
    final priceController   = TextEditingController();
    final stockController   = TextEditingController();
    final unitController    = TextEditingController();
    final originController  = TextEditingController();
    final qualityController = TextEditingController();

    File? selectedImage;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('🆕 Add New Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Image Picker ─────────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 300,
                        maxHeight: 300,
                      );
                      if (image != null) {
                        setDialogState(
                            () => selectedImage = File(image.path));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text('Tap to select product image',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Fields ────────────────────────────────────────────────
                  _dialogField(nameController,    'Product Name *',   Icons.label_rounded),
                  const SizedBox(height: 12),
                  _dialogField(priceController,   'Price (Rs.) *',    Icons.payments_outlined,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _dialogField(stockController,   'Stock Quantity *', Icons.inventory_2_rounded,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _dialogField(unitController,    'Unit *',           Icons.scale_rounded),
                  const SizedBox(height: 8),

                  // ── Quick unit chips ──────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    children: ['kg', 'bunch', 'dozen', 'piece', 'gram']
                        .map((u) => ActionChip(
                              label: Text(u),
                              onPressed: () => unitController.text = u,
                              backgroundColor: Colors.green.shade50,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  _dialogField(originController,  'Origin (optional)',  Icons.location_on_rounded),
                  const SizedBox(height: 12),
                  _dialogField(qualityController, 'Quality (optional)', Icons.verified_rounded),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name    = nameController.text.trim();
                  final price   = double.tryParse(priceController.text);
                  final stock   = int.tryParse(stockController.text);
                  final unit    = unitController.text.trim();
                  final origin  = originController.text.trim();
                  final quality = qualityController.text.trim();

                  if (name.isEmpty || price == null || stock == null || unit.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please fill all required fields (*)'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }
                  if (price <= 0 || stock < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Price must be > 0 and Stock >= 0'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }

                  final newProduct = Product(
                    id:            'p${DateTime.now().millisecondsSinceEpoch}',
                    name:          name,
                    urduName:      name,
                    price:         price,
                    unit:          unit,
                    stockQuantity: stock,
                    imageUrl:      selectedImage?.path ?? 'assets/images/placeholder.png',
                    vendorId:      'u2',
                    isActive:      true,
                    categoryId:    'cat1',
                    description:   '',
                    origin:        origin.isEmpty  ? 'Local'    : origin,
                    quality:       quality.isEmpty ? 'Standard' : quality,
                    usage:         '',
                  );

                  try {
                    await MockDataService.instance.addProduct(newProduct);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('✅ "$name" added successfully!'),
                      backgroundColor: Colors.green,
                    ));
                    _loadProducts();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to add product: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                child: const Text('Add Product'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Bulk Price Dialog ─────────────────────────────────────────────────────

  void _showBulkPriceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Price Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update all product prices by percentage'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bulkPriceUpdate(context, 10, true),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('+10%'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bulkPriceUpdate(context, 10, false),
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('-10%'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bulkPriceUpdate(context, 20, true),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('+20%'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bulkPriceUpdate(context, 20, false),
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('-20%'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                ),
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkPriceUpdate(
      BuildContext context, double percentage, bool increase) async {
    Navigator.pop(context);
    try {
      final products = await MockDataService.instance.getProducts();
      for (final p in products) {
        final newPrice = increase
            ? p.price + (p.price * percentage / 100)
            : p.price - (p.price * percentage / 100);
        await MockDataService.instance
            .updateProduct(p.copyWith(price: newPrice.roundToDouble()));
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '✅ Prices ${increase ? "increased" : "decreased"} by ${percentage.toInt()}%'),
        backgroundColor: Colors.green,
      ));
      _loadProducts();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update prices: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── Shared helper ─────────────────────────────────────────────────────────

  TextFormField _dialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.onRefresh,
    required this.onDelete,
  });

  final Product                    product;
  final VoidCallback               onRefresh;
  final Future<void> Function(Product) onDelete;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Color _stockColor() {
    if (_product.stockQuantity == 0) return Colors.red;
    if (_product.stockQuantity <= 5) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel() {
    if (_product.stockQuantity == 0) return 'Out of Stock';
    if (_product.stockQuantity <= 5) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── Image ───────────────────────────────────────────────────
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _product.imageUrl.startsWith('/')
                      ? Image.file(File(_product.imageUrl),
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                              Icons.eco_rounded,
                              color: _kPlaceholderIconColor, size: 30))
                      : Image.asset(_product.imageUrl,
                          width: 60, height: 60, fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                              Icons.eco_rounded,
                              color: _kPlaceholderIconColor, size: 30)),
                ),
              ),
              const SizedBox(width: 14),

              // ── Info ─────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _stockColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _stockLabel(),
                            style: TextStyle(
                                color: _stockColor(),
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Rs ',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500)),
                        Text(
                          _product.price.toStringAsFixed(0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green),
                        ),
                        Text('/${_product.unit}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 16),
                        Icon(Icons.inventory_2_rounded,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${_product.stockQuantity} ${_product.unit}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Menu ─────────────────────────────────────────────────────
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_rounded, size: 18, color: Colors.blue),
                        SizedBox(width: 8), Text('Edit Product'),
                      ])),
                  PopupMenuItem(value: 'stock',
                      child: Row(children: [
                        Icon(Icons.inventory_2_rounded, size: 18, color: Colors.orange),
                        SizedBox(width: 8), Text('Update Stock'),
                      ])),
                  PopupMenuItem(value: 'price',
                      child: Row(children: [
                        Icon(Icons.payments_outlined, size: 18, color: Colors.green),
                        SizedBox(width: 8), Text('Update Price'),
                      ])),
                  PopupMenuItem(value: 'toggle',
                      child: Row(children: [
                        Icon(Icons.power_settings_new_rounded, size: 18, color: Colors.orange),
                        SizedBox(width: 8), Text('Toggle Active'),
                      ])),
                  PopupMenuItem(value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                        SizedBox(width: 8), Text('Delete Product'),
                      ])),
                ],
                onSelected: (value) {
                  if (value == 'edit')   _showEditDialog(context);
                  if (value == 'stock')  _showStockDialog(context);
                  if (value == 'price')  _showPriceDialog(context);
                  if (value == 'toggle') _toggleProduct(context);
                  if (value == 'delete') _confirmDelete(context);
                },
              ),
            ],
          ),

          // ── Quick action buttons ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: _quickBtn(Icons.inventory_2_rounded, 'Stock',
                      Colors.orange, () => _showStockDialog(context)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _quickBtn(Icons.payments_outlined, 'Price',
                      Colors.green, () => _showPriceDialog(context)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _quickBtn(Icons.edit_rounded, 'Edit',
                      Colors.blue, () => _showEditDialog(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickBtn(IconData icon, String label, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${_product.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(_product);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Edit Dialog ────────────────────────────────────────────────────────────

  void _showEditDialog(BuildContext context) {
    final nameController    = TextEditingController(text: _product.name);
    final priceController   = TextEditingController(text: _product.price.toString());
    final stockController   = TextEditingController(text: _product.stockQuantity.toString());
    final unitController    = TextEditingController(text: _product.unit);
    final originController  = TextEditingController(text: _product.origin);
    final qualityController = TextEditingController(text: _product.quality);

    File? selectedImage;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('✏️ Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Image Picker ───────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 300,
                          maxHeight: 300);
                      if (image != null) {
                        setDialogState(
                            () => selectedImage = File(image.path));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: selectedImage != null
                            ? Image.file(selectedImage!,
                                fit: BoxFit.cover, width: double.infinity)
                            : _product.imageUrl.startsWith('/')
                                ? Image.file(File(_product.imageUrl),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, _, _) =>
                                        _imagePlaceholder())
                                : Image.asset(_product.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, _, _) =>
                                        _imagePlaceholder()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _field(nameController,    'Product Name *',   Icons.label_rounded),
                  const SizedBox(height: 12),
                  _field(priceController,   'Price (Rs.) *',    Icons.payments_outlined,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _field(stockController,   'Stock Quantity *', Icons.inventory_2_rounded,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _field(unitController,    'Unit *',           Icons.scale_rounded),
                  const SizedBox(height: 12),
                  _field(originController,  'Origin (optional)',  Icons.location_on_rounded),
                  const SizedBox(height: 12),
                  _field(qualityController, 'Quality (optional)', Icons.verified_rounded),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  final newName    = nameController.text.trim();
                  final newPrice   = double.tryParse(priceController.text) ?? 0;
                  final newStock   = int.tryParse(stockController.text) ?? 0;
                  final newUnit    = unitController.text.trim();
                  final newOrigin  = originController.text.trim();
                  final newQuality = qualityController.text.trim();

                  if (newName.isEmpty || newPrice <= 0 || newUnit.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }

                  final updated = _product.copyWith(
                    name:          newName,
                    price:         newPrice,
                    stockQuantity: newStock,
                    unit:          newUnit,
                    imageUrl:      selectedImage?.path ?? _product.imageUrl,
                    description:   '',
                    origin:        newOrigin.isEmpty  ? _product.origin  : newOrigin,
                    quality:       newQuality.isEmpty ? _product.quality : newQuality,
                    usage:         '',
                  );

                  await MockDataService.instance.updateProduct(updated);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('✅ Product updated successfully!'),
                    backgroundColor: Colors.green,
                  ));
                  widget.onRefresh();
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Stock Dialog ───────────────────────────────────────────────────────────

  void _showStockDialog(BuildContext context) {
    final controller =
        TextEditingController(text: _product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product: ${_product.name}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2_rounded),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ActionChip(
                label: const Text('+10'),
                onPressed: () {
                  final c = int.tryParse(controller.text) ?? 0;
                  controller.text = (c + 10).toString();
                },
              ),
              ActionChip(
                label: const Text('+50'),
                onPressed: () {
                  final c = int.tryParse(controller.text) ?? 0;
                  controller.text = (c + 50).toString();
                },
              ),
              ActionChip(
                label: const Text('Set to 0'),
                onPressed: () => controller.text = '0',
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text) ?? 0;
              if (newStock >= 0) {
                await MockDataService.instance
                    .updateProduct(_product.copyWith(stockQuantity: newStock));
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('✅ Stock updated to $newStock ${_product.unit}'),
                  backgroundColor: Colors.green,
                ));
                widget.onRefresh();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ── Price Dialog ───────────────────────────────────────────────────────────

  void _showPriceDialog(BuildContext context) {
    final controller =
        TextEditingController(text: _product.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product: ${_product.name}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (Rs.)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current price: Rs ${_product.price.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final newPrice = double.tryParse(controller.text) ?? 0;
              if (newPrice > 0) {
                await MockDataService.instance
                    .updateProduct(_product.copyWith(price: newPrice));
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '✅ Price updated to Rs ${newPrice.toStringAsFixed(0)}'),
                  backgroundColor: Colors.green,
                ));
                widget.onRefresh();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ── Toggle ─────────────────────────────────────────────────────────────────

  Future<void> _toggleProduct(BuildContext context) async {
    await MockDataService.instance
        .updateProduct(_product.copyWith(isActive: !_product.isActive));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '✅ Product ${_product.isActive ? "deactivated" : "activated"}'),
      backgroundColor: Colors.orange,
    ));
    widget.onRefresh();
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  TextFormField _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_rounded, size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text('Tap to change image',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}