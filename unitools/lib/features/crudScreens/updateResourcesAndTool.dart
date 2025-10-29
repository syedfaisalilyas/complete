import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/utils/constants/sizes.dart';

class UpdateResourcesAndToolsScreen extends StatefulWidget {
  const UpdateResourcesAndToolsScreen({super.key});

  @override
  State<UpdateResourcesAndToolsScreen> createState() =>
      _UpdateResourcesAndToolsState();
}

class _UpdateResourcesAndToolsState
    extends State<UpdateResourcesAndToolsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> categories = ["Buy", "Borrow"];
  final List<String> conditions = ["New", "Like New", "Used", "Needs Repair"];

  bool _isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final snap = await _firestore.collection("products").get();
      setState(() {
        _products = snap.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching products: $e")),
      );
    }
  }

  /// ✅ Show confirmation before deleting
  Future<void> _confirmDelete(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Product"),
        content: Text(
          "Are you sure you want to delete \"$name\"?",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteProduct(docId);
    }
  }

  /// ✅ Delete product after confirmation
  Future<void> _deleteProduct(String docId) async {
    try {
      await _firestore.collection("products").doc(docId).delete();
      _showSuccessDialog("Product deleted successfully!");
      _fetchProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting product: $e")),
      );
    }
  }

  /// Update Modal
  void _showUpdateModal(String docId, Map<String, dynamic> item) {
    final nameCtrl = TextEditingController(text: item["name"]);
    final descCtrl = TextEditingController(text: item["description"]);
    final priceCtrl = TextEditingController(text: item["price"]?.toString() ?? "");
    final stockCtrl = TextEditingController(text: item["stock"]?.toString() ?? "");
    final imageCtrl = TextEditingController(text: item["image"] ?? "");

    String selectedCategory = item["category"] ?? categories.first;
    String selectedCondition = item["condition"] ?? conditions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: TSizes.lg,
                left: TSizes.lg,
                right: TSizes.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + TSizes.lg,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Update Resource",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: TSizes.md),
                    _buildTextField("Product Name", nameCtrl),
                    const SizedBox(height: TSizes.md),
                    _buildTextField("Description", descCtrl, maxLines: 3),
                    const SizedBox(height: TSizes.md),
                    _buildDropdown(
                      "Category",
                      categories,
                      selectedCategory,
                          (val) => setModalState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: TSizes.md),
                    _buildTextField("Price", priceCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: TSizes.md),
                    _buildTextField("Stock Quantity", stockCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: TSizes.md),
                    _buildDropdown(
                      "Condition",
                      conditions,
                      selectedCondition,
                          (val) => setModalState(() => selectedCondition = val!),
                    ),
                    const SizedBox(height: TSizes.md),
                    _buildTextField("Image URL", imageCtrl),
                    const SizedBox(height: TSizes.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: "Update",
                            onPressed: () async {
                              final updatedData = {
                                "name": nameCtrl.text,
                                "description": descCtrl.text,
                                "category": selectedCategory,
                                "price":
                                double.tryParse(priceCtrl.text) ?? 0.0,
                                "stock": int.tryParse(stockCtrl.text) ?? 0,
                                "condition": selectedCondition,
                                "image": imageCtrl.text,
                              };

                              try {
                                await _firestore
                                    .collection("products")
                                    .doc(docId)
                                    .update(updatedData);
                                Navigator.pop(context);
                                _showSuccessDialog("Product updated successfully!");
                                _fetchProducts();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 60),
              const SizedBox(height: 16),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
      items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildAvatar(String name, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(imageUrl));
    }
    String initials = name.isNotEmpty ? name[0].toUpperCase() : "NA";
    return CircleAvatar(
      backgroundColor: Colors.deepPurple,
      child: Text(
        initials,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: TSizes.lg),
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _products.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final doc = _products[index];
                      final item = doc.data();

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin:
                        const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            leading: _buildAvatar(
                                item["name"] ?? "", item["image"]),
                            title: Text(item["name"] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            subtitle: Padding(
                              padding:
                              const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Price: ${item["price"] ?? 0} | Stock: ${item["stock"] ?? 0} | ${item["condition"] ?? ""}",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.deepPurple),
                                  onPressed: () => _showUpdateModal(
                                      doc.id, item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(
                                      doc.id, item["name"] ?? ""),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: TSizes.md),
          const Expanded(
            child: Text(
              "Update Resources & Tools",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
