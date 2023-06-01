
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';

class TodoItem {
  String title;
  String description;
  bool isDone;
  bool isFavorite;

  TodoItem({required this.title, required this.description, this.isDone=false, this.isFavorite=false});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'isFavorite': isFavorite
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'] ?? false,
      isFavorite: json['isFavorite'] ?? false
    );
  }
}

class SharedPreferencesHelper {
  static const _keyTodo = 'todo_items';

  static Future<List<TodoItem>> getTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTodo) ?? '[]';
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((json) => TodoItem.fromJson(json)).toList();
  }

  static Future<void> saveTodoItems(List<TodoItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(items.map((item) => item.toJson()).toList());
    prefs.setString(_keyTodo, jsonString);
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late List<TodoItem> _items = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  _loadTodoItems() async {
    final items = await SharedPreferencesHelper.getTodoItems();
    setState(() {
      _items = items;
    });
  }
  _saveTodoItems() {
    SharedPreferencesHelper.saveTodoItems(_items);
  }
  _addItem() {
    setState(() {
      FocusScope.of(context).unfocus();
      _items.add(TodoItem(
          title: _titleController.text,
          description: _descriptionController.text));
      _titleController.clear();
      _descriptionController.clear();
      _saveTodoItems();
    });

  }
  _editItem(TodoItem item) async {
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    await showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: const Text('Edit Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() {
                      item.title = _titleController.text;
                      item.description = _descriptionController.text;
                      _saveTodoItems();
                      Fluttertoast.showToast(
                        msg: "List berhasil diupdate",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    });
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
    _titleController.clear();
    _descriptionController.clear();
  }
  _deleteItem(TodoItem item) {
    setState(() {
      if(item.isDone){
        _items.removeWhere((item) => item.isDone);
        _saveTodoItems();
        Fluttertoast.showToast(
          msg: "List berhasil dihapus",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else{
        Fluttertoast.showToast(
          msg: "List belum diselesaikan",
          toastLength: Toast.LENGTH_SHORT,
        );
      }

    });
  }

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To Do List'),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),),
                    onPressed: _addItem,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_task),
                        SizedBox(width: 5),
                        Text('Add to List')
                      ],
                    )
                  ),
                ]
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Slidable(
                    key: ValueKey('${_items[index]}'),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_){
                            _deleteItem(item);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_){
                            setState(() {
                              if(item.isFavorite){
                                item.isFavorite = false;
                              }else{
                                item.isFavorite = true;
                              }
                            });
                          },
                          backgroundColor: const Color(0xFF7BC043),
                          foregroundColor: item.isFavorite ? Colors.red : Colors.white,
                          icon: Icons.favorite,
                          label: 'Favorite',
                        ),
                      ],
                    ),
                    child: CheckboxListTile(
                      title: Text(item.title),
                      subtitle: Text(item.description),
                      value: item.isDone,
                      onChanged: (value) {
                        setState(() {
                          item.isDone = value!;
                          _saveTodoItems();
                        });
                      },
                      secondary: IconButton(
                        icon: item.isDone ? const Icon(Icons.playlist_add_check_rounded,color: Colors.green,) :
                          const Icon(Icons.edit,color: Colors.green),
                        onPressed: () {
                          if(item.isDone){
                            Fluttertoast.showToast(
                              msg: "List sudah selesai",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          } else{
                            _editItem(item);
                          }
                        }
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
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

class TodoListScreenState extends ChangeNotifier {
  late List todoItem;

  void initValue(){

  }


}