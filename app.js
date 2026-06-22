/**
 * ARtie Sketch - Application Logic
 */

// ==========================================================================
// 1. Built-in Stencil Templates (Self-contained inline SVGs for offline use)
// ==========================================================================
const TEMPLATE_STENCILS = [
  {
    id: 'cute-cat',
    name: 'Cute Cat',
    category: 'cute',
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M15 55c0 15 10 25 35 25s35-10 35-25M15 55c0-12 12-25 35-25s35 13 35 25" />
      <path d="M22 35l-7-15 13 8M78 35l7-15-13 8" />
      <circle cx="38" cy="48" r="3" fill="currentColor" />
      <circle cx="62" cy="48" r="3" fill="currentColor" />
      <path d="M50 53l-3-3h6z" />
      <path d="M44 57c-2 2-4 2-4 0s2-4 10-4 10 2 10 4-2 2-4 0" />
      <path d="M50 80c0 10 10 12 10 5" />
      <path d="M5 55h8M95 55h-8M8 65h8M92 65h-8" />
    </svg>`
  },
  {
    id: 'anime-eyes',
    name: 'Anime Eyes',
    category: 'anime',
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 80" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
      <!-- Left Eye -->
      <path d="M10 42c5-15 20-22 35-15 10 5 13 15 13 15" />
      <path d="M13 46c3 8 12 14 22 12 8-2 13-8 13-12" />
      <ellipse cx="32" cy="41" rx="9" ry="13" fill="currentColor" />
      <ellipse cx="29" cy="35" rx="3.5" ry="4.5" fill="#fff" />
      <ellipse cx="34" cy="47" rx="2" ry="2.5" fill="#fff" />
      <path d="M15 20q18-12 32 2" stroke-width="3" />
      
      <!-- Right Eye -->
      <path d="M110 42c-5-15-20-22-35-15-10 5-13 15-13 15" />
      <path d="M107 46c-3 8-12 14-22 12-8-2-13-8-13-12" />
      <ellipse cx="88" cy="41" rx="9" ry="13" fill="currentColor" />
      <ellipse cx="85" cy="35" rx="3.5" ry="4.5" fill="#fff" />
      <ellipse cx="90" cy="47" rx="2" ry="2.5" fill="#fff" />
      <path d="M105 20q-18-12-32 2" stroke-width="3" />
    </svg>`
  },
  {
    id: 'beautiful-rose',
    name: 'Rose Flower',
    category: 'flowers',
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M50 40c-2-6-8-10-15-10-10 0-15 8-10 18 5 10 25 22 25 22s20-12 25-22c5-10 0-18-10-18-7 0-13 4-15 10" />
      <path d="M50 40c3-10 12-15 18-10s5 15-5 20M50 40c-3-10-12-15-18-10s-5 15 5 20" />
      <path d="M50 32c0-8 6-12 12-10" />
      <path d="M50 70v25M50 78c-5 1-12 5-12 10s8 5 12-2M50 83c5 1 12 5 12 10s-8 5-12-2" />
    </svg>`
  },
  {
    id: 'butterfly',
    name: 'Butterfly',
    category: 'animals',
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M50 30v40M48 28c0-3 2-5 2-5s2 2 2 5M46 25c-3-5-8-6-10-2M54 25c3-5 8-6 10-2" />
      <!-- Left Wings -->
      <path d="M48 35C35 15 10 18 15 45c3 15 20 15 33 5" />
      <path d="M48 48C35 52 20 68 25 78c5 8 18 2 23-15" />
      <!-- Right Wings -->
      <path d="M52 35C65 15 90 18 85 45c-3 15-20 15-33 5" />
      <path d="M52 48C65 52 80 68 75 78c-5 8-18 2-23-15" />
      <circle cx="32" cy="38" r="2" fill="currentColor" />
      <circle cx="68" cy="38" r="2" fill="currentColor" />
    </svg>`
  },
  {
    id: 'sports-car',
    name: 'Sports Car',
    category: 'vehicles',
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M10 65h80M12 65l3-10h12l5-8h36l5 8h15l3 10" />
      <path d="M32 55h36M15 65v5h70v-5" />
      <circle cx="28" cy="65" r="9" fill="#0d0d12" stroke="currentColor" stroke-width="2" />
      <circle cx="28" cy="65" r="3" fill="currentColor" />
      <circle cx="72" cy="65" r="9" fill="#0d0d12" stroke="currentColor" stroke-width="2" />
      <circle cx="72" cy="65" r="3" fill="currentColor" />
      <path d="M85 58h4M12 59h3" />
    </svg>`
  },
  {
    id: 'cute-panda',
    name: 'Cute Panda',
    category: 'cute',
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <circle cx="50" cy="53" r="32" />
      <!-- Ears -->
      <path d="M24 28c-5-5-14-1-14 7s7 11 11 7" fill="currentColor" />
      <path d="M76 28c5-5 14-1 14 7s-7 11-11 7" fill="currentColor" />
      <!-- Eyes -->
      <ellipse cx="37" cy="48" rx="7" ry="10" fill="currentColor" />
      <ellipse cx="63" cy="48" rx="7" ry="10" fill="currentColor" />
      <circle cx="37" cy="46" r="2.5" fill="#fff" />
      <circle cx="63" cy="46" r="2.5" fill="#fff" />
      <!-- Nose / Mouth -->
      <polygon points="50,58 46,55 54,55" fill="currentColor" />
      <path d="M47 62c1 2 3 2 3 0s2-2 3 0" />
      <!-- Cheeks -->
      <circle cx="24" cy="56" r="3" opacity="0.3" fill="currentColor" />
      <circle cx="76" cy="56" r="3" opacity="0.3" fill="currentColor" />
    </svg>`
  }
];

// Helper to convert SVG markup into a data URL
function svgToDataUrl(svgString) {
  return 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svgString);
}

// Map templates with data URLs
TEMPLATE_STENCILS.forEach(stencil => {
  stencil.src = svgToDataUrl(stencil.svg);
});

// ==========================================================================
// 2. Application State Management
// ==========================================================================
const appState = {
  // Camera state
  videoDevices: [],
  currentVideoDeviceIndex: 0,
  cameraStream: null,
  isCameraRunning: false,
  
  // Stencil state
  stencils: [...TEMPLATE_STENCILS],
  activeStencil: null,
  activeStencilImg: null,
  customStencilCount: 0,
  
  // Stencil transformations
  x: 0,
  y: 0,
  scale: 1.0,
  rotation: 0, // degrees
  flipH: false,
  flipV: false,
  opacity: 0.5,
  color: '#000000', // default black line
  
  // Filter settings
  filterMode: 'outline', // 'outline' or 'raw'
  edgeThreshold: 50,
  
  // User interactions
  isDragging: false,
  startX: 0,
  startY: 0,
  lastX: 0,
  lastY: 0,
  
  // Lock state
  isLocked: false
};

// DOM References
const videoEl = document.getElementById('camera-feed');
const placeholderEl = document.getElementById('camera-placeholder');
const enableCameraBtn = document.getElementById('enable-camera-btn');
const canvasEl = document.getElementById('stencil-canvas');
const ctx = canvasEl.getContext('2d');
const gridOverlay = document.getElementById('grid-overlay');

// Navigation / Header Controls
const gridToggleBtn = document.getElementById('grid-toggle-btn');
const cameraToggleBtn = document.getElementById('camera-toggle-btn');
const lockModeBtn = document.getElementById('lock-mode-btn');

// Locks Screen Controls
const lockOverlay = document.getElementById('drawing-lock-overlay');
const unlockBtn = document.getElementById('unlock-trigger-btn');

// Drawer elements
const drawerEl = document.getElementById('control-drawer');
const dragArea = document.getElementById('drawer-drag-area');
const drawerToggleBtn = document.getElementById('drawer-toggle-btn');
const stencilNameLabel = document.getElementById('active-stencil-name');
const tabButtons = document.querySelectorAll('.tab-btn');
const tabPanes = document.querySelectorAll('.tab-pane');
const categoryChips = document.querySelectorAll('.chip');
const gridContainer = document.getElementById('stencils-grid-container');

// Upload controls
const fileInput = document.getElementById('stencil-file-input');
const uploadCard = document.getElementById('upload-trigger-card');

// Sliders and adjustment controls
const sliderOpacity = document.getElementById('slider-opacity');
const opacityVal = document.getElementById('opacity-val');
const sliderScale = document.getElementById('slider-scale');
const scaleVal = document.getElementById('scale-val');
const sliderRotation = document.getElementById('slider-rotation');
const rotationVal = document.getElementById('rotation-val');

const btnFlipH = document.getElementById('btn-flip-h');
const btnFlipV = document.getElementById('btn-flip-v');
const btnResetPos = document.getElementById('btn-reset-pos');

const filterOutlineBtn = document.getElementById('filter-outline-btn');
const filterRawBtn = document.getElementById('filter-raw-btn');
const thresholdContainer = document.getElementById('threshold-container');
const sliderThreshold = document.getElementById('slider-threshold');
const thresholdVal = document.getElementById('threshold-val');
const colorDots = document.querySelectorAll('.color-dot');
const pwaToast = document.getElementById('pwa-toast');
const gestureHelper = document.getElementById('gesture-helper');

// Offscreen helper canvas for outline conversion
const helperCanvas = document.createElement('canvas');
const helperCtx = helperCanvas.getContext('2d');

// ==========================================================================
// 3. Setup & Initialization
// ==========================================================================
window.addEventListener('DOMContentLoaded', () => {
  // PWA Service Worker Registration
  registerServiceWorker();
  
  // Canvas resizing
  resizeCanvas();
  window.addEventListener('resize', resizeCanvas);
  
  // Set up events
  initEvents();
  
  // Render stencils library
  renderStencilsGrid('all');
  
  // Ask camera permissions and list cameras
  initCamera();
});

// Register PWA Service Worker
function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('./sw.js')
      .then(reg => {
        console.log('Service Worker registered successfully:', reg.scope);
        // Detect updates
        reg.addEventListener('updatefound', () => {
          const newWorker = reg.installing;
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              showToast("App updated! Reload to apply changes.");
            }
          });
        });
      })
      .catch(err => {
        console.warn('Service Worker registration failed:', err);
      });
  }
}

function showToast(message) {
  pwaToast.textContent = message;
  pwaToast.classList.remove('hidden');
  setTimeout(() => pwaToast.classList.add('visible'), 100);
  setTimeout(() => {
    pwaToast.classList.remove('visible');
    setTimeout(() => pwaToast.classList.add('hidden'), 300);
  }, 4000);
}

function resizeCanvas() {
  canvasEl.width = window.innerWidth;
  canvasEl.height = window.innerHeight;
  // If stencil is loaded, center it if position is (0,0)
  if (appState.x === 0 && appState.y === 0) {
    centerStencil();
  }
  drawStencil();
}

function centerStencil() {
  appState.x = canvasEl.width / 2;
  appState.y = canvasEl.height / 2;
}

// ==========================================================================
// 4. Camera Stream Handling
// ==========================================================================
async function initCamera() {
  try {
    const devices = await navigator.mediaDevices.enumerateDevices();
    appState.videoDevices = devices.filter(d => d.kind === 'videoinput');
    
    // Sort cameras to put rear-facing cameras first
    appState.videoDevices.sort((a, b) => {
      const labelA = a.label.toLowerCase();
      const labelB = b.label.toLowerCase();
      const isBackA = labelA.includes('back') || labelA.includes('environment') || labelA.includes('rear');
      const isBackB = labelB.includes('back') || labelB.includes('environment') || labelB.includes('rear');
      if (isBackA && !isBackB) return -1;
      if (!isBackA && isBackB) return 1;
      return 0;
    });

    if (appState.videoDevices.length > 0) {
      await startCameraStream();
    } else {
      placeholderEl.querySelector('p').textContent = "No camera devices found.";
      enableCameraBtn.style.display = 'none';
    }
  } catch (err) {
    console.error("Error enumerating camera devices:", err);
    showCameraError(err);
  }
}

async function startCameraStream() {
  if (appState.cameraStream) {
    appState.cameraStream.getTracks().forEach(track => track.stop());
  }

  const device = appState.videoDevices[appState.currentVideoDeviceIndex];
  // Basic constraints setup
  const constraints = {
    audio: false,
    video: {
      width: { ideal: 1920 },
      height: { ideal: 1080 }
    }
  };

  // If we have a specific device, use it. Otherwise request environment camera.
  if (device) {
    constraints.video.deviceId = { exact: device.deviceId };
  } else {
    constraints.video.facingMode = { ideal: "environment" };
  }

  try {
    placeholderEl.querySelector('p').textContent = "Connecting to camera...";
    const stream = await navigator.mediaDevices.getUserMedia(constraints);
    appState.cameraStream = stream;
    videoEl.srcObject = stream;
    
    // Listen for video loading
    videoEl.onloadedmetadata = () => {
      videoEl.play();
      placeholderEl.classList.add('hidden');
      appState.isCameraRunning = true;
      cameraToggleBtn.classList.remove('active');
    };
  } catch (err) {
    console.error("Camera access denied or failed:", err);
    showCameraError(err);
  }
}

function showCameraError(err) {
  placeholderEl.classList.remove('hidden');
  appState.isCameraRunning = false;
  
  if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
    placeholderEl.querySelector('p').innerHTML = "Camera permission denied.<br><small>Please enable camera access in your browser settings to trace sketches.</small>";
  } else {
    placeholderEl.querySelector('p').innerHTML = "Could not access back camera.<br><small>We will fallback to default browser video constraints.</small>";
  }
}

async function flipCamera() {
  if (appState.videoDevices.length <= 1) {
    showToast("Only one camera device found.");
    return;
  }
  
  // Advance to next index
  appState.currentVideoDeviceIndex = (appState.currentVideoDeviceIndex + 1) % appState.videoDevices.length;
  cameraToggleBtn.classList.add('active');
  await startCameraStream();
}

// ==========================================================================
// 5. Image & Stencil Canvas Drawing
// ==========================================================================
function selectStencil(stencilId) {
  const stencil = appState.stencils.find(s => s.id === stencilId);
  if (!stencil) return;
  
  appState.activeStencil = stencil;
  stencilNameLabel.textContent = stencil.name;
  
  // Show loaded indicator dot
  const dot = document.querySelector('.active-stencil-info .indicator-dot');
  dot.classList.add('green');
  
  // Load the image object
  const img = new Image();
  img.onload = () => {
    appState.activeStencilImg = img;
    // Reset positioning and scale fitting nicely
    resetStencilTransforms();
    drawStencil();
    
    // Flash gesture helper message
    gestureHelper.classList.remove('hidden');
    // Hide drawer on selection for convenience on small mobile devices
    setTimeout(() => {
      drawerEl.classList.add('collapsed');
    }, 400);
  };
  img.src = stencil.src;
  
  // Highlight active card
  document.querySelectorAll('.stencil-card').forEach(card => {
    card.classList.remove('active');
    if (card.dataset.id === stencilId) {
      card.classList.add('active');
    }
  });
}

function resetStencilTransforms() {
  if (!appState.activeStencilImg) return;
  
  centerStencil();
  appState.rotation = 0;
  appState.flipH = false;
  appState.flipV = false;
  appState.scale = 1.0;
  
  // Calculate auto-scale to fit roughly 60% of viewport width
  const imgWidth = appState.activeStencilImg.naturalWidth || 300;
  const targetWidth = canvasEl.width * 0.65;
  appState.scale = parseFloat((targetWidth / imgWidth).toFixed(2));
  
  // Sync sliders
  sliderScale.value = Math.round(appState.scale * 100);
  scaleVal.textContent = appState.scale.toFixed(2) + 'x';
  sliderRotation.value = 0;
  rotationVal.textContent = '0°';
  
  btnFlipH.classList.remove('active');
  btnFlipV.classList.remove('active');
}

// Drawing Logic
function drawStencil() {
  // Clear main display canvas
  ctx.clearRect(0, 0, canvasEl.width, canvasEl.height);
  
  if (!appState.activeStencilImg) return;
  
  const img = appState.activeStencilImg;
  const w = img.naturalWidth || 300;
  const h = img.naturalHeight || 300;
  
  ctx.save();
  
  // Translate to center coordinates of stencil
  ctx.translate(appState.x, appState.y);
  
  // Apply rotation
  ctx.rotate((appState.rotation * Math.PI) / 180);
  
  // Apply scaling and mirroring
  const scaleX = appState.flipH ? -appState.scale : appState.scale;
  const scaleY = appState.flipV ? -appState.scale : appState.scale;
  ctx.scale(scaleX, scaleY);
  
  // Apply transparency global alpha
  ctx.globalAlpha = appState.opacity;
  
  if (appState.filterMode === 'outline' && appState.activeStencil.category === 'uploads') {
    // Drawn filtered line art from offscreen processing
    ctx.drawImage(helperCanvas, -w/2, -h/2);
  } else {
    // For standard built-in SVGs or raw image mode
    if (appState.filterMode === 'outline') {
      // For vector SVGs, we draw them and apply outline color tinting via canvas composites
      // Draw SVG silhouette
      ctx.drawImage(img, -w/2, -h/2);
      
      // Composite color overlay
      ctx.globalCompositeOperation = 'source-in';
      ctx.fillStyle = appState.color;
      ctx.fillRect(-w/2, -h/2, w, h);
      ctx.globalCompositeOperation = 'source-over';
    } else {
      // Raw mode
      ctx.drawImage(img, -w/2, -h/2);
    }
  }
  
  ctx.restore();
}

// ==========================================================================
// 6. Real-Time Canvas Image Filter Processing (Grayscale & Sobel Edge)
// ==========================================================================
function processCustomUpload(img) {
  const w = img.naturalWidth;
  const h = img.naturalHeight;
  
  helperCanvas.width = w;
  helperCanvas.height = h;
  
  // Render original
  helperCtx.clearRect(0, 0, w, h);
  helperCtx.drawImage(img, 0, 0);
  
  // Get image pixels
  const imgData = helperCtx.getImageData(0, 0, w, h);
  const data = imgData.data;
  
  // Create output buffer
  const outputData = helperCtx.createImageData(w, h);
  const output = outputData.data;
  
  // Pre-calculate threshold and trace color RGB parts
  const threshold = appState.edgeThreshold;
  const rColor = parseInt(appState.color.slice(1, 3), 16);
  const gColor = parseInt(appState.color.slice(3, 5), 16);
  const bColor = parseInt(appState.color.slice(5, 7), 16);
  
  // Simple, fast difference operator for edges (high performant on mobile)
  for (let y = 1; y < h - 1; y++) {
    for (let x = 1; x < w - 1; x++) {
      const idx = (y * w + x) * 4;
      
      // Central pixel brightness
      const cLuma = data[idx] * 0.299 + data[idx+1] * 0.587 + data[idx+2] * 0.114;
      
      // Right pixel brightness
      const rIdx = (y * w + (x + 1)) * 4;
      const rLuma = data[rIdx] * 0.299 + data[rIdx+1] * 0.587 + data[rIdx+2] * 0.114;
      
      // Bottom pixel brightness
      const bIdx = ((y + 1) * w + x) * 4;
      const bLuma = data[bIdx] * 0.299 + data[bIdx+1] * 0.587 + data[bIdx+2] * 0.114;
      
      // Compute gradients
      const dx = rLuma - cLuma;
      const dy = bLuma - cLuma;
      const edgeVal = Math.sqrt(dx * dx + dy * dy);
      
      // Threshold check
      if (edgeVal > threshold) {
        // Outline pixel: apply selected color
        output[idx] = rColor;
        output[idx+1] = gColor;
        output[idx+2] = bColor;
        output[idx+3] = 255; // Solid line
      } else {
        // Background pixel: transparent
        output[idx] = 0;
        output[idx+1] = 0;
        output[idx+2] = 0;
        output[idx+3] = 0; 
      }
    }
  }
  
  helperCtx.putImageData(outputData, 0, 0);
}

// Re-process currently active custom image when adjustments (color, threshold) change
function triggerImageReprocess() {
  if (appState.activeStencil && appState.activeStencil.category === 'uploads' && appState.activeStencilImg) {
    processCustomUpload(appState.activeStencilImg);
    drawStencil();
  }
}

// ==========================================================================
// 7. Touch & Gesture Events for Moving Stencils
// ==========================================================================
function initEvents() {
  
  // Camera permission button handler
  enableCameraBtn.addEventListener('click', () => {
    initCamera();
  });
  
  // Canvas pointer/mouse controls for moving stencils
  canvasEl.addEventListener('pointerdown', (e) => {
    if (appState.isLocked) return;
    appState.isDragging = true;
    appState.startX = e.clientX;
    appState.startY = e.clientY;
    appState.lastX = appState.x;
    appState.lastY = appState.y;
    canvasEl.setPointerCapture(e.pointerId);
  });
  
  canvasEl.addEventListener('pointermove', (e) => {
    if (!appState.isDragging || appState.isLocked) return;
    const dx = e.clientX - appState.startX;
    const dy = e.clientY - appState.startY;
    
    appState.x = appState.lastX + dx;
    appState.y = appState.lastY + dy;
    drawStencil();
  });
  
  canvasEl.addEventListener('pointerup', (e) => {
    if (appState.isDragging) {
      appState.isDragging = false;
      canvasEl.releasePointerCapture(e.pointerId);
    }
  });

  // Double tap to center stencil
  let lastTap = 0;
  canvasEl.addEventListener('click', (e) => {
    if (appState.isLocked) return;
    const now = Date.now();
    if (now - lastTap < 300) {
      resetStencilTransforms();
      drawStencil();
      showToast("View centered!");
    }
    lastTap = now;
  });
  
  // Action header buttons
  gridToggleBtn.addEventListener('click', () => {
    const isHidden = gridOverlay.classList.toggle('hidden');
    gridToggleBtn.classList.toggle('active', !isHidden);
  });
  
  cameraToggleBtn.addEventListener('click', () => {
    flipCamera();
  });
  
  lockModeBtn.addEventListener('click', () => {
    toggleScreenLock(true);
  });
  
  // Screen Unlock Holding Interaction
  let unlockTimer = null;
  
  const startUnlockTimer = (e) => {
    e.preventDefault();
    unlockBtn.classList.add('holding');
    unlockBtn.textContent = "HOLDING...";
    
    unlockTimer = setTimeout(() => {
      toggleScreenLock(false);
      unlockBtn.classList.remove('holding');
    }, 2000); // Hold for 2 seconds to unlock
  };
  
  const clearUnlockTimer = () => {
    if (unlockTimer) {
      clearTimeout(unlockTimer);
      unlockTimer = null;
    }
    unlockBtn.classList.remove('holding');
    unlockBtn.textContent = "HOLD TO UNLOCK";
  };
  
  unlockBtn.addEventListener('mousedown', startUnlockTimer);
  unlockBtn.addEventListener('touchstart', startUnlockTimer);
  unlockBtn.addEventListener('mouseup', clearUnlockTimer);
  unlockBtn.addEventListener('mouseleave', clearUnlockTimer);
  unlockBtn.addEventListener('touchend', clearUnlockTimer);
  unlockBtn.addEventListener('touchcancel', clearUnlockTimer);

  // Drawer Bottom Sheet Sliding Behavior
  dragArea.addEventListener('click', () => {
    drawerEl.classList.toggle('collapsed');
  });
  
  drawerToggleBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    drawerEl.classList.toggle('collapsed');
  });

  // Tab switching
  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      tabButtons.forEach(b => b.classList.remove('active'));
      tabPanes.forEach(pane => pane.classList.remove('active'));
      
      btn.classList.add('active');
      const paneId = 'tab-' + btn.dataset.tab;
      document.getElementById(paneId).classList.add('active');
    });
  });

  // Category Filtering for Stencils
  categoryChips.forEach(chip => {
    chip.addEventListener('click', () => {
      categoryChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      renderStencilsGrid(chip.dataset.category);
    });
  });

  // Stencil Selection
  gridContainer.addEventListener('click', (e) => {
    const card = e.target.closest('.stencil-card');
    if (!card || card.id === 'upload-trigger-card') return;
    
    selectStencil(card.dataset.id);
  });

  // Custom File Image Upload
  fileInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    const reader = new FileReader();
    reader.onload = (event) => {
      appState.customStencilCount++;
      const id = 'custom-' + appState.customStencilCount;
      const name = 'Custom Stencil ' + appState.customStencilCount;
      
      const newStencil = {
        id: id,
        name: name,
        category: 'uploads',
        src: event.target.result // Base64 data url
      };
      
      // Prepend to appState.stencils list
      appState.stencils.unshift(newStencil);
      
      // Auto-filter category to Custom / Uploads to see the card
      document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
      document.querySelector('[data-category="uploads"]').classList.add('active');
      
      renderStencilsGrid('uploads');
      selectStencil(id);
      
      // Trigger Tab change to adjustments
      document.getElementById('tab-btn-adjustments').click();
    };
    reader.readAsDataURL(file);
  });

  // Sliders input handling
  sliderOpacity.addEventListener('input', (e) => {
    appState.opacity = parseInt(e.target.value) / 100;
    opacityVal.textContent = e.target.value + '%';
    drawStencil();
  });

  sliderScale.addEventListener('input', (e) => {
    appState.scale = parseFloat((parseInt(e.target.value) / 100).toFixed(2));
    scaleVal.textContent = appState.scale.toFixed(2) + 'x';
    drawStencil();
  });

  sliderRotation.addEventListener('input', (e) => {
    appState.rotation = parseInt(e.target.value);
    rotationVal.textContent = e.target.value + '°';
    drawStencil();
  });

  sliderThreshold.addEventListener('input', (e) => {
    appState.edgeThreshold = parseInt(e.target.value);
    thresholdVal.textContent = e.target.value;
    triggerImageReprocess();
  });

  // Buttons transformations
  btnFlipH.addEventListener('click', () => {
    appState.flipH = !appState.flipH;
    btnFlipH.classList.toggle('active', appState.flipH);
    drawStencil();
  });

  btnFlipV.addEventListener('click', () => {
    appState.flipV = !appState.flipV;
    btnFlipV.classList.toggle('active', appState.flipV);
    drawStencil();
  });

  btnResetPos.addEventListener('click', () => {
    resetStencilTransforms();
    drawStencil();
    showToast("Transforms reset.");
  });

  // Filter modes (line sketch vs original)
  filterOutlineBtn.addEventListener('click', () => {
    appState.filterMode = 'outline';
    filterOutlineBtn.classList.add('active');
    filterRawBtn.classList.remove('active');
    thresholdContainer.style.display = 'flex';
    triggerImageReprocess();
    drawStencil();
  });

  filterRawBtn.addEventListener('click', () => {
    appState.filterMode = 'raw';
    filterRawBtn.classList.add('active');
    filterOutlineBtn.classList.remove('active');
    thresholdContainer.style.display = 'none';
    drawStencil();
  });

  // Color selection
  colorDots.forEach(dot => {
    dot.addEventListener('click', () => {
      colorDots.forEach(d => d.classList.remove('active'));
      dot.classList.add('active');
      appState.color = dot.dataset.color;
      
      triggerImageReprocess();
      drawStencil();
    });
  });
}

function toggleScreenLock(shouldLock) {
  appState.isLocked = shouldLock;
  if (shouldLock) {
    lockOverlay.classList.remove('hidden');
    drawerEl.classList.add('collapsed');
    document.body.classList.add('locked');
  } else {
    lockOverlay.classList.add('hidden');
    document.body.classList.remove('locked');
    showToast("Controls Unlocked!");
  }
}

// Render library grid dynamically
function renderStencilsGrid(category) {
  // Clear all items except the upload card
  const cards = gridContainer.querySelectorAll('.stencil-card:not(.upload-card)');
  cards.forEach(c => c.remove());
  
  // Filter stencils list
  const filtered = appState.stencils.filter(s => category === 'all' || s.category === category);
  
  filtered.forEach(stencil => {
    const card = document.createElement('div');
    card.className = 'stencil-card';
    card.dataset.id = stencil.id;
    if (appState.activeStencil && appState.activeStencil.id === stencil.id) {
      card.classList.add('active');
    }
    
    // Create card elements
    const img = document.createElement('img');
    img.src = stencil.src;
    img.alt = stencil.name;
    img.loading = 'lazy';
    
    const label = document.createElement('span');
    label.className = 'stencil-label';
    label.textContent = stencil.name;
    
    card.appendChild(img);
    card.appendChild(label);
    
    gridContainer.appendChild(card);
  });
}
