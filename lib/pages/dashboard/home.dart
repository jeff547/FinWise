import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:fin_wise/pages/title.dart';
import 'package:fin_wise/services/socials_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //temp for testing
    List<Map<String, String>> transactions = [
      {'title': 'Shopping', 'description': 'JcPenny'},
      {'title': 'Food', 'description': 'Mcdonalds'},
      {'title': 'Salary', 'description': 'Starbucks monthly income'},
    ];

    return Scaffold(
      appBar: AppBar(
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
      ),
      backgroundColor: const Color.fromARGB(240, 255, 255, 255),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.white,
        color: const Color.fromRGBO(23, 178, 255, 1),
        height: 45,
        curveSize: 100,
        style: TabStyle.fixedCircle,
        items: [
          TabItem(
            icon: Center(
              child: FaIcon(
                FontAwesomeIcons.house,
                color: Colors.grey[700],
              ),
            ),
          ),
          TabItem(
            icon: Center(
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: Colors.grey[700],
              ),
            ),
          ),
          TabItem(
            icon: Center(
              child: FaIcon(
                FontAwesomeIcons.plus,
                color: Colors.grey[800],
              ),
            ),
          ),
          TabItem(
            icon: Center(
              child: FaIcon(
                FontAwesomeIcons.chartLine,
                color: Colors.grey[700],
              ),
            ),
          ),
          TabItem(
            icon: Center(
              child: FaIcon(
                FontAwesomeIcons.gear,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
        initialActiveIndex: 1,
      ),
      body: SafeArea(
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
                    padding:
                        const EdgeInsets.only(left: 30, top: 20, bottom: 15),
                    child: Column(
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
                          '\$8,459.32',
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
                                'Income:',
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
                            //add Income value from db
                            Text(
                              '\$12,450',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            //add expenses value from db
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Text(
                                '\$3,991',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
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
                  const SizedBox(width: 100),
                  Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  var data = transactions[index];

                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 60, 238, 191),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(Icons.storage),
                        ),
                      ),
                      title: Text(
                        data['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(data['description'] ?? 'No Description'),
                      trailing: Text(
                        "\$100",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
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
            ),
            Expanded(
              child: Padding(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                              itemCount: 2,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // add categories from db
                                          Text(
                                            'Shopping',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '35%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    LinearProgressIndicator(
                                      backgroundColor: Colors.grey[200],
                                      minHeight: 10,
                                      color: Colors.blue,
                                      value: .35,
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
