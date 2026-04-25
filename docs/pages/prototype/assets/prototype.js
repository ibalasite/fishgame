// FishGame 競技捕魚 — Main Prototype Logic
// Router + 8 Screens + Game Canvas Engine

'use strict';

// ============================================================
// Router
// ============================================================
const router = {
  current: null,
  screens: {},
  history: [],

  register(id, fn) {
    this.screens[id] = fn;
  },

  navigate(id, data) {
    if (this.screens[id]) {
      this.current = id;
      this.history.push(id);
      if (this.history.length > 20) this.history.shift();

      // Update breadcrumb
      const crumb = document.getElementById('proto-breadcrumb');
      const names = {
        'loading-scene':      '載入中',
        'login-scene':        '登入',
        'lobby-scene':        '遊戲大廳',
        'cannon-select-scene':'砲台選擇',
        'matchmaking-scene':  '配對等待',
        'game-scene':         '遊戲中',
        'settlement-scene':   '結算',
        'shop-scene':         '商城'
      };
      if (crumb) crumb.textContent = names[id] || id;

      // Clear timers
      if (window._gameTimers) {
        window._gameTimers.forEach(t => clearInterval(t));
      }
      window._gameTimers = [];

      const content = document.getElementById('proto-content');
      if (content) {
        content.innerHTML = '';
        this.screens[id](data);
      }

      window.location.hash = id;
      if (window.audioEngine) audioEngine.playSFX('button');
    }
  },

  back() {
    if (this.history.length > 1) {
      this.history.pop();
      const prev = this.history[this.history.length - 1];
      if (prev) this.navigate(prev);
    }
  }
};

// ============================================================
// Toast
// ============================================================
function showToast(message, type = 'success') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;

  const icons = { success: '✓', error: '✕', info: 'ℹ', gold: '★' };
  toast.innerHTML = `<span>${icons[type] || '●'}</span><span>${message}</span>`;

  container.appendChild(toast);

  setTimeout(() => {
    toast.style.animation = 'toastOut 0.3s ease-in forwards';
    setTimeout(() => {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, 300);
  }, 2500);
}

// ============================================================
// Flow Map Modal
// ============================================================
function showFlowMap() {
  const modal = document.getElementById('flow-map-modal');
  const grid = document.getElementById('screen-grid');
  if (!modal || !grid) return;

  const screens = [
    { id: 'loading-scene',       name: '① 載入畫面',   icon: '⏳' },
    { id: 'login-scene',         name: '② 登入/註冊',   icon: '🔑' },
    { id: 'lobby-scene',         name: '③ 遊戲大廳',   icon: '🏠' },
    { id: 'cannon-select-scene', name: '④ 砲台選擇',   icon: '🔫' },
    { id: 'matchmaking-scene',   name: '⑤ 配對等待',   icon: '⏱️' },
    { id: 'game-scene',          name: '⑥ 遊戲進行',   icon: '🎮' },
    { id: 'settlement-scene',    name: '⑦ 結算',       icon: '🏆' },
    { id: 'shop-scene',          name: '⑧ 商城',       icon: '🛒' }
  ];

  grid.innerHTML = screens.map(s => `
    <button onclick="router.navigate('${s.id}'); document.getElementById('flow-map-modal').style.display='none';"
      style="background:rgba(10,35,64,0.9);border:1px solid rgba(245,200,66,0.3);border-radius:12px;padding:14px 10px;cursor:pointer;color:#fff;font-family:inherit;font-size:13px;font-weight:600;transition:all 0.2s;display:flex;align-items:center;gap:8px;"
      onmouseover="this.style.borderColor='#F5C842';this.style.background='rgba(245,200,66,0.1)'"
      onmouseout="this.style.borderColor='rgba(245,200,66,0.3)';this.style.background='rgba(10,35,64,0.9)'">
      <span style="font-size:18px">${s.icon}</span>
      <span>${s.name}</span>
    </button>
  `).join('');

  modal.style.display = 'flex';
}

// ============================================================
// Screen 1: Loading Scene
// ============================================================
function renderLoadingScene() {
  const content = document.getElementById('proto-content');
  content.innerHTML = `
    <div class="screen" style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;padding:24px;">
      <div style="text-align:center;max-width:340px;width:100%;">
        <span class="loading-fish-logo">🐟</span>
        <h1 style="font-size:clamp(28px,7vw,52px);font-weight:900;margin-bottom:8px;letter-spacing:2px;" class="text-gradient">
          FishGame
        </h1>
        <p style="font-size:18px;color:rgba(255,255,255,0.6);margin-bottom:48px;letter-spacing:4px;">
          競技捕魚
        </p>

        <div style="margin-bottom:12px;">
          <div class="progress-container">
            <div class="progress-bar" id="loading-bar" style="width:0%"></div>
          </div>
        </div>
        <p id="loading-text" style="font-size:13px;color:rgba(255,255,255,0.45);margin-top:8px;">正在載入遊戲資源...</p>

        <div style="display:flex;justify-content:center;gap:24px;margin-top:48px;color:rgba(255,255,255,0.3);font-size:12px;">
          <span>深海冒險</span><span>·</span><span>競技捕魚</span><span>·</span><span>贏取大獎</span>
        </div>
      </div>
    </div>
  `;

  // Animate progress bar
  const bar = document.getElementById('loading-bar');
  const text = document.getElementById('loading-text');
  const steps = [
    { pct: 20, msg: '正在載入圖形資源...' },
    { pct: 45, msg: '連接遊戲伺服器...' },
    { pct: 70, msg: '載入音效資源...' },
    { pct: 88, msg: '初始化遊戲引擎...' },
    { pct: 100, msg: '準備就緒！' }
  ];

  let step = 0;
  const advance = () => {
    if (step >= steps.length) {
      setTimeout(() => router.navigate('login-scene'), 400);
      return;
    }
    const s = steps[step++];
    if (bar) bar.style.width = s.pct + '%';
    if (text) text.textContent = s.msg;
    setTimeout(advance, step === steps.length ? 300 : 250 + Math.random() * 150);
  };

  setTimeout(advance, 300);
}

// ============================================================
// Screen 2: Login Scene
// ============================================================
function renderLoginScene() {
  const content = document.getElementById('proto-content');
  let isRegister = false;

  content.innerHTML = `
    <div class="screen" style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;padding:24px;">
      <div style="width:100%;max-width:360px;">

        <div style="text-align:center;margin-bottom:36px;">
          <span style="font-size:52px;display:block;margin-bottom:10px;">🐟</span>
          <h1 style="font-size:26px;font-weight:900;letter-spacing:2px;" class="text-gradient">FishGame</h1>
          <p style="color:rgba(255,255,255,0.5);font-size:14px;margin-top:4px;">競技捕魚 · 競爭到底</p>
        </div>

        <div class="game-card" style="padding:28px;">
          <h2 id="form-title" style="font-size:18px;font-weight:700;margin-bottom:24px;text-align:center;" class="text-gold">
            登入帳號
          </h2>

          <div style="display:flex;flex-direction:column;gap:14px;">
            <div>
              <label style="display:block;font-size:12px;color:rgba(255,255,255,0.5);margin-bottom:6px;font-weight:600;letter-spacing:0.5px;">帳號</label>
              <input class="input-field" type="text" id="login-user" placeholder="例：fishking2024" autocomplete="username">
            </div>
            <div>
              <label style="display:block;font-size:12px;color:rgba(255,255,255,0.5);margin-bottom:6px;font-weight:600;letter-spacing:0.5px;">密碼</label>
              <input class="input-field" type="password" id="login-pass" placeholder="請輸入密碼" autocomplete="current-password">
            </div>
            <div id="register-extra" style="display:none;">
              <label style="display:block;font-size:12px;color:rgba(255,255,255,0.5);margin-bottom:6px;font-weight:600;letter-spacing:0.5px;">暱稱</label>
              <input class="input-field" type="text" id="login-nick" placeholder="例：深海獵人">
            </div>
          </div>

          <button id="login-btn" class="btn-primary" style="width:100%;margin-top:24px;font-size:16px;padding:14px;"
            onclick="handleLogin()">
            登入遊戲
          </button>

          <div style="text-align:center;margin-top:16px;">
            <button onclick="toggleRegister()" style="background:none;border:none;color:rgba(0,245,212,0.8);font-size:13px;cursor:pointer;font-family:inherit;text-decoration:underline;">
              <span id="toggle-text">尚未加入？立即註冊</span>
            </button>
          </div>

          <div style="margin-top:20px;padding-top:16px;border-top:1px solid rgba(255,255,255,0.07);text-align:center;">
            <p style="font-size:12px;color:rgba(255,255,255,0.3);margin-bottom:8px;">快速體驗（無需登入）</p>
            <button class="btn-ghost" style="font-size:13px;padding:8px 20px;" onclick="router.navigate('lobby-scene')">
              訪客模式
            </button>
          </div>
        </div>

        <p style="text-align:center;margin-top:16px;font-size:11px;color:rgba(255,255,255,0.2);">
          繼續即表示同意服務條款及隱私政策
        </p>
      </div>
    </div>
  `;

  window.toggleRegister = function() {
    isRegister = !isRegister;
    document.getElementById('form-title').textContent = isRegister ? '建立帳號' : '登入帳號';
    document.getElementById('login-btn').textContent = isRegister ? '立即註冊' : '登入遊戲';
    document.getElementById('register-extra').style.display = isRegister ? 'block' : 'none';
    document.getElementById('toggle-text').textContent = isRegister ? '已有帳號？返回登入' : '尚未加入？立即註冊';
    if (window.audioEngine) audioEngine.playSFX('button');
  };

  window.handleLogin = function() {
    const user = document.getElementById('login-user').value;
    const pass = document.getElementById('login-pass').value;
    if (!user || !pass) {
      showToast('請填寫帳號和密碼', 'error');
      if (window.audioEngine) audioEngine.playSFX('error');
      return;
    }
    const btn = document.getElementById('login-btn');
    btn.textContent = '驗證中...';
    btn.disabled = true;
    setTimeout(() => {
      router.navigate('lobby-scene');
    }, 800);
  };

  // Enter key support
  document.getElementById('login-pass').addEventListener('keydown', e => {
    if (e.key === 'Enter') handleLogin();
  });
}

// ============================================================
// Screen 3: Lobby Scene
// ============================================================
function renderLobbyScene() {
  const content = document.getElementById('proto-content');
  const user = mockData.CURRENT_USER;
  const rooms = mockData.ROOMS;

  if (window.audioEngine) audioEngine.playBGM('lobby');

  content.innerHTML = `
    <div class="screen" style="min-height:100vh;display:flex;flex-direction:column;">

      <!-- Player Info Bar -->
      <div style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:rgba(3,11,26,0.8);border-bottom:1px solid rgba(255,255,255,0.06);">
        <div class="player-avatar vip" style="width:44px;height:44px;font-size:17px;flex-shrink:0;">${user.avatarInitial}</div>
        <div style="flex:1;min-width:0;">
          <div style="display:flex;align-items:center;gap:6px;">
            <span style="font-weight:700;font-size:15px;">${user.nickname}</span>
            <span class="vip-badge vip-${user.vipLevel}">VIP${user.vipLevel}</span>
          </div>
          <span style="font-size:12px;color:rgba(255,255,255,0.45);">Lv.${user.level} 砲手</span>
        </div>
        <div style="display:flex;gap:8px;flex-shrink:0;">
          <div class="stat-chip">🪙 <span>${user.coinBalance.toLocaleString()}</span></div>
          <div class="stat-chip" style="color:#00F5D4;border-color:rgba(0,245,212,0.2);">💎 ${user.diamondBalance}</div>
        </div>
      </div>

      <!-- Main Content -->
      <div style="flex:1;padding:16px 16px 80px;overflow-y:auto;">

        <!-- Quick Match Banner -->
        <div style="background:linear-gradient(135deg,rgba(245,200,66,0.12),rgba(0,245,212,0.08));border:1px solid rgba(245,200,66,0.25);border-radius:16px;padding:20px;margin-bottom:20px;display:flex;align-items:center;justify-content:space-between;cursor:pointer;"
          onclick="router.navigate('cannon-select-scene')"
          onmouseover="this.style.borderColor='rgba(245,200,66,0.5)'"
          onmouseout="this.style.borderColor='rgba(245,200,66,0.25)'">
          <div>
            <p style="font-size:11px;color:rgba(255,255,255,0.5);letter-spacing:1px;text-transform:uppercase;margin-bottom:4px;">推薦模式</p>
            <h2 style="font-size:20px;font-weight:800;" class="text-gold">⚡ 快速配對</h2>
            <p style="font-size:13px;color:rgba(255,255,255,0.55);margin-top:4px;">自動尋找最佳對手，即刻開戰</p>
          </div>
          <div style="text-align:right;">
            <div style="font-size:32px;margin-bottom:4px;">🎮</div>
            <div style="font-size:11px;color:rgba(255,255,255,0.4);">平均等待 &lt;30s</div>
          </div>
        </div>

        <!-- Section Header -->
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
          <h3 style="font-size:16px;font-weight:700;">選擇房間</h3>
          <span style="font-size:12px;color:rgba(255,255,255,0.4);">在線 ${rooms.reduce((a,r)=>a+r.online,0)} 人</span>
        </div>

        <!-- Room Grid -->
        <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:12px;">
          ${rooms.map(room => `
            <div class="room-card" onclick="selectRoom('${room.id}')">
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                <span style="font-size:22px;">${room.icon}</span>
                <span class="room-status ${room.status}">
                  ${room.status === 'waiting' ? '等待中' : room.status === 'playing' ? '進行中' : '已滿'}
                </span>
              </div>
              <h4 style="font-size:14px;font-weight:700;margin-bottom:4px;">${room.name}</h4>
              <p style="font-size:11px;color:rgba(255,255,255,0.45);margin-bottom:10px;line-height:1.4;">${room.description}</p>
              <div style="display:flex;align-items:center;justify-content:space-between;">
                <div>
                  <p style="font-size:10px;color:rgba(255,255,255,0.4);">最低賭注</p>
                  <p style="font-size:13px;font-weight:700;color:#F5C842;">${room.minBet.toLocaleString()}</p>
                </div>
                <div style="text-align:right;">
                  <p style="font-size:10px;color:rgba(255,255,255,0.4);">在線</p>
                  <p style="font-size:13px;font-weight:700;">${room.online}/${room.capacity}</p>
                </div>
              </div>
            </div>
          `).join('')}
        </div>

        <!-- Jackpot Banner -->
        <div style="margin-top:20px;background:rgba(245,200,66,0.06);border:1px solid rgba(245,200,66,0.2);border-radius:14px;padding:16px;text-align:center;">
          <p style="font-size:11px;color:rgba(255,255,255,0.4);letter-spacing:1px;margin-bottom:6px;">當前 JACKPOT 獎池</p>
          <p style="font-size:28px;font-weight:900;" class="text-glow">💰 ${mockData.GAME_SESSION.jackpotPool.toLocaleString()} 金幣</p>
          <div class="jackpot-progress" style="margin-top:12px;">
            <div class="jackpot-fill" style="width:${Math.round(mockData.GAME_SESSION.jackpotPool/mockData.GAME_SESSION.jackpotMax*100)}%"></div>
          </div>
        </div>

      </div>

      <!-- Tab Bar -->
      <nav class="tab-bar">
        <button class="tab-item active" onclick="audioEngine.playSFX('button')">
          <span class="tab-icon">🎮</span><span>遊戲</span>
        </button>
        <button class="tab-item" onclick="openShop()">
          <span class="tab-icon">🛒</span><span>商城</span>
        </button>
        <button class="tab-item" onclick="showLeaderboard()">
          <span class="tab-icon">🏆</span><span>排行榜</span>
        </button>
        <button class="tab-item" onclick="showSettings()">
          <span class="tab-icon">⚙️</span><span>設定</span>
        </button>
      </nav>
    </div>
  `;

  window.selectRoom = function(roomId) {
    const room = rooms.find(r => r.id === roomId);
    if (room && room.status === 'full') {
      showToast('此房間已滿，請選擇其他房間', 'error');
      return;
    }
    if (window.audioEngine) audioEngine.playSFX('button');
    router.navigate('cannon-select-scene', { roomId });
  };

  window.openShop = function() {
    if (window.audioEngine) audioEngine.playSFX('button');
    renderShopModal();
  };

  window.showLeaderboard = function() {
    if (window.audioEngine) audioEngine.playSFX('button');
    renderLeaderboardModal();
  };

  window.showSettings = function() {
    if (window.audioEngine) audioEngine.playSFX('button');
    showToast('設定功能開發中', 'info');
  };
}

// ============================================================
// Screen 4: Cannon Select Scene
// ============================================================
function renderCannonSelectScene(data) {
  const content = document.getElementById('proto-content');
  const weapons = mockData.WEAPONS;
  const skills = mockData.SKILLS;
  let selectedWeapon = 'weapon001';
  let selectedSkills = ['skill001', 'skill004'];

  content.innerHTML = `
    <div class="screen" style="min-height:100vh;padding:20px 16px 30px;">

      <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px;">
        <button class="btn-ghost" style="padding:8px 14px;font-size:13px;" onclick="router.navigate('lobby-scene')">← 大廳</button>
        <h1 style="font-size:20px;font-weight:800;">選擇裝備</h1>
      </div>

      <!-- Weapon Selection -->
      <div style="margin-bottom:28px;">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px;">
          <span style="font-size:16px;">🔫</span>
          <h2 style="font-size:15px;font-weight:700;" class="text-gold">砲台選擇</h2>
        </div>
        <div id="weapon-grid" style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;">
          ${weapons.map(w => `
            <div class="weapon-card ${w.id === selectedWeapon ? 'selected' : ''}" id="wcard-${w.id}"
              onclick="selectWeapon('${w.id}')">
              <span class="weapon-icon">${w.icon}</span>
              <h3 style="font-size:13px;font-weight:700;margin-bottom:4px;">${w.name}</h3>
              <p style="font-size:11px;color:rgba(255,255,255,0.45);margin-bottom:8px;line-height:1.4;">${w.special}</p>
              <div style="display:flex;justify-content:space-between;font-size:11px;">
                <span style="color:rgba(255,255,255,0.4);">費用</span>
                <span class="text-gold" style="font-weight:700;">${w.cost}</span>
              </div>
              <div style="display:flex;justify-content:space-between;font-size:11px;margin-top:3px;">
                <span style="color:rgba(255,255,255,0.4);">攻擊力</span>
                <div style="display:flex;gap:2px;">
                  ${Array.from({length: w.level}).map(()=>'<span style="color:#F5C842;font-size:10px;">▲</span>').join('')}
                </div>
              </div>
              ${w.id === selectedWeapon ? '<div style="position:absolute;top:8px;right:8px;font-size:14px;">✓</div>' : ''}
            </div>
          `).join('')}
        </div>
      </div>

      <!-- Skill Selection -->
      <div style="margin-bottom:28px;">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
          <div style="display:flex;align-items:center;gap:8px;">
            <span style="font-size:16px;">✨</span>
            <h2 style="font-size:15px;font-weight:700;" class="text-gold">技能選擇</h2>
          </div>
          <span style="font-size:12px;color:rgba(255,255,255,0.4);">最多選 2 個</span>
        </div>
        <div id="skill-grid" style="display:grid;grid-template-columns:repeat(2,1fr);gap:10px;">
          ${skills.map(s => `
            <div class="game-card ${selectedSkills.includes(s.id) ? 'selected' : ''}" id="scard-${s.id}"
              onclick="toggleSkill('${s.id}')"
              style="cursor:pointer;padding:14px;">
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;">
                <span style="font-size:26px;">${s.icon}</span>
                <div>
                  <h3 style="font-size:13px;font-weight:700;">${s.name}</h3>
                  <span style="font-size:11px;color:rgba(255,255,255,0.4);">冷卻 ${s.cooldown}s</span>
                </div>
              </div>
              <p style="font-size:12px;color:rgba(255,255,255,0.55);line-height:1.5;">${s.description}</p>
              ${selectedSkills.includes(s.id) ? '<div style="position:absolute;top:8px;right:8px;color:#F5C842;font-size:14px;">✓</div>' : ''}
            </div>
          `).join('')}
        </div>
      </div>

      <!-- Confirm Button -->
      <button class="btn-primary" style="width:100%;font-size:16px;padding:16px;" onclick="confirmSelection()">
        確認出戰 →
      </button>
    </div>
  `;

  window.selectWeapon = function(id) {
    selectedWeapon = id;
    weapons.forEach(w => {
      const el = document.getElementById('wcard-' + w.id);
      if (!el) return;
      el.classList.toggle('selected', w.id === id);
      const check = el.querySelector('.check-icon');
      if (w.id === id) {
        if (!el.querySelector('.check-icon')) {
          const c = document.createElement('div');
          c.className = 'check-icon';
          c.style.cssText = 'position:absolute;top:8px;right:8px;font-size:14px;';
          c.textContent = '✓';
          el.appendChild(c);
        }
      } else {
        const c = el.querySelector('.check-icon');
        if (c) c.remove();
      }
    });
    if (window.audioEngine) audioEngine.playSFX('button');
  };

  window.toggleSkill = function(id) {
    if (selectedSkills.includes(id)) {
      selectedSkills = selectedSkills.filter(s => s !== id);
    } else {
      if (selectedSkills.length >= 2) {
        showToast('最多選擇 2 個技能', 'error');
        return;
      }
      selectedSkills.push(id);
    }
    skills.forEach(s => {
      const el = document.getElementById('scard-' + s.id);
      if (!el) return;
      el.classList.toggle('selected', selectedSkills.includes(s.id));
    });
    if (window.audioEngine) audioEngine.playSFX('button');
  };

  window.confirmSelection = function() {
    mockData.CURRENT_USER.selectedWeapon = selectedWeapon;
    mockData.CURRENT_USER.selectedSkills = selectedSkills;
    router.navigate('matchmaking-scene');
  };
}

// ============================================================
// Screen 5: Matchmaking Scene
// ============================================================
function renderMatchmakingScene() {
  const content = document.getElementById('proto-content');
  const players = mockData.PLAYERS.slice(0, 4);
  let countdown = 30;

  content.innerHTML = `
    <div class="screen" style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;padding:24px;text-align:center;">

      <h1 style="font-size:22px;font-weight:800;margin-bottom:6px;">正在配對中...</h1>
      <p style="font-size:14px;color:rgba(255,255,255,0.45);margin-bottom:40px;">正在為您尋找最佳對手</p>

      <!-- Players -->
      <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:24px;max-width:300px;width:100%;margin-bottom:40px;">
        ${players.map((p, i) => `
          <div class="match-player" style="animation-delay:${i * 0.2}s;">
            <div class="player-avatar large ${p.isVIP ? 'vip' : ''}"
              style="width:68px;height:68px;font-size:24px;${i === 0 ? 'border-color:#F5C842;' : ''}">
              ${p.avatarInitial}
            </div>
            <p style="font-size:13px;font-weight:600;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:120px;">${p.nickname}</p>
            <p style="font-size:11px;color:rgba(255,255,255,0.4);">Lv.${p.level}</p>
          </div>
        `).join('')}
      </div>

      <!-- Progress -->
      <div style="width:100%;max-width:280px;margin-bottom:20px;">
        <div class="progress-container" style="height:6px;">
          <div class="progress-bar" id="match-bar" style="width:0%;transition:width 2s linear;"></div>
        </div>
      </div>

      <!-- Countdown -->
      <div style="display:flex;flex-direction:column;align-items:center;gap:4px;margin-bottom:32px;">
        <span id="match-countdown" style="font-size:42px;font-weight:900;" class="text-gold">${countdown}</span>
        <span style="font-size:13px;color:rgba(255,255,255,0.4);">秒後自動配對</span>
      </div>

      <!-- Status indicator -->
      <div id="match-status" style="display:flex;align-items:center;gap:8px;margin-bottom:24px;font-size:14px;color:rgba(255,255,255,0.6);">
        <div style="width:8px;height:8px;border-radius:50%;background:#00F5D4;animation:pulse 1s infinite;"></div>
        正在搜尋玩家...
      </div>

      <button class="btn-ghost" onclick="router.navigate('cannon-select-scene')" style="font-size:14px;padding:10px 24px;">
        取消配對
      </button>
    </div>
  `;

  // Start countdown
  setTimeout(() => {
    const bar = document.getElementById('match-bar');
    if (bar) bar.style.width = '100%';
  }, 100);

  const timer = setInterval(() => {
    countdown--;
    const el = document.getElementById('match-countdown');
    if (el) el.textContent = countdown;

    if (countdown <= 0 || countdown === 28) {
      clearInterval(timer);
      const status = document.getElementById('match-status');
      if (status) {
        status.innerHTML = '<div style="width:8px;height:8px;border-radius:50%;background:#00FF88;animation:pulse 0.5s infinite;"></div><span style="color:#00FF88;font-weight:600;">配對成功！準備進入遊戲...</span>';
      }
      if (window.audioEngine) audioEngine.playSFX('levelup');
      setTimeout(() => router.navigate('game-scene'), 1200);
    }
  }, 1000);

  if (window._gameTimers) window._gameTimers.push(timer);
}

// ============================================================
// Screen 6: Game Scene
// ============================================================
function renderGameScene() {
  const content = document.getElementById('proto-content');
  const user = mockData.CURRENT_USER;
  const session = mockData.GAME_SESSION;
  const selectedSkills = (user.selectedSkills || []).map(id => mockData.SKILLS.find(s => s.id === id)).filter(Boolean);

  if (window.audioEngine) audioEngine.playBGM('battle');

  content.innerHTML = `
    <div class="screen" style="position:relative;width:100%;height:calc(100vh - 48px);overflow:hidden;background:#030B1A;">

      <!-- Game Canvas -->
      <canvas id="gameCanvas" style="position:absolute;inset:0;width:100%;height:100%;cursor:crosshair;touch-action:none;"></canvas>

      <!-- Top HUD -->
      <div style="position:absolute;top:0;left:0;right:0;z-index:10;padding:8px 12px;background:linear-gradient(to bottom,rgba(3,11,26,0.92),transparent);">
        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
          <!-- Score -->
          <div style="background:rgba(0,0,0,0.5);border:1px solid rgba(245,200,66,0.3);border-radius:8px;padding:5px 10px;display:flex;align-items:center;gap:6px;">
            <span style="font-size:11px;color:rgba(255,255,255,0.45);">分數</span>
            <span id="score-display" style="font-size:14px;font-weight:800;color:#F5C842;">0</span>
          </div>
          <!-- Coins -->
          <div style="background:rgba(0,0,0,0.5);border:1px solid rgba(245,200,66,0.3);border-radius:8px;padding:5px 10px;display:flex;align-items:center;gap:6px;">
            <span style="font-size:12px;">🪙</span>
            <span id="coin-display" style="font-size:14px;font-weight:800;color:#F5C842;">0</span>
          </div>
          <!-- Rank -->
          <div style="background:rgba(0,0,0,0.5);border:1px solid rgba(255,255,255,0.15);border-radius:8px;padding:5px 10px;display:flex;align-items:center;gap:6px;">
            <span style="font-size:11px;color:rgba(255,255,255,0.45);">排名</span>
            <span id="rank-display" style="font-size:14px;font-weight:800;color:#00F5D4;">#2</span>
          </div>

          <!-- Jackpot progress -->
          <div style="flex:1;min-width:80px;">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:3px;">
              <span style="font-size:10px;color:rgba(255,255,255,0.4);">JACKPOT</span>
              <span style="font-size:10px;color:#F5C842;font-weight:700;">72%</span>
            </div>
            <div class="jackpot-progress" style="height:6px;">
              <div class="jackpot-fill" style="width:72%;"></div>
            </div>
          </div>

          <!-- Settle button -->
          <button class="btn-secondary" style="padding:5px 12px;font-size:12px;" onclick="router.navigate('settlement-scene')">
            結算
          </button>
        </div>
      </div>

      <!-- Boss HP Bar -->
      <div id="boss-section" style="position:absolute;top:58px;left:0;right:0;z-index:10;padding:0 12px;">
        <div style="display:flex;align-items:center;gap:8px;">
          <span style="font-size:14px;">🦑</span>
          <span style="font-size:11px;color:rgba(255,68,68,0.9);font-weight:600;white-space:nowrap;">深海海神</span>
          <div class="boss-hp-container" style="flex:1;">
            <div class="boss-hp-bar" id="boss-hp-bar" style="width:${Math.round(session.bossHp/session.bossMaxHp*100)}%;"></div>
          </div>
          <span id="boss-hp-text" style="font-size:11px;color:rgba(255,255,255,0.6);white-space:nowrap;">${session.bossHp}/${session.bossMaxHp}</span>
        </div>
      </div>

      <!-- Mini Leaderboard (right side) -->
      <div style="position:absolute;top:90px;right:8px;z-index:10;background:rgba(0,0,0,0.6);border:1px solid rgba(255,255,255,0.08);border-radius:10px;padding:8px;min-width:110px;">
        <p style="font-size:10px;color:rgba(255,255,255,0.4);margin-bottom:6px;letter-spacing:0.5px;">即時排名</p>
        ${session.players.map((p, i) => {
          const player = mockData.PLAYERS.find(pl => pl.id === p.playerId);
          const rankIcons = ['🥇','🥈','🥉','4'];
          return `<div style="display:flex;align-items:center;gap:5px;margin-bottom:4px;">
            <span style="font-size:11px;width:16px;text-align:center;">${rankIcons[i]}</span>
            <span style="font-size:11px;flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:${i===1?'#F5C842':'#fff'}">${player ? player.nickname.substring(0,4) : '...'}</span>
            <span style="font-size:11px;color:#F5C842;font-weight:700;">${p.score}</span>
          </div>`;
        }).join('')}
      </div>

      <!-- Bottom Skills -->
      <div style="position:absolute;bottom:0;left:0;right:0;z-index:10;padding:8px 12px 12px;background:linear-gradient(to top,rgba(3,11,26,0.95),transparent 100%);">
        <div style="display:flex;align-items:flex-end;justify-content:space-between;gap:10px;">

          <!-- Cannon info -->
          <div style="background:rgba(0,0,0,0.6);border:1px solid rgba(245,200,66,0.2);border-radius:10px;padding:8px 12px;text-align:center;">
            <div style="font-size:22px;">🔫</div>
            <div style="font-size:10px;color:rgba(255,255,255,0.4);margin-top:2px;">標準砲台</div>
            <div style="font-size:11px;color:#F5C842;font-weight:700;">Lv.3</div>
          </div>

          <!-- Skill buttons -->
          <div style="display:flex;gap:14px;justify-content:center;flex:1;padding-bottom:4px;">
            ${selectedSkills.concat(mockData.SKILLS.filter(s => !selectedSkills.find(ss=>ss.id===s.id))).slice(0,4).map((skill, i) => `
              <div style="display:flex;flex-direction:column;align-items:center;gap:16px;">
                <button class="skill-btn" id="skill-btn-${i}" onclick="useSkill(${i},'${skill.id}')">
                  ${skill.icon}
                  <div class="cooldown-overlay" style="--cd-progress:0%;"></div>
                </button>
                <span style="font-size:10px;color:rgba(255,255,255,0.5);white-space:nowrap;margin-top:-8px;">${skill.name}</span>
              </div>
            `).join('')}
          </div>

          <!-- Auto fire toggle -->
          <div style="background:rgba(0,0,0,0.6);border:1px solid rgba(255,255,255,0.1);border-radius:10px;padding:8px 10px;text-align:center;cursor:pointer;"
            id="auto-fire-btn" onclick="toggleAutoFire()">
            <div style="font-size:20px;">🤖</div>
            <div id="auto-fire-label" style="font-size:10px;color:rgba(255,255,255,0.4);margin-top:2px;">自動</div>
          </div>
        </div>
      </div>

      <!-- Jackpot Overlay (hidden initially) -->
      <div id="jackpot-overlay" style="display:none;position:absolute;inset:0;z-index:50;display:none;align-items:center;justify-content:center;flex-direction:column;background:rgba(0,0,0,0.7);">
        <div class="jackpot-text">JACKPOT!</div>
        <div style="font-size:24px;color:#F5C842;font-weight:700;margin-top:8px;">+28,650 金幣</div>
      </div>
    </div>
  `;

  // Init game canvas
  const canvas = document.getElementById('gameCanvas');
  if (canvas) {
    const game = new GameCanvas(canvas);
    game.init();
    game.loop();
    window._gameInstance = game;
  }

  // Track auto fire
  let autoFire = false;
  window.toggleAutoFire = function() {
    autoFire = !autoFire;
    const label = document.getElementById('auto-fire-label');
    const btn = document.getElementById('auto-fire-btn');
    if (label) label.textContent = autoFire ? 'ON' : '自動';
    if (btn) btn.style.borderColor = autoFire ? '#00F5D4' : 'rgba(255,255,255,0.1)';
    if (window.audioEngine) audioEngine.playSFX('button');
  };

  window.useSkill = function(index, skillId) {
    if (window.audioEngine) audioEngine.playSFX('shoot');
    const btn = document.getElementById('skill-btn-' + index);
    if (!btn || btn.classList.contains('on-cooldown')) return;

    const skill = mockData.SKILLS.find(s => s.id === skillId);
    if (!skill) return;

    btn.classList.add('on-cooldown');
    showToast(`使用技能：${skill.name}`, 'gold');

    const cd = skill.cooldown;
    let elapsed = 0;
    const interval = setInterval(() => {
      elapsed += 0.5;
      const pct = Math.round((elapsed / cd) * 100);
      const overlay = btn.querySelector('.cooldown-overlay');
      if (overlay) overlay.style.setProperty('--cd-progress', pct + '%');

      if (elapsed >= cd) {
        clearInterval(interval);
        btn.classList.remove('on-cooldown');
        if (overlay) overlay.style.setProperty('--cd-progress', '0%');
        showToast(`${skill.name} 冷卻完成`, 'info');
      }
    }, 500);

    if (window._gameTimers) window._gameTimers.push(interval);
  };

  // Trigger Jackpot animation after 5 seconds
  const jackpotTimer = setTimeout(() => {
    if (window.audioEngine) {
      audioEngine.stopBGM();
      audioEngine.playBGM('jackpot');
      audioEngine.playSFX('jackpot');
    }
    if (window.fxEngine) fxEngine.spawnJackpot();

    const overlay = document.getElementById('jackpot-overlay');
    if (overlay) {
      overlay.style.display = 'flex';
      setTimeout(() => {
        overlay.style.display = 'none';
        if (window.audioEngine) {
          audioEngine.stopBGM();
          audioEngine.playBGM('battle');
        }
      }, 3000);
    }

    showToast('JACKPOT！大獎爆發！', 'gold');
  }, 5000);

  if (window._gameTimers) window._gameTimers.push(jackpotTimer);
}

// ============================================================
// Game Canvas Engine
// ============================================================
class GameCanvas {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.fishes = [];
    this.bullets = [];
    this.score = 0;
    this.coins = 0;
    this.bossHp = mockData.GAME_SESSION.bossHp;
    this.bossMaxHp = mockData.GAME_SESSION.bossMaxHp;
    this.animId = null;
    this.frameCount = 0;
    this._boundShoot = this._handleClick.bind(this);
    this._boundTouch = this._handleTouch.bind(this);
  }

  init() {
    this._resize();
    window.addEventListener('resize', () => this._resize());
    this.canvas.addEventListener('click', this._boundShoot);
    this.canvas.addEventListener('touchend', this._boundTouch, { passive: true });

    const w = this.canvas.width;
    const h = this.canvas.height;

    // Spawn regular fish
    const types = mockData.FISH_TYPES.slice(0, 5);
    for (let i = 0; i < 8; i++) {
      const type = types[Math.floor(Math.random() * types.length)];
      const fromLeft = Math.random() > 0.5;
      this.fishes.push({
        id: i,
        x: fromLeft ? -50 : w + 50,
        y: 80 + Math.random() * (h - 200),
        vx: fromLeft ? 1.2 + Math.random() * 1.5 : -(1.2 + Math.random() * 1.5),
        vy: (Math.random() - 0.5) * 0.5,
        type: type,
        hp: type.hp,
        maxHp: type.hp,
        emoji: type.emoji,
        size: type.size === 'small' ? 18 : type.size === 'medium' ? 26 : type.size === 'large' ? 38 : 24,
        dead: false,
        wobble: Math.random() * Math.PI * 2
      });
    }

    // Boss fish
    this.boss = {
      x: w - 80,
      y: h * 0.4,
      vx: -0.4,
      vy: 0.3,
      emoji: '🦑',
      hp: this.bossHp,
      maxHp: this.bossMaxHp,
      size: 56,
      dead: false,
      wobble: 0
    };
  }

  _resize() {
    const rect = this.canvas.parentElement.getBoundingClientRect();
    this.canvas.width = rect.width || window.innerWidth;
    this.canvas.height = rect.height || window.innerHeight - 48;
  }

  _handleClick(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    this.shoot(x, y);
  }

  _handleTouch(e) {
    if (e.changedTouches.length > 0) {
      const rect = this.canvas.getBoundingClientRect();
      const t = e.changedTouches[0];
      this.shoot(t.clientX - rect.left, t.clientY - rect.top);
    }
  }

  shoot(x, y) {
    if (window.audioEngine) audioEngine.playSFX('shoot');

    // Find nearest fish target
    let target = null;
    let minDist = 999999;

    const checkFish = (fish) => {
      if (fish.dead) return;
      const dx = fish.x - x;
      const dy = fish.y - y;
      const d = Math.sqrt(dx * dx + dy * dy);
      if (d < minDist) { minDist = d; target = fish; }
    };

    this.fishes.forEach(checkFish);
    if (this.boss && !this.boss.dead) checkFish(this.boss);

    // Spawn bullet
    const bullet = {
      x: x,
      y: y,
      tx: target ? target.x : x,
      ty: target ? target.y : y - 100,
      target: target,
      speed: 12,
      life: 1.0,
      hit: false,
      color: '#F5C842'
    };
    this.bullets.push(bullet);
  }

  _fishDie(fish) {
    fish.dead = true;
    if (window.audioEngine) audioEngine.playSFX('coin');

    const rect = this.canvas.getBoundingClientRect();
    const absX = rect.left + fish.x;
    const absY = rect.top + fish.y;

    if (window.fxEngine) fxEngine.spawnCoins(absX, absY, fish === this.boss ? 30 : 10);

    const gained = fish.type ? fish.type.multiplier * 50 : 100;
    const coinsGained = fish.type ? fish.type.multiplier * 20 : 50;

    this.score += gained;
    this.coins += coinsGained;

    const scoreEl = document.getElementById('score-display');
    const coinEl = document.getElementById('coin-display');
    if (scoreEl) scoreEl.textContent = this.score.toLocaleString();
    if (coinEl) coinEl.textContent = this.coins.toLocaleString();

    // Boss death
    if (fish === this.boss) {
      if (window.audioEngine) audioEngine.playSFX('levelup');
      if (window.fxEngine) fxEngine.spawnBossKill(absX, absY);
      this.boss = null;
      showToast('Boss 擊殺！獲得 5000 金幣', 'gold');
    }

    // Respawn after 2s
    if (fish !== this.boss) {
      setTimeout(() => {
        const i = this.fishes.indexOf(fish);
        if (i !== -1) {
          const w = this.canvas.width;
          const h = this.canvas.height;
          const types = mockData.FISH_TYPES.slice(0, 5);
          const type = types[Math.floor(Math.random() * types.length)];
          const fromLeft = Math.random() > 0.5;
          this.fishes[i] = {
            id: fish.id,
            x: fromLeft ? -50 : w + 50,
            y: 80 + Math.random() * (h - 200),
            vx: fromLeft ? 1.2 + Math.random() * 1.5 : -(1.2 + Math.random() * 1.5),
            vy: (Math.random() - 0.5) * 0.5,
            type, hp: type.hp, maxHp: type.hp,
            emoji: type.emoji,
            size: type.size === 'small' ? 18 : type.size === 'medium' ? 26 : type.size === 'large' ? 38 : 24,
            dead: false,
            wobble: Math.random() * Math.PI * 2
          };
        }
      }, 2000 + Math.random() * 1000);
    }
  }

  update() {
    this.frameCount++;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Update fish
    this.fishes.forEach(fish => {
      if (fish.dead) return;
      fish.wobble += 0.06;
      fish.x += fish.vx;
      fish.y += Math.sin(fish.wobble) * 0.4 + fish.vy;

      if (fish.x < -80) { fish.x = w + 50; fish.vx = Math.abs(fish.vx); }
      if (fish.x > w + 80) { fish.x = -50; fish.vx = -Math.abs(fish.vx); }
      if (fish.y < 70) { fish.vy = Math.abs(fish.vy) + 0.1; }
      if (fish.y > h - 80) { fish.vy = -(Math.abs(fish.vy) + 0.1); }
    });

    // Update boss
    if (this.boss && !this.boss.dead) {
      this.boss.wobble += 0.03;
      this.boss.x += this.boss.vx;
      this.boss.y += Math.sin(this.boss.wobble * 0.7) * 0.8 + this.boss.vy;
      if (this.boss.x < w * 0.3) { this.boss.vx = Math.abs(this.boss.vx); }
      if (this.boss.x > w - 60) { this.boss.vx = -Math.abs(this.boss.vx); }
      if (this.boss.y < 80) { this.boss.vy = 0.5; }
      if (this.boss.y > h * 0.8) { this.boss.vy = -0.5; }
    }

    // Update bullets
    for (let i = this.bullets.length - 1; i >= 0; i--) {
      const b = this.bullets[i];

      if (b.target && !b.target.dead) {
        b.tx = b.target.x;
        b.ty = b.target.y;
      }

      const dx = b.tx - b.x;
      const dy = b.ty - b.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < 16 || b.hit) {
        // Hit!
        if (!b.hit && b.target && !b.target.dead) {
          b.hit = true;
          const weapon = mockData.WEAPONS.find(w => w.id === (mockData.CURRENT_USER.selectedWeapon || 'weapon001'));
          const dmg = weapon ? weapon.power : 10;
          b.target.hp -= dmg;

          if (window.audioEngine) audioEngine.playSFX('hit');
          const rect = this.canvas.getBoundingClientRect();
          if (window.fxEngine) fxEngine.spawnHit(rect.left + b.target.x, rect.top + b.target.y);

          // Update boss HP display
          if (b.target === this.boss) {
            this.bossHp = this.boss.hp;
            const bar = document.getElementById('boss-hp-bar');
            const txt = document.getElementById('boss-hp-text');
            if (bar) bar.style.width = Math.max(0, this.bossHp / this.bossMaxHp * 100) + '%';
            if (txt) txt.textContent = Math.max(0, this.bossHp) + '/' + this.bossMaxHp;
          }

          if (b.target.hp <= 0) this._fishDie(b.target);
        }
        this.bullets.splice(i, 1);
        continue;
      }

      const speed = b.speed;
      b.x += (dx / dist) * speed;
      b.y += (dy / dist) * speed;
      b.life -= 0.02;

      if (b.life <= 0) this.bullets.splice(i, 1);
    }
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Background
    const bg = ctx.createLinearGradient(0, 0, 0, h);
    bg.addColorStop(0, '#051428');
    bg.addColorStop(0.5, '#062040');
    bg.addColorStop(1, '#030B1A');
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, w, h);

    // Underwater light rays
    ctx.save();
    ctx.globalAlpha = 0.03 + Math.sin(this.frameCount * 0.02) * 0.02;
    for (let i = 0; i < 5; i++) {
      const x = w * (i / 4);
      const grad = ctx.createLinearGradient(x, 0, x + 40, h);
      grad.addColorStop(0, 'rgba(100,200,255,0.8)');
      grad.addColorStop(1, 'transparent');
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.moveTo(x - 20, 0);
      ctx.lineTo(x + 20, 0);
      ctx.lineTo(x + 60, h);
      ctx.lineTo(x - 40, h);
      ctx.closePath();
      ctx.fill();
    }
    ctx.restore();

    // Coral decorations at bottom
    ctx.save();
    ctx.globalAlpha = 0.4;
    const corals = ['🪸', '🌊', '🐚'];
    for (let i = 0; i < 6; i++) {
      ctx.font = `${20 + (i % 3) * 8}px serif`;
      ctx.fillText(corals[i % corals.length], w * (i / 5) - 10, h - 10);
    }
    ctx.restore();

    // Draw bubbles
    if (this.frameCount % 60 === 0) {
      if (!this._bubbles) this._bubbles = [];
      this._bubbles.push({ x: Math.random() * w, y: h, r: 2 + Math.random() * 6, vy: 0.8 + Math.random() * 1.2, life: 1.0 });
    }
    if (this._bubbles) {
      ctx.save();
      for (let i = this._bubbles.length - 1; i >= 0; i--) {
        const b = this._bubbles[i];
        b.y -= b.vy;
        b.life -= 0.003;
        if (b.life <= 0 || b.y < 0) { this._bubbles.splice(i, 1); continue; }
        ctx.globalAlpha = b.life * 0.4;
        ctx.strokeStyle = 'rgba(100,200,255,0.7)';
        ctx.lineWidth = 0.8;
        ctx.beginPath();
        ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
        ctx.stroke();
      }
      ctx.restore();
    }

    // Draw fish
    ctx.save();
    this.fishes.forEach(fish => {
      if (fish.dead) return;

      ctx.save();
      ctx.translate(fish.x, fish.y);
      if (fish.vx < 0) ctx.scale(-1, 1);
      ctx.font = `${fish.size * 2}px serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(fish.emoji, 0, 0);
      ctx.restore();

      // HP bar (only if damaged)
      if (fish.hp < fish.maxHp) {
        const bw = fish.size * 1.8;
        ctx.fillStyle = 'rgba(0,0,0,0.5)';
        ctx.fillRect(fish.x - bw/2, fish.y - fish.size - 8, bw, 4);
        const hpPct = fish.hp / fish.maxHp;
        ctx.fillStyle = hpPct > 0.5 ? '#00FF88' : hpPct > 0.25 ? '#FF8800' : '#FF4444';
        ctx.fillRect(fish.x - bw/2, fish.y - fish.size - 8, bw * hpPct, 4);
      }
    });
    ctx.restore();

    // Draw boss
    if (this.boss && !this.boss.dead) {
      ctx.save();
      ctx.translate(this.boss.x, this.boss.y);
      ctx.font = `${this.boss.size * 2}px serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';

      // Boss glow
      ctx.shadowColor = '#FF4444';
      ctx.shadowBlur = 20 + Math.sin(this.frameCount * 0.1) * 8;
      ctx.fillText(this.boss.emoji, 0, 0);
      ctx.restore();
    }

    // Draw bullets
    this.bullets.forEach(b => {
      ctx.save();
      const grd = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, 6);
      grd.addColorStop(0, '#FFFFFF');
      grd.addColorStop(0.4, '#F5C842');
      grd.addColorStop(1, 'transparent');
      ctx.fillStyle = grd;
      ctx.shadowColor = '#F5C842';
      ctx.shadowBlur = 10;
      ctx.beginPath();
      ctx.arc(b.x, b.y, 5, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    });
  }

  loop() {
    this.update();
    this.draw();
    this.animId = requestAnimationFrame(() => {
      if (document.getElementById('gameCanvas') === this.canvas) {
        this.loop();
      }
    });
  }

  destroy() {
    if (this.animId) cancelAnimationFrame(this.animId);
    this.canvas.removeEventListener('click', this._boundShoot);
    this.canvas.removeEventListener('touchend', this._boundTouch);
  }
}

// ============================================================
// Screen 7: Settlement Scene
// ============================================================
function renderSettlementScene() {
  const content = document.getElementById('proto-content');
  const session = mockData.GAME_SESSION;
  const players = session.players.map(p => ({
    ...p,
    player: mockData.PLAYERS.find(pl => pl.id === p.playerId)
  })).sort((a, b) => a.rank - b.rank);

  if (window.audioEngine) {
    audioEngine.stopBGM();
    audioEngine.playBGM('jackpot');
  }

  if (window.fxEngine) fxEngine.spawnJackpot();

  content.innerHTML = `
    <div class="screen" style="display:flex;align-items:center;justify-content:center;min-height:100vh;padding:16px;background:rgba(0,0,0,0.5);">
      <div class="modal-content" style="max-width:420px;width:100%;text-align:center;padding:28px 24px;">

        <div style="font-size:36px;margin-bottom:8px;">🏆</div>
        <h1 style="font-size:22px;font-weight:900;margin-bottom:4px;" class="text-gold">本局結算</h1>
        <p style="font-size:13px;color:rgba(255,255,255,0.45);margin-bottom:24px;">深海峽谷 · 第3局</p>

        <!-- Top 3 Rankings -->
        <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:20px;">
          ${players.slice(0, 3).map((p, i) => {
            const medals = ['🥇', '🥈', '🥉'];
            const isMe = p.playerId === 'usr001';
            return `<div class="rank-reveal" style="display:flex;align-items:center;gap:12px;background:${isMe ? 'rgba(245,200,66,0.08)' : 'rgba(255,255,255,0.03)'};border:1px solid ${isMe ? 'rgba(245,200,66,0.3)' : 'rgba(255,255,255,0.07)'};border-radius:12px;padding:12px 14px;">
              <span style="font-size:24px;flex-shrink:0;">${medals[i]}</span>
              <div class="player-avatar" style="width:36px;height:36px;font-size:14px;flex-shrink:0;">${p.player ? p.player.avatarInitial : '?'}</div>
              <div style="flex:1;text-align:left;">
                <p style="font-size:14px;font-weight:700;${isMe ? 'color:#F5C842' : ''}">${p.player ? p.player.nickname : '未知玩家'} ${isMe ? '（你）' : ''}</p>
                <p style="font-size:12px;color:rgba(255,255,255,0.4);">得分 ${p.score.toLocaleString()}</p>
              </div>
              <div style="text-align:right;">
                <p style="font-size:14px;font-weight:700;color:#F5C842;">+${p.coinsEarned}</p>
                <p style="font-size:11px;color:rgba(255,255,255,0.4);">金幣</p>
              </div>
            </div>`;
          }).join('')}
        </div>

        <!-- My Result -->
        <div style="background:rgba(245,200,66,0.06);border:1px solid rgba(245,200,66,0.2);border-radius:12px;padding:16px;margin-bottom:20px;">
          <p style="font-size:13px;color:rgba(255,255,255,0.5);margin-bottom:6px;">你的成績</p>
          <p style="font-size:20px;font-weight:800;">第 2 名 🥈</p>
          <div style="display:flex;align-items:center;justify-content:center;gap:8px;margin-top:8px;">
            <span style="font-size:24px;">🪙</span>
            <span id="coin-counter" style="font-size:32px;font-weight:900;" class="text-gold">0</span>
            <span style="font-size:18px;color:rgba(255,255,255,0.5);">金幣</span>
          </div>
        </div>

        <!-- Action Buttons -->
        <div style="display:flex;flex-direction:column;gap:10px;">
          <button class="btn-primary" style="width:100%;font-size:15px;padding:14px;" onclick="router.navigate('lobby-scene')">
            再玩一局 →
          </button>
          <button class="btn-secondary" style="width:100%;font-size:14px;" onclick="shareResult()">
            分享戰績
          </button>
        </div>

      </div>
    </div>
  `;

  // Animate coin counter
  let count = 0;
  const target = 450;
  const duration = 1500;
  const step = target / (duration / 50);
  const counter = setInterval(() => {
    count = Math.min(count + step, target);
    const el = document.getElementById('coin-counter');
    if (el) el.textContent = Math.floor(count).toLocaleString();
    if (count >= target) clearInterval(counter);
  }, 50);

  if (window._gameTimers) window._gameTimers.push(counter);

  window.shareResult = function() {
    if (window.audioEngine) audioEngine.playSFX('button');
    showToast('戰績已複製到剪貼板！', 'success');
  };
}

// ============================================================
// Screen 8: Shop Modal (overlay on lobby)
// ============================================================
function renderShopModal() {
  const existing = document.getElementById('shop-modal-overlay');
  if (existing) existing.remove();

  const overlay = document.createElement('div');
  overlay.id = 'shop-modal-overlay';
  overlay.className = 'modal-overlay';
  overlay.style.cssText = 'position:fixed;inset:0;z-index:2000;';
  overlay.onclick = e => { if (e.target === overlay) overlay.remove(); };

  const products = mockData.PRODUCTS;
  let activeTab = 'diamond';

  overlay.innerHTML = `
    <div class="modal-content" style="max-width:440px;width:100%;max-height:88vh;overflow-y:auto;">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;">
        <h2 style="font-size:18px;font-weight:800;" class="text-gold">🛒 商城</h2>
        <button onclick="document.getElementById('shop-modal-overlay').remove()"
          style="background:none;border:none;color:rgba(255,255,255,0.5);cursor:pointer;font-size:20px;padding:4px;">✕</button>
      </div>

      <!-- Tabs -->
      <div style="display:flex;gap:8px;margin-bottom:20px;background:rgba(255,255,255,0.05);border-radius:10px;padding:4px;">
        <button id="tab-diamond" onclick="switchShopTab('diamond')"
          style="flex:1;padding:8px;border:none;border-radius:8px;cursor:pointer;font-family:inherit;font-size:13px;font-weight:700;transition:all 0.2s;background:linear-gradient(135deg,#F5C842,#E0A800);color:#1A1000;">
          💎 充值
        </button>
        <button id="tab-vip" onclick="switchShopTab('vip')"
          style="flex:1;padding:8px;border:none;border-radius:8px;cursor:pointer;font-family:inherit;font-size:13px;font-weight:700;transition:all 0.2s;background:transparent;color:rgba(255,255,255,0.5);">
          👑 禮包
        </button>
      </div>

      <div id="shop-content"></div>
    </div>
  `;

  document.body.appendChild(overlay);

  window.switchShopTab = function(tab) {
    activeTab = tab;
    const dBtn = document.getElementById('tab-diamond');
    const vBtn = document.getElementById('tab-vip');
    if (dBtn && vBtn) {
      if (tab === 'diamond') {
        dBtn.style.cssText += 'background:linear-gradient(135deg,#F5C842,#E0A800);color:#1A1000;';
        vBtn.style.background = 'transparent';
        vBtn.style.color = 'rgba(255,255,255,0.5)';
      } else {
        vBtn.style.cssText += 'background:linear-gradient(135deg,#F5C842,#E0A800);color:#1A1000;';
        dBtn.style.background = 'transparent';
        dBtn.style.color = 'rgba(255,255,255,0.5)';
      }
    }
    renderShopContent(tab);
    if (window.audioEngine) audioEngine.playSFX('button');
  };

  window.buyProduct = function(productId) {
    const p = products.find(pr => pr.id === productId);
    if (!p) return;
    if (window.audioEngine) audioEngine.playSFX('coin');
    showToast(`購買成功！${p.name} 已加入帳戶`, 'gold');
  };

  function renderShopContent(tab) {
    const shopContent = document.getElementById('shop-content');
    if (!shopContent) return;

    const items = products.filter(p => p.type === tab);

    if (tab === 'diamond') {
      shopContent.innerHTML = `
        <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:10px;">
          ${items.map(p => `
            <div style="background:rgba(255,255,255,0.04);border:1px solid rgba(245,200,66,0.15);border-radius:12px;padding:14px;text-align:center;transition:all 0.2s;cursor:pointer;position:relative;"
              onmouseover="this.style.borderColor='rgba(245,200,66,0.4)'"
              onmouseout="this.style.borderColor='rgba(245,200,66,0.15)'">
              ${p.tag ? `<div style="position:absolute;top:-1px;right:8px;background:linear-gradient(135deg,#FF6B35,#FF4444);color:#fff;font-size:10px;font-weight:700;padding:2px 8px;border-radius:0 0 6px 6px;">${p.tag}</div>` : ''}
              <div style="font-size:28px;margin-bottom:8px;">${p.icon}</div>
              <p style="font-size:15px;font-weight:800;color:#F5C842;margin-bottom:2px;">${p.diamonds} 鑽石</p>
              ${p.bonus ? `<p style="font-size:11px;color:#00F5D4;margin-bottom:8px;">+${p.bonus} 贈送</p>` : '<p style="margin-bottom:8px;height:16px;"></p>'}
              <button class="btn-primary" style="width:100%;padding:8px;font-size:13px;" onclick="buyProduct('${p.id}')">
                $${p.price}
              </button>
            </div>
          `).join('')}
        </div>
      `;
    } else {
      shopContent.innerHTML = `
        <div style="display:flex;flex-direction:column;gap:12px;">
          ${items.map(p => `
            <div style="background:rgba(255,255,255,0.04);border:1px solid rgba(245,200,66,0.15);border-radius:14px;padding:16px;display:flex;align-items:center;gap:14px;transition:all 0.2s;position:relative;"
              onmouseover="this.style.borderColor='rgba(245,200,66,0.4)'"
              onmouseout="this.style.borderColor='rgba(245,200,66,0.15)'">
              ${p.tag ? `<div style="position:absolute;top:8px;right:8px;background:linear-gradient(135deg,#F5C842,#E0A800);color:#1A1000;font-size:10px;font-weight:700;padding:2px 8px;border-radius:var(--radius-full);">${p.tag}</div>` : ''}
              <div style="font-size:36px;flex-shrink:0;">${p.icon}</div>
              <div style="flex:1;min-width:0;">
                <p style="font-size:15px;font-weight:800;margin-bottom:4px;">${p.name}</p>
                <p style="font-size:12px;color:rgba(255,255,255,0.5);line-height:1.4;">${p.description || ''}</p>
                ${p.duration ? `<p style="font-size:11px;color:#00F5D4;margin-top:4px;">${p.duration} 天有效</p>` : ''}
              </div>
              <button class="btn-primary" style="padding:8px 16px;font-size:13px;flex-shrink:0;" onclick="buyProduct('${p.id}')">
                $${p.price}
              </button>
            </div>
          `).join('')}
        </div>
      `;
    }
  }

  renderShopContent('diamond');
}

// ============================================================
// Leaderboard Modal
// ============================================================
function renderLeaderboardModal() {
  const existing = document.getElementById('lb-modal');
  if (existing) existing.remove();

  const overlay = document.createElement('div');
  overlay.id = 'lb-modal';
  overlay.className = 'modal-overlay';
  overlay.onclick = e => { if (e.target === overlay) overlay.remove(); };

  const lb = mockData.LEADERBOARD;
  const medalIcons = ['🥇','🥈','🥉'];

  overlay.innerHTML = `
    <div class="modal-content" style="max-width:400px;width:100%;max-height:88vh;overflow-y:auto;">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;">
        <h2 style="font-size:18px;font-weight:800;" class="text-gold">🏆 總排行榜</h2>
        <button onclick="document.getElementById('lb-modal').remove()"
          style="background:none;border:none;color:rgba(255,255,255,0.5);cursor:pointer;font-size:20px;padding:4px;">✕</button>
      </div>
      <div style="display:flex;flex-direction:column;gap:6px;">
        ${lb.map((entry, i) => `
          <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:10px;">
            <span style="font-size:${i < 3 ? '20' : '14'}px;min-width:24px;text-align:center;${i >= 3 ? 'color:rgba(255,255,255,0.4)' : ''}">${i < 3 ? medalIcons[i] : entry.rank}</span>
            <div class="player-avatar" style="width:32px;height:32px;font-size:13px;flex-shrink:0;">${entry.avatarInitial}</div>
            <div style="flex:1;">
              <p style="font-size:13px;font-weight:600;">${entry.nickname}</p>
              <span class="vip-badge vip-${entry.vipLevel}" style="font-size:10px;">VIP${entry.vipLevel}</span>
            </div>
            <span style="font-size:14px;font-weight:800;color:#F5C842;">${entry.score.toLocaleString()}</span>
          </div>
        `).join('')}
      </div>
    </div>
  `;

  document.body.appendChild(overlay);
}

// ============================================================
// Screen Registration
// ============================================================
router.register('loading-scene',       renderLoadingScene);
router.register('login-scene',         renderLoginScene);
router.register('lobby-scene',         renderLobbyScene);
router.register('cannon-select-scene', renderCannonSelectScene);
router.register('matchmaking-scene',   renderMatchmakingScene);
router.register('game-scene',          renderGameScene);
router.register('settlement-scene',    renderSettlementScene);
router.register('shop-scene',          () => {
  router.navigate('lobby-scene');
  setTimeout(() => renderShopModal(), 300);
});

// ============================================================
// Init
// ============================================================
(function init() {
  // Expose globals needed by inline onclick handlers
  window.router = router;
  window.showToast = showToast;
  window.showFlowMap = showFlowMap;

  // Read URL hash
  const hash = window.location.hash.replace('#', '');
  const validScreens = [
    'loading-scene','login-scene','lobby-scene',
    'cannon-select-scene','matchmaking-scene','game-scene',
    'settlement-scene','shop-scene'
  ];

  if (hash && validScreens.includes(hash)) {
    router.navigate(hash);
  } else {
    router.navigate('loading-scene');
  }

  // hashchange support for browser back/forward
  window.addEventListener('hashchange', () => {
    const h = window.location.hash.replace('#', '');
    if (h && validScreens.includes(h) && h !== router.current) {
      router.navigate(h);
    }
  });
})();
