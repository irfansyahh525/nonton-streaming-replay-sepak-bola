function playHlsVideo(videoId, url) {
    const video = document.getElementById(videoId);

    if (video.canPlayType('application/vnd.apple.mpegurl')) {
        // Native support (Safari)
        video.src = url;
    } else if (Hls.isSupported()) {
        const hls = new Hls();
        hls.loadSource(url);
        hls.attachMedia(video);
    }
}
