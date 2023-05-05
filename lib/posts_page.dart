import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  PostsPageState createState() => PostsPageState();
}

class PostsPageState extends State<PostsPage> {
  List<dynamic> _posts = [];
  String uri = 'http://192.168.1.159:3000/posts/';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> _fetchPosts() async {
    final response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      setState(() {
        _posts = jsonDecode(response.body);
      });
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Ошибка в загрузке постов'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _createPost() async {
    final response = await http.post(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleController.text,
        'body': _bodyController.text,
      }),
    );
    if (response.statusCode == 201) {
      _fetchPosts();
      _titleController.clear();
      _bodyController.clear();
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Ошибка в создании поста'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _updatePost(int id) async {
    final response = await http.put(
      Uri.parse('$uri$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleController.text,
        'body': _bodyController.text,
      }),
    );
    if (response.statusCode == 200) {
      _fetchPosts();
      _titleController.clear();
      _bodyController.clear();
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Ошибка в редактировании поста'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _deletePost(int id) async {
    final response = await http.delete(Uri.parse('$uri$id'));
    if (response.statusCode == 200) {
      _fetchPosts();
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Ошибка в удалении поста'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Посты'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_posts[index]['title']),
                  subtitle: Text(_posts[index]['body']),
                  onTap: () {
                    _titleController.text = _posts[index]['title'];
                    _bodyController.text = _posts[index]['body'];
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Отредактировать пост'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Заголовок',
                              ),
                            ),
                            TextField(
                              controller: _bodyController,
                              decoration: const InputDecoration(
                                labelText: 'Подзаголовок',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Отменить'),
                            onPressed: () {
                              Navigator.pop(context);
                              _titleController.clear();
                              _bodyController.clear();
                            },
                          ),
                          TextButton(
                            child: const Text('Редактировать'),
                            onPressed: () {
                              _updatePost(_posts[index]['id']);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить пост?'),
                        content: const Text(
                            'Вы уверены что хотите удалить этот пост?'),
                        actions: [
                          TextButton(
                            child: const Text('Отменить'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Удалить'),
                            onPressed: () {
                              _deletePost(_posts[index]['id']);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Заголовок',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      labelText: 'Подзаголовок',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  child: const Text('Создать'),
                  onPressed: () {
                    _createPost();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
