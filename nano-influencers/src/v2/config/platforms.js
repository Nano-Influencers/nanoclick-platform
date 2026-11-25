export const PLATFORM_CONFIG = Object.freeze({
  facebook: {
    id: "facebook",
    label: "Facebook",
    actions: ["like", "follow", "comment", "share"],
  },
  youtube: {
    id: "youtube",
    label: "YouTube",
    actions: ["like", "comment", "share", "subscribe"],
  },
  twitter: {
    id: "twitter",
    label: "X",
    actions: ["like", "follow", "comment", "repost", "trend"],
  },
  whatsapp: {
    id: "whatsapp",
    label: "WhatsApp",
    actions: ["join", "share"],
  },
  instagram: {
    id: "instagram",
    label: "Instagram",
    actions: ["like", "follow", "comment", "share"],
  },
  telegram: {
    id: "telegram",
    label: "Telegram",
    actions: ["join", "share"],
  },
  tiktok: {
    id: "tiktok",
    label: "TikTok",
    actions: ["like", "follow", "comment", "share"],
  },
  linkedin: {
    id: "linkedin",
    label: "LinkedIn",
    actions: ["like", "follow", "comment", "share"],
  },
  audiomack: {
    id: "audiomack",
    label: "Audiomack",
    actions: ["follow", "stream", "share"],
  },
  spotify: {
    id: "spotify",
    label: "Spotify",
    actions: ["follow", "stream", "share"],
  },
  boomplay: {
    id: "boomplay",
    label: "Boomplay",
    actions: ["follow", "stream", "share"],
  },
  youtube_music: {
    id: "youtube_music",
    label: "YouTube Music",
    actions: ["follow", "stream", "share"],
  },
});

export const PLATFORMS = Object.freeze(Object.values(PLATFORM_CONFIG));

export function getPlatformConfig(platformId) {
  return PLATFORM_CONFIG[platformId] || null;
}
