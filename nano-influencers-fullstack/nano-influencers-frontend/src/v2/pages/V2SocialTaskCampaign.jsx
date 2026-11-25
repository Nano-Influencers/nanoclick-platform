import React, { useMemo, useRef, useState } from "react";
const ASSET_BASE = "/assets/nano-v2-app/";
import "./v2-social-task-campaign.css";

const commonIcons = {
  arrowLeft: `${ASSET_BASE}custom-task-arrow-left.svg`,
};

const facebookIcons = {
  like: `${ASSET_BASE}task-social-like.svg`,
  followers: `${ASSET_BASE}task-social-profile-2user.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  live: `${ASSET_BASE}task-social-radar.svg`,
  friend: `${ASSET_BASE}task-chat-profile-add.svg`,
  story: `${ASSET_BASE}task-social-book.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  external: `${ASSET_BASE}task-social-export.svg`,
  group: `${ASSET_BASE}task-chat-people.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
};

const youtubeIcons = {
  like: `${ASSET_BASE}task-social-like.svg`,
  subscribe: `${ASSET_BASE}task-social-notification.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  dislike: `${ASSET_BASE}task-social-dislike.svg`,
  save: `${ASSET_BASE}task-chat-archive-tick.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  live: `${ASSET_BASE}task-social-radar.svg`,
  external: `${ASSET_BASE}task-social-export.svg`,
  music: `${ASSET_BASE}task-social-music-filter.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
  collab: `${ASSET_BASE}task-social-profile-2user.svg`,
  scissor: `${ASSET_BASE}task-social-scissor.svg`,
  background: `${ASSET_BASE}task-social-video-vertical.svg`,
  community: `${ASSET_BASE}task-chat-heart-add.svg`,
};

const xIcons = {
  like: `${ASSET_BASE}task-social-like.svg`,
  followers: `${ASSET_BASE}task-social-profile-2user.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  repost: `${ASSET_BASE}task-social-refresh-2.svg`,
  quote: `${ASSET_BASE}task-social-mouse-square.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  space: `${ASSET_BASE}task-social-microphone-2.svg`,
  external: `${ASSET_BASE}task-social-export.svg`,
  group: `${ASSET_BASE}task-chat-people.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
  views: `${ASSET_BASE}task-social-eye.svg`,
  poll: `${ASSET_BASE}task-social-task-square.svg`,
  bookmark: `${ASSET_BASE}task-chat-archive-tick.svg`,
  trend: `${ASSET_BASE}task-social-smileys.svg`,
};

const instagramIcons = {
  like: `${ASSET_BASE}task-social-like.svg`,
  followers: `${ASSET_BASE}task-social-profile-2user.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  live: `${ASSET_BASE}task-social-radar.svg`,
  save: `${ASSET_BASE}task-chat-archive-tick.svg`,
  views: `${ASSET_BASE}task-social-eye.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  external: `${ASSET_BASE}task-social-export.svg`,
  group: `${ASSET_BASE}task-chat-people.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
};

const tiktokIcons = {
  like: `${ASSET_BASE}task-social-like.svg`,
  followers: `${ASSET_BASE}task-social-profile-2user.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  repost: `${ASSET_BASE}task-social-refresh-2.svg`,
  bookmark: `${ASSET_BASE}task-chat-archive-tick.svg`,
  external: `${ASSET_BASE}task-social-export.svg`,
  live: `${ASSET_BASE}task-social-radar.svg`,
  views: `${ASSET_BASE}task-social-eye.svg`,
  music: `${ASSET_BASE}task-social-music-filter.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
  duet: `${ASSET_BASE}task-social-profile-2user.svg`,
  lipsync: `${ASSET_BASE}task-social-unlimited.svg`,
  mimic: `${ASSET_BASE}task-social-video-vertical.svg`,
  stitch: `${ASSET_BASE}task-social-scissor.svg`,
};


const linkedinIcons = {
  like: `${ASSET_BASE}task-social-like.svg`,
  followers: `${ASSET_BASE}task-social-profile-2user.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  live: `${ASSET_BASE}task-social-radar.svg`,
  connections: `${ASSET_BASE}task-social-profile-2user.svg`,
  save: `${ASSET_BASE}task-chat-archive-tick.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  external: `${ASSET_BASE}task-social-export.svg`,
  repost: `${ASSET_BASE}task-social-refresh-2.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
};

const audiomackIcons = {
  liked: `${ASSET_BASE}task-chat-heart-add.svg`,
  follow: `${ASSET_BASE}task-chat-profile-add.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  boost: `${ASSET_BASE}task-social-trend-up.svg`,
  playlist: `${ASSET_BASE}task-social-music-filter.svg`,
  resave: `${ASSET_BASE}task-chat-archive-tick.svg`,
  unique: `${ASSET_BASE}task-social-chart-square.svg`,
  multiple: `${ASSET_BASE}task-chat-people.svg`,
  reup: `${ASSET_BASE}task-social-refresh-2.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  highlight: `${ASSET_BASE}task-social-star.svg`,
  embed: `${ASSET_BASE}task-social-link-2.svg`,
};

const boomplayIcons = {
  favourite: `${ASSET_BASE}task-chat-heart-add.svg`,
  download: `${ASSET_BASE}task-social-document-download.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  boost: `${ASSET_BASE}task-social-trend-up.svg`,
  playlist: `${ASSET_BASE}task-social-music-filter.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  unique: `${ASSET_BASE}task-social-chart-square.svg`,
  multiple: `${ASSET_BASE}task-chat-people.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  embed: `${ASSET_BASE}task-social-link-2.svg`,
};

const spotifyIcons = {
  liked: `${ASSET_BASE}task-chat-heart-add.svg`,
  follow: `${ASSET_BASE}task-chat-profile-add.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  boost: `${ASSET_BASE}task-social-trend-up.svg`,
  playlist: `${ASSET_BASE}task-social-music-filter.svg`,
  resave: `${ASSET_BASE}task-chat-archive-tick.svg`,
  unique: `${ASSET_BASE}task-social-chart-square.svg`,
  multiple: `${ASSET_BASE}task-chat-people.svg`,
};

const ytMusicIcons = {
  like: `${ASSET_BASE}task-chat-heart-add.svg`,
  download: `${ASSET_BASE}task-social-document-download.svg`,
  share: `${ASSET_BASE}task-chat-send.svg`,
  boost: `${ASSET_BASE}task-social-trend-up.svg`,
  playlist: `${ASSET_BASE}task-social-music-filter.svg`,
  comment: `${ASSET_BASE}task-social-message.svg`,
  unique: `${ASSET_BASE}task-social-chart-square.svg`,
  multiple: `${ASSET_BASE}task-chat-people.svg`,
  subscribe: `${ASSET_BASE}task-social-notification.svg`,
  radio: `${ASSET_BASE}task-social-radio.svg`,
  engagement: `${ASSET_BASE}task-social-device-message.svg`,
  library: `${ASSET_BASE}task-social-folder-add.svg`,
  interactive: `${ASSET_BASE}task-social-category.svg`,
  report: `${ASSET_BASE}task-chat-flag.svg`,
  video: `${ASSET_BASE}task-social-video.svg`,
  embed: `${ASSET_BASE}task-social-link-2.svg`,
};

const linkedinReactions = [
  ["👍 Like", 10], ["👏 Celebrate", 10], ["🫴 Support", 10],
  ["❤️ Love", 10], ["😂 Funny", 15], ["💡 Insightful", 10],
];

const externalShareOptions = [
  ["WhatsApp", 20], ["X (Twitter)", 20], ["Youtube", 20], ["Instagram", 20],
  ["TikTok", 20], ["Telegram", 20], ["Snapchat", 20], ["Messenger", 20], ["Discord", 20],
];

const listenDurations = [["30 Secs", 10], ["45 Secs", 15], ["Full Song", 30]];
const repeatFrequencies = [["3-5 Times/Week", 50], ["6-10 Times/Week", 100], ["11-15 Times/Week", 150], ["16-20 Times/Week", 200]];

const reactions = [
  ["❤️ Love", 10],
  ["👍 Like", 10],
  ["😦 Wow", 10],
  ["🤗 Care", 10],
  ["😂 Funny", 15],
  ["😢 Sad", 5],
  ["😡 Angry", 20],
];

const task = (label, mode, icon, tone, extra = {}) => ({ label, mode, icon, tone, ...extra });

const platformConfigs = {
  facebook: {
    slug: "facebook",
    title: "I need Facebook:",
    linkPlaceholder: "https://facebook.com/...",
    grid: 6,
    tasks: [
      task("Like / Others", "reaction", facebookIcons.like, "orange", { instructions: false }),
      task("Friend Request", "simple", facebookIcons.friend, "blue"),
      task("FB Share", "share", facebookIcons.share, "green"),
      task("Comments", "comment", facebookIcons.comment, "sky"),
      task("Live Participants", "simple", facebookIcons.live, "peach"),
      task("Followers", "simple", facebookIcons.followers, "lavender"),
      task("Story View", "simple", facebookIcons.story, "yellow", { unitCost: 5 }),
      task("Video Viewers", "view", facebookIcons.video, "navy"),
      task("Report", "report", facebookIcons.report, "red"),
      task("External Shares", "external-share", facebookIcons.external, "blue"),
      task("Join Group/community", "simple", facebookIcons.group, "green", { unitCost: 10 }),
      task("Interactive Comment Review", "interactive", facebookIcons.interactive, "orange", { unitCost: 30 }),
    ],
  },
  youtube: {
    slug: "youtube",
    title: "I need Youtube:",
    linkPlaceholder: "https://youtube.com/...",
    grid: 4,
    tasks: [
      task("Like", "reaction", youtubeIcons.like, "orange", { instructions: false }),
      task("Subscribe", "subscribe", youtubeIcons.subscribe, "red", { instructions: false }),
      task("Share on Youtube", "share", youtubeIcons.share, "green"),
      task("Comments", "comment", youtubeIcons.comment, "sky"),
      task("Report", "report", youtubeIcons.report, "red"),
      task("Dislike", "dislike", youtubeIcons.dislike, "blue"),
      task("Save", "simple", youtubeIcons.save, "green", { unitCost: 10 }),
      task("Video Viewers", "view", youtubeIcons.video, "navy"),
      task("Live Participants", "simple", youtubeIcons.live, "peach"),
      task("External Shares", "external-share", youtubeIcons.external, "blue"),
      task("Use Sound from TT Video & Post", "special-media", youtubeIcons.music, "sky", { specialTitle: "Use Sound", specialCopy: "Get a Nano-Influencer to use your sound to create content on Youtube", mediaLabel: "Choose Sound Part" }),
      task("Interactive Comments", "interactive", youtubeIcons.interactive, "orange", { unitCost: 30 }),
      task("Collab: create alongside video", "special-media", youtubeIcons.collab, "lavender", { specialTitle: "YouTube Collab", specialCopy: "Pay people to collab your post", mediaLabel: "Choose Video Part" }),
      task("Use Segment of Video as BG", "special-media", youtubeIcons.scissor, "peach", { specialTitle: "Use Segment of Video as Background", mediaLabel: "Choose Video Part", unitCost: 200 }),
      task("Use Video as a Background", "special-media", youtubeIcons.background, "orange", { specialTitle: "Use Video as a Background", mediaLabel: "Choose Video Part", unitCost: 500 }),
      task("Build my own Community", "simple", youtubeIcons.community, "red"),
    ],
  },
  x: {
    slug: "x",
    title: "I need X (Twitter):",
    linkPlaceholder: "https://x.com/...",
    grid: 8,
    tasks: [
      task("Like", "reaction", xIcons.like, "orange", { instructions: false }),
      task("Followers", "simple", xIcons.followers, "lavender"),
      task("Internal Shares", "share", xIcons.share, "green"),
      task("Comments", "comment", xIcons.comment, "sky"),
      task("Report", "report", xIcons.report, "red"),
      task("Repost", "simple", xIcons.repost, "blue", { unitCost: 20 }),
      task("Quotes", "quote", xIcons.quote, "green"),
      task("Video Viewers", "view", xIcons.video, "navy"),
      task("Space Participation", "simple", xIcons.space, "lavender"),
      task("External Shares", "external-share", xIcons.external, "blue"),
      task("Join Group", "simple", xIcons.group, "green", { unitCost: 10 }),
      task("Interactive Comments", "interactive", xIcons.interactive, "orange", { unitCost: 30 }),
      task("Post Views", "simple", xIcons.views, "peach", { unitCost: 10 }),
      task("Poll Votes", "poll", xIcons.poll, "blue", { unitCost: 20 }),
      task("Bookmark", "simple", xIcons.bookmark, "green", { unitCost: 10 }),
      task("Trend on X", "trend", xIcons.trend, "gray", { unitCost: 30 }),
    ],
  },
  instagram: {
    slug: "instagram",
    title: "I need Instagram:",
    linkPlaceholder: "https://instagram.com/...",
    grid: 4,
    tasks: [
      task("Like", "reaction", instagramIcons.like, "orange", { instructions: false }),
      task("Followers", "simple", instagramIcons.followers, "lavender"),
      task("IG Shares / Ads", "share", instagramIcons.share, "green"),
      task("Comments", "comment", instagramIcons.comment, "sky"),
      task("Live Participants", "simple", instagramIcons.live, "peach"),
      task("Save Post", "simple", instagramIcons.save, "green", { unitCost: 10 }),
      task("Story Views", "simple", instagramIcons.views, "peach", { unitCost: 5 }),
      task("Video Viewers", "view", instagramIcons.video, "navy"),
      task("Report", "report", instagramIcons.report, "red"),
      task("External Shares", "external-share", instagramIcons.external, "blue"),
      task("Join Group", "simple", instagramIcons.group, "green", { unitCost: 10 }),
      task("Interactive Comments", "interactive", instagramIcons.interactive, "orange", { unitCost: 30 }),
    ],
  },
  tiktok: {
    slug: "tiktok",
    title: "I need TikTok:",
    linkPlaceholder: "https://tiktok.com/...",
    grid: 8,
    tasks: [
      task("Like", "reaction", tiktokIcons.like, "orange", { instructions: false }),
      task("Followers", "simple", tiktokIcons.followers, "lavender"),
      task("Share on TikTok", "share", tiktokIcons.share, "green"),
      task("Comments", "comment", tiktokIcons.comment, "sky"),
      task("Report", "report", tiktokIcons.report, "red"),
      task("Repost", "simple", tiktokIcons.repost, "blue", { unitCost: 20 }),
      task("Bookmark", "simple", tiktokIcons.bookmark, "green", { unitCost: 10 }),
      task("External Shares", "external-share", tiktokIcons.external, "blue"),
      task("Live Participants", "simple", tiktokIcons.live, "peach"),
      task("Views", "view", tiktokIcons.views, "peach"),
      task("Sound & Post", "special-media", tiktokIcons.music, "sky", { specialTitle: "Use Sound", specialCopy: "Get a Nano-Influencer to use your sound to create content on TikTok", mediaLabel: "Choose Sound Part" }),
      task("Interactive Comments", "interactive", tiktokIcons.interactive, "orange", { unitCost: 30 }),
      task("Duet", "special-media", tiktokIcons.duet, "lavender", { specialTitle: "Duet Post", specialCopy: "Get a Nano-Influencer to use your sound to create content on Youtube", mediaLabel: "Choose Video Part" }),
      task("Lip-sync", "special-media", tiktokIcons.lipsync, "gray", { specialTitle: "Lip-Sync", mediaLabel: "Choose Sound Part", unitCost: 200 }),
      task("Mimic Video", "special-media", tiktokIcons.mimic, "orange", { specialTitle: "Video Mimic", mediaLabel: "Choose Video Part", unitCost: 500 }),
      task("Stitch my Video", "special-media", tiktokIcons.stitch, "peach", { specialTitle: "Stitch Video", specialCopy: "Get a Nano-Influencer to use your sound to create content on Youtube", mediaLabel: "Choose Video Part" }),
    ],
  },

  linkedin: {
    slug: "linkedin",
    title: "I need LinkedIn:",
    linkPlaceholder: "https://linkedIn.com/...",
    grid: 4,
    tasks: [
      task("Like / Others", "reaction", linkedinIcons.like, "orange", { reactions: linkedinReactions, instructions: false }),
      task("Followers", "gender", linkedinIcons.followers, "lavender", { options: [["Female Followers", 10], ["Male Followers", 10]] }),
      task("Share on LinkedIn", "multi-share", linkedinIcons.share, "green", { options: [["Newsfeed", 10], ["Connection's DM", 20], ["Comment Session", 30]], formats: ["Video", "Images"] }),
      task("Comments", "comment", linkedinIcons.comment, "sky", { surfaces: ["Post", "Comment Section"] }),
      task("Live Participants", "live", linkedinIcons.live, "peach"),
      task("Connections", "gender", linkedinIcons.connections, "lavender", { options: [["Female Connections", 10], ["Male Connections", 10]] }),
      task("Save", "priced", linkedinIcons.save, "green", { unitCost: 10, specialTitle: "Save Post" }),
      task("Video Viewers", "view", linkedinIcons.video, "navy"),
      task("Report", "report", linkedinIcons.report, "red"),
      task("External Shares", "multi-share", linkedinIcons.external, "blue", { options: externalShareOptions, formats: ["Video", "Images"] }),
      task("Repost", "repost-options", linkedinIcons.repost, "green", { unitCost: 20 }),
      task("Interactive Comments", "interactive", linkedinIcons.interactive, "orange", { unitCost: 30, surfaces: ["Post", "Comment Section"] }),
    ],
  },
  audiomack: {
    slug: "audiomack",
    title: "I need Audiomack:",
    linkPlaceholder: "https://audiomack.com/...",
    grid: 4,
    tasks: [
      task("Add to Liked Songs", "priced", audiomackIcons.liked, "red", { unitCost: 100, specialTitle: "Add my Song to Liked Songs" }),
      task("Follow Artist", "gender", audiomackIcons.follow, "lavender", { options: [["Female Followers", 10], ["Male Followers", 10]] }),
      task("Share Song/Album", "multi-share", audiomackIcons.share, "green", { options: externalShareOptions, formats: ["Audio"] }),
      task("Boost/React Album", "priced", audiomackIcons.boost, "orange", { unitCost: 20 }),
      task("Add Song to Playlist", "priced", audiomackIcons.playlist, "green", { unitCost: 100 }),
      task("Re-Save Song/Album", "priced", audiomackIcons.resave, "green", { unitCost: 10 }),
      task("Unique Listen", "duration-choice", audiomackIcons.unique, "blue", { options: listenDurations }),
      task("Multiple Listeners", "frequency-choice", audiomackIcons.multiple, "lavender", { options: repeatFrequencies }),
      task("Re-Up my Song", "priced", audiomackIcons.reup, "blue", { unitCost: 20, specialTitle: "Re-post my Song" }),
      task("Comments", "comment", audiomackIcons.comment, "sky", { surfaces: ["Song", "Comment Section"] }),
      task("Highlight my Album/Playlist", "priced", audiomackIcons.highlight, "yellow", { unitCost: 20 }),
      task("Embed my Songt my Song", "priced", audiomackIcons.embed, "blue", { unitCost: 20 }),
    ],
  },
  boomplay: {
    slug: "boomplay",
    title: "I need Boomplay:",
    linkPlaceholder: "https://boomplay.com/...",
    grid: 4,
    tasks: [
      task("Add to Favourite", "favourite-type", boomplayIcons.favourite, "red", { unitCost: 100 }),
      task("Download Song/Album", "priced", boomplayIcons.download, "blue", { unitCost: 20 }),
      task("Share Song/Album", "multi-share", boomplayIcons.share, "green", { options: externalShareOptions, formats: ["Audio"] }),
      task("Boost/React Album", "priced", boomplayIcons.boost, "orange", { unitCost: 20 }),
      task("Add Song to Playlist", "priced", boomplayIcons.playlist, "green", { unitCost: 100 }),
      task("Comment on my Song", "comment", boomplayIcons.comment, "sky", { surfaces: ["Song", "Comment Section"] }),
      task("Unique Listen", "duration-choice", boomplayIcons.unique, "blue", { options: listenDurations }),
      task("Multiple Listeners", "frequency-choice", boomplayIcons.multiple, "lavender", { options: repeatFrequencies }),
      task("Interactive Comments", "interactive", boomplayIcons.interactive, "orange", { unitCost: 30, surfaces: ["Song", "Comment Section"] }),
      task("Report", "report", boomplayIcons.report, "red"),
      task("Video Viewers", "view", boomplayIcons.video, "navy"),
      task("Embed my Songt my Song", "priced", boomplayIcons.embed, "blue", { unitCost: 20 }),
    ],
  },
  spotify: {
    slug: "spotify",
    title: "I need Spotify:",
    linkPlaceholder: "https://spotify.com/...",
    grid: 4,
    tasks: [
      task("Add to Liked Songs", "priced", spotifyIcons.liked, "red", { unitCost: 100, specialTitle: "Add my Song to Liked Songs" }),
      task("Follow Artist", "gender", spotifyIcons.follow, "lavender", { options: [["Female Followers", 10], ["Male Followers", 10]] }),
      task("Share Song/Album", "multi-share", spotifyIcons.share, "green", { options: externalShareOptions, formats: ["Audio"] }),
      task("Boost/React Album", "priced", spotifyIcons.boost, "orange", { unitCost: 20 }),
      task("Add Song to Playlist", "priced", spotifyIcons.playlist, "green", { unitCost: 100 }),
      task("Re-Save Song/Album", "priced", spotifyIcons.resave, "green", { unitCost: 10 }),
      task("Unique Listen", "duration-choice", spotifyIcons.unique, "blue", { options: listenDurations }),
      task("Multiple Listeners", "frequency-choice", spotifyIcons.multiple, "lavender", { options: repeatFrequencies }),
    ],
  },
  "youtube-music": {
    slug: "youtube-music",
    title: "I need YouTube Music:",
    linkPlaceholder: "https://ytubemusic.com/...",
    grid: 4,
    tasks: [
      task("Like my Song", "reaction", ytMusicIcons.like, "red", { instructions: false }),
      task("Download Song/Playlist", "priced", ytMusicIcons.download, "blue", { unitCost: 20 }),
      task("Share Song/Album", "multi-share", ytMusicIcons.share, "green", { options: externalShareOptions, formats: ["Audio"] }),
      task("Boost in Music/Album", "priced", ytMusicIcons.boost, "orange", { unitCost: 20 }),
      task("Add Song to Playlist", "priced", ytMusicIcons.playlist, "green", { unitCost: 100 }),
      task("Comment on my Song", "comment", ytMusicIcons.comment, "sky", { surfaces: ["Song", "Comment Section"] }),
      task("Unique Listen", "duration-choice", ytMusicIcons.unique, "blue", { options: listenDurations }),
      task("Multiple Listeners", "frequency-choice", ytMusicIcons.multiple, "lavender", { options: repeatFrequencies }),
      task("Subscribe to an Artist", "music-subscribe", ytMusicIcons.subscribe, "red"),
      task("Start a Radio with Song/Album", "priced", ytMusicIcons.radio, "blue", { unitCost: 10, specialTitle: "Start a Radio" }),
      task("Comment Engagements", "comment-engagement", ytMusicIcons.engagement, "sky"),
      task("Add Song to my Library", "priced", ytMusicIcons.library, "yellow", { unitCost: 10 }),
      task("Interactive Comments", "interactive", ytMusicIcons.interactive, "orange", { unitCost: 30, surfaces: ["Song", "Comment Section"] }),
      task("Report", "report", ytMusicIcons.report, "red"),
      task("Video Viewers", "view", ytMusicIcons.video, "navy"),
      task("Embed my Songt my Song", "priced", ytMusicIcons.embed, "blue", { unitCost: 20 }),
    ],
  },

};

const normalize = (value = "") => value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
const money = (value) => `₦${Number(value || 0).toLocaleString("en-NG")}`;

function BackIcon() {
  return <img src={commonIcons.arrowLeft} alt="" width="24" height="24" />;
}

function UploadIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path d="M12 16V4m0 0L7.5 8.5M12 4l4.5 4.5M5 14v4.5A1.5 1.5 0 006.5 20h11a1.5 1.5 0 001.5-1.5V14" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function TaskCard({ item, active, onClick }) {
  return (
    <button className={`v2-stc-task-card${active ? " is-active" : ""}`} type="button" onClick={onClick}>
      <span className={`v2-stc-task-icon tone-${item.tone}`}><img src={item.icon} alt="" /></span>
      <span>{item.label}</span>
    </button>
  );
}

function FieldHeader({ title, help }) {
  return (
    <div className="v2-stc-field-head">
      <label>{title}</label>
      {help ? <p className="v2-stc-help">{help}</p> : null}
    </div>
  );
}

function CheckChoice({ checked, onChange, label, cost }) {
  return (
    <label className="v2-stc-check">
      <input type="checkbox" checked={checked} onChange={onChange} />
      <span className="v2-stc-box">{checked ? "✓" : ""}</span>
      <span>{label}</span>
      {typeof cost === "number" ? <small>(Cost {money(cost)})</small> : null}
    </label>
  );
}

function Consent({ checked, onChange, children }) {
  return (
    <label className="v2-stc-consent">
      <input type="checkbox" checked={checked} onChange={onChange} />
      <span className="v2-stc-box">{checked ? "✓" : ""}</span>
      <span>{children}</span>
    </label>
  );
}

function RadioButtons({ title, values, value, onChange }) {
  return (
    <div className="v2-stc-prompt-row">
      <h2 className="v2-stc-subtitle">{title}</h2>
      <div className="v2-stc-button-group">
        {values.map((item) => (
          <button key={item} className={`v2-stc-choice-btn${value === item ? " is-active" : ""}`} type="button" onClick={() => onChange(item)}>{item}</button>
        ))}
      </div>
    </div>
  );
}

function UploadBox({ fileName, onFile, accept = "image/*", label = "Choose file" }) {
  const ref = useRef(null);
  return (
    <>
      <input ref={ref} type="file" accept={accept} hidden onChange={(event) => onFile(event.target.files?.[0]?.name || "")} />
      <button className="v2-stc-upload" type="button" onClick={() => ref.current?.click()}>
        <UploadIcon />
        <strong>{fileName || label}</strong>
        <span>Size limit: 25mb</span>
      </button>
    </>
  );
}

function TaskSpecificFields({ selectedTask, values, setValue, selectedReactions, setSelectedReactions, selectedOptions, setSelectedOptions, taskMedia, setTaskMedia }) {
  const mode = selectedTask.mode;
  const toggleReaction = (label) => {
    setSelectedReactions((current) => current.includes(label) ? current.filter((item) => item !== label) : [...current, label]);
  };

  if (mode === "reaction") {
    return (
      <section className="v2-stc-panel">
        <h2 className="v2-stc-subtitle">What kind of Reaction(s) do you want on your post</h2>
        <div className="v2-stc-choice-list">
          {(selectedTask.reactions || reactions).map(([label, cost]) => <CheckChoice key={label} label={label} cost={cost} checked={selectedReactions.includes(label)} onChange={() => toggleReaction(label)} />)}
        </div>
        <div className="v2-stc-divider" />
        <RadioButtons title="I want the reaction to happen on a:" values={selectedTask.surfaces || ["Post", "Comment Section"]} value={values.targetSurface} onChange={(value) => setValue("targetSurface", value)} />
      </section>
    );
  }

  if (mode === "subscribe") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-field">
          <FieldHeader title="Choose the Subscriber Plan you want:" />
          <select className="v2-stc-select" value={values.subscriberPlan} onChange={(event) => setValue("subscriberPlan", event.target.value)}>
            <option value="">Select plan</option>
          </select>
        </div>
        <div className="v2-stc-field">
          <FieldHeader title="I want:" />
          <input className="v2-stc-input" value={values.want} onChange={(event) => setValue("want", event.target.value)} placeholder="type here" />
        </div>
      </section>
    );
  }

  if (mode === "share" || mode === "external-share") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-field">
          <FieldHeader title="What type of Video View do you want?" help="Here you do not get any engagements only nano-influencers viewing your video for a period of time. How long do you want the nano-influencers to watch the video." />
          <input className="v2-stc-input" value={values.viewType} onChange={(event) => setValue("viewType", event.target.value)} placeholder="Select option" />
        </div>
        <div className="v2-stc-field">
          <FieldHeader title={mode === "share" ? "How do you want us to Share your Content?" : "Where do you want us to Share your Content"} />
          <input className="v2-stc-input" value={values.shareDestination} onChange={(event) => setValue("shareDestination", event.target.value)} placeholder="Select option" />
        </div>
        <div className="v2-stc-field">
          <FieldHeader title="Format" help="You can select one or more" />
          <input className="v2-stc-input" value={values.format} onChange={(event) => setValue("format", event.target.value)} placeholder="Select format" />
        </div>
      </section>
    );
  }

  if (mode === "comment") {
    return (
      <section className="v2-stc-panel">
        <RadioButtons title="I want the Comment to happen on:" values={["Post", "Comment Section"]} value={values.targetSurface} onChange={(value) => setValue("targetSurface", value)} />
      </section>
    );
  }

  if (mode === "report") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-field"><FieldHeader title="I want to report a:" /><input className="v2-stc-input" value={values.reportType} onChange={(event) => setValue("reportType", event.target.value)} placeholder="Select option" /></div>
        <div className="v2-stc-field"><FieldHeader title="Why are you reporting this comment?" help="Choose the option that best describes the issue" /><input className="v2-stc-input" value={values.reportReason} onChange={(event) => setValue("reportReason", event.target.value)} placeholder="Select option" /></div>
        <div className="v2-stc-field"><FieldHeader title="Please write a short letter to our admin on why you are reporting this comment" /><textarea className="v2-stc-textarea" value={values.reportLetter} onChange={(event) => setValue("reportLetter", event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
        <div className="v2-stc-field"><FieldHeader title="Upload Evidence to back your claims on why this comment deserves to be reported" /><UploadBox fileName={taskMedia} onFile={setTaskMedia} /></div>
        <div className="v2-stc-field"><FieldHeader title="Commenter’s Handle" /><input className="v2-stc-input" value={values.commenterHandle} onChange={(event) => setValue("commenterHandle", event.target.value)} placeholder="type here" /></div>
        <div className="v2-stc-field"><FieldHeader title="Drop the comment you want us to report" /><textarea className="v2-stc-textarea" value={values.reportComment} onChange={(event) => setValue("reportComment", event.target.value)} placeholder="type here" /></div>
      </section>
    );
  }

  if (mode === "view") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-field"><FieldHeader title="What type of Video View do you want?" help="Here you do not get any engagements only nano-influencers viewing your video for a period of time. How long do you want the nano-influencers to watch the video." /><input className="v2-stc-input" value={values.viewType} onChange={(event) => setValue("viewType", event.target.value)} placeholder="Select option" /></div>
        <div className="v2-stc-field"><FieldHeader title="I want:" /><input className="v2-stc-input" value={values.want} onChange={(event) => setValue("want", event.target.value)} placeholder="type here" /></div>
      </section>
    );
  }

  if (mode === "interactive") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-special-title"><h2>Interactive Comment Session</h2>{selectedTask.unitCost ? <p>(Cost {money(selectedTask.unitCost)})</p> : null}</div>
        <RadioButtons title="I want the Interactive Comment Session to happen on a:" values={selectedTask.surfaces || ["Post", "Comment Section"]} value={values.targetSurface} onChange={(value) => setValue("targetSurface", value)} />
      </section>
    );
  }

  if (mode === "dislike") {
    return (
      <section className="v2-stc-panel">
        <RadioButtons title="I want the Dislike to happen on a:" values={["Post", "Comment Section"]} value={values.targetSurface} onChange={(value) => setValue("targetSurface", value)} />
        <div className="v2-stc-field"><FieldHeader title="Reasons for Dislike (To Admin)" /><textarea className="v2-stc-textarea" value={values.reason} onChange={(event) => setValue("reason", event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
        <div className="v2-stc-field"><FieldHeader title="Upload any image evidence." /><UploadBox fileName={taskMedia} onFile={setTaskMedia} /></div>
      </section>
    );
  }

  if (mode === "quote") {
    return (
      <section className="v2-stc-panel"><div className="v2-stc-field"><FieldHeader title="What kind of Write-Up" /><textarea className="v2-stc-textarea" value={values.writeUp} onChange={(event) => setValue("writeUp", event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div></section>
    );
  }

  if (mode === "poll") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-special-title"><h2>Poll Votes</h2><p>(Cost ₦20)</p></div>
        <div className="v2-stc-field"><FieldHeader title="Option to select in the Poll" /><textarea className="v2-stc-textarea" value={values.pollOption} onChange={(event) => setValue("pollOption", event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
      </section>
    );
  }

  if (mode === "trend") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-special-title"><h2>Trend on X</h2><p>(Cost ₦30)</p></div>
        <div className="v2-stc-field"><FieldHeader title="Trend Duration" help="(Cost ₦5)" /><input className="v2-stc-input" value={values.trendDuration} onChange={(event) => setValue("trendDuration", event.target.value)} placeholder="type here" /></div>
        <div className="v2-stc-field"><FieldHeader title="Trend Request" /><textarea className="v2-stc-textarea" value={values.trendRequest} onChange={(event) => setValue("trendRequest", event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
        <div className="v2-stc-field"><FieldHeader title="Additional Information" /><textarea className="v2-stc-textarea" value={values.additionalInfo} onChange={(event) => setValue("additionalInfo", event.target.value)} placeholder="type here" /></div>
      </section>
    );
  }

  if (mode === "special-media") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-special-title"><h2>{selectedTask.specialTitle || selectedTask.label}</h2>{selectedTask.specialCopy ? <p>{selectedTask.specialCopy}</p> : null}{selectedTask.unitCost ? <p>(Cost {money(selectedTask.unitCost)})</p> : null}</div>
        <div className="v2-stc-field"><FieldHeader title="Upload sound." /><UploadBox fileName={taskMedia} onFile={setTaskMedia} accept="audio/*,video/*" /></div>
        <div className="v2-stc-field"><FieldHeader title={selectedTask.mediaLabel || "Choose Video Part"} /><div className="v2-stc-two"><input className="v2-stc-input" value={values.mediaStart} onChange={(event) => setValue("mediaStart", event.target.value)} placeholder="Start time" /><input className="v2-stc-input" value={values.mediaEnd} onChange={(event) => setValue("mediaEnd", event.target.value)} placeholder="End time" /></div></div>
        <div className="v2-stc-field"><FieldHeader title="What kind of Content" /><input className="v2-stc-input" value={values.contentType} onChange={(event) => setValue("contentType", event.target.value)} placeholder="type here" /></div>
        <div className="v2-stc-field"><FieldHeader title="What do you want to Achieve?" /><textarea className="v2-stc-textarea" value={values.goal} onChange={(event) => setValue("goal", event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
      </section>
    );
  }


  if (mode === "gender") {
    const toggle = (label) => setSelectedOptions((current) => current.includes(label) ? current.filter((item) => item !== label) : [...current, label]);
    return (
      <section className="v2-stc-panel">
        <h2 className="v2-stc-subtitle">I want:</h2>
        <div className="v2-stc-choice-list">{(selectedTask.options || []).map(([label, cost]) => <CheckChoice key={label} label={label} cost={cost} checked={selectedOptions.includes(label)} onChange={() => toggle(label)} />)}</div>
      </section>
    );
  }

  if (mode === "multi-share") {
    const toggle = (label) => setSelectedOptions((current) => current.includes(label) ? current.filter((item) => item !== label) : [...current, label]);
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-field">
          <FieldHeader title="Where do you want us to Share your Content" />
          <div className="v2-stc-choice-list">{(selectedTask.options || []).map(([label, cost]) => <CheckChoice key={label} label={label} cost={cost} checked={selectedOptions.includes(label)} onChange={() => toggle(label)} />)}</div>
        </div>
        <div className="v2-stc-field">
          <FieldHeader title="Format" help="You can select one or more" />
          <RadioButtons title="" values={selectedTask.formats || ["Video", "Images"]} value={values.format} onChange={(value) => setValue("format", value)} />
        </div>
      </section>
    );
  }

  if (mode === "live") {
    return <section className="v2-stc-panel"><RadioButtons title="I want:" values={["Participants on my Live (No Sharing)", "Participants on my Live (Share to Friends/Contacts)"]} value={values.want} onChange={(value) => setValue("want", value)} /></section>;
  }

  if (mode === "priced") {
    return <section className="v2-stc-panel"><div className="v2-stc-special-title"><h2>{selectedTask.specialTitle || selectedTask.label}</h2>{selectedTask.unitCost ? <p>(Cost {money(selectedTask.unitCost)})</p> : null}</div></section>;
  }

  if (mode === "duration-choice" || mode === "frequency-choice") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-special-title"><h2>{selectedTask.label}</h2>{mode === "duration-choice" ? <p>(Cost depends on duration)</p> : <p>(Cost depends on frequency)</p>}</div>
        <h2 className="v2-stc-subtitle">Set Duration:</h2>
        <div className="v2-stc-choice-list">{(selectedTask.options || []).map(([label, cost]) => <CheckChoice key={label} label={label} cost={cost} checked={values.durationChoice === label} onChange={() => setValue("durationChoice", values.durationChoice === label ? "" : label)} />)}</div>
      </section>
    );
  }

  if (mode === "favourite-type") {
    return (
      <section className="v2-stc-panel">
        <RadioButtons title="Favourite type:" values={["Song", "Album", "Playlist", "Artist"]} value={values.favouriteType} onChange={(value) => setValue("favouriteType", value)} />
        <div className="v2-stc-special-title"><h2>Add my Song to Liked Songs</h2><p>(Cost {money(selectedTask.unitCost || 100)})</p></div>
      </section>
    );
  }

  if (mode === "repost-options") {
    return (
      <section className="v2-stc-panel">
        <div className="v2-stc-special-title"><h2>Re-post my post</h2><p>(Cost {money(selectedTask.unitCost || 20)})</p></div>
        <RadioButtons title="Quantity" values={["Just Repost", "Repost with Thoughts"]} value={values.repostType} onChange={(value) => setValue("repostType", value)} />
      </section>
    );
  }

  if (mode === "music-subscribe") {
    return (
      <section className="v2-stc-panel">
        <RadioButtons title="Choose the Subscriber Plan you want:" values={["Only Subscribe", "Subscribe and turn on Notifications"]} value={values.subscriberPlan} onChange={(value) => setValue("subscriberPlan", value)} />
        <RadioButtons title="I want:" values={["Female Subscribers", "Subscribers"]} value={values.subscriberGender} onChange={(value) => setValue("subscriberGender", value)} />
      </section>
    );
  }

  if (mode === "comment-engagement") {
    return (
      <section className="v2-stc-panel">
        <RadioButtons title="" values={["Like Comment", "Dislike Comment"]} value={values.commentAction} onChange={(value) => setValue("commentAction", value)} />
        <div className="v2-stc-field"><FieldHeader title="Commenter’s Handle" /><input className="v2-stc-input" value={values.commenterHandle} onChange={(event) => setValue("commenterHandle", event.target.value)} placeholder="type here" /></div>
        <div className="v2-stc-field"><FieldHeader title="The Comment that needs Reaction." /><textarea className="v2-stc-textarea" value={values.reportComment} onChange={(event) => setValue("reportComment", event.target.value)} placeholder="type here" /></div>
      </section>
    );
  }

  return null;
}

export default function V2SocialTaskCampaign() {
  const pathSlug = window.location.pathname.split("/").filter(Boolean).pop()?.toLowerCase() || "facebook";
  const platform = platformConfigs[pathSlug === "twitter" ? "x" : pathSlug] || platformConfigs.facebook;
  const query = new URLSearchParams(window.location.search);
  const requestedTask = query.get("task") || "";
  const initialIndex = Math.max(0, platform.tasks.findIndex((item) => normalize(item.label) === normalize(requestedTask)));
  const [selectedTaskIndex, setSelectedTaskIndex] = useState(initialIndex);
  const selectedTask = platform.tasks[selectedTaskIndex];
  const [selectedReactions, setSelectedReactions] = useState([]);
  const [selectedOptions, setSelectedOptions] = useState([]);
  const [values, setValues] = useState({
    targetSurface: "Post",
    subscriberPlan: "",
    want: "",
    viewType: "",
    shareDestination: "",
    format: "",
    reportType: "",
    reportReason: "",
    reportLetter: "",
    commenterHandle: "",
    reportComment: "",
    reason: "",
    writeUp: "",
    pollOption: "",
    trendDuration: "",
    trendRequest: "",
    additionalInfo: "",
    mediaStart: "",
    mediaEnd: "",
    contentType: "",
    goal: "",
    durationChoice: "",
    favouriteType: "",
    subscriberGender: "",
    commentAction: "",
    repostType: "",
  });
  const [pageAbout, setPageAbout] = useState("");
  const [link, setLink] = useState("");
  const [quantity, setQuantity] = useState("");
  const [country, setCountry] = useState("");
  const [targetState, setTargetState] = useState("All States");
  const [delivery, setDelivery] = useState("Default Time");
  const [startDate, setStartDate] = useState("Today");
  const [startTime, setStartTime] = useState("19:00");
  const [instruction, setInstruction] = useState("");
  const [instructionFile, setInstructionFile] = useState("");
  const [taskMedia, setTaskMedia] = useState("");
  const [cashbackEvidence, setCashbackEvidence] = useState("");
  const [privacyAccepted, setPrivacyAccepted] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [copied, setCopied] = useState(false);

  const setValue = (key, value) => setValues((current) => ({ ...current, [key]: value }));

  const unitCost = useMemo(() => {
    if (selectedTask.mode === "reaction") {
      const pool = selectedTask.reactions || reactions;
      return pool.filter(([label]) => selectedReactions.includes(label)).reduce((sum, [, cost]) => sum + cost, 0);
    }
    if (selectedTask.mode === "gender" || selectedTask.mode === "multi-share") {
      return (selectedTask.options || []).filter(([label]) => selectedOptions.includes(label)).reduce((sum, [, cost]) => sum + cost, 0);
    }
    if (selectedTask.mode === "duration-choice" || selectedTask.mode === "frequency-choice") {
      return (selectedTask.options || []).find(([label]) => label === values.durationChoice)?.[1] || 0;
    }
    if (selectedTask.mode === "music-subscribe") {
      return values.subscriberPlan === "Subscribe and turn on Notifications" ? 20 : values.subscriberPlan ? 10 : 0;
    }
    return selectedTask.unitCost || 0;
  }, [selectedTask, selectedReactions, selectedOptions, values.durationChoice, values.subscriberPlan]);

  const totalCost = useMemo(() => Number(quantity || 0) * unitCost, [quantity, unitCost]);

  const selectTask = (index) => {
    setSelectedTaskIndex(index);
    setSelectedReactions([]);
    setSelectedOptions([]);
    setValues((current) => ({ ...current, targetSurface: "Post", durationChoice: "", favouriteType: "", subscriberPlan: "", subscriberGender: "", commentAction: "", repostType: "" }));
    const nextUrl = new URL(window.location.href);
    nextUrl.searchParams.set("task", normalize(platform.tasks[index].label));
    window.history.replaceState({}, "", `${nextUrl.pathname}${nextUrl.search}`);
  };

  const copyCashback = async () => {
    try {
      await navigator.clipboard.writeText("https://nanoinfluencer.ng/ref/adaeze");
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1200);
    } catch {
      setCopied(false);
    }
  };

  const submit = (event) => {
    event.preventDefault();
    const draft = {
      platform: platform.slug,
      task: selectedTask.label,
      pageAbout,
      link,
      quantity,
      unitCost,
      totalCost,
      country,
      targetState,
      delivery,
      startDate,
      startTime,
      instruction,
      instructionFile,
      taskMedia,
      cashbackEvidence,
      selectedReactions,
      taskValues: values,
      privacyAccepted,
      termsAccepted,
    };
    sessionStorage.setItem("v2SocialTaskCampaignDraft", JSON.stringify(draft));
    const destination = query.get("payment") === "success" ? "/campaigns/subscription-success" : "/campaigns/insufficient-balance";
    window.location.assign(destination);
  };

  return (
    <main className="v2-stc-page">
      <div className="v2-stc-shell">
        <header className="v2-stc-backbar">
          <a href="/campaigns"><BackIcon /><span>Go Back</span></a>
          <div className="v2-stc-user"><span className="v2-stc-user-avatar">A</span><span className="v2-stc-user-copy"><strong>Adaeze O.</strong><small>Free Plan</small></span></div>
        </header>

        <header className="v2-stc-heading"><h1>{platform.title}</h1></header>

        <section className="v2-stc-task-panel">
          <div className={`v2-stc-task-grid cols-${platform.grid}`}>
            {platform.tasks.map((item, index) => <TaskCard key={item.label} item={item} active={index === selectedTaskIndex} onClick={() => selectTask(index)} />)}
          </div>
          <button className="v2-stc-how" type="button">Click this text to know how this service works</button>
        </section>

        <form className="v2-stc-fields" onSubmit={submit}>
          <TaskSpecificFields selectedTask={selectedTask} values={values} setValue={setValue} selectedReactions={selectedReactions} setSelectedReactions={setSelectedReactions} selectedOptions={selectedOptions} setSelectedOptions={setSelectedOptions} taskMedia={taskMedia} setTaskMedia={setTaskMedia} />

          <section className="v2-stc-panel">
            <div className="v2-stc-field"><FieldHeader title="What is your page/profile about" /><input className="v2-stc-input" value={pageAbout} onChange={(event) => setPageAbout(event.target.value)} placeholder="type here" maxLength={50} /><p className="v2-stc-meta">{pageAbout.length}/50</p></div>
            <div className="v2-stc-field"><FieldHeader title="Link" help="Ensure that you drop the correct link here." /><p className="v2-stc-inline-note">Drop the link to the post here.</p><input className="v2-stc-input" value={link} onChange={(event) => setLink(event.target.value)} placeholder={platform.linkPlaceholder} /></div>
            <div className="v2-stc-field"><FieldHeader title="Total Quantity" help="Total quantity based on the addition of all individual quantities." /><input className="v2-stc-input" type="number" min="0" value={quantity} onChange={(event) => setQuantity(event.target.value)} placeholder="0" /></div>
            <div className="v2-stc-field"><FieldHeader title="Cost" help="Total cost based on the addition of all individual costs." /><input className="v2-stc-input" value={money(totalCost)} readOnly /></div>
          </section>

          {selectedTask.instructions !== false && selectedTask.mode !== "report" && selectedTask.mode !== "special-media" ? (
            <section className="v2-stc-panel">
              <div className="v2-stc-instruction"><FieldHeader title="Any Instruction for the Nano-Influencer (Optional)" /><textarea className="v2-stc-textarea" value={instruction} onChange={(event) => setInstruction(event.target.value)} placeholder="Drop anything you like the nano-inflencer to know about this task" /></div>
              <div className="v2-stc-field"><FieldHeader title="Upload any image sample for the instruction." /><UploadBox fileName={instructionFile} onFile={setInstructionFile} /></div>
            </section>
          ) : null}

          <section className="v2-stc-panel">
            <div className="v2-stc-field"><FieldHeader title="Country of Target" help="Select the country or countries you want to get this service from." /><select className="v2-stc-select" value={country} onChange={(event) => setCountry(event.target.value)}><option value="">Select Country</option><option value="Nigeria">Nigeria</option></select></div>
            <div className="v2-stc-field"><FieldHeader title="State of Target" help="Select the State you want to get the engagement from. Note that this affects and reduces the maximum number of nano-influencers that would perform the task if you select fewer states." /><select className="v2-stc-select" value={targetState} onChange={(event) => setTargetState(event.target.value)}><option>All States</option><option>Lagos</option><option>FCT Abuja</option><option>Rivers</option><option>Ogun</option><option>Oyo</option></select></div>
          </section>

          <section className="v2-stc-panel">
            <div className="v2-stc-field"><FieldHeader title="How Fast do you want the job to be delivered. I want the job delivered in:" help={'Only apply if your order is time bound. Just Select "Default Time" if your campaign is not time bound.'} /><select className="v2-stc-select" value={delivery} onChange={(event) => setDelivery(event.target.value)}><option>Default Time</option><option>24 Hours</option><option>48 Hours</option><option>3 Days</option><option>7 Days</option></select></div>
            <div className="v2-stc-two">
              <div className="v2-stc-field"><FieldHeader title="Start Date" /><input className="v2-stc-input" value={startDate} onChange={(event) => setStartDate(event.target.value)} /></div>
              <div className="v2-stc-field"><FieldHeader title="Start time" /><input className="v2-stc-input" value={startTime} onChange={(event) => setStartTime(event.target.value)} /></div>
            </div>
            <p className="v2-stc-total-line">Total Cost (Cost × Delivery Speed) × 1 <strong>= {money(totalCost)}</strong></p>
          </section>

          <section className="v2-stc-panel">
            <div className="v2-stc-cashback">
              <div className="v2-stc-section-head"><h2>(Optional)</h2><p>Share the link and image below on your whatsapp status to get 1% cash back on your payment = {money(totalCost * 0.01)} money back.</p></div>
              <div className="v2-stc-cashback-actions">
                <button type="button" onClick={copyCashback}><i>↗</i><span>{copied ? "link copied" : "click on the icon\nto copy link"}</span></button>
                <button type="button"><i>↓</i><span>click on the icon to\ndownload image</span></button>
              </div>
            </div>
            <div className="v2-stc-upload-block"><h2>Upload the Evidence (Screen Shot) of Image and link shared on your whatsapp status</h2><UploadBox fileName={cashbackEvidence} onFile={setCashbackEvidence} /></div>
          </section>

          <section className="v2-stc-panel v2-stc-terms">
            <h2>Terms & Conditions</h2>
            <Consent checked={privacyAccepted} onChange={(event) => setPrivacyAccepted(event.target.checked)}>I have read and agreed to privacy policy for all tasks.</Consent>
            <Consent checked={termsAccepted} onChange={(event) => setTermsAccepted(event.target.checked)}>I have read and agreed to terms and condition.</Consent>
          </section>

          <button className="v2-stc-proceed" type="submit">Proceed</button>
        </form>
      </div>
    </main>
  );
}
