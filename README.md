# SwiftUI HealthKit Write Steps

A simple SwiftUI app that allows to write HealthKit data (steps count), avoiding the "Was User Entered" flag. This happens when a regular user decides to tamper with Apple Health app data and adds their own step count. This might be filtered out by other applications.

## Getting Started

This project was built with Xcode 12.4 & SwiftUI. To get started, clone this repository and open it with Xcode. Then, build and run in the simulator or on a real device (certificate must be trusted first on your iPhone's settings).

To add steps, type the number you'd like to add, then select a start date and end date. Finally, press the "Add Steps" button. This will transfer the amount of steps to Apple Health app.

![steps-write-app-preview-with-healthkit](/steps-write-app-preview.jpg)

## Contributing

Feel free to fork this repository and make adjustments and/or improvements. Changes are welcome.

## Licence

MIT Licence
