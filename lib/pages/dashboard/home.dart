import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:fin_wise/pages/title.dart';
import 'package:fin_wise/services/db.dart';
import 'package:fin_wise/services/models.dart';
import 'package:fin_wise/services/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController budgetController = TextEditingController();

  String selectedCurrency = 'USD';
  int isAscending = 0;
  String query = "";
  double budget = 0.0;
  bool darkMode = false;
  DateTime? _selectedDate;
  String? selectedCategory;

  final List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
  ];

  final List<String> categories = [
    "Food",
    "Shopping",
    "Utilities",
    "Income",
    "Transportation",
    "Health",
    "Subscriptions",
    "Investments"
  ];

  Map<String, Widget> categoryIcons = {
    "Food": Icon(Icons.fastfood, color: Colors.orange),
    "Shopping": Icon(Icons.shopping_cart, color: Colors.blue),
    "Utilities": Icon(Icons.settings, color: Colors.grey),
    "Income": Icon(Icons.attach_money, color: Colors.green),
    "Transportation": Icon(Icons.directions_car, color: Colors.purple),
    "Health": Icon(Icons.health_and_safety, color: Colors.red),
    "Subscriptions": Icon(Icons.subscriptions, color: Colors.teal),
    "Investments": Icon(Icons.account_balance_wallet, color: Colors.amber),
  };

  int curPage = 0;

  void _selectDate(BuildContext context, Function setModalState) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    setModalState(() {
      _selectedDate = pickedDate;
    });
  }

  //handles date
  DateTime date = DateTime.now();

  void addMonth() {
    setState(() {
      int newMonth = date.month + 1;
      int newYear = date.year;

      if (newMonth > 12) {
        newMonth = 1;
        newYear += 1;
      }

      int newDay = date.day;
      DateTime newDate = DateTime(newYear, newMonth, newDay);

      if (newDate.month != newMonth) {
        newDate = DateTime(newYear, newMonth + 1, 0);
      }

      date = newDate;
    });
  }

  void subtractMonth() {
    setState(() {
      int newMonth = date.month - 1;
      int newYear = date.year;

      if (newMonth < 1) {
        newMonth = 12;
        newYear -= 1;
      }

      int newDay = date.day;
      DateTime newDate = DateTime(newYear, newMonth, newDay);

      if (newDate.month != newMonth) {
        newDate = DateTime(newYear, newMonth - 1, 0);
      }

      date = newDate;
    });
  }

  List<TabItem> items = <TabItem>[
    TabItem(
      title: 'Home',
      icon: FontAwesomeIcons.house,
    ),
    TabItem(
      title: 'Transactions',
      icon: FontAwesomeIcons.magnifyingGlass,
    ),
    TabItem(
      title: 'Data',
      icon: FontAwesomeIcons.chartLine,
    ),
    TabItem(
      title: 'Settings',
      icon: FontAwesomeIcons.gear,
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    _loadBudgetData();
  }

  // Fetch user budget from Firestore
  Future<void> _loadBudgetData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        budget = userDoc['budget'] ?? 0.0;
      });
    }
  }

  Future<void> updateBudget(double newBudget) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'budget': newBudget, // Update the budget field
    });
    setState(() {
      budget = newBudget; // Update the local budget state
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    amountController.dispose();
    titleController.dispose();
    passwordController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    final financialsProvider = Provider.of<FinancialsProvider>(context);

    String sortOrderText = "";

    return Scaffold(
      appBar: curPage == 0
          ? AppBar(
              backgroundColor: Colors.white,
              leadingWidth: 140,
              leading: Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10),
                child: Text(
                  'FinWise',
                  style: TextStyle(
                    color: const Color.fromRGBO(23, 178, 255, 1),
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.yellow[800],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    logOut(context);
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.red[600],
                  ),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            )
          : null,
      backgroundColor: const Color.fromARGB(235, 255, 255, 255),
      floatingActionButton: curPage == 3 || curPage == 2
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                backgroundColor: const Color.fromRGBO(23, 178, 255, 1),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                tooltip: 'Add Item',
                onPressed: () {
                  addTransactionModal(context);
                },
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
      body: TabBarView(
        controller: tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 210,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 33, 139, 238),
                            Colors.cyan,
                            const Color.fromARGB(255, 24, 241, 169),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 30, top: 20, bottom: 15),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: financialsProvider.financialDataStream,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.data() == null) {
                              return Center(child: Text('No data available.'));
                            }

                            // Extract data from Firestore
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            double balance = data['balance'] ?? 0.0;
                            double revenue = data['revenue'] ?? 0.0;
                            double expenses = data['expenses'] ?? 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                // add balance from db
                                Text(
                                  '\$${balance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    letterSpacing: -2.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 34,
                                  ),
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 50,
                                      ),
                                      child: Text(
                                        'Revenue:',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                            height: 2),
                                      ),
                                    ),
                                    Icon(
                                      Icons.trending_down,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        'Expenses:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  spacing: 50,
                                  children: [
                                    //add income value from db
                                    Text(
                                      '\$${revenue.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    //add expenses value from db
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 45.0),
                                      child: Text(
                                        '\$(${expenses.toStringAsFixed(2)})',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 80),
                      GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              curPage = 1;
                              tabController.animateTo(1);
                            },
                          );
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: authService.getAllTransactions(0),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text('No transactions available.'));
                      }

                      var transactions = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                          "Are you sure you want to delete this transaction?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              context), // Cancel button
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await authService.deleteTransaction(
                                                transaction
                                                    .id); // Call delete function
                                            if (!context.mounted) return;
                                            Navigator.pop(
                                                context); // Close dialog
                                          },
                                          child: const Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:
                                      categoryIcons[transaction['category']] ??
                                          Icon(Icons.help_outline,
                                              color: Colors.black),
                                ),
                              ),
                              title: Text(
                                transaction['category'] ?? 'No Title',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(transaction['description'] ??
                                  'No Description'),
                              trailing: Text(
                                '\$${transaction['amount']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SpendingAnalytics(),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15,
                    bottom: 40,
                  ),
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category Breakdown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseAuth.instance.currentUser == null
                                        ? Stream.empty()
                                        : FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(authService.user!.uid)
                                            .collection('transactions')
                                            .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Text("No transactions available.");
                                  }

                                  // Process Firestore data into category totals
                                  Map<String, double> categoryTotals = {};
                                  double totalAmount = 0.0;

                                  for (var doc in snapshot.data!.docs) {
                                    var data =
                                        doc.data() as Map<String, dynamic>;
                                    String category = data['category'];
                                    double amount =
                                        (data['amount'] ?? 0).toDouble();

                                    categoryTotals[category] =
                                        (categoryTotals[category] ?? 0) +
                                            amount;
                                    totalAmount += amount;
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: categoryTotals.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final category =
                                          categoryTotals.keys.elementAt(index);
                                      final amount = categoryTotals[category]!;
                                      final percentage = totalAmount > 0
                                          ? (amount / totalAmount)
                                          : 0.0;

                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 13,
                                              bottom: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  category, // Dynamic category name
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '${(percentage * 100).toStringAsFixed(1)}%', // Percentage
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          LinearProgressIndicator(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            backgroundColor: Colors.grey[200],
                                            minHeight: 10,
                                            color: Colors.blue,
                                            value: percentage,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: double.maxFinite,
                height: 190,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(23, 178, 255, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 65.0),
                  child: Column(
                    children: [
                      Text(
                        'My Transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          left: 35,
                          right: 35,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      border: InputBorder.none,
                                      isDense: false,
                                      hintText: 'Search by category',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    onSubmitted: (context) {
                                      setState(() {
                                        query = searchController.text
                                            .trim()
                                            .toLowerCase();
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        isAscending = (isAscending + 1) %
                                            3; // Cycles through 0, 1, 2

                                        if (isAscending == 0) {
                                          sortOrderText = 'None';
                                        } else if (isAscending == 1) {
                                          sortOrderText = 'Descending';
                                        } else {
                                          sortOrderText = 'Ascending';
                                        }
                                      },
                                    );
                                    // Remove any currently visible SnackBar
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();

                                    // Show new SnackBar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        content: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 8),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 80),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            sortOrderText,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.filter_list,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: query.isEmpty
                        ? authService.getAllTransactions(
                            isAscending) // Show all if no query
                        : authService.getTransactionsByCategory(
                            query[0].toUpperCase() + query.substring(1),
                            isAscending,
                          ), // Filter by category
                    builder: (BuildContext context, snapshot) {
                      print(snapshot);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No transactions found.'));
                      } else {
                        var transactions = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              child: ListTile(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: const Text(
                                            "Are you sure you want to delete this transaction?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context), // Cancel button
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              authService.deleteTransaction(
                                                  transaction
                                                      .id); // Call delete function
                                              Navigator.pop(
                                                  context); // Close dialog
                                            },
                                            child: const Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                leading: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: categoryIcons[
                                            transaction['category']] ??
                                        Icon(Icons.help_outline,
                                            color: Colors.black),
                                  ),
                                ),
                                title: Text(
                                  transaction['category'] ?? 'No Title',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(transaction['description'] ??
                                    'No Description'),
                                trailing: Text(
                                  '\$${transaction['amount']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(23, 178, 255, 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 65,
                      left: 80,
                      right: 80,
                    ),
                    child: Text(
                      'Financial Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 13,
                    left: 40,
                    right: 40,
                    bottom: 20,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              //back month
                              subtractMonth();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                            ),
                          ),
                          //fetch date from query
                          Text(
                            DateFormat('MMMM yyyy').format(date),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              //forward month
                              addMonth();
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 20,
                    left: 40,
                    right: 40,
                  ),
                  child: FutureBuilder<Map<String, double>>(
                    future: authService.calculatePercentChange(
                        date.month, date.year),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show a loading spinner while fetching data
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error if any
                      } else if (!snapshot.hasData) {
                        return Text('No data available');
                      }

                      final percentChange = snapshot.data!;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Revenue',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  FutureBuilder<Map<String, double>>(
                                      future: authService
                                          .calculateMonthlyRevenueAndExpenses(
                                        date.month,
                                        date.year,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData) {
                                          return Text('No data available');
                                        }

                                        final revenue =
                                            snapshot.data!['revenue'] ?? 0.0;

                                        return Text(
                                          '\$${revenue.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        );
                                      }),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_drop_up,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        '${percentChange['revenueChange']?.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expenses',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  FutureBuilder<Map<String, double>>(
                                      future: authService
                                          .calculateMonthlyRevenueAndExpenses(
                                        date.month,
                                        date.year,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData) {
                                          return Text('No data available');
                                        }

                                        final expenses =
                                            snapshot.data!['expenses'] ?? 0.0;

                                        return Text(
                                          '\$${expenses.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        );
                                      }),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_drop_up,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        '${percentChange['expenseChange']?.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: 310,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseAuth.instance.currentUser == null
                          ? Stream.empty()
                          : FirebaseFirestore.instance
                              .collection('users')
                              .doc(authService.user!.uid)
                              .collection('transactions')
                              .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No transactions found'));
                        }

                        // Calculate the total expenses from transactions
                        double currentExpenses = 0.0;
                        snapshot.data!.docs.forEach((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final category = data['category'];
                          final amount = (data['amount'] ?? 0.0).toDouble();

                          // Count expenses (you can modify this logic based on your category conditions)
                          if (category != 'Income' &&
                              category != 'Investments') {
                            currentExpenses += amount;
                          }
                        });

                        // Calculate the percentage
                        double percent =
                            budget > 0 ? currentExpenses / budget : 0.0;
                        percent = percent > 1.0 ? 1.0 : percent;

                        return Center(
                          child: CircularPercentIndicator(
                            progressColor:
                                const Color.fromRGBO(23, 178, 255, 1),
                            animation: true,
                            curve: Curves.decelerate,
                            radius: 100,
                            lineWidth: 15,
                            percent:
                                percent, // Update the percentage dynamically
                            center: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '\$${currentExpenses.toStringAsFixed(2)}', // Current expenses
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '/\$${budget.toStringAsFixed(2)}', // Budget
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            header: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                'My Budget',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Enter New Budget'),
                            content: TextField(
                              controller: budgetController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText: 'New Budget',
                                hintText: 'Enter amount',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Close the dialog without saving
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Get the new budget value from the text field
                                  double newBudget =
                                      double.tryParse(budgetController.text) ??
                                          0.0;
                                  if (newBudget > 0) {
                                    // Call function to update budget in Firestore
                                    updateBudget(newBudget);
                                    Navigator.pop(context); // Close the dialog
                                  } else {
                                    // Show error message if the input is invalid
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please enter a valid input'),
                                          behavior: SnackBarBehavior.floating),
                                    );
                                  }
                                },
                                child: Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Set Budget',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 40.0,
                    right: 25,
                    left: 25,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 30.0,
                                top: 25,
                                bottom: 20,
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.bottomEnd,
                                fit: StackFit.loose,
                                children: [
                                  Image(
                                    width: 60,
                                    height: 60,
                                    image: AssetImage('lib/assets/profile.png'),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      //handle image upload
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: const Color.fromARGB(
                                                255, 140, 139, 139)),
                                        borderRadius: BorderRadius.circular(50),
                                        color: const Color.fromARGB(
                                            255, 234, 234, 234),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 17,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authService.user?.displayName ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    authService.user?.email! ?? '',
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              //handle email update
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.only(left: 20),
                            ),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.envelope,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Update Email',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 125),
                                Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Enter new password"),
                                    content: TextField(
                                      controller: passwordController,
                                      decoration: InputDecoration(
                                        hintText: "Type here...",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          authService.changePassword(
                                            passwordController.text
                                                .trim()
                                                .toLowerCase(),
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Text("Submit"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.only(left: 20),
                            ),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.lock,
                                  color: Colors.grey[800],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Change Password',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 90),
                                Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              //handle phone number
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.only(left: 20),
                            ),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.phone,
                                  color: Colors.grey[800],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add Your Phone',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 105),
                                Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 25,
                    right: 25,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'App Customization',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.dollarSign,
                                size: 20,
                              ),
                              const SizedBox(width: 30),
                              Text(
                                'Currency',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 90),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DropdownButton<String>(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  value: selectedCurrency,
                                  dropdownColor: Colors.white,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCurrency = newValue!;
                                    });
                                  },
                                  items:
                                      currencies.map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.moon),
                              const SizedBox(width: 25),
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 90),
                              Switch.adaptive(
                                applyCupertinoTheme: true,
                                value: darkMode,
                                onChanged: (bool value) {
                                  setState(
                                    () {
                                      darkMode = value;
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => logOut(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.white,
        controller: tabController,
        activeColor: const Color.fromRGBO(23, 178, 255, 1),
        height: 60,
        curveSize: 90,
        style: TabStyle.textIn,
        initialActiveIndex: 1,
        items: List.generate(items.length, (index) {
          return TabItem(
            icon: Center(
              child: FaIcon(
                items[index].icon,
                color: curPage == index ? Colors.black : Colors.grey[600],
              ),
            ),
            title: items[index].title,
          );
        }),
        onTap: (index) {
          setState(() {
            curPage = index;
          });
        },
      ),
    );
  }

  Future<dynamic> addTransactionModal(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text('Add Transaction',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Select Category",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(
                      () {
                        selectedCategory = value;
                      },
                    );
                  },
                ),
                SizedBox(height: 15),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: () => _selectDate(context, setModalState),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Choose a date'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0],
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final transaction = TransactionModel(
                      category: selectedCategory.toString(),
                      amount: double.parse(
                        amountController.text.trim(),
                      ),
                      date: Timestamp.fromDate(_selectedDate!),
                      description: titleController.text.trim().toLowerCase(),
                    );
                    UserRepository.instance.createTransaction(
                      FirebaseAuth.instance.currentUser!.uid,
                      transaction,
                    );
                    //clear fields
                    titleController.clear();
                    amountController.clear();
                    _selectedDate = date;
                    selectedCategory = null;

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Center(
                    child: Text('Save Transaction',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> logOut(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                AuthService().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TitlePage(),
                  ),
                );
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SpendingAnalytics extends StatelessWidget {
  const SpendingAnalytics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 15.0, bottom: 12),
        child: Text(
          'Spending Analytics',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
