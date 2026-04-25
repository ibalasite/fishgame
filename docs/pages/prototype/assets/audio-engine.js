// FishGame 競技捕魚 — Audio Engine
// Web Audio API synthesized sound effects and BGM

class AudioEngine {
  constructor() {
    this.ctx = null;
    this.unlocked = false;
    this.sfxGain = null;
    this.bgmGain = null;
    this.bgmOscillators = [];
    this.bgmInterval = null;
    this.currentBGM = null;
    this.sfxVolume = 0.7;
    this.bgmVolume = 0.35;
  }

  _ensureContext() {
    if (!this.ctx) {
      try {
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        this.sfxGain = this.ctx.createGain();
        this.sfxGain.gain.value = this.sfxVolume;
        this.sfxGain.connect(this.ctx.destination);

        this.bgmGain = this.ctx.createGain();
        this.bgmGain.gain.value = this.bgmVolume;
        this.bgmGain.connect(this.ctx.destination);
      } catch (e) {
        console.warn('[AudioEngine] Web Audio API not available:', e);
        return false;
      }
    }
    return true;
  }

  unlock() {
    if (!this._ensureContext()) return;
    if (this.ctx.state === 'suspended') {
      this.ctx.resume().then(() => {
        this.unlocked = true;
        console.log('[AudioEngine] Audio context unlocked');
        const btn = document.getElementById('audio-unlock-btn');
        if (btn) btn.style.display = 'none';
      });
    } else {
      this.unlocked = true;
    }
  }

  _createOscillator(type, freq, startTime, duration, gainValue = 0.3, detune = 0) {
    if (!this.ctx) return null;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = type;
    osc.frequency.setValueAtTime(freq, startTime);
    if (detune !== 0) osc.detune.setValueAtTime(detune, startTime);

    gain.gain.setValueAtTime(0, startTime);
    gain.gain.linearRampToValueAtTime(gainValue, startTime + 0.01);
    gain.gain.linearRampToValueAtTime(0, startTime + duration);

    osc.connect(gain);
    gain.connect(this.sfxGain);

    osc.start(startTime);
    osc.stop(startTime + duration + 0.05);
    return osc;
  }

  playBGM(type) {
    if (!this._ensureContext()) return;
    if (this.ctx.state === 'suspended') this.ctx.resume();
    this.stopBGM();
    this.currentBGM = type;

    const now = this.ctx.currentTime;

    if (type === 'lobby') {
      this._playLobbyBGM(now);
    } else if (type === 'battle') {
      this._playBattleBGM(now);
    } else if (type === 'jackpot') {
      this._playJackpotBGM(now);
    }
  }

  _playLobbyBGM(startTime) {
    // Soft, calm ambient tones — pentatonic-ish
    const notes = [261.63, 293.66, 329.63, 392.00, 440.00];
    let t = startTime;

    const schedule = () => {
      if (this.currentBGM !== 'lobby') return;
      const note = notes[Math.floor(Math.random() * notes.length)];
      const osc = this._createOscillator('sine', note, this.ctx.currentTime, 1.2, 0.15);
      const osc2 = this._createOscillator('triangle', note * 2, this.ctx.currentTime, 0.8, 0.06);
      if (osc) this.bgmOscillators.push(osc);
      if (osc2) this.bgmOscillators.push(osc2);
      this.bgmInterval = setTimeout(schedule, 600 + Math.random() * 400);
    };

    // Base drone
    const drone = this.ctx.createOscillator();
    const droneGain = this.ctx.createGain();
    drone.type = 'sine';
    drone.frequency.value = 65.41; // C2
    droneGain.gain.value = 0.08;
    drone.connect(droneGain);
    droneGain.connect(this.bgmGain);
    drone.start(startTime);
    this.bgmOscillators.push(drone);
    this._droneNode = { osc: drone, gain: droneGain };

    schedule();
  }

  _playBattleBGM(startTime) {
    // Tense, rhythmic bass pattern
    const bassNotes = [110, 110, 146.83, 123.47, 110, 98];
    let beatIndex = 0;
    const tempo = 0.22;

    const schedule = () => {
      if (this.currentBGM !== 'battle') return;
      const freq = bassNotes[beatIndex % bassNotes.length];
      const now = this.ctx.currentTime;

      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(0, now);
      gain.gain.linearRampToValueAtTime(0.18, now + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.001, now + tempo * 0.9);
      osc.connect(gain);
      gain.connect(this.bgmGain);
      osc.start(now);
      osc.stop(now + tempo);
      this.bgmOscillators.push(osc);

      beatIndex++;
      this.bgmInterval = setTimeout(schedule, tempo * 1000);
    };

    // High tension string simulation
    const stringSchedule = () => {
      if (this.currentBGM !== 'battle') return;
      const highNotes = [440, 494, 440, 392];
      const now = this.ctx.currentTime;
      const note = highNotes[Math.floor(Math.random() * highNotes.length)];
      const osc = this._createOscillator('square', note, now, 0.3, 0.04);
      if (osc) this.bgmOscillators.push(osc);
      setTimeout(stringSchedule, 350 + Math.random() * 200);
    };

    schedule();
    setTimeout(stringSchedule, 500);
  }

  _playJackpotBGM(startTime) {
    // Victory fanfare — ascending major scale
    const fanfare = [
      { freq: 523.25, time: 0,    dur: 0.15 },
      { freq: 659.25, time: 0.15, dur: 0.15 },
      { freq: 783.99, time: 0.30, dur: 0.15 },
      { freq: 1046.5, time: 0.45, dur: 0.4  },
      { freq: 783.99, time: 0.55, dur: 0.1  },
      { freq: 1046.5, time: 0.65, dur: 0.6  }
    ];

    fanfare.forEach(n => {
      const t = startTime + n.time;
      const osc1 = this._createOscillator('triangle', n.freq, t, n.dur, 0.3);
      const osc2 = this._createOscillator('sine', n.freq * 1.5, t, n.dur * 0.8, 0.1);
      if (osc1) this.bgmOscillators.push(osc1);
      if (osc2) this.bgmOscillators.push(osc2);
    });

    // Repeated celebration
    setTimeout(() => {
      if (this.currentBGM === 'jackpot') {
        this._playJackpotBGM(this.ctx.currentTime);
      }
    }, 1600);
  }

  stopBGM() {
    if (this.bgmInterval) {
      clearTimeout(this.bgmInterval);
      this.bgmInterval = null;
    }

    this.bgmOscillators.forEach(osc => {
      try {
        const now = this.ctx ? this.ctx.currentTime : 0;
        if (osc.stop) {
          if (this.bgmGain) {
            this.bgmGain.gain.setValueAtTime(this.bgmGain.gain.value, now);
            this.bgmGain.gain.linearRampToValueAtTime(0, now + 0.3);
          }
          setTimeout(() => {
            try { osc.stop(); } catch(e) {}
          }, 350);
        }
      } catch (e) {}
    });

    this.bgmOscillators = [];
    this.currentBGM = null;

    // Reset gain after fade
    if (this.bgmGain && this.ctx) {
      setTimeout(() => {
        if (this.bgmGain) {
          this.bgmGain.gain.setValueAtTime(this.bgmVolume, this.ctx.currentTime);
        }
      }, 400);
    }
  }

  playSFX(type) {
    if (!this._ensureContext()) return;
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
      return;
    }

    const now = this.ctx.currentTime;

    switch (type) {
      case 'shoot':
        this._sfxShoot(now);
        break;
      case 'hit':
        this._sfxHit(now);
        break;
      case 'coin':
        this._sfxCoin(now);
        break;
      case 'button':
        this._sfxButton(now);
        break;
      case 'levelup':
        this._sfxLevelUp(now);
        break;
      case 'error':
        this._sfxError(now);
        break;
      case 'jackpot':
        this._sfxJackpot(now);
        break;
      default:
        break;
    }
  }

  _sfxShoot(now) {
    // Short high-to-low sweep: freq 800→200, 0.1s
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(800, now);
    osc.frequency.exponentialRampToValueAtTime(200, now + 0.1);

    gain.gain.setValueAtTime(0.35, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);

    osc.connect(gain);
    gain.connect(this.sfxGain);
    osc.start(now);
    osc.stop(now + 0.12);
  }

  _sfxHit(now) {
    // Mid-freq impact: noise burst
    const bufferSize = this.ctx.sampleRate * 0.15;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = (Math.random() * 2 - 1) * (1 - i / bufferSize);
    }

    const noise = this.ctx.createBufferSource();
    noise.buffer = buffer;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 400;
    filter.Q.value = 1.0;

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(0.5, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(this.sfxGain);
    noise.start(now);
    noise.stop(now + 0.16);

    // Tone overlay
    const osc = this.ctx.createOscillator();
    const og = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.value = 350;
    og.gain.setValueAtTime(0.2, now);
    og.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
    osc.connect(og);
    og.connect(this.sfxGain);
    osc.start(now);
    osc.stop(now + 0.14);
  }

  _sfxCoin(now) {
    // High metallic tinkle: 1200→800, 0.2s
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(1200, now);
    osc.frequency.exponentialRampToValueAtTime(800, now + 0.2);

    gain.gain.setValueAtTime(0.4, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.2);

    osc.connect(gain);
    gain.connect(this.sfxGain);
    osc.start(now);
    osc.stop(now + 0.22);

    // Harmonic
    const osc2 = this.ctx.createOscillator();
    const g2 = this.ctx.createGain();
    osc2.type = 'triangle';
    osc2.frequency.setValueAtTime(2400, now);
    osc2.frequency.exponentialRampToValueAtTime(1600, now + 0.15);
    g2.gain.setValueAtTime(0.15, now);
    g2.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
    osc2.connect(g2);
    g2.connect(this.sfxGain);
    osc2.start(now);
    osc2.stop(now + 0.17);
  }

  _sfxButton(now) {
    // Crisp click: 600 Hz, 0.05s
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(600, now);
    osc.frequency.linearRampToValueAtTime(400, now + 0.05);

    gain.gain.setValueAtTime(0.25, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);

    osc.connect(gain);
    gain.connect(this.sfxGain);
    osc.start(now);
    osc.stop(now + 0.07);
  }

  _sfxLevelUp(now) {
    // Ascending scale: C4 D4 E4 G4 C5
    const scale = [261.63, 293.66, 329.63, 392.00, 523.25];
    scale.forEach((freq, i) => {
      const t = now + i * 0.1;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = i === scale.length - 1 ? 'sine' : 'triangle';
      osc.frequency.value = freq;

      const dur = i === scale.length - 1 ? 0.4 : 0.12;
      gain.gain.setValueAtTime(0.35, t);
      gain.gain.exponentialRampToValueAtTime(0.001, t + dur);

      osc.connect(gain);
      gain.connect(this.sfxGain);
      osc.start(t);
      osc.stop(t + dur + 0.05);
    });
  }

  _sfxError(now) {
    const freqs = [200, 150];
    freqs.forEach((freq, i) => {
      const t = now + i * 0.12;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(0.3, t);
      gain.gain.exponentialRampToValueAtTime(0.001, t + 0.1);
      osc.connect(gain);
      gain.connect(this.sfxGain);
      osc.start(t);
      osc.stop(t + 0.12);
    });
  }

  _sfxJackpot(now) {
    // Multi-tone celebration burst
    const chords = [
      [523.25, 659.25, 783.99],
      [587.33, 739.99, 880.00],
      [659.25, 830.61, 987.77]
    ];

    chords.forEach((chord, ci) => {
      const t = now + ci * 0.2;
      chord.forEach(freq => {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.value = freq;
        gain.gain.setValueAtTime(0.2, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.3);
        osc.connect(gain);
        gain.connect(this.sfxGain);
        osc.start(t);
        osc.stop(t + 0.35);
      });
    });
  }

  setVolume(sfx, bgm) {
    if (sfx !== undefined && this.sfxGain) {
      this.sfxVolume = sfx;
      this.sfxGain.gain.value = sfx;
    }
    if (bgm !== undefined && this.bgmGain) {
      this.bgmVolume = bgm;
      this.bgmGain.gain.value = bgm;
    }
  }
}

export const audioEngine = new AudioEngine();
