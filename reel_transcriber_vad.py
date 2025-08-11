import os
import re
import yt_dlp
import datetime
import random
import time
import whisper
import cv2
import pytesseract

# ==== CONFIG ====
BASE_SAVE_DIR = os.path.join(os.path.expanduser("~"), "Documents", "Reel Transcriptions")
COOKIES_PATH = os.path.join(os.path.expanduser("~"), "Downloads", "cookies.txt")
MAX_URLS = 10

# Optional: specify Tesseract path if needed
# pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# ==== FUNCTIONS ====

def sanitize_filename(name):
    return re.sub(r'[\\/*?:"<>|]', "_", name)

def get_reel_id(url):
    match = re.search(r"reel/([^/?]+)", url)
    return match.group(1) if match else None

def get_reel_caption(url, cookies_path=None):
    """Extract Instagram Reel caption"""
    ydl_opts = {
        'quiet': True,
        'skip_download': True,
    }
    if cookies_path and os.path.exists(cookies_path):
        ydl_opts['cookiefile'] = cookies_path

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            info = ydl.extract_info(url, download=False)
            caption = info.get('description', "").strip()
            return caption if caption else "(No caption found)"
        except Exception as e:
            print(f"⚠ Could not get caption: {e}")
            return "(No caption found)"

def download_reel(url, save_path, cookies_path):
    """Download Reel video"""
    ydl_opts = {
        'outtmpl': save_path,
        'cookiefile': cookies_path,
        'quiet': True,
        'no_warnings': True
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])

def transcribe_audio(video_path):
    """Transcribe audio with Whisper"""
    model = whisper.load_model("base")
    result = model.transcribe(video_path)
    return result["text"]

def extract_ocr(video_path):
    """Extract on-screen text with OCR"""
    cap = cv2.VideoCapture(video_path)
    frame_count = 0
    ocr_results = []
    fps = cap.get(cv2.CAP_PROP_FPS)

    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if frame_count % int(fps) == 0:  # 1 FPS sampling
            text = pytesseract.image_to_string(frame)
            if text.strip():
                timestamp = frame_count / fps
                ocr_results.append(f"[{timestamp:.1f}s] {text.strip()}")
        frame_count += 1

    cap.release()
    return "\n".join(ocr_results)

def clean_text(text):
    """Clean OCR output"""
    text = re.sub(r"\s+", " ", text)
    return text.strip()

# ==== MAIN ====
if __name__ == "__main__":
    print("Running Reel Transcriber (Captions + OCR)...")
    urls = []
    print(f"Enter up to {MAX_URLS} Instagram Reel URLs (one per line). Blank line to start:")
    while len(urls) < MAX_URLS:
        line = input().strip()
        if not line:
            break
        urls.append(line)

    for idx, reel_url in enumerate(urls, start=1):
        reel_id = get_reel_id(reel_url)
        if not reel_id:
            print(f"❌ Invalid URL: {reel_url}")
            continue

        reel_dir = os.path.join(BASE_SAVE_DIR, reel_id)
        os.makedirs(reel_dir, exist_ok=True)
        video_path = os.path.join(reel_dir, f"{reel_id}.mp4")

        print(f"\n=== Processing Reel {idx} of {len(urls)} ===")
        print(f"[1/5] Downloading Reel {reel_id}...")
        try:
            download_reel(reel_url, video_path, COOKIES_PATH)
        except Exception as e:
            print(f"❌ Skipping {reel_id} due to download error: {e}")
            continue

        print(f"[2/5] Getting caption for {reel_id}...")
        caption_text = get_reel_caption(reel_url, COOKIES_PATH)

        print(f"[3/5] Transcribing audio for {reel_id}...")
        audio_text = transcribe_audio(video_path)

        print(f"[4/5] Extracting OCR text for {reel_id}...")
        ocr_text = extract_ocr(video_path)

        print(f"[5/5] Saving transcripts for {reel_id}...")
        raw_output = (
            f"=== REEL CAPTION ===\n{caption_text}\n\n"
            f"=== AUDIO TRANSCRIPT ===\n{audio_text}\n\n"
            f"=== ON-SCREEN TEXT (OCR) ===\n{ocr_text}"
        )
        clean_output = (
            f"=== REEL CAPTION ===\n{caption_text}\n\n"
            f"=== AUDIO TRANSCRIPT ===\n{audio_text}\n\n"
            f"=== ON-SCREEN TEXT (OCR - CLEAN) ===\n{clean_text(ocr_text)}"
        )

        with open(os.path.join(reel_dir, "transcript_raw.txt"), "w", encoding="utf-8") as f:
            f.write(raw_output)
        with open(os.path.join(reel_dir, "transcript_clean.txt"), "w", encoding="utf-8") as f:
            f.write(clean_output)

        print(f"✅ Finished {reel_id} — saved to {reel_dir}")
        time.sleep(random.uniform(1, 3))  # small delay
