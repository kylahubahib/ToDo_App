import 'package:flutter/material.dart';
import 'package:todo_app/database/tasks_database.dart';
import 'package:todo_app/extensions/extensions.dart';
import 'package:todo_app/models/task.dart';

final _formKey = GlobalKey<FormState>();

class AddTask extends StatefulWidget {
  const AddTask({super.key, this.task});

  final Task? task;

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _startDate = widget.task!.startDate;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> addTask() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      isCompleted: false,
    );

    await TasksDatabase.instance.createTask(task);
    Navigator.of(context).pop();
  }

  Future<void> updateTask() async {
    final task = widget.task!.copy(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
    );

    await TasksDatabase.instance.updateTask(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Start Date: ',
                    style: TextStyle(fontSize: 17),
                  ),
                  TextButton(
                    onPressed: () async {
                      _startDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000),
                          ) ??
                          DateTime.now();
                      setState(() {});
                    },
                    child: Text(
                      _startDate.format(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addUpdateTask,
                child: Text(widget.task != null ? 'Update Task' : 'Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addUpdateTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final isUpdating = widget.task != null;

      if (isUpdating) {
        await updateTask();
      } else {
        await addTask();
      }

      Navigator.of(context).pop();
    }
  }
}
