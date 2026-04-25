/// Vertical placement of the toast on screen.
enum ToastGravity { top, bottom, center }

/// Horizontal placement of the toast on web only.
enum ToastWebPosition { left, center, right }

/// The entrance/exit animation used for the toast.
enum ToastAnimation {
  /// Slide in from the gravity direction combined with a fade.
  slide,

  /// Fade in and out.
  fade,

  /// Scale in and out combined with a fade.
  scale,
}

/// How a new toast replaces the currently visible one.
enum ReplacementMode {
  /// Remove the current toast immediately, then show the new one.
  instantReplace,

  /// Animate the current toast out while animating the new one in.
  gracefulCrossfade,
}
