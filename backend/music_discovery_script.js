/**
 * Maza Pandurang - YouTube Bhakti Music Discovery Script
 * 
 * This script is used as a backend/admin tool to fetch devotional content
 * using the YouTube Data API and save it to a local cache (or Supabase).
 * 
 * IMPORTANT: This runs SERVER-SIDE. Do not execute YouTube searches
 * directly from the Flutter client to conserve quota.
 */

require('dotenv').config();
const axios = require('axios');
const fs = require('fs');

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;
if (!YOUTUBE_API_KEY) {
  console.log("Mock Mode: No YOUTUBE_API_KEY provided. Generating mock curated catalogue.");
  // Fall back to generating the mock JSON for Flutter testing.
}

// Exactly matching the requested Categories
const CATEGORIES = {
  VITTHAL_BHAJANS: "Vitthal Bhajans",
  ABHANG: "Abhang",
  WARI_SONGS: "Wari Songs",
  AARTI: "Aarti",
  PANDURANG: "Pandurang"
};

// Mapped search queries per category
const SEARCH_QUERIES = {
  VITTHAL_BHAJANS: "Vitthal Bhajan Marathi",
  ABHANG: "Vitthal Abhang Marathi",
  WARI_SONGS: "Pandharpur Wari Geet",
  AARTI: "Vitthal Aarti Marathi",
  PANDURANG: "Pandurang Bhajan Marathi"
};

/**
 * Perform a real YouTube API search.
 */
async function searchYouTube(query) {
  try {
    const response = await axios.get('https://www.googleapis.com/youtube/v3/search', {
      params: {
        part: 'snippet',
        q: query,
        type: 'video',
        videoEmbeddable: 'true',
        relevanceLanguage: 'mr',
        maxResults: 5,
        key: YOUTUBE_API_KEY
      }
    });
    
    return response.data.items.map(item => ({
      id: `YTB-${item.id.videoId}`,
      youtubeVideoId: item.id.videoId,
      title: item.snippet.title,
      thumbnailUrl: item.snippet.thumbnails.high.url,
      channelTitle: item.snippet.channelTitle,
      approved: true
    }));
  } catch (error) {
    console.error("YouTube API Error:", error.message);
    return [];
  }
}

/**
 * Generate Hackathon fallback curated data when API key is not present.
 */
function getMockCuratedData() {
  const curated = [];
  let index = 1;
  for (const [key, name] of Object.entries(CATEGORIES)) {
    for (let i = 1; i <= 5; i++) {
      curated.push({
        id: `DEMO-${index}`,
        youtubeVideoId: 'u433z_C74-k', // Valid fallback embeddable video ID (e.g., standard Abhang)
        category: key,
        title: `${name} - Curated Demo Track ${i}`,
        thumbnailUrl: `https://img.youtube.com/vi/u433z_C74-k/hqdefault.jpg`,
        channelTitle: `Bhakti Demo Channel`,
        approved: true
      });
      index++;
    }
  }
  return curated;
}

async function discoverAndSeed() {
  console.log("Starting YouTube Bhakti Music Discovery...");
  
  let catalogue = [];
  
  if (YOUTUBE_API_KEY && YOUTUBE_API_KEY !== 'your_youtube_api_key_here') {
    for (const [key, query] of Object.entries(SEARCH_QUERIES)) {
      console.log(`[YouTube Discovery] category=${key} query="${query}"`);
      const results = await searchYouTube(query);
      results.forEach(r => {
        r.category = key;
        catalogue.push(r);
      });
    }
  } else {
    catalogue = getMockCuratedData();
  }

  // 1. Output to local JSON for Flutter Mock Repository (MVP hackathon flow)
  fs.writeFileSync('approved_music_catalogue.json', JSON.stringify(catalogue, null, 2));
  console.log(`Saved ${catalogue.length} approved videos to approved_music_catalogue.json`);

  // 2. Here you would normally push to Supabase:
  // const { data, error } = await supabase.from('music_videos').upsert(catalogue, { onConflict: 'youtubeVideoId' });
  // console.log("Supabase seed complete.");
}

discoverAndSeed();
