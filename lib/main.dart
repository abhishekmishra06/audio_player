import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:simple_audio_player/const/color.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(MyMusicApp());
}

class MyMusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AudioPlayer _audioPlayer; // Declare the audio player
  bool isPlaying = false; // Track if audio is playing
  String currentSong = '';
  String currentArtist = '';
  String playSongImage = '';
  String currentPlaySong = '';
  double lastPosition = 0.0;

  double progress = 0.0;
  bool isMenuSelected = false;
  double totalDuration = 0.0; // Total song duration

  int currentIndex = 0;

  List<String> lastPlayedSongs = [];

  List<Map<String, String>> songs = [
    {
      'songName': 'Papa Meri Jaan Animal',
      'artist': 'Sonu Nigam, Harshavardhan Rameshwar, Raj Shekhar',
      'image':
          'assets/images/papa-meri-jaan-animal.jpg',
      'songPath': 'song/Papa Meri Jaan Animal 128 Kbps.mp3',
    },
    {
      'songName': 'Abrars Entry Jamal Kudu Animal',
      'artist': 'Harshavardhan Rameshwar, Choir',
      'image':
          'assets/images/abrars-entry-jamal-kudu-animal.jpg',
      'songPath': 'song/Abrars Entry Jamal Kudu Animal 128 Kbps.mp3',
    },
    {
      'songName': 'Hua Main Animal',
      'artist': 'Raghav Chaitanya, Manoj Muntashir, Pritam',
      'image':
          'assets/images/hua-main-animal.jpg',
      'songPath':
          'song/Hua Main Animal 128 Kbps.mp3',
    },
    {
      'songName': 'Bhaavein Jaane Ya Na Jaane Animal',
      'artist': 'Bhupinder Babbal',
      'image':
          'assets/images/bhaavein-jaane-ya-na-jaane-animal.jpg',
      'songPath':
          'song/Bhaavein Jaane Ya Na Jaane Animal 128 Kbps.mp3',
    },
    {
      'songName': 'Husn',
      'artist': 'Anuv Jain',
      'image':
          'assets/images/128Husn - Anuv Jain 128 Kbps.jpg',
      'songPath':
          'song/128-Husn - Anuv Jain 128 Kbps.mp3',
    },
    {
      'songName': 'Jo Tum Mere Ho',
      'artist': 'Anuv Jain',
      'image':
          'assets/images/download (1).jpg',
      'songPath':
          'song/128-Jo Tum Mere Ho - Anuv Jain 128 Kbps.mp3',
    },
    {
      'songName': 'ANUV JAIN BEST SONGS',
      'artist': 'Anuv Jain',
      'image':
          'assets/images/Screenshot 2024-11-30 102900.png',
      'songPath':
          'song/ANUV JAIN BEST SONGS COLLECTION 2024 __ BEST OF ANUV JAIN __ ANUV JAIN BEST PLAYLIST #music.mp3',
    },
    {
      'songName': 'Call Me Bae',
      'artist': 'RUUH, Joh, Smriti Bhoker',
      'image':
          'assets/images/call-me-bae-500-500.jpg',
      'songPath':
          'song/Baatein Call Me Bae 128 Kbps.mp3',
    },
    {
      'songName': 'Babu Ki Baby',
      'artist': 'Sunidhi Chauhan',
      'image':
          'assets/images/babu-ki-baby.jpg',
      'songPath':
          'song/Babu Ki Baby Kahan Shuru Kahan Khatam 128 Kbps.mp3',
    },
    {
      'songName': 'Cha Chadheya Amar Prem Ki Prem Kahani',
      'artist': 'Cha Chadheya Amar Prem Ki Prem Kahani',
      'image':
          'assets/images/cha-chadheya.jpg',
      'songPath':
          'song/Cha Chadheya Amar Prem Ki Prem Kahani 128 Kbps.mp3',
    },
    {
      'songName': 'Chumma Vicky Vidya Ka Woh Wala Video',
      'artist': 'Sachin-Jigar, Pawan Singhv',
      'image':
          'assets/images/chumma.jpg',
      'songPath':
          'song/Chumma Vicky Vidya Ka Woh Wala Video 128 Kbps.mp3',
    },
    {
      'songName': 'Dumroo',
      'artist': 'Mohit Chauhan and Anupam Amod',
      'image':
          'assets/images/dumroo-sector-36-500-500.jpg',
      'songPath':
          'song/Dumroo Sector 36 128 Kbps.mp3',
    },
    {
      'songName': 'Luga Kin Ke Dewela Raja Ji Ho Nachaniya Ke',
      'artist': 'Bikku Singh',
      'image':
          'assets/images/Luga Kin Ke Dewela Raja Ji Ho Nachaniya Kev.jpg',
      'songPath':
          'song/Luga Kin Ke Dewela Raja Ji Ho Nachaniya Ke (Hit Matter)-BiharMasti.IN.mp3',
    },
    {
      'songName': 'Kahe Ruselu Power',
      'artist': 'Pawan Singh',
      'image':
          'assets/images/Kahe Ruselu Power Star.jpg',
      'songPath': 'Kahe Ruselu Power Star Pawan Singh 128 Kbps.mp3',
    },

 {
      'songName': 'Dil Ko Karaar',
      'artist': 'Rajat Nagpal',
      'image':
          'assets/images/Dil Ko Karaar Aaya.jpg',
      'songPath': 'Dil Ko Karaar Aaya Flute.mp3',
    },

     
  ];

  List<String> likedSongs = [];
  bool isDownloading = false;

  // Initial selected index for menu
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    currentSong = songs[0]['songName']!;
    currentArtist = songs[0]['artist']!;
    playSongImage = songs[0]['image']!;
    currentPlaySong = songs[0]['songPath']!;

    _loadLikedSongs();

    _audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        progress = duration.inSeconds.toDouble().clamp(0.0, totalDuration);
      });
    });
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration.inSeconds.toDouble();
      });
    });

    // Listen for when the player completes
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        // Change icon to pause when song ends
        isPlaying = false;
      });
    });
// Initialize the audio player
  }

  void _addSongToHistory(String songTitle) {
    setState(() {
      if (lastPlayedSongs.isEmpty || lastPlayedSongs.last != songTitle) {
        lastPlayedSongs.add(songTitle);
        print("Added to history: $songTitle"); // Debug print
        if (lastPlayedSongs.length > 4) {
          lastPlayedSongs.removeAt(0);
        }
      }
    });
  }

  Future<void> _loadLikedSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      likedSongs = prefs.getStringList('likedSongs') ?? [];
    });
  }

  Future<void> _toggleLike(String songName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (likedSongs.contains(songName)) {
        likedSongs.remove(songName);
      } else {
        likedSongs.add(songName);
      }
    });
    await prefs.setStringList('likedSongs', likedSongs);
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else {
      // Handle permission denial
      throw Exception('Storage permission denied');
    }
  }

  Future<void> _downloadSong(String localPath, String songName) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isDenied) {
        throw Exception('Storage permission denied');
      }

      // Get the app's documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final localFilePath =
          '${appDocDir.path}/$localPath'; // Path to the local file

      // Read the file as bytes
      final ByteData fileData = await rootBundle.load(localPath);
      final Uint8List bytes = fileData.buffer.asUint8List();

      // Get the "Downloads" directory
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        throw Exception('Downloads folder does not exist');
      }

      // Save the file to the "Downloads" directory
      final savePath = '${downloadsDir.path}/$songName.mp3';
      final file = File(savePath);
      await file.writeAsBytes(bytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $songName to $savePath')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download $songName: $e')),
      );
    }
  }

  Future<void> _playAudio(String songPath, String songTitle) async {
    try {
      if (lastPosition > 0) {
        // Resume from the last position if applicable
        await _audioPlayer.seek(Duration(seconds: lastPosition.toInt()));
      }

      // Play the selected song
      await _audioPlayer.play(AssetSource(songPath));

      setState(() {
        isPlaying = true;
      });

      // Add the song to the history
      _addSongToHistory(songTitle);
    } catch (e) {
      print("Error while playing audio: $e");
    }
  }

//  Future<void> _playAudio(String songPath) async {
//     if (lastPosition > 0) {
//       await _audioPlayer.seek(Duration(seconds: lastPosition.toInt()));
//     }
//     await _audioPlayer.play(AssetSource(songPath));
//     setState(() {
//       isPlaying = true;
//     });
//   }

  void _seekTo(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  Future<void> _stopAudio() async {
    lastPosition = progress; // Save the current position when stopped
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  // Update progress
  void _updateProgress() {
    _audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        progress = duration.inSeconds.toDouble();
      });
    });
  }

  void playNextSong() {
    if (currentIndex < songs.length - 1) {
      currentIndex++;
      _playAudio(songs[currentIndex]['songPath']!, currentSong);
    }
  }

  void playPreviousSong() {
    if (currentIndex > 0) {
      currentIndex--;
      _playAudio(songs[currentIndex]['songPath']!, currentSong);
    }
  }

  @override
  void dispose() {
    _audioPlayer
        .dispose(); // Dispose the audio player when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: Row(
        children: [
          // Custom Sidebar Menu
          Container(
            width: 90,
            color: const Color(0xFFE0E7EF),
            child: Column(
              children: [
                _buildMenuItem(Icons.dashboard, 'Dashboard', 0),
                _buildMenuItem(Icons.album, 'Album', 1),
                _buildMenuItem(Icons.speaker, 'Speaker', 2),
                _buildMenuItem(Icons.favorite, 'Like', 3),
                _buildMenuItem(Icons.star, 'Premium', 4),
                _buildMenuItem(Icons.settings, 'Settings', 5),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hallo, Dhe Mufni',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.search, size: 30, color: Colors.grey),
                          SizedBox(width: 16),
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Playlist and Now Playing Section
                Expanded(
                  child: Row(
                    children: [
                      // Playlist Section
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Playlist',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Featured Song Section
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:Image.asset(playSongImage,     width: 100,
                                        height: 100,
                                                  fit: BoxFit.cover,)
                                      
                                      
                                      //  Image.network(
                                      //   playSongImage,
                                      //   width: 100,
                                      //   height: 100,
                                      //   fit: BoxFit.cover,
                                      // ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pop Punk',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentSong,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentArtist,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: isPlaying
                                                  ? _stopAudio
                                                  : () => _playAudio(
                                                      currentPlaySong,
                                                      currentSong),
                                              child: SizedBox(
                                                height: 25,
                                                width: 65,
                                                child: DecoratedBox(
                                                  decoration:
                                                        BoxDecoration(
                                                          color: Color
                                                              .fromARGB(
                                                                  255,
                                                                  202,
                                                                  202,
                                                                  202).withOpacity(0.7),


                                                                  
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Center(
                                                      child: Text(
                                                    isPlaying ? 'Stop' : 'Play',
                                                  )),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 25,
                                            ),
                                            // const Icon(
                                            //     Icons.favorite_border_rounded),

  Text(
                                        '${(progress ~/ 60).toString().padLeft(2, '0')}:${(progress % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: blackcolor,
                                        ),
                                      ),
                                                
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Playlist List
                              Expanded(
                                child: ListView.builder(
                                  itemCount: songs.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentSong =
                                                songs[index]['songName']!;
                                            currentArtist =
                                                songs[index]['artist']!;
                                            playSongImage =
                                                songs[index]['image']!;

                                            currentIndex = index;
                                            currentPlaySong =
                                                songs[index]['songPath']!;
                                          });
                                          _playAudio(songs[index]['songPath']!,
                                              currentSong);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${index + 1}.',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(width: 20),
                                              // GestureDetector(
                                              //     child: const Icon(Icons
                                              //         .favorite_border_rounded)),

                                              GestureDetector(
                                                onTap: () => _toggleLike(
                                                    songs[index]['songName']!),
                                                child: Icon(
                                                  likedSongs.contains(
                                                          songs[index]
                                                              ['songName'])
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: likedSongs.contains(
                                                          songs[index]
                                                              ['songName'])
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.asset(songs[index]['image']!,    width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,)

                                                // Image.network(
                                                //   songs[index]['image']!,
                                                  // width: 50,
                                                  // height: 50,
                                                  // fit: BoxFit.cover,
                                                // ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      songs[index]['songName']!,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      songs[index]['artist']!,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Text(
                                                '3:14',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(width: 30),
                                              GestureDetector(
                                                onTap: () {
                                                  _downloadSong(
                                                      songs[index]['songPath']!,
                                                      songs[index]
                                                          ['songName']!);
                                                },
                                                child: isDownloading
                                                    ? const CircularProgressIndicator()
                                                    : const Icon(
                                                        Icons.download,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Sidebar for Last Played and Now Playing
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                            
                            ),
                            // SizedBox(
                            //   height: 100,
                            //   child: ListView.builder(
                            //     scrollDirection: Axis.horizontal,
                            //     itemCount: 4,
                            //     itemBuilder: (context, index) {
                            //       return Padding(
                            //         padding: const EdgeInsets.only(left: 16.0),
                            // child: ClipRRect(
                            //   borderRadius: BorderRadius.circular(8),
                            //   child: Image.network(
                            //     'https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                            //     width: 100,
                            //     height: 100,
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),
                            //       );
                            //     },
                            //   ),
                            // ),


if (lastPlayedSongs.isNotEmpty) ...[
  Container(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Played Songs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true, // To make it work inside a scrollable parent
          physics: const NeverScrollableScrollPhysics(), // Prevent grid from scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of items per row
            crossAxisSpacing: 5, // Spacing between columns
            mainAxisSpacing: 5, // Spacing between rows
            childAspectRatio: 1.5, // Aspect ratio for each grid item
          ),
          itemCount: lastPlayedSongs.length,
          itemBuilder: (context, index) {
            final song = lastPlayedSongs[index];
            return SizedBox(
              height: 55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    Image.asset('assets/images/download.png',    width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,),
                    // Image.network(
                    //   'https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                    //   width: double.infinity,
                    //   height: double.infinity,
                    //   fit: BoxFit.cover,
                    // ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        color: Color.fromARGB(255, 65, 65, 65).withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                         ),
                        child: Text(
                          song, // Replace with the actual song title
                          style: const TextStyle(
                            color: whitecolor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  ),
],



                            
                            // if (lastPlayedSongs.isNotEmpty) ...[
                            //   Container(
                            //      child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         const Text(
                            //           'Last Played Songs',
                            //           style: TextStyle(
                            //               fontSize: 18,
                            //               fontWeight: FontWeight.bold),
                            //         ),
                            //         const SizedBox(height: 10),
                            //         Column(
                            //           children: lastPlayedSongs
                            //               .map(
                            //                 (song) => ClipRRect(
                            //                   borderRadius:
                            //                       BorderRadius.circular(8),
                            //                   child: SizedBox(
                            //                     height: 70,
                            //                     width: 50,
                            //                     child: Stack(
                            //                       children: [
                            //                         Image.network(
                            //                           'https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                            //                           width: 100,
                            //                           height: 100,
                            //                           fit: BoxFit.cover,
                            //                         ),
                            //                         Align(
                            //                           alignment:
                            //                               Alignment.bottomCenter,
                            //                           child: Container(
                            //                             width: double.infinity,
                            //                             color: Colors.black
                            //                                 .withOpacity(0.6),
                            //                             padding:
                            //                                 const EdgeInsets.symmetric(
                            //                                     vertical: 4,
                            //                                     horizontal: 8),
                            //                             child: Text(
                            //                               song,
                            //                               style: const TextStyle(
                            //                                 color: Colors.white,
                            //                                 fontSize: 14,
                            //                                 fontWeight:
                            //                                     FontWeight.bold,
                            //                               ),
                            //                               textAlign:
                            //                                   TextAlign.center,
                            //                               overflow: TextOverflow
                            //                                   .ellipsis,
                            //                             ),
                            //                           ),
                            //                         ),

                            //                         const SizedBox(
                            //                             height: 70,
                            //                     width: 50,
                            //                         )
                            //                       ],
                            //                     ),
                            //                   ),
                            //                 ),

                            //                 //  Container(
                            //                 //   padding: const EdgeInsets.all(8),
                            //                 //   margin:
                            //                 //       const EdgeInsets.symmetric(
                            //                 //           vertical: 4),
                            //                 //   decoration: BoxDecoration(
                            //                 //     color: Colors.grey.shade200,
                            //                 //     borderRadius:
                            //                 //         BorderRadius.circular(8),
                            //                 //   ),
                            //                 //   child: Text(
                            //                 //     song,
                            //                 //     style: const TextStyle(
                            //                 //       fontSize: 16,
                            //                 //       fontWeight: FontWeight.normal,
                            //                 //     ),
                            //                 //   ),
                            //                 // ),
                            //               )
                            //               .toList(),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ],
                            const SizedBox(height: 20),
                            // Now Playing Section

                         
                            Container(
                              
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                
                                color: lightgreencolor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  const Text(
                                    'Now Playing',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(playSongImage,    height: 160,
                                      width: double.infinity,
                                                  fit: BoxFit.cover,),
                                    
                                    
                                    // Image.network(
                                    //   playSongImage,
                                    //   height: 140,
                                    //   width: double.infinity,
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Who\'s Know?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$currentSong ',
                                    style: const TextStyle(
                                      color: blackcolor,
                                    ),
                                  ),
                                  Text(
                                    'Artist - $currentArtist',
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(progress ~/ 60).toString().padLeft(2, '0')}:${(progress % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: blackcolor,
                                        ),
                                      ),
                                      // const SizedBox(width: 5),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          child: Slider(
                                            value: progress,
                                            min: 0.0,
                                            max: totalDuration,
                                            onChanged: (value) {
                                              setState(() {
                                                progress = value;
                                              });
                                              _seekTo(value);
                                            },
                                          ),
                                        ),
                                      ),

                                      Text(
                                        '${(totalDuration ~/ 60).toString().padLeft(2, '0')}:${(totalDuration % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: blackcolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: playPreviousSong,
                                        child: Icon(
                                          Icons.skip_previous_rounded,
                                          color: currentIndex == 0
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: isPlaying
                                              ? _stopAudio
                                              : () => _playAudio(
                                                  currentPlaySong, currentSong),
                                          child: isPlaying
                                              ? const Icon(
                                                  Icons.pause_circle_filled,
                                                  color: whitecolor,
                                                  size: 35,
                                                )
                                              : const Icon(
                                                  Icons.play_circle_filled,
                                                  color: Colors.white,
                                                  size: 35)),
                                      GestureDetector(
                                        onTap: playNextSong,
                                        child: Icon(
                                          Icons.skip_next_rounded,
                                          color:
                                              currentIndex + 1 == songs.length
                                                  ? Colors.grey
                                                  : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                                   // Volume control

                                  // Show vertical volume control if `showVolumeControl` is true
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Menu Item Widget
  Widget _buildMenuItem(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: selectedIndex == index ? Colors.blue : Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: selectedIndex == index ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
