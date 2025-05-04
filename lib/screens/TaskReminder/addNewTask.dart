import 'dart:developer';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
// import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:productify/screens/TaskReminder/home_tr.dart';
import 'package:productify/utils/local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomWidgets/taskList.dart';

class AddNewTask extends StatefulWidget {
  final Task task;
  const AddNewTask({super.key, required this.task});

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DateTime now = DateTime.now();

  String? _selectedDate;
  String? _selectedTime;
  DateTime? _scheduleDateTime;

  bool _everyday = false;
  bool _everyWeek = false;
  bool _everyMonth = false;
  bool _isRepeat = false;

  bool _titleBoxBorder = false;
  bool _dateBoxBorder = false;
  bool _timeBoxBorder = false;

  String _category = 'note';
  String _categoryImageUrl = 'assets/images/note.png';

  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    if (!widget.task.title.isEmpty) {
      _titleController.text = widget.task.title;
      _selectedDate = widget.task.date;
      _selectedTime = widget.task.time;
      _noteController.text = widget.task.note;
      _isRepeat = widget.task.isRepeat;
      _assignRepeatType(widget.task.repeatType);
      _updateCategory(widget.task.category);
      _updateScheduleDateTime(_selectedDate, _selectedTime, now);
    }
    super.initState();
  }

  void dateTimePicker() async {
    try {
      var date;
      date = await showDatePicker(
        context: context,
        firstDate: now,
        initialDate: now,
        lastDate: DateTime(2100),
      );
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(now),
        );
        if (date == null || time == null) return;

        _updateScheduleDateTime(date, time, now);
      }
    } catch (e) {}
  }

  _updateScheduleDateTime(var date, var time, var now) {
    try {
      if (date is String) {
        DateTime dateValue = DateFormat('dd-MM-yyyy').parse(date);
        DateTime dateTime = DateFormat("h:mm a").parse(time);
        TimeOfDay timeValue = TimeOfDay.fromDateTime(dateTime);

        date = dateValue;
        time = timeValue;
      }
      _scheduleDateTime = DateTimeField.combine(date, time);
      _selectedDate = dateFormatter.format(date);
      _selectedTime = _formatTimeOfDay(time);
      setState(() {});
    } catch (e) {
      log('Exception-_updateScheduleDateTime $e');
    }
  }

  String generateUniqueTimestampId() {
    int timeStamp = DateTime.now().microsecondsSinceEpoch;
    String uniqueNumber = timeStamp.toString().substring(0, 5) +
        timeStamp.toString().substring(6, 9);
    return uniqueNumber;
  }

  bool _validation() {
    bool isAlldataPopulated = true;
    if (_titleController.text.isEmpty) {
      _titleBoxBorder = true;
      isAlldataPopulated = false;
    }
    if (_selectedDate == null) {
      _dateBoxBorder = true;
      isAlldataPopulated = false;
    }
    if (_selectedTime == null) {
      _timeBoxBorder = true;
      isAlldataPopulated = false;
    }
    if (_scheduleDateTime == null || _scheduleDateTime!.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a future time."),
        backgroundColor: Colors.red,
      ));
      isAlldataPopulated = false;
    }

    setState(() {});
    return isAlldataPopulated;
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<String> saveTaskInLocalDB(List<String> task) async {
    final SharedPreferences prefs = await _prefs;
    List<String> taskIdList = prefs.getStringList('taskIdList') ?? [];
    String uniqueKey = task[7];
    //If new task
    if (widget.task.title.isEmpty) {
      taskIdList.add(uniqueKey);
    }
    await prefs.setStringList(uniqueKey, task);
    await prefs.setStringList('taskIdList', taskIdList);
    return uniqueKey;
  }

  String _repeatType() {
    if (_everyday) return 'daily';
    if (_everyWeek) return 'weekly';
    if (_everyMonth) return 'monthly';
    return '';
  }

  void _assignRepeatType(String repeatFrequency) {
    if (repeatFrequency == 'daily') {
      _everyday = true;
    } else if (repeatFrequency == 'weekly') {
      _everyWeek = true;
    } else {
      _everyMonth = true;
    }
  }

  String _updateCategoryUrl(String category) {
    _category = category;
    if (category == 'note') {
      _categoryImageUrl = 'assets/images/note.png';
    } else if (category == 'event') {
      _categoryImageUrl = 'assets/images/calander.png';
    } else {
      _categoryImageUrl = 'assets/images/trophy.png';
    }
    setState(() {});
    return _category;
  }

  void _updateCategory(String categoryUrl) {
    _categoryImageUrl = categoryUrl;
    if (categoryUrl == 'assets/images/note.png') {
      _category = 'note';
    } else if (categoryUrl == 'assets/images/calander.png') {
      _category = 'event';
    } else {
      _category = 'trophy';
    }
    setState(() {});
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure?',
          ),
          content: const Text(
            'You want to leave this page without Save/Update the page?',
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Stay'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  String getRemainingTime(DateTime scheduledDateTime) {
    Duration difference = scheduledDateTime.difference(DateTime.now());
    if (difference.isNegative) {
      return 'The scheduled time has passed.';
    } else {
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;
      String timeRemaining = '';
      if(days!=0) timeRemaining += '$days days, ';
      if(hours!=0) timeRemaining += '$hours hours, ';
      timeRemaining += '$minutes minutes remaining';
      return timeRemaining;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ToastContext().init(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
              color: const Color(0xFF40D8AA),
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final bool shouldPop = await _showBackDialog() ?? false;
                      if (context.mounted && shouldPop) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 10, left: 10),
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
                  const Text(
                    'Add New Task',
                    style: TextStyle(
                        fontSize: 15, // Example font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (widget.task.id.isNotEmpty) {
                        final SharedPreferences prefs = await _prefs;
                        await prefs.remove('${widget.task.id}');
                        List<String> taskIdList =
                            await prefs.getStringList('taskIdList') ?? [];
                        taskIdList.remove(widget.task.id);
                        await prefs.setStringList('taskIdList', taskIdList);
                        await LocalNotifications.cancel('${widget.task.id}');
                        taskList.remove(widget.task);
                        taskDoneList.remove(widget.task);
                      }

                      Navigator.pop(context, widget.task);
                    },
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8, // This gives 75% of the available height
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF1F5F9),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Title',
                          style: TextStyle(color: Colors.black),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 20),
                          child: TextField(
                            controller: _titleController,
                            onTap: () {
                              _titleBoxBorder = false;
                            },
                            decoration: InputDecoration(
                                hintText: 'Enter your text here',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: _titleBoxBorder
                                      ? BorderSide(color: Colors.red, width: 1)
                                      : BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: _titleBoxBorder
                                      ? BorderSide(color: Colors.red, width: 1)
                                      : BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0)),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Category',
                              style: TextStyle(color: Colors.black),
                            ),

                            SizedBox(
                                width: 20), // Space between text and first icon
                            GestureDetector(
                              onTap: () {
                                _updateCategoryUrl('note');
                              },
                              child: Container(
                                width:
                                    44.0, // 40 (CircleAvatar's diameter) + 2*2 (border width)
                                height: 44.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _category == 'note'
                                        ? Color(0xFF40D8AA)
                                        : Colors.transparent,
                                    width:
                                        2.0, // Change to your preferred border width
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage('assets/images/note.png'),
                                ),
                              ),
                            ),

                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                _updateCategoryUrl('event');
                              },
                              child: Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _category == 'event'
                                        ? Color(0xFF40D8AA)
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage('assets/images/calander.png'),
                                ),
                              ),
                            ),

                            SizedBox(width: 10),

                            GestureDetector(
                              onTap: () {
                                _updateCategoryUrl('trophy');
                              },
                              child: Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _category == 'trophy'
                                        ? Color(0xFF40D8AA)
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage('assets/images/trophy.png'),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'When',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _dateBoxBorder = false;
                            _timeBoxBorder = false;
                            dateTimePicker();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: _dateBoxBorder
                                        ? Colors.red
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_selectedDate != null ? _selectedDate : 'Date'}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(width: 15.0),
                                    const Icon(Icons.calendar_today_outlined,
                                        color: Colors.black),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: _timeBoxBorder
                                        ? Colors.red
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_selectedTime != null ? _selectedTime : 'Time'}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(width: 15.0),
                                    const Icon(Icons.timer_outlined,
                                        color: Colors.black),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Repeat',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            Checkbox(
                              value: _isRepeat,
                              onChanged: (bool? value) async {
                                _isRepeat = value!;
                                _everyday = value;
                                _everyWeek = false;
                                _everyMonth = false;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        _isRepeat
                            ? Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _everyday = !_everyday;
                                        _everyWeek = false;
                                        _everyMonth = false;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 10),
                                      padding: EdgeInsets.only(
                                          top: 2,
                                          bottom: 3,
                                          left: 10,
                                          right: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _everyday
                                                ? Color(0xFF40D8AA)
                                                : Colors.black,
                                            width: _everyday ? 1.5 : 0.5,
                                          )),
                                      child: const Text(
                                        'Daily',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _everyWeek = !_everyWeek;
                                        _everyday = false;
                                        _everyMonth = false;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 10),
                                      padding: EdgeInsets.only(
                                          top: 2,
                                          bottom: 3,
                                          left: 10,
                                          right: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _everyWeek
                                              ? Color(0xFF40D8AA)
                                              : Colors.black,
                                          width: _everyWeek ? 1.5 : 0.5,
                                        ),
                                      ),
                                      child: const Text(
                                        'Every Week',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _everyMonth = !_everyMonth;
                                        _everyday = false;
                                        _everyWeek = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 2,
                                          bottom: 3,
                                          left: 10,
                                          right: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _everyMonth
                                                ? Color(0xFF40D8AA)
                                                : Colors.black,
                                            width: _everyMonth ? 1.5 : 0.5,
                                          )),
                                      child: const Text(
                                        'Every Month',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: _isRepeat ? 30 : 20,
                        ),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0), // Border color
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(
                                    0xFFE0E0E0), // Border color when enabled
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(
                                    0xFFE0E0E0), // Border color when focused
                              ),
                            ),
                            labelText: 'Notes (Optional)',
                            hintText: 'Enter your notes here...',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5, // Allows multiple lines of input
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                // try {
                if (!_validation()) return;
                String uniqueId = widget.task.id;
                if (widget.task.title.isEmpty) {
                  uniqueId = generateUniqueTimestampId();
                }

                String taskKey = await saveTaskInLocalDB([
                  '${_titleController.text}',
                  _categoryImageUrl,
                  '$_selectedDate',
                  '$_selectedTime',
                  '${_noteController.text}',
                  '${widget.task.isChecked}',
                  '$_isRepeat',
                  uniqueId,
                  _repeatType()
                ]);
                if (!widget.task.title.isEmpty) {
                  widget.task.title = _titleController.text;
                  widget.task.category = _categoryImageUrl;
                  widget.task.date = '$_selectedDate';
                  widget.task.time = '$_selectedTime';
                  widget.task.note = _noteController.text;
                }

                LocalNotifications.scheduleTask(
                    uniqueId,
                    _scheduleDateTime!,
                    _titleController.text,
                    _noteController.text,
                    _isRepeat,
                    _repeatType());
                // Toast.show(getRemainingTime(_scheduleDateTime!),
                //     duration: Toast.lengthLong, gravity: Toast.bottom);
                Navigator.pop(context, taskKey);

                // } catch (e) {
                //   log('Excpetion while adding task');
                // }
              },
              child: Container(
                width: screenWidth * 0.90,
                height: screenHeight * 0.07,
                margin: EdgeInsets.only(bottom: 15),
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
                child: Center(
                  child: Text(
                    widget.task.title.isEmpty ? 'Save' : 'Update',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
