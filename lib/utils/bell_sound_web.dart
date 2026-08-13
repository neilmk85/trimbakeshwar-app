import 'dart:js_interop';

@JS('eval')
external JSAny? _eval(String code);

void playBell() {
  try {
    _eval(r'''
(function() {
  var AC = window.AudioContext || window.webkitAudioContext;
  if (!AC) return;
  var ac = new AC();
  var t  = ac.currentTime;

  function tone(freq, vol) {
    var osc  = ac.createOscillator();
    var gain = ac.createGain();
    osc.connect(gain);
    gain.connect(ac.destination);
    osc.type = 'sine';
    osc.frequency.value = freq;
    gain.gain.setValueAtTime(vol, t);
    gain.gain.exponentialRampToValueAtTime(0.0001, t + 1.6);
    osc.start(t);
    osc.stop(t + 1.6);
  }

  tone(880,  0.40);   // fundamental  A5
  tone(2637, 0.18);   // overtone     E7 — inharmonic shimmer
  tone(1319, 0.12);   // overtone     E6
})()
    ''');
  } catch (_) {}
}
