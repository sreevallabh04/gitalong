import 'package:flutter/services.dart';

/// Centralized haptic & sound feedback service.
/// Provides tactile feedback for all major interactions.
class FeedbackService {
  FeedbackService._();

  // ── Haptics ──────────────────────────────────────────────────────────────

  /// Light tap — button presses, tab switches
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  /// Medium tap — swipe threshold crossed, card flip
  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy tap — match found, important action
  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }

  /// Selection tick — scrolling through items
  static void selectionTick() {
    HapticFeedback.selectionClick();
  }

  /// Vibration pattern — match celebration
  static Future<void> matchCelebration() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Error buzz
  static void errorBuzz() {
    HapticFeedback.vibrate();
  }

  // ── Sounds ───────────────────────────────────────────────────────────────
  // Uses system sounds for zero-dependency audio feedback

  /// Swipe right (like) — short positive click
  static void swipeLikeSound() {
    SystemSound.play(SystemSoundType.click);
  }

  /// Swipe left (dislike) — short click
  static void swipeDislikeSound() {
    SystemSound.play(SystemSoundType.click);
  }

  /// Match found — alert sound
  static void matchSound() {
    SystemSound.play(SystemSoundType.alert);
  }

  /// Message sent — click
  static void messageSentSound() {
    SystemSound.play(SystemSoundType.click);
  }

  /// Button press — click
  static void buttonSound() {
    SystemSound.play(SystemSoundType.click);
  }

  // ── Combined feedback ────────────────────────────────────────────────────

  /// Swipe like — haptic + sound
  static void onSwipeLike() {
    mediumTap();
    swipeLikeSound();
  }

  /// Swipe dislike — lighter haptic + sound
  static void onSwipeDislike() {
    lightTap();
    swipeDislikeSound();
  }

  /// Super like — strong haptic + sound
  static void onSuperLike() {
    heavyTap();
    swipeLikeSound();
  }

  /// Match — celebration haptic + alert
  static void onMatch() {
    matchCelebration();
    matchSound();
  }

  /// Message sent — light haptic + click
  static void onMessageSent() {
    lightTap();
    messageSentSound();
  }

  /// Swipe threshold crossed (during drag)
  static void onThresholdCrossed() {
    selectionTick();
  }

  /// Card snap back (no swipe)
  static void onSnapBack() {
    lightTap();
  }

  /// Nav tab change
  static void onTabChange() {
    selectionTick();
  }

  /// Button pressed
  static void onButtonPress() {
    lightTap();
    buttonSound();
  }
}
