// FishGame 競技捕魚 — FX Engine
// Canvas particle effects for coins, explosions, and hits

class FXEngine {
  constructor() {
    this.canvas = null;
    this.ctx = null;
    this.particles = [];
    this.animId = null;
    this.flashAlpha = 0;
    this.flashColor = '#FFFFFF';
  }

  init(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this._resize();
    window.addEventListener('resize', () => this._resize());
    this.animate();
  }

  _resize() {
    if (!this.canvas) return;
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }

  // ---- Particle Creation ----

  spawnCoins(x, y, count = 20) {
    const colors = ['#F5C842', '#FFD700', '#FFF068', '#E0A800', '#FFE566'];

    for (let i = 0; i < count; i++) {
      const angle = -Math.PI / 2 + (Math.random() - 0.5) * Math.PI * 1.2;
      const speed = 3 + Math.random() * 6;

      this.particles.push({
        type: 'coin',
        x: x,
        y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1.0,
        decay: 0.018 + Math.random() * 0.012,
        gravity: 0.25 + Math.random() * 0.15,
        size: 6 + Math.random() * 8,
        rotation: Math.random() * Math.PI * 2,
        rotSpeed: (Math.random() - 0.5) * 0.3,
        color: colors[Math.floor(Math.random() * colors.length)],
        scaleX: 1.0
      });
    }
  }

  spawnJackpot() {
    const cx = window.innerWidth / 2;
    const cy = window.innerHeight / 2;
    const count = 120;
    const colors = ['#F5C842', '#FFD700', '#FFF068', '#FF6B35', '#00F5D4', '#FF00AA'];

    for (let i = 0; i < count; i++) {
      const angle = (Math.PI * 2 * i) / count + Math.random() * 0.3;
      const speed = 4 + Math.random() * 12;

      this.particles.push({
        type: 'coin',
        x: cx + (Math.random() - 0.5) * 100,
        y: cy + (Math.random() - 0.5) * 100,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed - 3,
        life: 1.0,
        decay: 0.010 + Math.random() * 0.010,
        gravity: 0.18,
        size: 8 + Math.random() * 12,
        rotation: Math.random() * Math.PI * 2,
        rotSpeed: (Math.random() - 0.5) * 0.25,
        color: colors[Math.floor(Math.random() * colors.length)],
        scaleX: 1.0
      });
    }

    // Add sparkle bursts
    for (let i = 0; i < 30; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 2 + Math.random() * 8;
      this.particles.push({
        type: 'sparkle',
        x: cx + (Math.random() - 0.5) * 200,
        y: cy + (Math.random() - 0.5) * 200,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1.0,
        decay: 0.025,
        gravity: 0.05,
        size: 3 + Math.random() * 5,
        color: '#FFFFFF'
      });
    }

    // Screen flash
    this.flashAlpha = 0.5;
    this.flashColor = 'rgba(245, 200, 66, 0.4)';
  }

  spawnBossKill(x, y) {
    // Large explosion
    for (let i = 0; i < 60; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 2 + Math.random() * 14;
      const colors = ['#FF4444', '#FF8800', '#FFD700', '#FFFFFF', '#FF6600'];

      this.particles.push({
        type: 'explosion',
        x: x + (Math.random() - 0.5) * 60,
        y: y + (Math.random() - 0.5) * 60,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1.0,
        decay: 0.015 + Math.random() * 0.015,
        gravity: 0.1,
        size: 6 + Math.random() * 20,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }

    // Shockwave ring
    this.particles.push({
      type: 'ring',
      x: x, y: y,
      radius: 10,
      maxRadius: 200,
      life: 1.0,
      decay: 0.04,
      color: '#FF8800'
    });

    // Coin burst from boss kill
    this.spawnCoins(x, y, 30);

    // Big flash
    this.flashAlpha = 0.8;
    this.flashColor = 'rgba(255, 255, 255, 0.6)';
  }

  spawnHit(x, y) {
    const colors = ['#00F5D4', '#FFFFFF', '#F5C842'];
    for (let i = 0; i < 10; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 1.5 + Math.random() * 4;

      this.particles.push({
        type: 'hit',
        x: x + (Math.random() - 0.5) * 20,
        y: y + (Math.random() - 0.5) * 20,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1.0,
        decay: 0.06 + Math.random() * 0.04,
        gravity: 0.05,
        size: 2 + Math.random() * 4,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }
  }

  spawnLevelUp(x, y) {
    const colors = ['#F5C842', '#00F5D4', '#FFFFFF', '#FFD700'];
    for (let i = 0; i < 25; i++) {
      const angle = -Math.PI / 2 + (Math.random() - 0.5) * Math.PI;
      const speed = 3 + Math.random() * 7;
      this.particles.push({
        type: 'sparkle',
        x: x + (Math.random() - 0.5) * 40,
        y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1.0,
        decay: 0.02,
        gravity: 0.1,
        size: 3 + Math.random() * 6,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }
  }

  // ---- Animation Loop ----

  animate() {
    this.animId = requestAnimationFrame(() => this.animate());
    this._update();
    this._draw();
  }

  _update() {
    // Decay flash
    if (this.flashAlpha > 0) {
      this.flashAlpha = Math.max(0, this.flashAlpha - 0.04);
    }

    // Update particles
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];

      if (p.type === 'ring') {
        p.radius += 8;
        p.life -= p.decay;
        if (p.life <= 0 || p.radius >= p.maxRadius) {
          this.particles.splice(i, 1);
        }
        continue;
      }

      p.x += p.vx;
      p.y += p.vy;
      p.vy += p.gravity || 0;
      p.vx *= 0.98;
      p.life -= p.decay;

      if (p.rotation !== undefined) {
        p.rotation += p.rotSpeed || 0;
      }

      // Coin flip effect
      if (p.type === 'coin' && p.scaleX !== undefined) {
        p.scaleX = Math.cos(p.rotation * 3);
      }

      if (p.life <= 0) {
        this.particles.splice(i, 1);
      }
    }
  }

  _draw() {
    if (!this.ctx || !this.canvas) return;
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // Screen flash
    if (this.flashAlpha > 0) {
      this.ctx.save();
      this.ctx.globalAlpha = this.flashAlpha;
      this.ctx.fillStyle = this.flashColor;
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
      this.ctx.restore();
    }

    // Draw particles
    for (const p of this.particles) {
      this.ctx.save();
      this.ctx.globalAlpha = Math.max(0, p.life);

      if (p.type === 'ring') {
        this.ctx.strokeStyle = p.color;
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        this.ctx.stroke();
      } else if (p.type === 'coin') {
        this.ctx.translate(p.x, p.y);
        this.ctx.rotate(p.rotation || 0);
        this.ctx.scale(p.scaleX !== undefined ? Math.abs(p.scaleX) || 0.1 : 1, 1);

        const grad = this.ctx.createRadialGradient(-p.size * 0.2, -p.size * 0.2, 0, 0, 0, p.size);
        grad.addColorStop(0, '#FFF8CC');
        grad.addColorStop(0.4, p.color);
        grad.addColorStop(1, '#C99A00');

        this.ctx.beginPath();
        this.ctx.arc(0, 0, p.size, 0, Math.PI * 2);
        this.ctx.fillStyle = grad;
        this.ctx.fill();

        this.ctx.strokeStyle = 'rgba(255,255,255,0.3)';
        this.ctx.lineWidth = 0.5;
        this.ctx.stroke();
      } else if (p.type === 'sparkle') {
        this.ctx.translate(p.x, p.y);
        const size = p.size * p.life;
        this.ctx.fillStyle = p.color;
        this.ctx.shadowColor = p.color;
        this.ctx.shadowBlur = size * 2;
        this.ctx.beginPath();
        for (let j = 0; j < 4; j++) {
          const angle = (j * Math.PI) / 2;
          const dist = size * 2;
          if (j === 0) this.ctx.moveTo(Math.cos(angle) * dist, Math.sin(angle) * dist);
          else this.ctx.lineTo(Math.cos(angle) * dist, Math.sin(angle) * dist);
        }
        this.ctx.closePath();
        this.ctx.fill();
      } else {
        // Generic circle particle (hit, explosion)
        this.ctx.translate(p.x, p.y);
        this.ctx.fillStyle = p.color;
        this.ctx.shadowColor = p.color;
        this.ctx.shadowBlur = p.size * 1.5;
        this.ctx.beginPath();
        this.ctx.arc(0, 0, p.size * p.life, 0, Math.PI * 2);
        this.ctx.fill();
      }

      this.ctx.restore();
    }
  }

  stop() {
    if (this.animId) {
      cancelAnimationFrame(this.animId);
      this.animId = null;
    }
  }

  clear() {
    this.particles = [];
    if (this.ctx && this.canvas) {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
  }
}

export const fxEngine = new FXEngine();
