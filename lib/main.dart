import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_flutter_libs/isar_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';

part 'main.g.dart';

@Collection()
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
}

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([TaskSchema], directory: dir.path);
  return isar;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openIsar();
  runApp(MyApp(isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp(this.isar, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      home: TaskPage(isar),
    );
  }
}

class TaskPage extends StatefulWidget {
  final Isar isar;
  const TaskPage(this.isar, {super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load task from database.
  Future<void> loadTasks() async {
    final allTasks = await widget.isar.tasks.where().findAll();
    setState(() {
      tasks = allTasks.where((task) {
        return task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  // Add new task
  Future<void> addTask(String title, String desc) async {
    final task = Task()
      ..title = title
      ..description = desc;

    await widget.isar.writeTxn(() async {
      await widget.isar.tasks.put(task);
    });
    loadTasks();
  }

  // Update existing task.
  Future<void> editTask(Task task, String newTitle, String newDesc) async {
    task.title = newTitle;
    task.description = newDesc;

    await widget.isar.writeTxn(() async {
      await widget.isar.tasks.put(task);
    });
    loadTasks();
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.tasks.delete(id);
    });
    loadTasks();
  }

  // Prompt to add new task
  void showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              addTask(titleController.text, descController.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Prompt to edit task
  void showEditDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              editTask(task, titleController.text, descController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                loadTasks();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final task = tasks[i];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(task.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteTask(task.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
