import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

// ==========================================================
// 1. DASHBOARD HOME (Refactored with Tabs)
// ==========================================================
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. DefaultTabController enables the "Slider" logic
    return DefaultTabController(
      length: 3, // User, Trainer, Admin
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          centerTitle: true,
          // 2. The TabBar is the visual slider at the top
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Users"),
              Tab(icon: Icon(Icons.fitness_center), text: "Trainers"),
              Tab(icon: Icon(Icons.admin_panel_settings), text: "Admins"),
            ],
          ),
        ),
        // 3. TabBarView holds the content for each slider page
        body: const TabBarView(
          children: [
            // PASS THE ROLE NAME TO EACH TAB
            _RoleManagementTab(role: 'user', color: Colors.blueAccent),
            _RoleManagementTab(role: 'trainer', color: Colors.orange),
            _RoleManagementTab(role: 'admin', color: Colors.purple),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 2. REUSABLE MENU TAB (Generates the 4 buttons)
// ==========================================================
class _RoleManagementTab extends StatelessWidget {
  final String role; // 'user', 'trainer', or 'admin'
  final Color color;

  const _RoleManagementTab({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    // Capitalize first letter for display (e.g., "trainer" -> "Trainer")
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
                    MaterialPageRoute(builder: (_) => GenericAddPage(role: role))
                  ),
                ),
                // 2. VIEW
                _DashboardCard(
                  icon: Icons.list_alt,
                  title: "View $displayRole",
                  color: color,
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => GenericListPage(role: role, mode: 'view', color: color))
                  ),
                ),
                // 3. EDIT
                _DashboardCard(
                  icon: Icons.edit,
                  title: "Edit $displayRole",
                  color: Colors.green, // Edit is always green usually
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => GenericListPage(role: role, mode: 'edit', color: Colors.green))
                  ),
                ),
                // 4. DELETE
                _DashboardCard(
                  icon: Icons.delete_forever,
                  title: "Remove $displayRole",
                  color: Colors.redAccent, // Delete is always red
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => GenericListPage(role: role, mode: 'delete', color: Colors.redAccent))
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
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
// 3. GENERIC ADD PAGE (Works for User, Trainer, Admin)
// ==========================================================
class GenericAddPage extends StatefulWidget {
  final String role; // Stores 'user', 'trainer', or 'admin'
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
      // 1. Create Login in Auth
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (authResponse.user != null) {
        // 2. Create Profile in DB with the correct ROLE
        await Supabase.instance.client.from('users').insert({
          'id': authResponse.user!.id,
          'name': nameController.text,
          'email': emailController.text,
          'role': widget.role, // <--- IMPORTANT: This saves 'trainer', 'admin' etc.
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
              width: double.infinity, height: 50,
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

// ==========================================================
// 4. GENERIC LIST PAGE (Smart list for View, Edit, Delete)
// ==========================================================
class GenericListPage extends StatefulWidget {
  final String role; // 'user', 'trainer', 'admin'
  final String mode; // 'view', 'edit', 'delete'
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
      // Fetch users ONLY where the role matches the current tab
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('role', widget.role) // <--- FILTERING HAPPENS HERE
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
                _fetchData(); // Refresh list
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
      appBar: AppBar(
        title: Text("${widget.mode.toUpperCase()} ${widget.role}s"), 
        backgroundColor: widget.color
      ),
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
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text(item['name'] ?? 'Unknown'),
                        subtitle: Text(item['email'] ?? 'No Email'),
                        // Logic to show Edit or Delete icon based on mode
                        trailing: widget.mode == 'view'
                            ? null
                            : Icon(
                                widget.mode == 'edit' ? Icons.edit : Icons.delete, 
                                color: widget.color
                              ),
                        onTap: () {
                          if (widget.mode == 'edit') {
                            // Go to Edit Page
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserForm(user: item)))
                                .then((_) => _fetchData());
                          } else if (widget.mode == 'delete') {
                            // Trigger Delete Popup
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

// ==========================================================
// 5. EDIT FORM (Kept mostly the same, but works for all roles)
// ==========================================================
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
              width: double.infinity, height: 50,
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