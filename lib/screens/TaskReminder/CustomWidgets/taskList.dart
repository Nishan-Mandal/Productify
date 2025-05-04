import 'dart:math';

import 'package:flutter/material.dart';
import 'package:productify/screens/TaskReminder/addNewTask.dart';
import 'package:productify/screens/TaskReminder/home_tr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CustomListViewContainer extends StatefulWidget {
  final List<Task> tasksList;
  final ValueChanged<Task> onTaskUpdate;
  final bool isTodoContext;

  CustomListViewContainer(
      {Key? key,
      required this.tasksList,
      required this.onTaskUpdate,
      required this.isTodoContext})
      : super(key: key);

  @override
  State<CustomListViewContainer> createState() =>
      _CustomListViewContainerState();
}

class _CustomListViewContainerState extends State<CustomListViewContainer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isRepeatFilter = false;

  String _getDisplayDate(String date) {
    DateTime taskDate = DateFormat('dd-MM-yyyy').parse(date);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(Duration(days: 1));
    DateTime yesterday = today.add(Duration(days: -1));
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd-MM-yyyy').format(taskDate);
    }
  }

  bool _isTaskOverdue(DateTime dateTime) {
    DateTime now = DateTime.now();
    return now.isAfter(dateTime);
  }

  String _displayDateTime(Task task) {
    switch (task.repeatType) {
      case 'daily':
        return '';
      case 'weekly':
        const List<String> daysOfWeek = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        return daysOfWeek[
            DateFormat('dd-MM-yyyy').parse(task.date).weekday - 1];
      case 'monthly':
        return DateFormat('dd-MM-yyyy').parse(task.date).day.toString() + ' ';
    }
    return '';
  }

  void _repeatFilter(bool isRepeat) {
    if (isRepeat) {
      _isRepeatFilter = true;
    } else {
      _isRepeatFilter = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.isTodoContext
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _repeatFilter(false);
                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              top: 2, bottom: 2, left: 20, right: 20),
                          margin: EdgeInsets.only(
                              top: 3, left: 3, right: 1.5, bottom: 3),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isRepeatFilter
                                ? Colors.grey[400]
                                : Colors.grey[200],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12)),
                          ),
                          child: const Text(
                            'One Time',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _repeatFilter(true);
                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              top: 2, bottom: 2, left: 20, right: 20),
                          margin: EdgeInsets.only(
                              top: 3, right: 3, left: 1.5, bottom: 3),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isRepeatFilter
                                ? Colors.grey[200]
                                : Colors.grey[400],
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                          ),
                          child: Text(
                            'Repeat',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          )),
                    ),
                  ),
                ],
              )
            : SizedBox(),
        Expanded(
          child: ListView.builder(
            itemCount: widget.tasksList.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final task = widget.tasksList[index];
              String displayDate = _getDisplayDate(task.date);
              if (task.isRepeat) {
                displayDate = _displayDateTime(task);
              }
              Task taskObj = Task();
              bool isOverdue =
                  _isTaskOverdue(taskObj.getDateTime(task.date, task.time));
              return task.isRepeat == _isRepeatFilter
                  ?  Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10, left: 20, right: 10),
                            child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddNewTask(task: task)));
                        setState(() {});
                      },
                      
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width:
                                  44.0, 
                              height: 44.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black38,
                                  width:
                                      1.0, // Change to your preferred border width
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  task.category,
                                  width: 40.0,
                                  height: 40.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title.length > 25
                                      ? '${task.title.substring(0, 26)}...'
                                      : task.title,
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(
                                    height:
                                        4.0), // Add some space between title and date/time
                                Row(
                                  children: [
                                    Text(
                                      '$displayDate ${task.time}',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.0),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    task.isRepeat
                                        ? Text(task.repeatType,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 12.0))
                                        : Text(
                                            task.isChecked
                                                ? 'Done'
                                                : isOverdue
                                                    ? 'Overdue'
                                                    : 'Upcoming',
                                            style: TextStyle(
                                                color: task.isChecked
                                                    ? Colors.green
                                                    : isOverdue
                                                        ? Colors.red
                                                        : Colors.green,
                                                fontSize: 12.0),
                                          ),
                                    // Spacer(),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            task.isRepeat
                                ? Icon(Icons.repeat)
                                : Checkbox(
                                    value: task.isChecked,
                                    onChanged: (bool? value) async {
                                      final SharedPreferences prefs =
                                          await _prefs;
                                      task.isChecked = value!;
                                      List<String> taskData = [
                                        task.title,
                                        task.category,
                                        task.date,
                                        task.time,
                                        task.note,
                                        '${task.isChecked}',
                                        '${task.isRepeat}',
                                        '${task.id}',
                                        '${task.repeatType}',
                                      ];

                                      await prefs.setStringList(
                                          '${task.id}', taskData);
                                      widget.onTaskUpdate(task);
                                      setState(() {});
                                    },
                                  )
                          ],
                        ),
                      ))

                  //   child: ListTile(
                  //       leading: Container(
                  //          width:
                  //               44.0, // 40 (CircleAvatar's diameter) + 2*2 (border width)
                  //           height: 44.0,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             border: Border.all(
                  //               color: Colors.black38,
                  //               width:
                  //                   1.0, // Change to your preferred border width
                  //             ),
                  //           ),
                  //         child: ClipOval(
                  //           child: Image.asset(
                  //             task.category,
                  //             width: 40.0,
                  //             height: 40.0,
                  //             fit: BoxFit.cover,

                  //           ),
                  //         ),
                  //       ),
                  //       title: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             task.title.length > 25
                  //                 ? '${task.title.substring(0, 25)}...'
                  //                 : task.title,
                  //             style: TextStyle(color: Colors.black),
                  //           ),
                  //           SizedBox(
                  //               height:
                  //                   4.0), // Add some space between title and date/time
                  //           Row(
                  //             children: [
                  //               Text(
                  //                 '$displayDate ${task.time}',
                  //                 style: TextStyle(
                  //                     color: Colors.grey, fontSize: 12.0),
                  //               ),
                  //               SizedBox(width: 10,),
                  //               task.isRepeat
                  //                   ? Text(task.repeatType,
                  //                       style: TextStyle(
                  //                           color: Colors.green,
                  //                           fontSize: 12.0))
                  //                   : Text(
                  //                       task.isChecked
                  //                           ? 'Done'
                  //                           : isOverdue
                  //                               ? 'Overdue'
                  //                               : 'Upcoming',
                  //                       style: TextStyle(
                  //                           color: task.isChecked
                  //                               ? Colors.green
                  //                               : isOverdue
                  //                                   ? Colors.red
                  //                                   : Colors.green,
                  //                           fontSize: 12.0),
                  //                     ),Spacer(),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //       trailing: task.isRepeat
                  //           ? Icon(Icons.repeat)
                  //           : Checkbox(
                  //               value: task.isChecked,
                  //               onChanged: (bool? value) async {
                  //                 final SharedPreferences prefs =
                  //                     await _prefs;
                  //                 task.isChecked = value!;
                  //                 List<String> taskData = [
                  //                   task.title,
                  //                   task.category,
                  //                   task.date,
                  //                   task.time,
                  //                   task.note,
                  //                   '${task.isChecked}',
                  //                   '${task.isRepeat}',
                  //                   '${task.id}',
                  //                   '${task.repeatType}',
                  //                 ];

                  //                 await prefs.setStringList(
                  //                     '${task.id}', taskData);
                  //                 widget.onTaskUpdate(task);
                  //                 setState(() {});
                  //               },
                  //             )),
                  // )
                  : SizedBox();
            },
          ),
        ),
      ],
    );
  }
}

class Task {
  String title;
  String category;
  String date;
  String time;
  String note;
  bool isChecked;
  bool isRepeat;
  String id;
  String repeatType;
  Task({
    this.title = '',
    this.category = '',
    this.date = '',
    this.time = '',
    this.note = '',
    this.isChecked = false,
    this.isRepeat = false,
    this.id = '',
    this.repeatType = '',
  });

  DateTime getDateTime(String date, String time) {
    String dateReversed = changeDateFormat(date);
    DateTime parsedDateTime =
        DateFormat('yyyy-MM-dd hh:mm a').parse('$dateReversed $time');
    return parsedDateTime;
  }

  String changeDateFormat(String date) {
    String format = date.substring(6, 10) +
        '-' +
        date.substring(3, 5) +
        '-' +
        date.substring(0, 2);
    return format;
  }
}
