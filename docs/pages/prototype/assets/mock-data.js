// FishGame 競技捕魚 — Mock Data
// All game data for prototype simulation

const mockData = {

  PLAYERS: [
    {
      id: 'usr001',
      name: '炮手王',
      nickname: '炮手王',
      level: 38,
      vipLevel: 3,
      score: 14820,
      coinBalance: 58300,
      diamondBalance: 420,
      avatarInitial: '王',
      isVIP: true,
      winRate: 0.68,
      totalGames: 412
    },
    {
      id: 'usr002',
      name: '海底霸主',
      nickname: '海底霸主',
      level: 92,
      vipLevel: 5,
      score: 89500,
      coinBalance: 520000,
      diamondBalance: 8800,
      avatarInitial: '霸',
      isVIP: true,
      winRate: 0.82,
      totalGames: 3241
    },
    {
      id: 'usr003',
      name: '新手小花',
      nickname: '新手小花',
      level: 2,
      vipLevel: 0,
      score: 320,
      coinBalance: 5000,
      diamondBalance: 0,
      avatarInitial: '花',
      isVIP: false,
      winRate: 0.32,
      totalGames: 11
    },
    {
      id: 'usr004',
      name: '魚王傳說',
      nickname: '魚王傳說',
      level: 65,
      vipLevel: 4,
      score: 42100,
      coinBalance: 198000,
      diamondBalance: 2100,
      avatarInitial: '傳',
      isVIP: true,
      winRate: 0.74,
      totalGames: 1520
    },
    {
      id: 'usr005',
      name: '快樂漁夫',
      nickname: '快樂漁夫',
      level: 21,
      vipLevel: 1,
      score: 5600,
      coinBalance: 22000,
      diamondBalance: 150,
      avatarInitial: '漁',
      isVIP: true,
      winRate: 0.51,
      totalGames: 280
    },
    {
      id: 'usr006',
      name: '深海獵人',
      nickname: '深海獵人',
      level: 47,
      vipLevel: 3,
      score: 28900,
      coinBalance: 87000,
      diamondBalance: 660,
      avatarInitial: '獵',
      isVIP: true,
      winRate: 0.70,
      totalGames: 820
    },
    {
      id: 'usr007',
      name: '金幣收集者',
      nickname: '金幣收集者',
      level: 14,
      vipLevel: 2,
      score: 3200,
      coinBalance: 41000,
      diamondBalance: 300,
      avatarInitial: '金',
      isVIP: true,
      winRate: 0.45,
      totalGames: 165
    },
    {
      id: 'usr008',
      name: '砲轟大師',
      nickname: '砲轟大師',
      level: 73,
      vipLevel: 4,
      score: 56700,
      coinBalance: 310000,
      diamondBalance: 4200,
      avatarInitial: '砲',
      isVIP: true,
      winRate: 0.78,
      totalGames: 2100
    }
  ],

  ROOMS: [
    {
      id: 'room001',
      name: '新手灣',
      description: '適合初學者練習',
      minBet: 100,
      maxBet: 500,
      online: 4,
      capacity: 6,
      status: 'waiting',
      theme: 'shallow',
      icon: '🌊',
      bgColor: 'rgba(0,80,160,0.4)'
    },
    {
      id: 'room002',
      name: '珊瑚礁',
      description: '中級玩家激戰',
      minBet: 500,
      maxBet: 2000,
      online: 6,
      capacity: 6,
      status: 'full',
      theme: 'coral',
      icon: '🪸',
      bgColor: 'rgba(180,60,20,0.3)'
    },
    {
      id: 'room003',
      name: '深海峽谷',
      description: '高手對決場',
      minBet: 2000,
      maxBet: 10000,
      online: 3,
      capacity: 6,
      status: 'playing',
      theme: 'abyss',
      icon: '🌑',
      bgColor: 'rgba(0,20,80,0.5)'
    },
    {
      id: 'room004',
      name: 'VIP 專屬廳',
      description: 'VIP3+ 限定，高額獎池',
      minBet: 10000,
      maxBet: 50000,
      online: 2,
      capacity: 4,
      status: 'waiting',
      theme: 'vip',
      icon: '👑',
      bgColor: 'rgba(180,140,0,0.2)',
      vipRequired: 3
    }
  ],

  FISH_TYPES: [
    {
      id: 'fish001',
      name: '小丑魚',
      multiplier: 2,
      hp: 1,
      emoji: '🐠',
      color: '#FF6B35',
      size: 'small',
      speed: 2.5
    },
    {
      id: 'fish002',
      name: '河豚',
      multiplier: 5,
      hp: 3,
      emoji: '🐡',
      color: '#F5C842',
      size: 'medium',
      speed: 1.5
    },
    {
      id: 'fish003',
      name: '鯊魚',
      multiplier: 15,
      hp: 8,
      emoji: '🦈',
      color: '#6B7D8E',
      size: 'large',
      speed: 3.0
    },
    {
      id: 'fish004',
      name: '龍蝦',
      multiplier: 20,
      hp: 10,
      emoji: '🦞',
      color: '#FF4444',
      size: 'medium',
      speed: 1.0
    },
    {
      id: 'fish005',
      name: '章魚',
      multiplier: 30,
      hp: 15,
      emoji: '🐙',
      color: '#9B59B6',
      size: 'large',
      speed: 1.2
    },
    {
      id: 'fish006',
      name: '大鯨魚',
      multiplier: 80,
      hp: 40,
      emoji: '🐋',
      color: '#2E86AB',
      size: 'xlarge',
      speed: 0.5
    }
  ],

  WEAPONS: [
    {
      id: 'weapon001',
      name: '標準砲台',
      cost: 100,
      power: 10,
      fireRate: 1.0,
      special: '普通射速，適合連射',
      icon: '🔫',
      level: 1,
      bulletColor: '#F5C842',
      unlockLevel: 1
    },
    {
      id: 'weapon002',
      name: '狙擊砲台',
      cost: 300,
      power: 35,
      fireRate: 0.4,
      special: '高傷害單發，精準狙擊',
      icon: '🎯',
      level: 2,
      bulletColor: '#00F5D4',
      unlockLevel: 10
    },
    {
      id: 'weapon003',
      name: '電磁砲台',
      cost: 800,
      power: 25,
      fireRate: 1.5,
      special: '電磁爆炸，範圍命中',
      icon: '⚡',
      level: 3,
      bulletColor: '#FF00AA',
      unlockLevel: 25,
      isSpecial: true
    }
  ],

  SKILLS: [
    {
      id: 'skill001',
      name: '魚雷攻擊',
      cooldown: 15,
      description: '發射魚雷，穿透命中範圍內所有魚',
      icon: '🚀',
      damage: 50,
      radius: 100
    },
    {
      id: 'skill002',
      name: '金網捕獲',
      cooldown: 20,
      description: '展開金網，使範圍內小魚立即死亡',
      icon: '🕸️',
      damage: 0,
      radius: 150
    },
    {
      id: 'skill003',
      name: '時間凍結',
      cooldown: 30,
      description: '凍結所有魚 5 秒，方便瞄準',
      icon: '❄️',
      damage: 0,
      duration: 5
    },
    {
      id: 'skill004',
      name: '黃金子彈',
      cooldown: 25,
      description: '10 秒內子彈傷害 × 3，金幣獲取 × 2',
      icon: '✨',
      damage: 3,
      duration: 10
    }
  ],

  PRODUCTS: [
    {
      id: 'prod001',
      name: '60 鑽石',
      diamonds: 60,
      price: 0.99,
      currency: 'USD',
      tag: null,
      icon: '💎',
      type: 'diamond'
    },
    {
      id: 'prod002',
      name: '300 鑽石',
      diamonds: 300,
      bonus: 30,
      price: 4.99,
      currency: 'USD',
      tag: '熱銷',
      icon: '💎💎',
      type: 'diamond'
    },
    {
      id: 'prod003',
      name: '600 鑽石',
      diamonds: 600,
      bonus: 80,
      price: 9.99,
      currency: 'USD',
      tag: '推薦',
      icon: '💎💎💎',
      type: 'diamond'
    },
    {
      id: 'prod004',
      name: '1500 鑽石',
      diamonds: 1500,
      bonus: 300,
      price: 24.99,
      currency: 'USD',
      tag: '超值',
      icon: '👑',
      type: 'diamond'
    },
    {
      id: 'prod005',
      name: 'VIP 週卡',
      description: '享受 7 天 VIP2 特權',
      price: 2.99,
      currency: 'USD',
      tag: '限時',
      icon: '🌟',
      type: 'vip',
      vipLevel: 2,
      duration: 7
    },
    {
      id: 'prod006',
      name: 'VIP 月卡',
      description: '享受 30 天 VIP3 特權，包含專屬頭像框',
      price: 9.99,
      currency: 'USD',
      tag: '最受歡迎',
      icon: '👑',
      type: 'vip',
      vipLevel: 3,
      duration: 30
    }
  ],

  LEADERBOARD: [
    { rank: 1,  playerId: 'usr002', nickname: '海底霸主', score: 89500, vipLevel: 5, avatarInitial: '霸' },
    { rank: 2,  playerId: 'usr008', nickname: '砲轟大師', score: 56700, vipLevel: 4, avatarInitial: '砲' },
    { rank: 3,  playerId: 'usr004', nickname: '魚王傳說', score: 42100, vipLevel: 4, avatarInitial: '傳' },
    { rank: 4,  playerId: 'usr006', nickname: '深海獵人', score: 28900, vipLevel: 3, avatarInitial: '獵' },
    { rank: 5,  playerId: 'usr001', nickname: '炮手王',   score: 14820, vipLevel: 3, avatarInitial: '王' },
    { rank: 6,  playerId: 'usr005', nickname: '快樂漁夫', score: 5600,  vipLevel: 1, avatarInitial: '漁' },
    { rank: 7,  playerId: 'usr007', nickname: '金幣收集者', score: 3200, vipLevel: 2, avatarInitial: '金' },
    { rank: 8,  playerId: 'usr003', nickname: '新手小花', score: 320,   vipLevel: 0, avatarInitial: '花' },
    { rank: 9,  playerId: 'usr009', nickname: '海浪騎手', score: 210,   vipLevel: 0, avatarInitial: '浪' },
    { rank: 10, playerId: 'usr010', nickname: '泡泡魚',   score: 150,   vipLevel: 0, avatarInitial: '泡' }
  ],

  GAME_SESSION: {
    sessionId: 'sess_20240425_001',
    roomId: 'room003',
    startTime: Date.now() - 120000,
    status: 'playing',
    activePlayerCount: 4,
    jackpotPool: 28650,
    jackpotMax: 40000,
    bossHp: 580,
    bossMaxHp: 1200,
    bossName: '深海海神',
    bossEmoji: '🦑',
    currentRound: 3,
    totalRounds: 5,
    players: [
      { playerId: 'usr001', rank: 2, score: 1240, coinsEarned: 380 },
      { playerId: 'usr002', rank: 1, score: 2100, coinsEarned: 650 },
      { playerId: 'usr004', rank: 3, score: 980,  coinsEarned: 290 },
      { playerId: 'usr005', rank: 4, score: 420,  coinsEarned: 120 }
    ]
  },

  CURRENT_USER: {
    id: 'usr001',
    name: '炮手王',
    nickname: '炮手王',
    level: 38,
    vipLevel: 3,
    score: 14820,
    coinBalance: 58300,
    diamondBalance: 420,
    avatarInitial: '王',
    isVIP: true,
    selectedWeapon: 'weapon001',
    selectedSkills: ['skill001', 'skill004']
  }

};

export default mockData;
