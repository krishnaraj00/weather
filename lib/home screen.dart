import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService weatherService = WeatherService();
  final TextEditingController cityController = TextEditingController();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchWeatherByCity("Edappal"); // Show Edappal on launch
  }

  Future<void> fetchWeatherByCity(String city) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await weatherService.getWeatherByCity(city);
      if (data != null) {
        setState(() {
          weatherData = data;
          cityController.text = city;
        });
      } else {
        setState(() {
          error = "City not found.";
        });
      }
    } catch (e) {
      setState(() {
        error = "Failed to fetch weather.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchWeatherForEdappal() async {
    await fetchWeatherByCity("Edappal");
  }

  Widget buildWeatherCard() {
    if (weatherData == null) return const SizedBox();

    final city = weatherData!['name'];
    final temp = weatherData!['main']['temp'].toStringAsFixed(1);
    final condition = weatherData!['weather'][0]['main'];
    final iconCode = weatherData!['weather'][0]['icon'];
    final iconUrl = "https://openweathermap.org/img/wn/$iconCode@4x.png";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue.shade200]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            city,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Image.network(iconUrl, width: 100),
          Text(
            "$temp °C",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            condition,
            style: const TextStyle(fontSize: 24, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: cityController,
            decoration: InputDecoration(
              hintText: "Enter city name",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (cityController.text.trim().isNotEmpty) {
              fetchWeatherByCity(cityController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Search", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text("🌤 Weather App", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildSearchField(),
            const SizedBox(height: 30),
            if (isLoading) const CircularProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
              ),
            if (!isLoading && weatherData != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: buildWeatherCard(),
              ),
            const SizedBox(height: 80), // space for bottom button
          ],
        ),
      ),

      // ✅ Location icon moved to bottom right
      floatingActionButton: FloatingActionButton.extended(
        onPressed: fetchWeatherForEdappal,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.location_on),
        label: const Text(""),
      ),
    );
  }
}
