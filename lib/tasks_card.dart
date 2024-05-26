import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/database/tasks_database.dart';
import 'package:todo_app/extensions/extensions.dart';
import 'package:todo_app/models/task.dart';

class TasksCard extends StatefulWidget {
  const TasksCard({
    super.key,
    required this.task,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onDelete;

  @override
  State<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends State<TasksCard> {
  bool isCompleted = false;

  @override
  void initState() {
    isCompleted = widget.task.isCompleted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CupertinoListTile(
          leading: Transform.scale(
            scale: 1.2,
            child: CupertinoCheckbox(
              value: isCompleted,
              onChanged: (value) async {
                setState(() {
                  isCompleted = value ?? false;
                });
                await TasksDatabase.instance.markTaskAsCompleted(
                  id: widget.task.id!,
                  isCompleted: isCompleted,
                );
              },
            ),
          ),
          title: Text(
            widget.task.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(13, 71, 161, 1),
            ),
          ),
          subtitle: Text(
            widget.task.description,
            maxLines: 3,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display start date
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.task.startDate.format(),
                ),
              ),
              // Delete button
              IconButton(
                onPressed: () async {
                  widget.onDelete();
                  await TasksDatabase.instance.deleteTask(widget.task.id!);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
