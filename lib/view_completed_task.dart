import 'package:flutter/material.dart';
import 'package:todo_app/database/tasks_database.dart';
import 'package:todo_app/extensions/extensions.dart';
import 'package:todo_app/models/task.dart';

class ViewCompletedTask extends StatefulWidget {
  const ViewCompletedTask({super.key});

  @override
  State<ViewCompletedTask> createState() => _ViewCompletedTask();
}

class _ViewCompletedTask extends State<ViewCompletedTask> {
  bool isLoading = false;
  List<Task> completedTasks = [];

  @override
  void initState() {
    super.initState();
    getCompletedTasks();
  }

  Future<void> getCompletedTasks() async {
    setState(() => isLoading = true);
    completedTasks = await TasksDatabase.instance.readCompletedTasks();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Completed Tasks',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(13, 71, 161, 1),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(task.description),
                    trailing: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(task.startDate.format()),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
