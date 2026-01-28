/// This library contains constants used throughout the application.
library;

/// Default date representing the first available date in the data
/// This is typically the landing date of Mars Curiosity Rover: August 6, 2012
final DateTime defaultDate = DateTime(2012, 8, 6);

/// Map of camera names and their full descriptions
/// These cameras are from NASA's Mars Curiosity Rover
const Map<String, String> cameras = {
  'FHAZ': 'Front Hazard Avoidance Camera',
  'RHAZ': 'Rear Hazard Avoidance Camera',
  'MAST': 'Mast Camera',
  'CHEMCAM': 'Chemistry and Camera Complex',
  'MAHLI': 'Mars Hand Lens Imager',
  'MARDI': 'Mars Descent Imager',
  'NAVCAM': 'Navigation Camera',
};

/// List of all available camera names
List<String> get camerasList => cameras.keys.toList();

/// Get camera full name from abbreviation
String getCameraName(String abbreviation) {
  return cameras[abbreviation] ?? abbreviation;
}

/// URL for the logos to be displayed on Liquid Galaxy
const String logosUrl = 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png';
