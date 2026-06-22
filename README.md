# ARtie Sketch - Flutter Native Android App

A premium, native Android application built with **Flutter** that lets you trace and sketch drawings on paper using your phone's camera feed as a real-time overlay. 

The application compiles into a standalone, shareable `.apk` file that works completely offline.

---

## Key Features

1. **Native Camera Preview**: Uses the high-performance native Android camera stream (optimized to select the default rear camera, with front/rear switching support).
2. **Gesture-Controlled Canvas**: Intuitively reposition (drag), scale (pinch-to-zoom), and rotate stencils with multi-touch gestures.
3. **Built-in Templates**: Includes vector SVG stencil templates (cat, eyes, rose, butterfly, car, panda) that render crisp lines at any zoom level.
4. **Custom Image Processing (Sobel Outline)**: Upload any photo from your gallery. The app runs a custom edge-detector filter inside a background isolate (multi-threading) to instantly extract tracing line-art without freezing the UI.
5. **Drawing Lock (Screen Lock)**: Blocks all control interactions, allowing you to draw on top of your screen without shifting the canvas. Features an animated circular progress hold-to-unlock gesture (2 seconds hold).
6. **Alignment Grid**: Toggle a drawing guidelines grid for accurate paper alignment.

---

## Project Structure

* **`lib/main.dart`**: Main application logic, multi-touch gesture handlers, native camera controls, glassmorphic sliders dashboard, and drawing lock screen.
* **`lib/utils/edge_detector.dart`**: Multi-threaded isolate processor converting custom image files to line art stencils.
* **`assets/stencils/`**: Pre-loaded SVG drawings for tracing.
* **`pubspec.yaml`**: App configuration and package dependencies (`camera`, `flutter_svg`, `image`, `permission_handler`, `image_picker`).

---

## How to Build the Standalone APK

Once your Android SDK installation has completed, follow these steps to build your `.apk` file:

### Step 1: Accept Android Licenses
Open your terminal (PowerShell) inside this project folder and run:
```bash
flutter doctor --android-licenses
```
*Press `y` and Enter for all license prompts.*

### Step 2: Compile the Release APK
Run the following command to compile a production-ready, highly optimized Android package:
```bash
flutter build apk --release
```

### Step 3: Extract and Install the App
1. Once the build finishes successfully, open your file explorer and navigate to:
   `build/app/outputs/flutter-apk/`
2. You will find a file named **`app-release.apk`**.
3. **Send this file to your phone** (e.g. transfer via USB, email, or send it to yourself on WhatsApp).
4. Tap the file on your phone to install it! (If prompted, allow installation from "Unknown sources" or "Chrome/WhatsApp" since this is your own custom app).

Enjoy drawing!
