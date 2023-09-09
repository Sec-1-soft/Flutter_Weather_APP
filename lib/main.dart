import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;


void main()=>runApp(WeatherMaterial());

class WeatherMaterial extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScaffold(),
    );
  }
}


class WeatherScaffold extends StatefulWidget{
  @override
  WeatherScaffoldState createState()=> WeatherScaffoldState();
}


class WeatherScaffoldState extends State<WeatherScaffold>{
  TextEditingController _weatherCity = TextEditingController();
  bool _isTap = false;
  String city = "";
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("lib/assets/backgroundImage.jpg"),
          fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height:MediaQuery.of(context).size.height * 0.3,
                  child: Text("Hava Durumu",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        color: Colors.white38,
                        blurRadius: 10,
                        offset: Offset(0, 1)
                      )
                    ]
                  ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _weatherCity,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(onPressed:(){
                         setState(() {
                           city = _weatherCity.text;
                           _isTap = true;
                         });
                      }, icon:Icon(Icons.search)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        )
                      )
                    ),
                  ),
                ),
                 SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                 _isTap ? weatherDataContainer(city:city) : SizedBox(),
              ],
            ),
          ],
        ),
      )
    );
  }
}

class weatherDataContainer extends StatefulWidget{
  String city;
  weatherDataContainer({required this.city});
  @override
  DataContainer createState()=>DataContainer();
}

class DataContainer extends State<weatherDataContainer>{

  @override
  Widget build(BuildContext context){
    bool _isTablet = MediaQuery.of(context).size.width * 0.6 >= 600;
    final API_KEY = '';  //Your OpenWeatherMap API Key
    String CITY = widget.city;

    Future<String> getData() async{
      final response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&lang=tr"));
      if(response.statusCode == 200){
        return response.body;
      }else{
        throw Exception("API2ye ulaşılamadı");
      }
    }

    return FutureBuilder(future:getData(), builder:(context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting){
        return Column(
          children: [
            CircularProgressIndicator(),
            Text("Lütfen bekleyin.."),
          ],
        );
      }else if(snapshot.hasError){
        return Column(
          children: [
            CircularProgressIndicator(),
            Text("Geçici bir hata oluştu..."),
          ],
        );
      }else{
        String dataString = snapshot.data.toString();
        Map<String,dynamic> data = jsonDecode(dataString); 
        windDirection(data["wind"]["deg"]);
        String state = data["weather"][0]["description"];
        String weatherState = "";
        for(int i = 0;i<state.length;){
          if(i == 0){
            weatherState += state[i].toUpperCase();
          }
           else {
            weatherState += state[i];
          }
           i++;
        }
        return Container(
          padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(5),
            alignment: Alignment.center,
            width: _isTablet ? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            Expanded(
                              child: Text(data["sys"]["country"] + "," + data["name"],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),//Lokasyon bilgisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        child: Image.asset(getWeatherIcon(data["weather"][0]["icon"].toString())),
                      ),
                    ),  //Hava durumu resmi için
                    Expanded(child:
                    Column(
                      children: [
                        Text(kelvinToCelsius(data["main"]["temp"]).toString() + "\u00B0",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                        ),
                        SizedBox(height: 5,),
                        Text(weatherState,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        ),
                      ],
                    )) //Hava durumu değeri için
                  ],
                ),
                Column(
                  children: [
                    Container(child: Row(
                      children: [
                        Image.asset("lib/assets/wind_icon.png",
                        width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 5,),
                        Text(data["wind"]["speed"].toInt().toString() + " " +"m/s",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        ),
                        SizedBox(width: 5,),
                        Text(wind_direction,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),),
                    SizedBox(height: 10,),
                    Container(child: Row(
                      children: [
                        Icon(Icons.cloud),
                        SizedBox(width: 5,),
                        Text(data["clouds"]["all"].toString() + "%",
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),),
                        SizedBox(width: 5,),
                        Text("Bulutlu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),),
                  ],
                )
              ],
            )
        );
      }
    },
    );
  }
}


String wind_direction = "";

void windDirection(int Speed) {
  if (Speed == 0 || Speed == 360) {
    wind_direction = "Kuzey";
  } else if (Speed > 0 && Speed < 90) {
    wind_direction = "KuzeyDoğu";
  } else if (Speed == 90) {
    wind_direction = "Doğu";
  } else if (Speed > 90 && Speed < 180) {
    wind_direction = "GüneyDoğu";
  } else if (Speed == 180) {
    wind_direction = "Güney";
  } else if (Speed > 180 && Speed < 270) {
    wind_direction = "GüneyBatı";
  } else if (Speed == 270) {
    wind_direction = "Batı";
  } else if (Speed > 270 && Speed < 360) {
    wind_direction = "KuzeyBatı";
  } else {
    // Belirli bir dereceye uymuyorsa bir hata mesajı veya varsayılan değer atanabilir.
    wind_direction = "Bilinmeyen";
  }
}


int kelvinToCelsius(double kelvin) {
  return (kelvin - 273.15).toInt();
}


DateTime Time(int UnixTime){ //Uniz zamanı normal zamana dönüştürdü.
  return DateTime.fromMillisecondsSinceEpoch(UnixTime);
}



String getWeatherIcon(String weatherCode) {
  switch (weatherCode) {
    case "01d":
      return "lib/assets/sun.png"; // Açık hava (güneşli)
    case "01n":
      return "lib/assets/moon"; // Açık hava (gece)
    case "02d":
      return "lib/assets/sun_partly.png"; // Az bulutlu (güneşli)
    case "02n":
      return "lib/assets/moon_partly.png"; // Az bulutlu (gece)
    case "03d":
      return "lib/assets/sun_partly.png"; // Parçalı bulutlu (güneşli)
    case "03n":
      return "lib/assets/moon_partly.png"; // Parçalı bulutlu (gece)
    case "04d":
      return "lib/assets/cloud.png"; // Bulutlu (güneşli)
    case "04n":
      return "lib/assets/cloud.png"; // Bulutlu (gece)
    case "09d":
      return "lib/assets/light_rain.png"; // Hafif yağmurlu (güneşli)
    case "09n":
      return "lib/assets/light_rain.png"; // Hafif yağmurlu (gece)
    case "10d":
      return "lib/assets/heavy_rain.png"; // Yağmurlu (güneşli)
    case "10n":
      return "lib/assets/heavy_rain.png"; // Yağmurlu (gece)
    case "11d":
      return "lib/assets/storm_heavy_rain.png"; // Gökgürültülü fırtına (güneşli)
    case "11n":
      return "lib/assets/storm_heavy_rain.png"; // Gökgürültülü fırtına (gece)
    case "13d":
      return "lib/assets/snow.png"; // Karlı (güneşli)
    case "13n":
      return "lib/assets/snow.png"; // Karlı (gece)
    case "50d":
      return "lib/assets/foggy.png"; // Sisli (güneşli)
    case "50n":
      return "lib/assets/foggy_night.png"; // Sisli (gece)
    default:
      return "lib/assets/sun.png"; // Bilinmeyen hava durumu
  }
}

