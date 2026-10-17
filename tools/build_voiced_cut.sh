#!/bin/bash
set -e
cd /home/user/Cartoon
SC=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad
SEG=$SC/seg
VO=$SC/vo
L=art/brand/prepped/certuvo_logo_t.png
enc=(-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p)

echo "[1/2] montage + watermark + score(ducked) + Urdu VO -> 16:9 (no captions)"
ffmpeg -y -loglevel error \
 -i "$SEG/montage.mp4" \
 -ss 66 -t 27 -i audio/certuvo_score.mp3 \
 -i "$VO/l1.mp3" -i "$VO/l2.mp3" -i "$VO/l3.mp3" -i "$VO/l4.mp3" -i "$VO/l5.mp3" \
 -i "$L" \
 -filter_complex \
"[7:v]scale=150:-1,format=rgba,colorchannelmixer=aa=0.92[wm];\
[0:v][wm]overlay=44:36[v];\
[1:a]volume=0.42,afade=t=in:st=0:d=0.6,afade=t=out:st=25.6:d=1.4[mus];\
[2:a]adelay=2500|2500,volume=1.6[a1];\
[3:a]adelay=7000|7000,volume=1.6[a2];\
[4:a]adelay=13000|13000,volume=1.6[a3];\
[5:a]adelay=18800|18800,volume=1.7[a4];\
[6:a]adelay=23000|23000,volume=1.7[a5];\
[mus][a1][a2][a3][a4][a5]amix=inputs=6:duration=first:normalize=0,alimiter=limit=0.95[a]" \
 -map "[v]" -map "[a]" -t 27 "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_voiced_16x9.mp4

echo "[2/2] 9:16 vertical"
ffmpeg -y -loglevel error -i renders/certuvo_voiced_16x9.mp4 -filter_complex \
"[0:v]scale=1080:1920,boxblur=26:4[bg];[0:v]scale=1080:-1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1[v]" \
 -map "[v]" -map 0:a "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_voiced_9x16.mp4

echo DONE
for f in renders/certuvo_voiced_16x9.mp4 renders/certuvo_voiced_9x16.mp4; do
  echo "$f dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$f") size=$(du -h "$f"|cut -f1)"
done