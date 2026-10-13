/**
 * Multimedia & Interactive Lab Suite Logic
 * Pure vanilla ES5/ES6, Web Audio API, Canvas, Presentation Deck, and Telemetry
 */
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    initAudioLab();
    initSlideDeck();
    initSimulator();
  });

  // ==========================================
  // 1. Dual Audio Crossfader Laboratory
  // ==========================================
  function initAudioLab() {
    var rawAudio = document.getElementById('audio-raw');
    var fixedAudio = document.getElementById('audio-fixed');
    var playBtn = document.getElementById('btn-lab-play');
    var fader = document.getElementById('lab-crossfader');
    var timeDisplay = document.getElementById('lab-time');
    var canvas = document.getElementById('visualizer-canvas');
    if (!rawAudio || !fixedAudio || !playBtn || !fader) return;

    var isPlaying = false;
    var audioCtx = null;
    var rawGain = null;
    var fixedGain = null;
    var analyser = null;
    var dataArray = null;

    function initWebAudio() {
      if (audioCtx) return;
      var AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!AudioContext) return;
      audioCtx = new AudioContext();

      var rawSource = audioCtx.createMediaElementSource(rawAudio);
      var fixedSource = audioCtx.createMediaElementSource(fixedAudio);

      rawGain = audioCtx.createGain();
      fixedGain = audioCtx.createGain();
      analyser = audioCtx.createAnalyser();
      analyser.fftSize = 256;

      rawSource.connect(rawGain);
      fixedSource.connect(fixedGain);

      rawGain.connect(analyser);
      fixedGain.connect(analyser);
      analyser.connect(audioCtx.destination);

      updateGainValues();
      startVisualizer();
    }

    function updateGainValues() {
      var val = parseFloat(fader.value); // 0.0 (Raw) to 1.0 (Fixed)
      if (rawGain && fixedGain) {
        // Equal-power crossfade curve
        rawGain.gain.setValueAtTime(Math.cos(val * 0.5 * Math.PI), audioCtx.currentTime);
        fixedGain.gain.setValueAtTime(Math.cos((1.0 - val) * 0.5 * Math.PI), audioCtx.currentTime);
      } else {
        rawAudio.volume = 1.0 - val;
        fixedAudio.volume = val;
      }
    }

    fader.addEventListener('input', function () {
      if (audioCtx && audioCtx.state === 'suspended') {
        audioCtx.resume();
      }
      updateGainValues();
    });

    playBtn.addEventListener('click', function () {
      initWebAudio();
      if (audioCtx && audioCtx.state === 'suspended') {
        audioCtx.resume();
      }

      if (!isPlaying) {
        // Synchronize playheads
        fixedAudio.currentTime = rawAudio.currentTime;
        Promise.all([rawAudio.play(), fixedAudio.play()]).then(function () {
          isPlaying = true;
          playBtn.innerHTML = '❚❚';
          playBtn.setAttribute('aria-label', 'Pause audio playback');
        }).catch(function (err) {
          console.warn('Playback error:', err);
        });
      } else {
        rawAudio.pause();
        fixedAudio.pause();
        isPlaying = false;
        playBtn.innerHTML = '▶';
        playBtn.setAttribute('aria-label', 'Play audio comparison');
      }
    });

    rawAudio.addEventListener('timeupdate', function () {
      var cur = rawAudio.currentTime;
      var dur = rawAudio.duration || 20;
      if (timeDisplay) {
        timeDisplay.innerText = formatTime(cur) + ' / ' + formatTime(dur);
      }
      // Re-sync if drifted beyond 50ms
      if (Math.abs(rawAudio.currentTime - fixedAudio.currentTime) > 0.05) {
        fixedAudio.currentTime = rawAudio.currentTime;
      }
    });

    rawAudio.addEventListener('ended', function () {
      isPlaying = false;
      playBtn.innerHTML = '▶';
    });

    function formatTime(sec) {
      var m = Math.floor(sec / 60);
      var s = Math.floor(sec % 60);
      return (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
    }

    // Canvas Frequency Visualizer
    function startVisualizer() {
      if (!canvas || !analyser) return;
      var ctx = canvas.getContext('2d');
      var bufferLength = analyser.frequencyBinCount;
      dataArray = new Uint8Array(bufferLength);

      function renderFrame() {
        requestAnimationFrame(renderFrame);
        analyser.getByteFrequencyData(dataArray);

        ctx.fillStyle = '#05080c';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        var barWidth = (canvas.width / bufferLength) * 2.2;
        var barHeight;
        var x = 0;

        for (var i = 0; i < bufferLength; i++) {
          barHeight = (dataArray[i] / 255) * canvas.height;
          // Red for raw harmonics, Green for cleaned spectrum
          var faderVal = parseFloat(fader.value);
          var r = Math.round(255 * (1 - faderVal) + 63 * faderVal);
          var g = Math.round(100 * (1 - faderVal) + 185 * faderVal);
          var b = Math.round(100 * (1 - faderVal) + 80 * faderVal);

          ctx.fillStyle = 'rgb(' + r + ',' + g + ',' + b + ')';
          ctx.fillRect(x, canvas.height - barHeight, barWidth, barHeight);
          x += barWidth + 1;
        }
      }
      renderFrame();
    }
  }

  // ==========================================
  // 2. Interactive Presentation Deck Engine
  // ==========================================
  function initSlideDeck() {
    var slides = document.querySelectorAll('.deck-slide');
    var dots = document.querySelectorAll('.deck-dot');
    var prevBtn = document.getElementById('deck-prev');
    var nextBtn = document.getElementById('deck-next');
    if (!slides.length) return;

    var currentIdx = 0;

    function showSlide(idx) {
      if (idx < 0) idx = 0;
      if (idx >= slides.length) idx = slides.length - 1;
      currentIdx = idx;

      slides.forEach(function (slide, i) {
        if (i === currentIdx) {
          slide.classList.add('active');
          slide.setAttribute('aria-hidden', 'false');
        } else {
          slide.classList.remove('active');
          slide.setAttribute('aria-hidden', 'true');
        }
      });

      dots.forEach(function (dot, i) {
        if (i === currentIdx) {
          dot.classList.add('active');
          dot.setAttribute('aria-current', 'true');
        } else {
          dot.classList.remove('active');
          dot.removeAttribute('aria-current');
        }
      });
    }

    if (prevBtn) {
      prevBtn.addEventListener('click', function () {
        showSlide(currentIdx - 1);
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', function () {
        showSlide(currentIdx + 1);
      });
    }

    dots.forEach(function (dot, i) {
      dot.addEventListener('click', function () {
        showSlide(i);
      });
    });

    // Keyboard navigation: Left/Right arrows
    document.addEventListener('keydown', function (e) {
      var deck = document.getElementById('presentation-deck');
      if (!deck) return;
      var rect = deck.getBoundingClientRect();
      // Only handle if deck is in or near viewport
      if (rect.top < window.innerHeight && rect.bottom > 0) {
        if (e.key === 'ArrowRight') {
          showSlide(currentIdx + 1);
        } else if (e.key === 'ArrowLeft') {
          showSlide(currentIdx - 1);
        }
      }
    });

    showSlide(0);
  }

  // ==========================================
  // 3. Epistemic Simulator Diagnostic Quiz
  // ==========================================
  function initSimulator() {
    var options = document.querySelectorAll('[data-simulator-choice]');
    var resultBox = document.getElementById('simulator-result');
    if (!options.length || !resultBox) return;

    options.forEach(function (opt) {
      opt.addEventListener('click', function () {
        var choice = opt.getAttribute('data-simulator-choice');
        resultBox.className = 'quiz-result ' + choice;
        if (choice === 'slop') {
          resultBox.innerHTML = '<strong>⚠️ High Risk of Synthetic Slop:</strong> The proposal relies on passing test assertions in isolation, accepts unverified container headers, or adds speculative architectural layers (The Homer). <em>Action: Stop, refuse the hallucination, and conduct physical keyframe verification.</em>';
        } else {
          resultBox.innerHTML = '<strong>✅ Sovereign Grounded Solution:</strong> The proposal enforces strict boundary testing against physical ground truth (speech onsets, lossless bitstream muxing, high-Q notch isolation), with clear human accountability. <em>Action: Approved for deployment.</em>';
        }
      });
    });
  }

})();
