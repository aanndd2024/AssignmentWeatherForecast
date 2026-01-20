# AssignmentWeatherForecast

## Screens

### 1. Search Screen
- Enter a US city to fetch weather data.
- Displays weather details and corresponding icon.
- Caches images for faster load times.
- Shows an error message if the city is not found or network fails.

### 2. Location-Based Weather
- Prompts the user to allow location access.
- Fetches weather data automatically if permission is granted.
- Falls back to the last searched city if permission is denied.

### 3. Last City Persistence
- Saves the last searched city in `UserDefaults`.
- Auto-loads this city upon app launch.

---

## Implementation Notes

- **ViewModel** handles fetching data from `WeatherService` and updates the UI reactively.
- **Coordinator** manages navigation and screen transitions.
- **Dependency Injection** is implemented via initializer injection.
- **Network Layer** uses `URLSession` for API requests.
- **Image Caching** uses `NSCache` for downloaded weather icons.
- **Error Handling** covers:
  - Network errors
  - Invalid API responses
  - Location permission denied
  - Edge cases like missing data
 
---

## Weather Icons
- Icons are available at [OpenWeatherMap Weather Conditions](http://openweathermap.org/weather-conditions).

---

## Testing

- **Unit Tests**
  - Test API parsing logic
  - Test ViewModel response to API data
  - Test error scenarios
- **UI Tests (Optional)**
  - Validate search input
  - Validate weather display for a given city
  - Validate app behavior when location permission is denied

---

## Requirements

### Must Have

- MVVM-C architecture
- UIKit + SwiftUI integration
- Dependency injection
- Orientation and size class support
- Native Swift frameworks only
- Robust error handling
- Unit tests for Model and ViewModel

### Nice to Have

- UI Tests
- Performance optimizations
- Accessibility support
- Localization support

---

## Known Limitations

- OpenWeatherMap API requests by city name, zip-code, or city ID are deprecated but still functional.
- The UI design is basic; focus is on functionality and architecture.

---

## Setup

1. Sign up at [OpenWeatherMap](https://openweathermap.org/api) and get your free API key.
2. Add the API key to the `WeatherService`.
3. Build and run the app in Xcode (no storyboards required).
4. Grant location permission for automatic weather fetching.
