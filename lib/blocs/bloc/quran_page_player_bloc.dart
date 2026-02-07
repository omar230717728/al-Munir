// ignore_for_file: unnecessary_null_comparison

import 'package:al_munir/main.dart';
import 'package:bloc/bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:quran/quran.dart';
import 'package:quran/reciters.dart';

part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';

class QuranPagePlayerBloc
    extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  QuranPagePlayerBloc() : super(QuranPagePlayerInitial()) {
    on<QuranPagePlayerEvent>((event, emit) async {
      if (event is PlayFromVerse) {
        // Stop existing playback if any
        if (audioPlayer != null && audioPlayer!.playing) {
          await audioPlayer!.stop();
        }

        final int totalVerses = getVerseCount(event.surahNumber);
        final List<AudioSource> playlist = [];

        // Construct standard filename/URL logic
        // URL Format: https://everyayah.com/data/<ReciterIdentifier>/<SurahID><AyahID>.mp3
        // SurahID and AyahID are 3 digits padded.

        // Global reciters list should be populated. Verify reciter exists.
        final reciterMatch = reciters.firstWhere(
          (element) => element["identifier"] == event.reciterIdentifier,
          orElse: () => null,
        );

        if (reciterMatch == null) {
          Fluttertoast.showToast(msg: "Reciter not found");
          return;
        }

        String reciterId = event
            .reciterIdentifier; // e.g., "AbdulSamad_64kbps_QuranExplorer.Com"
        String surahPad = event.surahNumber.toString().padLeft(3, '0');

        // SINGLE VERSE PLAYBACK LOGIC
        // We only add the requested verse to the playlist.
        // This stops the player from continuing to the next verse automatically.
        String url =
            getAudioURLByVerse(event.surahNumber, event.verse, reciterId);

        playlist.add(
          AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(
              id: url,
              album: reciterMatch["englishName"],
              title:
                  "${getSurahNameEnglish(event.surahNumber)} - Verse ${event.verse}",
              artUri: Uri.parse(
                  "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg"),
            ),
          ),
        );

        try {
          await audioPlayer!.setAudioSource(
            ConcatenatingAudioSource(children: playlist),
            initialIndex: 0, // Always 0 because playlist only has 1 item
          );

          // Listen for errors
          audioPlayer!.playbackEventStream.listen((event) {},
              onError: (Object e, StackTrace stackTrace) {
            Fluttertoast.showToast(msg: "Playback error: $e");
          });

          audioPlayer!.play();

          emit(QuranPagePlayerPlaying(
            player: audioPlayer!,
            audioPlayerStream: audioPlayer!.positionStream,
            suraNumber: event.surahNumber,
            reciter: reciterMatch,
            durations: [
              {
                "surah": event.surahNumber,
                "verseNumber": event.verse,
                "startDuration": 0,
                "endDuration": 100000000, // Arbitrary long duration
              }
            ],
          ));
        } catch (e) {
          Fluttertoast.showToast(msg: "Error loading audio: $e");
          print("Error: $e");
        }
      } else if (event is StopPlaying) {
        if (audioPlayer != null) {
          await audioPlayer!.stop();
        }
        emit(QuranPagePlayerInitial());
      } else if (event is KillPlayerEvent) {
        if (audioPlayer != null) {
          await audioPlayer!.stop();
        }
        emit(QuranPagePlayerInitial());
      }
    });
  }
}
