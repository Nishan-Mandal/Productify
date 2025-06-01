import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:productify/screens/TaskReminder/home_tr.dart';
import 'package:productify/utils/WeatherService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';
import 'TaskReminder/CustomWidgets/liveClock.dart';
import 'package:weather_icons/weather_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences prefs;
  String _greetingText = '';
  String _weekDay = '';
  Color textColor = Colors.white70;
  double weatherDetailsTextSize = 10;
  bool isCurrentWeather = false;
  bool isInProgress = false;

  Map<String, String> weatherDetailsMap = {
    'Temperature': '25°',
    'Location': 'Washington',
    'FeelsLike': '28°',
    'Humidity': '51',
    'Wind': '28.91',
    'WeatherDescription': 'scattered clouds',
    'WeatherIcon': '10n'
  };


  Future<Map<String, String>> getLastWeatherDetails() async {
    Map<String, String> weatherDetailsMap = Map();
    
     List<String>? weatherDetailsList = prefs.getStringList('lastWeatherDetails');
     if(weatherDetailsList != null){
      weatherDetailsMap['Temperature'] = weatherDetailsList![0];
      weatherDetailsMap['Location'] = weatherDetailsList[1];
      weatherDetailsMap['FeelsLike'] = weatherDetailsList[2];
      weatherDetailsMap['Humidity'] = weatherDetailsList[3];
      weatherDetailsMap['Wind'] = weatherDetailsList[4];
      weatherDetailsMap['WeatherDescription'] = weatherDetailsList[5];
      weatherDetailsMap['WeatherIcon'] = weatherDetailsList[6];
     }
     return weatherDetailsMap;
  }

  Future<Map<String, String>> getCurrentWeatherDetails() async {
    Map<String, String> currentWeatherDetailsMap = Map();
    List<String> currentWeatherDetailsList = [];
    Weather? weather = await _fetchWeather();
    currentWeatherDetailsMap['Temperature'] = '${weather?.temperature.toString().split('.')[0]}°';
    currentWeatherDetailsMap['Location'] = '${weather?.areaName}';
    currentWeatherDetailsMap['FeelsLike'] = '${weather?.tempFeelsLike}';
    currentWeatherDetailsMap['Humidity'] = '${weather?.humidity}';
    currentWeatherDetailsMap['Wind'] = (weather!.windSpeed! * 3.6).toStringAsFixed(2);
    currentWeatherDetailsMap['WeatherDescription'] = '${weather.weatherDescription}';
    currentWeatherDetailsMap['WeatherIcon'] = '${weather.weatherIcon}';

    currentWeatherDetailsList.add(currentWeatherDetailsMap['Temperature']!);
    currentWeatherDetailsList.add(currentWeatherDetailsMap['Location']!);
    currentWeatherDetailsList.add(currentWeatherDetailsMap['FeelsLike']!);
    currentWeatherDetailsList.add(currentWeatherDetailsMap['Humidity']!);
    currentWeatherDetailsList.add(currentWeatherDetailsMap['Wind']!);
    currentWeatherDetailsList.add(currentWeatherDetailsMap['WeatherDescription']!);
    currentWeatherDetailsList.add(currentWeatherDetailsMap['WeatherIcon']!);
    
    await prefs.setStringList('lastWeatherDetails', currentWeatherDetailsList);
    isCurrentWeather = true;

    return currentWeatherDetailsMap;
  }
  
  @override
  void initState() {
    super.initState();

    _greetingText = getGreeting();
    _weekDay = getCurrentWeekDay();
    if (_greetingText == 'Morning' || _greetingText == 'Afternoon') {
      textColor = Colors.black;
    }
     // Call async method without await
    _initAsyncData();
  }

  Future<void> _initAsyncData() async {
    prefs = await SharedPreferences.getInstance();
    Map<String, String> fetchedDetails = await getLastWeatherDetails();
    if (fetchedDetails.isNotEmpty) {
      weatherDetailsMap = fetchedDetails;
    }
    setState(() {});
  }

  Future<Weather?> _fetchWeather() async {
    Position? currentPosition = await WeatherService.getCurrentLocation();
    Weather? weather = await WeatherService.getWeather(
    currentPosition!.latitude, currentPosition.longitude);
    return weather;
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour >= 4 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 16) {
      return 'Afternoon';
    } else if (hour >= 4 && hour <= 20) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  String getCurrentWeekDay() {
    DateTime now = DateTime.now();
    int weekday = now.weekday;

    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  Future<LottieComposition?> customDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(bytes, filePicker: (files) {
      return files.firstWhereOrNull(
          (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _greetingText == 'Morning' || _greetingText == 'Afternoon'
              ? Colors.blue
              : Colors.indigo,
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _greetingText == 'Morning' || _greetingText == 'Afternoon'
                ? [Colors.blue, Colors.white, Colors.white]
                : [Colors.indigo, Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              alignment: Alignment.topCenter,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(
                  top: 20,
                  left: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good $_greetingText!',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      LiveClock(textColor: textColor),
                      Text(
                        '$_weekDay',
                        style: TextStyle(color: textColor),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${weatherDetailsMap['Temperature']}',
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                                color: textColor),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${weatherDetailsMap['Location']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: textColor),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 13,
                            color: textColor,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                _greetingText == 'Morning' || _greetingText == 'Afternoon'
                    ? Positioned(
                        top: 10,
                        right: 10,
                        child: Lottie.asset('assets/images/sun.lottie',
                            decoder: customDecoder),
                        height: 150,
                      )
                    : Positioned(
                        top: 10,
                        right: 10,
                        height: 160,
                        child: SvgPicture.asset(
                          _greetingText == 'Morning'
                              ? 'assets/images/morningSun.svg'
                              : _greetingText == 'Evening'
                                  ? 'assets/images/eveningClouds.svg'
                                  : 'assets/images/nightMoon.svg',
                          height: 200,
                          width: 200,
                        ),
                      )
              ]),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 80,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15)),
                border: Border.all(width: 1, color: Colors.black38),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  isCurrentWeather?Image.network(
                    'https://openweathermap.org/img/wn/${weatherDetailsMap['WeatherIcon']}@2x.png',
                    fit: BoxFit.fill,
                  ):isInProgress?CircularProgressIndicator():IconButton(onPressed: () async {
                    isInProgress = true;
                    setState(() {});
                    weatherDetailsMap = await getCurrentWeatherDetails();
                    isInProgress = false;
                    setState(() {});
                  }, icon: Icon(Icons.refresh, size: 40,)),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sunny,
                            color: Colors.white,
                            size: 12,
                          ),
                          Text(
                            '  Feels like ${weatherDetailsMap['FeelsLike']?.split('.')[0]}° \n',
                            style: TextStyle(fontSize: weatherDetailsTextSize),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.air_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          Text(
                            ' Winds ${weatherDetailsMap['Wind']} Kph',
                            style: TextStyle(fontSize: weatherDetailsTextSize),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            WeatherIcons.humidity,
                            color: Colors.white,
                            size: 12,
                          ),
                          Text(
                            ' Humidity ${weatherDetailsMap['Humidity']?.split('.')[0]}% \n',
                            style: TextStyle(fontSize: weatherDetailsTextSize),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud,
                            color: Colors.white,
                            size: 15,
                          ),
                          Text(
                            ' ${weatherDetailsMap['WeatherDescription']}',
                            style: TextStyle(fontSize: weatherDetailsTextSize),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeTR()));
                  },
                  child: SvgPicture.asset(
                    'assets/images/todoIcon.svg',
                    height: 150,
                    width: 200,
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/noteIcon.svg',
                  height: 150,
                  width: 150,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/AI.svg',
                  height: 150,
                  width: 200,
                ),
                SvgPicture.asset(
                  'assets/images/QuestionMark.svg',
                  height: 150,
                  width: 150,
                ),
              ],
            ),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Tip of day: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        'Continue to set new goals. Think about what you want ',
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
