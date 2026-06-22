# ARtie Sketch - AR Drawing Lab

A premium, mobile-first Progressive Web App (PWA) that helps you trace and sketch drawings on paper using your device's camera feed as an augmented reality overlay. 

This app is 100% free to run and host. All image processing (including custom photo edge detection) is done locally inside the web browser on your phone, meaning no paid APIs, no servers, and zero ongoing costs.

---

## Key Features

1. **AR Camera Overlay**: Uses your phone's rear camera as a background, overlaying transparent drawing stencils directly on top so you can align and trace them onto paper.
2. **Built-in Stencils**: Includes pre-loaded stencils for Anime, Animals, Cute drawings, and Flowers, which work fully offline.
3. **Custom Sketch Upload**: Upload any photo from your phone. The app will automatically run a client-side edge detector to convert it into a clean line stencil.
4. **Drawing Controls**: Adjust the stencil's opacity, scale (size), rotation angle, horizontal/vertical flip, line color, and edge strength.
5. **Drawing Lock (Screen Lock)**: A toggleable lock screen overlay that disables all control interactions, allowing you to trace on the screen without accidentally shifting the canvas.
6. **Calibration Grid**: Toggle an alignment grid to help you align your phone and paper correctly.
7. **Offline Support**: Fully functional offline once visited or installed, thanks to a built-in Service Worker.

---

## How to Run Locally

Since the app requests camera permissions via `getUserMedia`, modern browsers require either `localhost` or an `https://` secure context to start the camera.

To run it locally on your computer:
1. Open a terminal in the project directory.
2. Run any simple HTTP server. For example:
   * **Node.js**: `npx serve .` or `npx http-server`
   * **Python**: `python -m http.server 8000`
3. Open `http://localhost:3000` (or the port specified) in your browser.

---

## How to Push to GitHub & Enable GitHub Pages (Free Hosting)

To open this on your Android phone and install it as an app, you need to host it with `https://`. GitHub Pages provides secure HTTPS hosting for free.

Follow these steps to upload it:

### Step 1: Initialize Git and Push to GitHub
Open your terminal in this project folder (`new project 03`) and run:

```bash
# 1. Initialize git
git init

# 2. Add files
git add .

# 3. Create initial commit
git commit -m "feat: initial commit of ARtie Sketch app"

# 4. Rename default branch to main
git branch -M main

# 5. Link to your GitHub Repository
# (Create a empty public repository on github.com named 'artie-sketch' first!)
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/artie-sketch.git

# 6. Push code to GitHub
git push -u origin main
```

### Step 2: Enable GitHub Pages
1. Go to your repository on **GitHub.com**.
2. Click on the **Settings** tab.
3. Scroll down on the left sidebar and click **Pages**.
4. Under **Build and deployment**:
   * Source: **Deploy from a branch**
   * Branch: Select **main** and folder **/(root)**.
5. Click **Save**.
6. Wait about 1-2 minutes. Refresh the page, and you will see a banner at the top of the settings page saying:
   > *Your site is live at `https://YOUR_GITHUB_USERNAME.github.io/artie-sketch/`*

---

## How to Install on Your Android Phone

1. Open **Google Chrome** on your Android phone.
2. Enter your GitHub Pages URL: `https://YOUR_GITHUB_USERNAME.github.io/artie-sketch/`
3. Allow **Camera Access** when prompted.
4. An **Add to Home screen** or **Install App** banner will pop up at the bottom of the screen.
5. Click **Install**.
6. If the banner does not appear automatically:
   * Tap the **three dots** icon in the top right corner of Chrome.
   * Select **Add to Home screen** or **Install app**.
7. Go to your phone's home screen. You will see the **ARtie Sketch** app icon! Click it to open in full screen (without the browser bar).

---

## How to Position Your Phone for Tracing

For the best drawing experience:
1. Place a piece of paper on a flat surface (table).
2. Prop your phone up parallel to the paper, using a transparent glass cup, a tripod, or a phone stand.
3. Place a lamp or light source so the paper is well-lit.
4. Align the paper inside the camera feed.
5. Look at your phone's screen and trace the outlines onto the paper with a pencil!
