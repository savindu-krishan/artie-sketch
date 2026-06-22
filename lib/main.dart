import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

// Import our custom edge detector isolate utility
import 'utils/edge_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to query available cameras at startup
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Failed to query camera devices: $e');
  }

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(ARtieSketchApp(cameras: cameras));
}

class ARtieSketchApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const ARtieSketchApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARtie Sketch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF08080C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFF8A2BE2),
          surface: Color(0xFF12121A),
          background: Color(0xFF08080C),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF00F2FE),
          inactiveTrackColor: Colors.white10,
          thumbColor: Colors.white,
          overlayColor: const Color(0xFF00F2FE).withOpacity(0.2),
          valueIndicatorColor: const Color(0xFF00F2FE),
        ),
      ),
      home: ARDrawingScreen(cameras: cameras),
    );
  }
}

class ARDrawingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ARDrawingScreen({super.key, required this.cameras});

  @override
  State<ARDrawingScreen> createState() => _ARDrawingScreenState();
}

class _ARDrawingScreenState extends State<ARDrawingScreen> with TickerProviderStateMixin {
  // Camera state
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;
  String _cameraErrorMessage = '';

  // Stencil list
  final List<Map<String, String>> _stencils = [
    {'id': 'stencil-anime-girl', 'name': 'Anime Girl', 'path': 'assets/stencils/stencil_anime_girl.png', 'category': 'anime'},
    {'id': 'stencil-anime', 'name': 'Anime Warrior', 'path': 'assets/stencils/stencil_anime.png', 'category': 'anime'},
    {'id': 'anime-eyes', 'name': 'Anime Eyes', 'path': 'assets/stencils/anime_eyes.svg', 'category': 'anime'},
    
    {'id': 'stencil-lion', 'name': 'Majestic Lion', 'path': 'assets/stencils/stencil_lion.png', 'category': 'animals'},
    {'id': 'stencil-wolf', 'name': 'Wolf Head', 'path': 'assets/stencils/stencil_wolf.png', 'category': 'animals'},
    {'id': 'butterfly', 'name': 'Butterfly', 'path': 'assets/stencils/butterfly.svg', 'category': 'animals'},
    {'id': 'cute-cat', 'name': 'Cute Cat', 'path': 'assets/stencils/cute_cat.svg', 'category': 'animals'},
    
    {'id': 'stencil-rose', 'name': 'Detailed Rose', 'path': 'assets/stencils/stencil_rose.png', 'category': 'art'},
    {'id': 'stencil-mandala', 'name': 'Mandala Art', 'path': 'assets/stencils/stencil_mandala.png', 'category': 'art'},
    {'id': 'beautiful-rose', 'name': 'Rose Flower', 'path': 'assets/stencils/beautiful_rose.svg', 'category': 'art'},
    
    {'id': 'stencil-eiffel', 'name': 'Eiffel Tower', 'path': 'assets/stencils/stencil_eiffel.png', 'category': 'places'},
    {'id': 'stencil-castle', 'name': 'Fantasy Castle', 'path': 'assets/stencils/stencil_castle.png', 'category': 'places'},
    
    {'id': 'stencil-dragon', 'name': 'Tribal Dragon', 'path': 'assets/stencils/stencil_dragon.png', 'category': 'fantasy'},
    {'id': 'sports-car', 'name': 'Sports Car', 'path': 'assets/stencils/sports_car.svg', 'category': 'vehicles'},
    {'id': 'cute-panda', 'name': 'Cute Panda', 'path': 'assets/stencils/cute_panda.svg', 'category': 'cute'},
  ];

  // Active stencil state
  Map<String, String>? _activeStencil;
  Uint8List? _customImageBytes; // Loaded custom image bytes
  Uint8List? _processedOutlineBytes; // Grayscale/Sobel outline bytes
  bool _isProcessingImage = false;

  // Stencil transformations
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _scale = 1.0;
  double _startScale = 1.0;
  double _rotation = 0.0;
  double _startRotation = 0.0;
  bool _flipH = false;
  bool _flipV = false;
  double _opacity = 0.5;
  Color _strokeColor = const Color(0xFF000000);
  bool _outlineFilterMode = true; // true = Line Sketch, false = Raw Image
  int _edgeThreshold = 50;

  // UI state
  bool _showGrid = false;
  bool _isDrawerExpanded = true;
  String _activeTab = 'library'; // 'library' or 'adjustments'
  String _activeCategory = 'all';
  bool _isLocked = false;

  // Animated Unlock logic
  late AnimationController _unlockProgressController;
  bool _isHoldingUnlock = false;

  @override
  void initState() {
    super.initState();
    _cameras = widget.cameras;
    _activeStencil = _stencils.first; // select cute cat as default
    
    _unlockProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _unlockScreen();
        }
      });

    // Request permissions and initialize
    _checkPermissionsAndInit();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _unlockProgressController.dispose();
    super.dispose();
  }

  // Check permissions and initialize native camera
  Future<void> _checkPermissionsAndInit() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initCamera();
    } else {
      setState(() {
        _cameraErrorMessage = 'Camera permission was denied. Please grant permission in site settings.';
      });
    }
  }

  Future<void> _initCamera() async {
    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
      } catch (e) {
        setState(() {
          _cameraErrorMessage = 'No camera devices detected.';
        });
        return;
      }
    }

    if (_cameras.isEmpty) return;

    // Pick environment camera if available
    int cameraIndex = 0;
    for (int i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.back) {
        cameraIndex = i;
        break;
      }
    }

    _currentCameraIndex = cameraIndex;
    await _startCameraStream(_cameras[cameraIndex]);
  }

  Future<void> _startCameraStream(CameraDescription camera) async {
    setState(() {
      _isCameraInitialized = false;
      _cameraErrorMessage = '';
    });

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      // Center the stencil once screen dimensions are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerStencil();
      });
    } catch (e) {
      setState(() {
        _cameraErrorMessage = 'Failed to open camera: $e';
      });
    }
  }

  void _centerStencil() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _offset = Offset(size.width / 2, size.height * 0.45);
      _scale = 1.5;
      _rotation = 0.0;
    });
  }

  void _resetTransforms() {
    _centerStencil();
    setState(() {
      _flipH = false;
      _flipV = false;
    });
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length <= 1) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    await _startCameraStream(_cameras[_currentCameraIndex]);
  }

  // ==========================================================================
  // Image processing & Picker logic
  // ==========================================================================
  Future<void> _pickCustomImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101015),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF00F2FE)),
                  title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
                Divider(color: Colors.white.withOpacity(0.05)),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF8A2BE2)),
                  title: const Text('Capture with Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // Request gallery permissions explicitly (Permission.photos for Android 13+, Permission.storage for older versions)
        final statusPhotos = await Permission.photos.request();
        final statusStorage = await Permission.storage.request();
        if (!statusPhotos.isGranted && !statusStorage.isGranted) {
          // Some custom ROMs or devices might block, let's warn but still attempt, or stop if strictly required
          debugPrint("Gallery permissions not fully granted, attempting pick anyway.");
        }
      } else if (source == ImageSource.camera) {
        final statusCamera = await Permission.camera.request();
        if (!statusCamera.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Camera permission is required to capture photos."),
                backgroundColor: Color(0xFFFF3B30),
              ),
            );
          }
          return;
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _customImageBytes = bytes;
        _activeStencil = {
          'id': 'custom',
          'name': 'Custom Image',
          'path': '',
          'category': 'uploads'
        };
        _activeCategory = 'uploads';
      });

      _processOutline();
    } catch (e) {
      debugPrint("Error picking custom image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking photo: $e"),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  Future<void> _selectStencil(Map<String, String> item) async {
    setState(() {
      _activeStencil = item;
      _processedOutlineBytes = null;
      _customImageBytes = null;
    });

    _resetTransforms();

    final path = item['path']!;
    if (path.endsWith('.png')) {
      setState(() {
        _isProcessingImage = true;
      });
      try {
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = data.buffer.asUint8List();

        final processedBytes = await compute(EdgeDetector.process, {
          'bytes': bytes,
          'threshold': _edgeThreshold,
          'color': _strokeColor.value,
        });

        setState(() {
          _customImageBytes = bytes;
          _processedOutlineBytes = processedBytes;
          _isProcessingImage = false;
        });
      } catch (e) {
        debugPrint('Failed to process asset PNG stencil: $e');
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  Future<void> _processOutline() async {
    if (_customImageBytes == null) return;

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final processedBytes = await compute(EdgeDetector.process, {
        'bytes': _customImageBytes,
        'threshold': _edgeThreshold,
        'color': _strokeColor.value,
      });

      setState(() {
        _processedOutlineBytes = processedBytes;
        _isProcessingImage = false;
      });
    } catch (e) {
      debugPrint('Failed to run edge detector isolate: $e');
      setState(() {
        _isProcessingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error processing image outline: $e"),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  // ==========================================================================
  // Screen Unlock Holding handlers
  // ==========================================================================
  void _startUnlockTimer() {
    setState(() {
      _isHoldingUnlock = true;
    });
    _unlockProgressController.forward(from: 0.0);
  }

  void _stopUnlockTimer() {
    setState(() {
      _isHoldingUnlock = false;
    });
    _unlockProgressController.stop();
    _unlockProgressController.value = 0.0;
  }

  void _unlockScreen() {
    setState(() {
      _isLocked = false;
      _isHoldingUnlock = false;
    });
    _unlockProgressController.value = 0.0;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen unlocked!'), duration: Duration(seconds: 1)),
    );
  }

  // ==========================================================================
  // UI Building Methods
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Native Camera Stream or placeholder
          Positioned.fill(
            child: _isCameraInitialized && _cameraController != null
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  )
                : Container(
                    color: const Color(0xFF08080C),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _cameraErrorMessage.isNotEmpty
                                ? _cameraErrorMessage
                                : 'Loading Camera Preview...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (_cameraErrorMessage.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _checkPermissionsAndInit,
                              child: const Text('Retry Camera Access'),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
          ),

          // LAYER 2: Calibration Grid
          if (_showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ),
            ),

          // LAYER 3: Transformed Stencil Overlay
          if (_activeStencil != null)
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: _isLocked
                    ? null
                    : (details) {
                        _lastFocalPoint = details.focalPoint;
                        _startScale = _scale;
                        _startRotation = _rotation;
                      },
                onScaleUpdate: _isLocked
                    ? null
                    : (details) {
                        setState(() {
                          // Scale & rotation
                          if (details.pointerCount > 1) {
                            _scale = (_startScale * details.scale).clamp(0.1, 8.0);
                            _rotation = _startRotation + details.rotation;
                          }
                          // Offset position translation
                          final Offset delta = details.focalPoint - _lastFocalPoint;
                          _offset += delta;
                          _lastFocalPoint = details.focalPoint;
                        });
                      },
                onDoubleTap: _isLocked ? null : _resetTransforms,
                child: Stack(
                  children: [
                    Positioned(
                      left: _offset.dx,
                      top: _offset.dy,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateZ(_rotation)
                            ..scale(
                              _flipH ? -_scale : _scale,
                              _flipV ? -_scale : _scale,
                            ),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: _opacity,
                            child: _buildStencilGraphic(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // LAYER 4: Top Action Bar floating controls
          if (!_isLocked) _buildTopActionBar(),

          // LAYER 5: Floating Bottom Sheet drawer panel
          if (!_isLocked) _buildControlDrawer(size),

          // LAYER 6: Full Screen Drawing Lock Overlay
          if (_isLocked) _buildLockScreenOverlay(),
        ],
      ),
    );
  }

  Widget _buildStencilGraphic() {
    if (_activeStencil == null) return const SizedBox.shrink();

    final isCustom = _activeStencil!['id'] == 'custom';
    final isPng = _activeStencil!['path']!.endsWith('.png');

    if (_isProcessingImage) {
      return const SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F2FE)),
          ),
        ),
      );
    }

    if (isCustom || isPng) {
      if (_outlineFilterMode && _processedOutlineBytes != null) {
        return Image.memory(
          _processedOutlineBytes!,
          width: 300,
          fit: BoxFit.contain,
        );
      } else if (isCustom && _customImageBytes != null) {
        return Image.memory(
          _customImageBytes!,
          width: 300,
          fit: BoxFit.contain,
        );
      } else {
        return Image.asset(
          _activeStencil!['path']!,
          width: 300,
          fit: BoxFit.contain,
        );
      }
    } else {
      // Vector SVG stencil
      return SvgPicture.asset(
        _activeStencil!['path']!,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          _strokeColor,
          BlendMode.srcIn,
        ),
      );
    }
  }

  Widget _buildTopActionBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo text
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F14).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00F2FE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF00F2FE), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'AR',
                            style: TextStyle(
                              color: Color(0xFF00F2FE),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'tie Sketch',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              _buildFloatingActionBtn(
                icon: Icons.grid_on_outlined,
                isActive: _showGrid,
                onTap: () => setState(() => _showGrid = !_showGrid),
              ),
              const SizedBox(width: 8),
              _buildFloatingActionBtn(
                icon: Icons.flip_camera_android_outlined,
                isActive: false,
                onTap: _toggleCamera,
              ),
              const SizedBox(width: 8),
              _buildFloatingActionBtn(
                icon: Icons.lock_outline,
                isActive: false,
                highlightColor: const Color(0xFF00F2FE),
                onTap: () => setState(() {
                  _isLocked = true;
                  _isDrawerExpanded = false;
                }),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFloatingActionBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFF00F2FE)
                  : const Color(0xFF0F0F14).withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                    ? const Color(0xFF00F2FE)
                    : highlightColor?.withOpacity(0.4) ?? Colors.white.withOpacity(0.08),
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.4), blurRadius: 10)]
                  : null,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlDrawer(Size size) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      bottom: bottomPadding + 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isDrawerExpanded ? size.height * 0.52 : 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F14).withOpacity(0.78),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  // Header pull bar area
                  GestureDetector(
                    onTap: () => setState(() => _isDrawerExpanded = !_isDrawerExpanded),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _activeStencil != null 
                                            ? const Color(0xFF00F2FE)
                                            : Colors.white30,
                                        shape: BoxShape.circle,
                                        boxShadow: _activeStencil != null
                                            ? [BoxShadow(color: const Color(0xFF00F2FE).withOpacity(0.6), blurRadius: 6)]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _activeStencil != null
                                          ? _activeStencil!['name']!
                                          : 'No stencil selected',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                                    ),
                                  ],
                                ),
                                Icon(
                                  _isDrawerExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                  color: Colors.white60,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
  
                  if (_isDrawerExpanded) ...[
                    // Tabs Navigation
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
                      ),
                      child: Row(
                        children: [
                          _buildTabBtn(id: 'library', label: 'Library', icon: Icons.layers_outlined),
                          _buildTabBtn(id: 'adjustments', label: 'Adjustments', icon: Icons.tune),
                        ],
                      ),
                    ),
  
                    // Content Panel
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _activeTab == 'library' 
                            ? _buildLibraryTab() 
                            : _buildAdjustmentsTab(),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBtn({required String id, required String label, required IconData icon}) {
    final isActive = _activeTab == id;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? const Color(0xFF00F2FE).withOpacity(0.08) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? const Color(0xFF00F2FE).withOpacity(0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 16, 
                color: isActive ? const Color(0xFF00F2FE) : Colors.white60
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF00F2FE) : Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryTab() {
    final categories = ['all', 'anime', 'animals', 'art', 'places', 'fantasy', 'vehicles', 'cute', 'uploads'];
    
    final filtered = _stencils.where((item) {
      if (_activeCategory == 'all') return true;
      return item['category'] == _activeCategory;
    }).toList();

    return Column(
      children: [
        // Category Chips Scroll view
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isCatActive = _activeCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _activeCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isCatActive 
                        ? const LinearGradient(
                            colors: [Color(0xFF00F2FE), Color(0xFF8A2BE2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isCatActive ? null : const Color(0x0DFFFFFF),
                    border: Border.all(
                      color: isCatActive ? Colors.transparent : Colors.white.withOpacity(0.08),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isCatActive 
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00F2FE).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    cat.toUpperCase(),
                    style: TextStyle(
                      color: isCatActive ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Stencils Grid list
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: filtered.length + 1, // +1 for the upload button
            itemBuilder: (context, index) {
              if (index == 0) {
                // Custom Upload Card
                return GestureDetector(
                  onTap: _pickCustomImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00F2FE).withOpacity(0.05),
                          const Color(0xFF8A2BE2).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF00F2FE).withOpacity(0.25),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F2FE).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined, 
                            color: Color(0xFF00F2FE), 
                            size: 24
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload Photo', 
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Camera / Gallery', 
                          style: TextStyle(
                            fontSize: 8, 
                            color: Colors.white30,
                          )
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = filtered[index - 1];
              final isSelected = _activeStencil != null && _activeStencil!['id'] == item['id'];

              return GestureDetector(
                onTap: () => _selectStencil(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF00F2FE).withOpacity(0.06) 
                        : const Color(0xFF12121A).withOpacity(0.4),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF00F2FE).withOpacity(0.6) 
                          : Colors.white.withOpacity(0.06),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00F2FE).withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: -2,
                            )
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: item['path']!.endsWith('.svg')
                              ? SvgPicture.asset(
                                  item['path']!,
                                  colorFilter: ColorFilter.mode(
                                    isSelected ? const Color(0xFF00F2FE) : Colors.white70,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Image.asset(
                                  item['path']!,
                                  fit: BoxFit.contain,
                                  color: isSelected ? const Color(0xFF00F2FE) : Colors.white70,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['name']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF00F2FE) : Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentsTab() {
    return ListView(
      children: [
        // Slider: Opacity
        _buildSliderSetting(
          title: 'Stencil Opacity',
          value: _opacity,
          min: 0.05,
          max: 0.95,
          displayValue: '${(_opacity * 100).round()}%',
          onChanged: (val) => setState(() => _opacity = val),
        ),

        // Slider: Size/Scale
        _buildSliderSetting(
          title: 'Size Scale',
          value: _scale,
          min: 0.2,
          max: 5.0,
          displayValue: '${_scale.toStringAsFixed(2)}x',
          onChanged: (val) => setState(() => _scale = val),
        ),

        // Slider: Rotation
        _buildSliderSetting(
          title: 'Rotate Angle',
          value: _rotation * 180 / 3.14159, // show in degrees
          min: -180.0,
          max: 180.0,
          displayValue: '${(_rotation * 180 / 3.14159).round()}°',
          onChanged: (val) => setState(() => _rotation = val * 3.14159 / 180),
        ),

        // Transformations Button Action row
        Row(
          children: [
            Expanded(
              child: _buildActionBtn(
                label: 'Flip Horiz',
                icon: Icons.swap_horiz,
                isActive: _flipH,
                onTap: () => setState(() => _flipH = !_flipH),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionBtn(
                label: 'Flip Vert',
                icon: Icons.swap_vert,
                isActive: _flipV,
                onTap: () => setState(() => _flipV = !_flipV),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionBtn(
                label: 'Reset View',
                icon: Icons.refresh_sharp,
                isActive: false,
                isDanger: true,
                onTap: _resetTransforms,
              ),
            ),
          ],
        ),
        
        const Divider(color: Colors.white10, height: 32),

        // Settings unique to custom uploads or PNG templates
        if (_activeStencil?['id'] == 'custom' || _activeStencil?['path']?.endsWith('.png') == true) ...[
          const Text(
            'Outline Filter Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          
          // Outline Filter Switcher
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Line Sketch')),
                  selected: _outlineFilterMode,
                  onSelected: (val) {
                    setState(() => _outlineFilterMode = true);
                    _processOutline();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Original Photo')),
                  selected: !_outlineFilterMode,
                  onSelected: (val) {
                    setState(() => _outlineFilterMode = false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_outlineFilterMode)
            _buildSliderSetting(
              title: 'Line Edge Strength',
              value: _edgeThreshold.toDouble(),
              min: 10,
              max: 150,
              displayValue: '$_edgeThreshold',
              onChanged: (val) {
                setState(() => _edgeThreshold = val.round());
                _processOutline();
              },
            ),
        ],

        // Outline Stroke Color selector
        const Text(
          'Stencil Draw Color',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildColorDot(const Color(0xFF000000), 'Black'),
            const SizedBox(width: 14),
            _buildColorDot(const Color(0xFF00F2FE), 'Neon Cyan'),
            const SizedBox(width: 14),
            _buildColorDot(const Color(0xFFFF2A54), 'Neon Pink'),
            const SizedBox(width: 14),
            _buildColorDot(const Color(0xFF39FF14), 'Neon Green'),
            const SizedBox(width: 14),
            _buildColorDot(const Color(0xFFFFD700), 'Gold'),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
              Text(displayValue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE))),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    Color bg = const Color(0xFF12121A).withOpacity(0.4);
    Color border = Colors.white.withOpacity(0.06);
    Color text = Colors.white70;
    Color iconColor = Colors.white60;

    if (isActive) {
      bg = const Color(0xFF00F2FE).withOpacity(0.08);
      border = const Color(0xFF00F2FE).withOpacity(0.4);
      text = const Color(0xFF00F2FE);
      iconColor = const Color(0xFF00F2FE);
    } else if (isDanger) {
      bg = const Color(0xFFFF3B30).withOpacity(0.04);
      border = const Color(0xFFFF3B30).withOpacity(0.25);
      text = const Color(0xFFFF3B30);
      iconColor = const Color(0xFFFF3B30);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                color: text, 
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, String tooltip) {
    final isSelected = _strokeColor == color;
    
    return GestureDetector(
      onTap: () {
        setState(() => _strokeColor = color);
        final isPng = _activeStencil?['path']?.endsWith('.png') ?? false;
        final isCustom = _activeStencil?['id'] == 'custom';
        if (isCustom || isPng) {
          _processOutline();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 3.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildLockScreenOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 1. Top status indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, color: Color(0xFFFF3B30), size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Canvas Locked (Gestures Disabled)',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Bottom hold-to-unlock button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTapDown: (_) => _startUnlockTimer(),
                    onTapUp: (_) => _stopUnlockTimer(),
                    onTapCancel: _stopUnlockTimer,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F14).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _isHoldingUnlock 
                                  ? const Color(0xFF00F2FE) 
                                  : Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: _isHoldingUnlock
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00F2FE).withOpacity(0.4),
                                      blurRadius: 12,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Circular progress indicator inside button
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  value: _unlockProgressController.value,
                                  strokeWidth: 2.5,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F2FE)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isHoldingUnlock ? 'HOLDING...' : 'HOLD TO UNLOCK',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Calibration alignment grid
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;

    // Draw vertical lines
    const double gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
