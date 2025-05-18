import 'package:flutter/material.dart';
import 'package:productify/screens/TaskReminder/addNewTask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'CustomWidgets/taskList.dart';
import 'package:intl/intl.dart';

class HomeTR extends StatefulWidget {
  const HomeTR({super.key});

  @override
  State<HomeTR> createState() => _HomeTRState();
}

List<Task> taskList = [];
List<Task> taskDoneList = [];
String _currentDate = '';

class _HomeTRState extends State<HomeTR> {
  @override
  void initState() {
    if (taskList.isEmpty && taskDoneList.isEmpty) {
      getTaskFromLocalDB('');
    }
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    _currentDate = getCurrentDate();
    super.initState();
  }

  String getCurrentDate() {
    DateTime today = DateTime.now();
    DateFormat dateFormat = DateFormat('d MMMM yyyy');
    String formattedDate = dateFormat.format(today);
    return formattedDate;
  }

  Future<void> getTaskFromLocalDB(String taskId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskIdList = [];
    if (taskId != '') {
      taskIdList.add(taskId);
    } else {
      taskIdList = prefs.getStringList('taskIdList');
    }
    // await prefs.setStringList('taskIdList',[]);
    taskIdList?.forEach((Id) {
      final List<String>? task = prefs.getStringList(Id);
      if (task != null) {
        Task taskToAdd = Task(
            title: task[0],
            category: task[1],
            date: task[2],
            time: task[3],
            note: task[4],
            isChecked: task[5].toLowerCase() == 'true',
            isRepeat: task[6].toLowerCase() == 'true',
            id: task[7],
            repeatType: task[8]);

        task[5].toLowerCase() == 'true' //If task is done
            ? taskDoneList.add(taskToAdd)
            : taskList.add(taskToAdd);
      }
    });

    sortTaskList();
    setState(() {});
  }

  void _updateTask(Task task) {
    if (task.isChecked) {
      taskList.remove(task);
      taskDoneList.add(task);
    } else {
      taskList.add(task);
      taskDoneList.remove(task);
    }
    sortTaskList();
    setState(() {});
  }

  void sortTaskList() {
    taskList.sort((a, b) =>
        a.getDateTime(a.date, a.time).compareTo(b.getDateTime(b.date, b.time)));
    taskDoneList.sort((a, b) =>
        a.getDateTime(a.date, a.time).compareTo(b.getDateTime(b.date, b.time)));
  }

  void addNewTask() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddNewTask(task: Task())));

    if (result != null) {
      getTaskFromLocalDB(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1, // This gives 25% of the available height
                child: Container(
                  width: double.infinity,
                  color: Color(0xFF40D8AA),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 5,
                            bottom: 5),
                        child: Text(
                          _currentDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'My Todo List',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3, // This gives 75% of the available height
                child: Container(
                  width: double.infinity,
                  color: Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
          // Positioned container in the middle and above the two Expanded containers
          Positioned(
            top: screenHeight * 0.25 - 80,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: screenWidth * 0.90,
                    height: screenHeight * 0.45,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: taskList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'No Pending Task!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black38),
                                ),
                                IconButton(
                                    onPressed: () => addNewTask(),
                                    icon: const Icon(
                                      Icons.add_circle_outlined,
                                      color: Color(0xFF40D8AA),
                                      size: 40,
                                    ))
                              ],
                            ),
                          )
                        : CustomListViewContainer(
                            tasksList: taskList,
                            onTaskUpdate: _updateTask,
                            isTodoContext: true,
                          )),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                        fontSize: 15, // Example font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Container(
                  width: screenWidth * 0.90,
                  height: screenHeight * 0.22,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: taskDoneList.isEmpty
                      ? const Center(
                          child: Text(
                            'Nothing Completed',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black38),
                          ),
                        )
                      : CustomListViewContainer(
                          tasksList: taskDoneList,
                          onTaskUpdate: _updateTask,
                          isTodoContext: false,
                        ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () => addNewTask(),
                  child: Container(
                    width: screenWidth * 0.90,
                    height: screenHeight * 0.07,
                    margin: EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF40D8AA),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Add New Task',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 16, // Padding from the left
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
