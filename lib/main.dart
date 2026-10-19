import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TrackPenseApp());
}

class TrackPenseApp extends StatelessWidget {
  const TrackPenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackPense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardPage();
        }

        return const WelcomePage();
      },
    );
  }
}

// ==================== WELCOME PAGE ====================
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 90,
                  color: Colors.teal,
                ),
                const SizedBox(height: 20),
                const Text(
                  'TrackPense',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Track your money. Manage your future.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'I already have an account',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SIGNUP PAGE ====================
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await credential.user?.updateDisplayName(
        _nameController.text.trim(),
      );

      if (!mounted) return;

      Navigator.popUntil(context, (route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email already has an account. Please log in.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet.';
          break;
        default:
          message = e.message ?? 'Signup failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 65,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Join TrackPense',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account to manage your money.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      icon: Icon(
                        _hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _hideConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(
                          () => _hideConfirmPassword = !_hideConfirmPassword,
                        );
                      },
                      icon: Icon(
                        _hideConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _signup,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== LOGIN PAGE ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text('Welcome Back'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 65,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Log in to TrackPense',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back! Please enter your details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      icon: Icon(
                        _hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== DASHBOARD PAGE ====================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static const bg = Color(0xFF0B1020);
  static const panel = Color(0xFF171F35);
  static const green = Color(0xFF10B981);
  static const muted = Color(0xFF94A3B8);

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature next banayenge!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';

    final pages = [
      _homePage(name),
      _placeholderPage(Icons.receipt_long, 'Transactions',
          'Your income and expenses will appear here.'),
      _placeholderPage(Icons.pie_chart_outline, 'Analytics',
          'Your spending charts will appear here.'),
      _placeholderPage(Icons.settings_outlined, 'Settings',
          'Manage your TrackPense account here.'),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              backgroundColor: bg,
              foregroundColor: Colors.white,
              title: Text(
                ['Home', 'Transactions', 'Analytics', 'Settings']
                    [_selectedIndex],
              ),
            ),
      body: SafeArea(child: pages[_selectedIndex]),
            floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionPage(),
            ),
          );
        },
        backgroundColor: green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 34),
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        indicatorColor: green.withValues(alpha: 0.16),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _homePage(String name) {
    final now = DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 90),
      children: [
        Text(
          '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}',
          style: const TextStyle(color: muted, fontSize: 16),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Expanded(
              child: Text(
                'TrackPense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ),
                        CircleAvatar(
              radius: 29,
              backgroundColor: panel,
              child: IconButton(
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BudgetPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF063E32),
                Color(0xFF071927),
                Color(0xFF10182A),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Spent this month',
                  style: TextStyle(color: muted, fontSize: 16)),
              const SizedBox(height: 4),
              const Text(
                '₹0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today', style: TextStyle(color: muted)),
                        SizedBox(height: 3),
                        Text('₹0',
                            style: TextStyle(
                                color: Colors.white, fontSize: 22)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Budget left',
                          style: TextStyle(color: muted)),
                      SizedBox(height: 3),
                      Text('Not set',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _comingSoon('Monthly budget'),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: green),
                    SizedBox(width: 9),
                    Text(
                      'Set a monthly budget',
                      style: TextStyle(
                        color: green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.arrow_downward,
                'Income',
                '₹0',
                const Color(0xFF065F46),
                green,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _statCard(
                Icons.arrow_upward,
                'Net balance',
                '₹0',
                const Color(0xFF451820),
                const Color(0xFFF87171),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 32),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF222C43)),
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF075742),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Color(0xFFB7F7D9),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Start tracking your money',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add your first expense or income and '
                'TrackPense will build your charts and '
                'insights automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _comingSoon('Add transaction'),
                icon: const Icon(Icons.add),
                label: const Text('Add transaction'),
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome, $name!',
          style: const TextStyle(color: muted),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String amount,
    Color iconBg,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF222C43)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 25),
          ),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(color: muted)),
          const SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(
              color: title == 'Income' ? green : Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderPage(
    IconData icon,
    String title,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: green),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool _isExpense = true;
  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'Cash';
  
  final _amountController = TextEditingController();
  final _sourceMerchantController = TextEditingController();
  final _noteController = TextEditingController();

  static const bg = Color(0xFF0B1020);
  static const panel = Color(0xFF171F35);
  static const green = Color(0xFF10B981);
  static const muted = Color(0xFF94A3B8);

  @override
  void dispose() {
    _amountController.dispose();
    _sourceMerchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Categories tab ke mutabiq change hongi
    final categories = _isExpense
        ? [
            {'icon': Icons.fastfood, 'name': 'Food'},
            {'icon': Icons.directions_car, 'name': 'Transport'},
            {'icon': Icons.shopping_bag, 'name': 'Shopping'},
            {'icon': Icons.school, 'name': 'Education'},
          ]
        : [
            {'icon': Icons.work_outline, 'name': 'Salary'},
            {'icon': Icons.laptop_mac, 'name': 'Freelance'},
            {'icon': Icons.more_horiz, 'name': 'Other'},
          ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add transaction',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Expense / Income Toggle Switch
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpense = true;
                          _selectedCategory = 'Food'; // Reset category
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isExpense ? bg : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: _isExpense ? Colors.white : muted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpense = false;
                          _selectedCategory = 'Salary'; // Reset category
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_isExpense ? bg : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: !_isExpense ? Colors.white : muted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Amount Input Section
            const Text('Amount', style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF222C43)),
              ),
              child: Row(
                children: [
                  Text(
                    '₹',
                    style: TextStyle(color: green, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: muted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Category Section (Dynamic based on Expense/Income)
            const Text('Category', style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _categoryItem(cat['icon'] as IconData, cat['name'] as String),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 4. Date & Time Picker Mock
            const Text('Date & time', style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF222C43)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: muted, size: 20),
                      SizedBox(width: 12),
                      Text('Today, 8:20 PM', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down, color: muted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Payment Method Section
            const Text('Payment method', style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _paymentChip('Cash', Icons.wallet),
                _paymentChip('UPI', Icons.phone_android),
                _paymentChip('Card', Icons.credit_card),
                _paymentChip('Bank Transfer', Icons.account_balance),
              ],
            ),
            const SizedBox(height: 24),

            // 6. Source / Merchant Field (Dynamic Label & Hint)
            Text(
              _isExpense ? 'Merchant / shop (optional)' : 'Source (optional)',
              style: const TextStyle(color: muted, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sourceMerchantController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _isExpense ? 'e.g. Swiggy, Big Bazaar' : 'e.g. Acme Corp',
                hintStyle: const TextStyle(color: muted),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF222C43)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF222C43)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 7. Note Optional
            const Text('Note (optional)', style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a short note',
                hintStyle: const TextStyle(color: muted),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF222C43)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF222C43)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 8. Save Button (Dynamic text)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  // Yahan data save karne ka logic aayega
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: Text(
                  _isExpense ? 'Save expense' : 'Save income',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(IconData icon, String name) {
    bool isSelected = _selectedCategory == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = name),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? green : const Color(0xFF222C43),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? green : Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : muted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip(String name, IconData icon) {
    bool isSelected = _selectedPaymentMethod == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? green : const Color(0xFF222C43),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? green : muted, size: 18),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : muted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  static const bg = Color(0xFF0B1020);
  static const panel = Color(0xFF171F35);
  static const green = Color(0xFF10B981);
  static const muted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
      {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.blue},
      {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink},
      {'name': 'Education', 'icon': Icons.school, 'color': Colors.purple},
      {'name': 'Bills', 'icon': Icons.receipt, 'color': Colors.amber},
      {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.red},
      {'name': 'Health', 'icon': Icons.local_hospital, 'color': Colors.teal},
      {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.lightBlue},
      {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Budgets',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Budget Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF222C43)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Set budget action
                        },
                        child: const Text(
                          'Set budget',
                          style: TextStyle(
                            color: green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Spent ₹0 this month. Set a budget to track how much you have left.',
                    style: TextStyle(color: muted, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Budgets Title
            const Text(
              'Category budgets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Category List Container
            Container(
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF222C43)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color(0xFF222C43),
                  height: 1,
                  indent: 70,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      cat['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          '₹0 • No limit',
                          style: TextStyle(color: muted, fontSize: 14),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: muted),
                      ],
                    ),
                    onTap: () {
                      // Category item click action
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
