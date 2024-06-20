import 'package:flutter/material.dart';
import 'package:news/models/article.dart';
import 'package:news/services/news_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> _articles;
  late List<Article> _allArticles;
  late List<Article> _filteredArticles;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _searchController.addListener(_performSearch);
    _checkInternetConnection();
  }

  Future<void> _fetchArticles() async {
    _articles = NewsService().fetchTopHeadlines();
    _allArticles = await _articles;
    setState(() {
      _filteredArticles = _allArticles;
    });
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _hasInternet = false;
      });
      Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      setState(() {
        _hasInternet = true;
      });
    }
  }

  void _performSearch() {
    String query = _searchController.text;
    List<Article> filteredList = [];
    if (query.isNotEmpty) {
      for (Article article in _allArticles) {
        if (article.title!.toLowerCase().contains(query.toLowerCase())) {
          filteredList.add(article);
        }
      }
    } else {
      filteredList = _allArticles;
    }
    setState(() {
      _filteredArticles = filteredList;
      _isSearching = query.isNotEmpty;
    });
  }

  Future<void> _refreshArticles() async {
    await _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSearching) {
          _searchController.clear();
          _performSearch();
          setState(() {
            _isSearching = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  'InfoFlash',
                ),
          leading: _isSearching
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                    setState(() {
                      _isSearching = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.newspaper_rounded),
                  onPressed: () {},
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchFocus.requestFocus();
                });
              },
            ),
          ],
        ),
        body: _hasInternet
            ? RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
                onRefresh: _refreshArticles,
                child: FutureBuilder<List<Article>>(
                  future: _articles,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    } else {
                      return ListView.builder(
                        itemCount: _filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewsDetailScreen(article: article),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (article.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15.0)),
                                      child: Image.network(
                                        article.imageUrl!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      article.title ?? 'No Title',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              )
            : Center(
                child: Text(
                    'No internet connection. Please check your connection and try again.')),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
}
