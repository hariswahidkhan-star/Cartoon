#!/bin/bash
set -e
cd /home/user/Cartoon
N=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad/norm
S=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad/seg
mkdir -p "$S"
L=art/brand/prepped/certuvo_logo_t.png
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf
enc=(-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p)

# segment: src ss dur -> out   (video only, uniform)
seg(){ ffmpeg -y -loglevel error -ss "$2" -i "$1" -t "$3" -vf "fps=30,scale=1920:1080,setsar=1" -an "${enc[@]}" "$4"; }

echo "[1/4] trim segments"
seg "$N/n00.mp4" 0.0 3.0 "$S/0.mp4"      # hook
seg "$N/n01.mp4" 0.8 4.5 "$S/1.mp4"      # entrance
seg "$N/n04.mp4" 0.6 5.0 "$S/2.mp4"      # 4 judges
seg "$N/n03.mp4" 0.5 4.0 "$S/3.mp4"      # 11 certs
seg "$N/n08.mp4" 0.6 3.0 "$S/4.mp4"      # peers
seg "$N/n12.mp4" 1.5 6.5 "$S/5.mp4"      # branded champion (logo reveal)
seg "$N/n16.mp4" 0.4 4.0 "$S/6.mp4"      # title card

echo "[2/4] crossfade montage"
ffmpeg -y -loglevel error -i "$S/0.mp4" -i "$S/1.mp4" -i "$S/2.mp4" -i "$S/3.mp4" -i "$S/4.mp4" -i "$S/5.mp4" -i "$S/6.mp4" -filter_complex \
"[0][1]xfade=transition=fade:duration=0.5:offset=2.5[a];\
[a][2]xfade=transition=fade:duration=0.5:offset=6.5[b];\
[b][3]xfade=transition=fade:duration=0.5:offset=11.0[c];\
[c][4]xfade=transition=fade:duration=0.5:offset=14.5[d];\
[d][5]xfade=transition=dissolve:duration=0.6:offset=17.0[e];\
[e][6]xfade=transition=fade:duration=0.6:offset=23.0[v]" \
-map "[v]" "${enc[@]}" "$S/montage.mp4"

echo "[3/4] captions + watermark + score -> 16:9"
ffmpeg -y -loglevel error -i "$S/montage.mp4" -ss 66 -t 27 -i audio/certuvo_score.mp3 -i "$L" -filter_complex \
"[2:v]scale=150:-1,format=rgba,colorchannelmixer=aa=0.92[wm];\
[0:v][wm]overlay=44:36[bg];\
[bg]drawtext=fontfile=$FONT:text='4 JUDGES. 1 PASS.':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=h-180:shadowcolor=black@0.7:shadowx=3:shadowy=3:enable='between(t,7.3,10.6)'[t1];\
[t1]drawtext=fontfile=$FONT:text='ELEVEN CERTIFICATIONS. ONE WAY TO PREPARE.':fontcolor=white:fontsize=52:x=(w-text_w)/2:y=h-170:shadowcolor=black@0.7:shadowx=3:shadowy=3:enable='between(t,11.4,14.5)'[vv];\
[1:a]afade=t=in:st=0:d=0.8,afade=t=out:st=25.6:d=1.4,volume=1.0[aa]" \
-map "[vv]" -map "[aa]" -t 27 "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_tight_16x9.mp4

echo "[4/4] 9:16 vertical"
ffmpeg -y -loglevel error -i renders/certuvo_tight_16x9.mp4 -filter_complex \
"[0:v]scale=1080:1920,boxblur=26:4[bg];[0:v]scale=1080:-1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1[v]" \
-map "[v]" -map 0:a "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_tight_9x16.mp4

echo DONE
for f in renders/certuvo_tight_16x9.mp4 renders/certuvo_tight_9x16.mp4; do
  echo "$f  dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$f")  size=$(du -h "$f" | cut -f1)"
done