import 'package:flutter/material.dart';
import 'package:todo_app/add_task.dart';
import 'package:todo_app/database/tasks_database.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/tasks_card.dart';
import 'package:todo_app/view_completed_task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  List<Task> tasks = [];
  List<Task> filteredTasks = [];

  @override
  void initState() {
    super.initState();
    getAllTasks();
  }

  Future<void> getAllTasks() async {
    setState(() => isLoading = true);
    tasks = await TasksDatabase.instance.readAllTasks();
    filteredTasks = List.from(tasks);
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    TasksDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'ToDo List',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ViewCompletedTask(),
                  ),
                );
              },
              child: const Text(
                'History',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTasksList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTask(),
            ),
          );
          if (result == true) {
            await getAllTasks();
          }
        },
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 40.0,
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide:
                    const BorderSide(color: Color.fromRGBO(13, 71, 161, 1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            onChanged: (value) {
              setState(() {
                filteredTasks = tasks
                    .where((task) =>
                        task.title.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return GestureDetector(
                onTap: () async {
                  final updatedTask = await Navigator.of(context).push<Task?>(
                    MaterialPageRoute(
                      builder: (_) => AddTask(
                        task: task,
                      ),
                    ),
                  );
                  if (updatedTask != null) {
                    await getAllTasks();
                  }
                },
                child: TasksCard(
                  task: task,
                  onDelete: () {
                    setState(() {
                      tasks.remove(task);
                      filteredTasks.remove(task);
                    });
                    TasksDatabase.instance.deleteTask(task.id!);
                  },
                  onCompleted: () async {
                    await getAllTasks();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
