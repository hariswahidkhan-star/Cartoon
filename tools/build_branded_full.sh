#!/bin/bash
set -e
cd /home/user/Cartoon
L=art/brand/prepped/certuvo_logo_t.png
O=renders/certuvo
T=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad/norm
mkdir -p "$T"
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf
enc=(-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30)
aud=(-c:a aac -ar 44100 -ac 2 -b:a 192k)

echo "[1/5] branded champion (logo reveal)"
ffmpeg -y -loglevel error -loop 1 -i "$L" -i "$O/c12_champion.mp4" -filter_complex \
"[0:v]scale=640:-1,format=rgba,fade=in:st=3.6:d=0.9:alpha=1[lg];[1:v][lg]overlay=(W-w)/2:(H-h)/2-50:shortest=1[v]" \
-map "[v]" -map 1:a "${enc[@]}" "${aud[@]}" "$T/s12.mp4"

echo "[2/5] title card"
ffmpeg -y -loglevel error -f lavfi -i color=c=0x0a0e1a:s=1920x1080:r=30 -loop 1 -i "$L" \
-f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -filter_complex \
"[1:v]scale=820:-1[lg];[0:v][lg]overlay=(W-w)/2:250[v1];\
[v1]drawtext=fontfile=$FONT:text='Eleven certifications. One way to prepare.':fontcolor=white:fontsize=50:x=(w-text_w)/2:y=720[v2];\
[v2]drawtext=fontfile=$FONT:text='certuvo.com':fontcolor=0x2F6BFF:fontsize=66:x=(w-text_w)/2:y=800[v3];\
[v3]drawtext=fontfile=$FONT:text='Launching 01.09.2026':fontcolor=0xBBBBBB:fontsize=42:x=(w-text_w)/2:y=900,fade=in:st=0:d=0.6,fade=out:st=5.3:d=0.7[vo]" \
-map "[vo]" -map 2:a -t 6 "${enc[@]}" "${aud[@]}" "$T/s17.mp4"

echo "[3/5] normalize scene clips"
norm(){ ffmpeg -y -loglevel error -i "$1" -vf "scale=1920:1080,fps=30,format=yuv420p" "${enc[@]}" "${aud[@]}" "$2"; }
order=(c00_hook c01_entrance c02_reveal c03_eleven c04_judges c05_accuracy c06_relevance c07_coach c08_peers c09_arena c10_pass c11_global __S12__ c13_companion c14_future c16_cta __S17__)
list="$T/list.txt"; : > "$list"; i=0
for name in "${order[@]}"; do
  out="$T/n$(printf %02d $i).mp4"
  if [ "$name" = "__S12__" ]; then cp "$T/s12.mp4" "$out";
  elif [ "$name" = "__S17__" ]; then cp "$T/s17.mp4" "$out";
  else norm "$O/$name.mp4" "$out"; fi
  echo "file '$out'" >> "$list"; i=$((i+1))
done

echo "[4/5] concat + watermark -> branded cut"
ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$T/branded_nowm.mp4"
ffmpeg -y -loglevel error -i "$T/branded_nowm.mp4" -i "$L" -filter_complex \
"[1:v]scale=150:-1,format=rgba,colorchannelmixer=aa=0.9[wm];[0:v][wm]overlay=44:40[v]" \
-map "[v]" -map 0:a "${enc[@]}" "${aud[@]}" "$O/../certuvo_storm_branded_16x9.mp4"

echo "[5/5] 9:16 vertical"
ffmpeg -y -loglevel error -i "$O/../certuvo_storm_branded_16x9.mp4" -filter_complex \
"[0:v]scale=1080:1920,boxblur=24:4[bg];[0:v]scale=1080:-1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2[v]" \
-map "[v]" -map 0:a "${enc[@]}" "${aud[@]}" "$O/../certuvo_storm_branded_9x16.mp4"

echo "DONE"
ls -la renders/certuvo_storm_branded_16x9.mp4 renders/certuvo_storm_branded_9x16.mp4
for f in renders/certuvo_storm_branded_16x9.mp4 renders/certuvo_storm_branded_9x16.mp4; do
  echo "$f dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$f")"
done