import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plans_provider.dart'; 

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        home: const DashboardHome(),
      ),
    );
  }
}

// ==========================================================
// 1. DASHBOARD HOME (Main Container with 5 Tabs)
// ==========================================================
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // Changed from 3 to 5 (Users, Trainers, Admins, Shop, Plans)
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true, // Made scrollable to fit 5 tabs comfortably
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Users"),
              Tab(icon: Icon(Icons.fitness_center), text: "Trainers"),
              Tab(icon: Icon(Icons.admin_panel_settings), text: "Admins"),
              Tab(icon: Icon(Icons.storefront), text: "Shop"), // New Tab
              Tab(icon: Icon(Icons.price_change), text: "Plans"), // New Tab
              Tab(icon: Icon(Icons.message), text: "Messages"), // NEW TAB
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // 1. Users
            _RoleManagementTab(role: 'user', color: Colors.blueAccent),
            // 2. Trainers
            _RoleManagementTab(role: 'trainer', color: Colors.orange),
            // 3. Admins
            _RoleManagementTab(role: 'admin', color: Colors.purple),
            // 4. Shop Manager (Embedded)
            ManageShopTab(),
            // 5. Plans Manager (Embedded)
            AdminPlansTab(),
            // 6. Messages Manager (NEW)
            MessagesTab(),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 2. REUSABLE ROLE MANAGEMENT TAB (Grid Buttons)
// ==========================================================
class _RoleManagementTab extends StatelessWidget {
  final String role; // 'user', 'trainer', or 'admin'
  final Color color;

  const _RoleManagementTab({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    String displayRole = role[0].toUpperCase() + role.substring(1);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            "Manage ${displayRole}s",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                // 1. ADD
                _DashboardCard(
                  icon: Icons.add_circle,
                  title: "Add $displayRole",
                  color: color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GenericAddPage(role: role)),
                  ),
                ),
                // 2. VIEW
                _DashboardCard(
                  icon: Icons.list_alt,
                  title: "View $displayRole",
                  color: color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GenericListPage(role: role, mode: 'view', color: color)),
                  ),
                ),
                // 3. EDIT
                _DashboardCard(
                  icon: Icons.edit,
                  title: "Edit $displayRole",
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GenericListPage(role: role, mode: 'edit', color: Colors.green)),
                  ),
                ),
                // 4. DELETE
                _DashboardCard(
                  icon: Icons.delete_forever,
                  title: "Remove $displayRole",
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GenericListPage(role: role, mode: 'delete', color: Colors.redAccent)),
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _DashboardCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 30, color: color)),
          const SizedBox(height: 15),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ]),
      ),
    );
  }
}

// ==========================================================
// 3. GENERIC PAGES (Add, List, Edit for Users)
// ==========================================================
class GenericAddPage extends StatefulWidget {
  final String role;
  const GenericAddPage({super.key, required this.role});

  @override
  _GenericAddPageState createState() => _GenericAddPageState();
}

class _GenericAddPageState extends State<GenericAddPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> addEntity() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (authResponse.user != null) {
        await Supabase.instance.client.from('users').insert({
          'id': authResponse.user!.id,
          'name': nameController.text,
          'email': emailController.text,
          'role': widget.role,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.role.toUpperCase()} Created!")));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayRole = widget.role[0].toUpperCase() + widget.role.substring(1);
    return Scaffold(
      appBar: AppBar(title: Text('Add New $displayRole')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : addEntity,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenericListPage extends StatefulWidget {
  final String role;
  final String mode;
  final Color color;

  const GenericListPage({super.key, required this.role, required this.mode, required this.color});

  @override
  _GenericListPageState createState() => _GenericListPageState();
}

class _GenericListPageState extends State<GenericListPage> {
  List<Map<String, dynamic>> _dataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('role', widget.role)
          .order('name', ascending: true);

      if (mounted) setState(() { _dataList = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Permanently"),
        content: Text("Delete ${item['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Supabase.instance.client.rpc('admin_delete_user', params: {'target_user_id': item['id']});
                _fetchData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.mode.toUpperCase()} ${widget.role}s"), backgroundColor: widget.color),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dataList.isEmpty
              ? Center(child: Text("No ${widget.role}s found"))
              : ListView.builder(
                  itemCount: _dataList.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final item = _dataList[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(item['name'] ?? 'Unknown'),
                        subtitle: Text(item['email'] ?? 'No Email'),
                        trailing: widget.mode == 'view'
                            ? null
                            : Icon(widget.mode == 'edit' ? Icons.edit : Icons.delete, color: widget.color),
                        onTap: () {
                          if (widget.mode == 'edit') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserForm(user: item))).then((_) => _fetchData());
                          } else if (widget.mode == 'delete') {
                            _deleteItem(item);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class EditUserForm extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditUserForm({super.key, required this.user});

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['name']);
    emailController = TextEditingController(text: widget.user['email']);
  }

  Future<void> updateUser() async {
    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.rpc('admin_update_user', params: {
        'target_user_id': widget.user['id'],
        'new_email': emailController.text.trim(),
        'new_name': nameController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated Successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Details"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 4. MANAGE SHOP TAB (Embeddable List Items)
// ==========================================================
class ManageShopTab extends StatefulWidget {
  const ManageShopTab({super.key});
  @override
  _ManageShopTabState createState() => _ManageShopTabState();
}

class _ManageShopTabState extends State<ManageShopTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('supplements')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) setState(() { _items = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await Supabase.instance.client.from('supplements').delete().eq('id', id);
      _fetchItems();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item deleted!")));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: Used Scaffold to allow FloatingActionButton for the tab
    return Scaffold(
      backgroundColor: Colors.transparent, // Match parent background
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditItemPage()));
          _fetchItems();
        },
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _items.isEmpty 
          ? const Center(child: Text("No items yet. Add one!"))
          : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image_url'], 
                      width: 50, height: 50, fit: BoxFit.cover, 
                      errorBuilder: (c,e,s) => const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item['id']),
                  ),
                  onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditItemPage(item: item)));
                      _fetchItems();
                  },
                ),
              );
            },
          ),
    );
  }
}

// ==========================================================
// 5. SHOP: ADD / EDIT ITEM PAGE
// ==========================================================
class AddEditItemPage extends StatefulWidget {
  final Map<String, dynamic>? item; 
  const AddEditItemPage({super.key, this.item});

  @override
  _AddEditItemPageState createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _nameController = TextEditingController();
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!['title'];
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name required")));
      return;
    }
    
    if (widget.item == null && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please pick an image")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? imageUrl = widget.item?['image_url'];

      if (_imageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('shop_images')
            .uploadBinary(fileName, _imageBytes!);
            
        imageUrl = Supabase.instance.client.storage
            .from('shop_images')
            .getPublicUrl(fileName);
      }

      if (widget.item == null) {
        await Supabase.instance.client.from('supplements').insert({
          'title': _nameController.text,
          'image_url': imageUrl,
        });
      } else {
        await Supabase.instance.client.from('supplements').update({
          'title': _nameController.text,
          'image_url': imageUrl,
        }).eq('id', widget.item!['id']);
      }
      
      if(mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success!")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? "Add Item" : "Edit Item"), backgroundColor: Colors.purple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
                child: _imageBytes != null 
                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                  : (widget.item != null 
                      ? Image.network(widget.item!['image_url'], fit: BoxFit.cover)
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50, color: Colors.grey), Text("Tap to add photo")])),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Supplement Name", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _save,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Item"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 6. ADMIN PLANS TAB (Embedded Plan List)
// ==========================================================
class AdminPlansTab extends ConsumerWidget {
  const AdminPlansTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider);

    // Using Scaffold here only for body structure, no AppBar
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Current Price: \$${plan.price}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.indigo),
                      onPressed: () {
                        _showEditDialog(context, ref, plan);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Plan plan) {
    final controller = TextEditingController(text: plan.price.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit ${plan.title}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New Price", prefixText: "\$ "),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                ref.read(plansProvider.notifier).updatePrice(plan.title, val);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}

// ==========================================================
// 7. MESSAGES TAB (View Contact Us Messages)
// ==========================================================
class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('contact_messages') // Ensure this table exists
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC: SEND REPLY ---
  Future<void> _sendReply(String userId, String replyText) async {
    try {
      await Supabase.instance.client.from('notifications').insert({
        'user_id': userId, // Send specifically to this user
        'title': 'Admin Reply',
        'body': replyText,
      });
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reply sent!")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showReplyDialog(Map<String, dynamic> msg) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Reply to ${msg['full_name'] ?? 'User'}"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Type your reply here...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // Ensure the message has a user_id to reply to
              if (msg['user_id'] != null) {
                _sendReply(msg['user_id'], controller.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot reply: No User ID found on this message.")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            child: const Text("Send"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(child: Text("No messages"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ExpansionTile(
                        leading: const CircleAvatar(child: Icon(Icons.email)),
                        title: Text(msg['full_name'] ?? 'Unknown'),
                        subtitle: Text(msg['message'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        childrenPadding: const EdgeInsets.all(16),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Full Message: ${msg['message']}")
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // --- REPLY BUTTON ---
                              ElevatedButton.icon(
                                icon: const Icon(Icons.reply, size: 18),
                                label: const Text("Reply"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                                onPressed: () => _showReplyDialog(msg),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}