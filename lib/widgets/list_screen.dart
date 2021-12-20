import 'package:auditmerchant/providers/merchant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils.dart' as utils;

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ScrollController _scrollController = ScrollController();
  late MerchantProvider _merchantProvider;
  List _accountList = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    _merchantProvider = Provider.of<MerchantProvider>(context);
    _getAccountList();
    super.didChangeDependencies();
  }

  Future<void> _getAccountList() async {
    try {
      _accountList = await _merchantProvider.getAccountList();
    } catch (error) {
      utils.handleErrorResponse(context, (error as dynamic).message);
    }
    if (!this.mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 55.0,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 7.0,
                  top: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Account',
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: Icon(
                    //     Icons.power_settings_new,
                    //     color: Colors.red,
                    //   ),
                    //   iconSize: 20.0,
                    // ),
                  ],
                ),
              ),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _accountList.isEmpty
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.only(top: 50.0),
                          height: 80.0,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.signal_cellular_no_sim_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 50.0,
                                ),
                                Text(
                                  'No record found...',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _accountList.length,
                          itemBuilder: (_, index) => Column(
                            children: [
                              ListTile(
                                tileColor: Colors.white,
                                visualDensity: VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                title: Text(
                                  _accountList[index]['name'],
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                                onTap: () => Navigator.of(context).pushNamed(
                                  '/form',
                                  arguments: {
                                    'id': _accountList[index]['id'],
                                    'name': _accountList[index]['name']
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add Account',
        onPressed: () => Navigator.of(context).pushNamed('/form'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
