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
// 1. DASHBOARD HOME
// ==========================================================
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // 1. ADD USER
                  _DashboardCard(
                    icon: Icons.person_add, 
                    title: "Add New User", 
                    color: Colors.blueAccent, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddUserPage()))
                  ),
                  
                  // 2. VIEW USERS
                  _DashboardCard(
                    icon: Icons.list_alt, 
                    title: "View Users", 
                    color: Colors.orangeAccent, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewUsersPage()))
                  ),
                  
                  // 3. EDIT USERS (Select to Edit)
                  _DashboardCard(
                    icon: Icons.edit, 
                    title: "Edit User", 
                    color: Colors.green, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditUsersListPage()))
                  ),
                  
                  // 4. REMOVE USERS (Select to Delete)
                  _DashboardCard(
                    icon: Icons.delete_forever, 
                    title: "Remove User", 
                    color: Colors.redAccent, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteUsersListPage()))
                  ),
                ],
              ),
            ),
          ],
        ),
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ]),
      ),
    );
  }
}

// ==========================================================
// 2. ADD USER PAGE
// ==========================================================
class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> addUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email and Password required")));
      return;
    }
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
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User created & synced!")));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add New User')),
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
                onPressed: isLoading ? null : addUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 3. VIEW USERS PAGE (Read Only List)
// ==========================================================
class ViewUsersPage extends StatefulWidget {
  const ViewUsersPage({super.key});
  @override
  _ViewUsersPageState createState() => _ViewUsersPageState();
}

class _ViewUsersPageState extends State<ViewUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client.from('users').select().order('name', ascending: true);
      if (mounted) setState(() { _users = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Users"), backgroundColor: Colors.orangeAccent),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: _users.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user['name'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? 'No Email'),
                ),
              );
            },
          ),
    );
  }
}

// ==========================================================
// 4. EDIT USERS LIST PAGE (Select to Edit)
// ==========================================================
class EditUsersListPage extends StatefulWidget {
  const EditUsersListPage({super.key});
  @override
  _EditUsersListPageState createState() => _EditUsersListPageState();
}

class _EditUsersListPageState extends State<EditUsersListPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client.from('users').select().order('name', ascending: true);
      if (mounted) setState(() { _users = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select User to Edit"), backgroundColor: Colors.green),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: _users.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                child: ListTile(
                  title: Text(user['name'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? 'No Email'),
                  trailing: const Icon(Icons.edit, color: Colors.green),
                  onTap: () async {
                    // Go to Edit Form Page
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserForm(user: user)));
                    // Refresh when we come back
                    _fetchUsers();
                  },
                ),
              );
            },
          ),
    );
  }
}

// ==========================================================
// 5. DELETE USERS LIST PAGE (Select to Delete)
// ==========================================================
class DeleteUsersListPage extends StatefulWidget {
  const DeleteUsersListPage({super.key});
  @override
  _DeleteUsersListPageState createState() => _DeleteUsersListPageState();
}

class _DeleteUsersListPageState extends State<DeleteUsersListPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client.from('users').select().order('name', ascending: true);
      if (mounted) setState(() { _users = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete User Permanently"),
        content: Text("This will delete ${user['name']} from the App AND Login system. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              try {
                // Call SQL function for hard delete
                await Supabase.instance.client.rpc('admin_delete_user', params: {
                  'target_user_id': user['id']
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Hard Deleted!")));
                  _fetchUsers(); // Refresh list
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select User to Remove"), backgroundColor: Colors.redAccent),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: _users.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                child: ListTile(
                  title: Text(user['name'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? 'No Email'),
                  trailing: const Icon(Icons.delete, color: Colors.red),
                  onTap: () => _showDeleteDialog(user),
                ),
              );
            },
          ),
    );
  }
}

// ==========================================================
// 6. EDIT USER FORM (The actual edit screen)
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
      // Call SQL function for hard edit
      await Supabase.instance.client.rpc('admin_update_user', params: {
        'target_user_id': widget.user['id'],
        'new_email': emailController.text.trim(),
        'new_name': nameController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Login & Profile Updated!")));
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
      appBar: AppBar(title: const Text("Update User Details"), backgroundColor: Colors.green),
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