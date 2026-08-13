// Hibah Malik
// IT 315 - Project

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CombinedHwApp()); // start app
}

// main app
// one material app
class CombinedHwApp extends StatelessWidget {
  const CombinedHwApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // no banner
      title: 'HW Project App', // app name
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // colors
        useMaterial3: true, // material 3
      ),
      home: const CombinedHomePage(), // first page
    );
  }
}

// top tab layout
// holds 3 apps
class CombinedHomePage extends StatelessWidget {
  const CombinedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HW Project App'), // top title
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.check_circle), text: 'Todo'),
              Tab(icon: Icon(Icons.add_circle), text: 'Counter'),
              Tab(icon: Icon(Icons.monitor_weight), text: 'BMI'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TaskListPage(), // todo app
            MyHomePage(title: 'Hibahs Counter App'), // counter
            BmiHomePage(), // bmi
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////
// TODO APP
//////////////////////////////////////////////////

// main todo page
// stateful because list changes
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

// holds task list
class _TaskListPageState extends State<TaskListPage> {
  List<Map<String, String>> tasks = []; // stores tasks

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // save tasks locally
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    String encodedData = jsonEncode(tasks);

    await prefs.setString('task_data', encodedData);
  }

  // load saved tasks
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    String? storedData = prefs.getString('task_data');

    if (storedData != null) {
      List decodedData = jsonDecode(storedData);

      setState(() {
        tasks = decodedData.map((task) {
          return Map<String, String>.from(task);
        }).toList();
      });
    }
  }

  // add task
  Future<void> addTask() async {
    final Map<String, String>? newTask = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TaskFormPage()));

    if (newTask != null) {
      setState(() {
        tasks.add(newTask); // add to list
      });

      saveTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Task added', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  // edit old task
  Future<void> editTask(int index) async {
    final Map<String, String>? updatedTask = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TaskFormPage(task: tasks[index])),
    );

    if (updatedTask != null) {
      setState(() {
        tasks[index] = updatedTask; // replace old one
      });

      saveTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Task updated', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  // popup for task info
  void showTaskDialog(Map<String, String> task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            task['name']!,
            style: const TextStyle(color: Colors.indigo),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Due Time: ${task['time']}',
                style: const TextStyle(color: Colors.indigo),
              ),
              const SizedBox(height: 10),
              Text(
                task['description']!,
                style: const TextStyle(color: Colors.indigo),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close
              },
              child: const Text('Close', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  // ask before delete
  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Delete Task',
            style: TextStyle(color: Colors.indigo),
          ),
          content: const Text(
            'Do you want to delete this task?',
            style: TextStyle(color: Colors.indigo),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // no
              },
              child: const Text('No', style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.removeAt(index); // remove task
                });

                saveTasks();

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.blue,
                    content: Text(
                      'Task deleted',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  // open about page
  void openAboutPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AboutPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // page color
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'Daily Task App',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: openAboutPage, // info page
            icon: const Icon(Icons.info_outline, color: Colors.amber),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12), // spacing
        child: tasks.isEmpty
            ? const Center(
                child: Text(
                  'No tasks added yet',
                  style: TextStyle(fontSize: 20, color: Colors.indigo),
                ),
              )
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        tasks[index]['name']!,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        tasks[index]['time']!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        showTaskDialog(tasks[index]); // details
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              editTask(index); // edit
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () {
                              confirmDelete(index); // delete
                            },
                            icon: const Icon(Icons.delete, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: addTask, // add
        child: const Icon(Icons.add, color: Colors.amber),
      ),
    );
  }
}

// add or edit task page
class TaskFormPage extends StatefulWidget {
  final Map<String, String>? task; // old task if edit

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

// form state
class _TaskFormPageState extends State<TaskFormPage> {
  late TextEditingController nameController; // name box
  late TextEditingController descriptionController; // desc box

  String? selectedTime; // picked time

  final List<String> timeList = List.generate(96, (index) {
    int hour = index ~/ 4;
    int minute = (index % 4) * 15;
    String hourText = hour.toString().padLeft(2, '0');
    String minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  });

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.task?['name'] ?? '');
    descriptionController = TextEditingController(
      text: widget.task?['description'] ?? '',
    );
    selectedTime = widget.task?['time']; // old value
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // save task data
  void saveTask() {
    if (nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedTime != null) {
      Navigator.pop(context, {
        'name': nameController.text,
        'time': selectedTime!,
        'description': descriptionController.text,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            'Fill out all fields',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.task != null; // edit or add

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          isEdit ? 'Edit Task' : 'Add Task',
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // spacing
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.indigo),
              decoration: const InputDecoration(
                labelText: 'Task Name',
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedTime,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.indigo),
              decoration: const InputDecoration(
                labelText: 'Due Time',
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
              items: timeList.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text(
                    time,
                    style: const TextStyle(color: Colors.indigo),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTime = value; // update time
                });
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.indigo),
              decoration: const InputDecoration(
                labelText: 'Task Description',
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.amber,
              ),
              onPressed: saveTask, // save data
              child: Text(isEdit ? 'Update Task' : 'Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}

// about screen
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'About Page',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text(
              'This is a simple daily task app. It lets users add, edit, and delete tasks with a due time and short description.',
              style: TextStyle(fontSize: 18, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////
// COUNTER APP
//////////////////////////////////////////////////

// counter page
// stateful because number changes
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title; // app bar text

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// counter state
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0; // value

  // add one
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (_counter % 3 == 0)
          ? Colors.blue
          : (_counter % 3 == 1)
          ? Colors.red
          : Colors.yellow,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const Text(
                'Button pressed this many times:',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            RotatedBox(
              quarterTurns: _counter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                color: Colors.amber,
                child: Text('$_counter', style: const TextStyle(fontSize: 80)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, // add count
        child: const Icon(Icons.add),
      ),
    );
  }
}

//////////////////////////////////////////////////
// BMI APP
//////////////////////////////////////////////////

// bmi page
// input changes so stateful
class BmiHomePage extends StatefulWidget {
  const BmiHomePage({super.key});

  @override
  State<BmiHomePage> createState() => _BmiHomePageState();
}

// bmi data
class _BmiHomePageState extends State<BmiHomePage> {
  String unit = 'imperial'; // picked unit
  String height = ''; // height input
  String weight = ''; // weight input
  String result = ''; // bmi output

  // do bmi math
  void calculate() {
    double? h = double.tryParse(height);
    double? w = double.tryParse(weight);

    if (h == null || w == null || h == 0) {
      setState(() {
        result = 'Enter valid input'; // bad input
      });
      return;
    }

    double bmi;

    if (unit == 'imperial') {
      bmi = (w / (h * h)) * 703;
    } else {
      bmi = w / (h * h);
    }

    setState(() {
      result = bmi.toStringAsFixed(2); // show number
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        centerTitle: true,
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // spacing
        child: ListView(
          children: [
            const Text(
              'Choose unit type',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'imperial',
                  groupValue: unit,
                  onChanged: (value) {
                    setState(() {
                      unit = value.toString(); // imperial
                    });
                  },
                ),
                const Text('Imperial', style: TextStyle(color: Colors.brown)),
                Radio<String>(
                  value: 'metric',
                  groupValue: unit,
                  onChanged: (value) {
                    setState(() {
                      unit = value.toString(); // metric
                    });
                  },
                ),
                const Text('Metric', style: TextStyle(color: Colors.brown)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              style: const TextStyle(color: Colors.brown),
              decoration: InputDecoration(
                labelText: unit == 'imperial' ? 'Height (in)' : 'Height (m)',
                labelStyle: const TextStyle(color: Colors.brown),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                height = value; // save height
              },
            ),
            const SizedBox(height: 10),
            TextField(
              style: const TextStyle(color: Colors.brown),
              decoration: InputDecoration(
                labelText: unit == 'imperial' ? 'Weight (lb)' : 'Weight (kg)',
                labelStyle: const TextStyle(color: Colors.brown),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                weight = value; // save weight
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              onPressed: calculate, // calculate
              child: const Text(
                'Calculate BMI',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'BMI Result',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Colors.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
