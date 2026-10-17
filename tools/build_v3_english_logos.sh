#!/bin/bash
set -e
cd /home/user/Cartoon
SC=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad
SEG=$SC/seg
VO=$SC/voen
BR=art/brand
L=$BR/prepped/certuvo_logo_t.png
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf
enc=(-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p)
mkdir -p "$VO" "$SC/tiles"

echo "[A] English VO"
python3 -I - "$VO" <<'PY'
import sys
from gtts import gTTS
sp=sys.argv[1]
lines=[
 ("l1","Eleven certifications. One way to prepare."),
 ("l2","Every question faces four judges before it ever reaches you."),
 ("l3","Your own A.I. coach, and thousands of peers, every step of the way."),
 ("l4","One name that gets you through."),
 ("l5","Certuvo. certuvo dot com."),
]
for n,t in lines:
    gTTS(t, lang="en", tld="com").save(f"{sp}/{n}.mp3")
    print("saved",n)
PY

echo "[B] certification badge grid"
tile(){ convert "$BR/$1" -resize 190x190 -background white -alpha remove -alpha off -gravity center -extent 236x236 "$SC/tiles/$2.png"; }
tile cert_cpa_mark.jpg cpa
tile cert_cma.png cma
tile cert_cia.jpg cia
tile cert_cfa.png cfa
tile cert_pmp.png pmp
tile cert_cisa.png cisa
tile cert_pci.jpg pci
tile cert_nclex.png nclex
montage "$SC/tiles/cpa.png" "$SC/tiles/cma.png" "$SC/tiles/cia.png" "$SC/tiles/cfa.png" \
        "$SC/tiles/pmp.png" "$SC/tiles/cisa.png" "$SC/tiles/pci.png" "$SC/tiles/nclex.png" \
        -tile 4x2 -geometry +18+18 -background none "$SC/grid.png"
identify "$SC/grid.png"

echo "[C] title card (NO launch date)"
ffmpeg -y -loglevel error -f lavfi -i color=c=0x0a0e1a:s=1920x1080:r=30 -loop 1 -i "$L" -filter_complex \
"[1:v]scale=860:-1[lg];[0:v][lg]overlay=(W-w)/2:330[v1];\
[v1]drawtext=fontfile=$FONT:text='Eleven certifications. One way to prepare.':fontcolor=white:fontsize=52:x=(w-text_w)/2:y=780[v2];\
[v2]drawtext=fontfile=$FONT:text='certuvo.com':fontcolor=0x2F6BFF:fontsize=70:x=(w-text_w)/2:y=870,fade=in:st=0:d=0.5,fade=out:st=3.4:d=0.6[v]" \
-map "[v]" -t 4 "${enc[@]}" -an "$SEG/6.mp4"

echo "[D] rebuild crossfade montage (new title)"
ffmpeg -y -loglevel error -i "$SEG/0.mp4" -i "$SEG/1.mp4" -i "$SEG/2.mp4" -i "$SEG/3.mp4" -i "$SEG/4.mp4" -i "$SEG/5.mp4" -i "$SEG/6.mp4" -filter_complex \
"[0][1]xfade=transition=fade:duration=0.5:offset=2.5[a];\
[a][2]xfade=transition=fade:duration=0.5:offset=6.5[b];\
[b][3]xfade=transition=fade:duration=0.5:offset=11.0[c];\
[c][4]xfade=transition=fade:duration=0.5:offset=14.5[d];\
[d][5]xfade=transition=dissolve:duration=0.6:offset=17.0[e];\
[e][6]xfade=transition=fade:duration=0.6:offset=23.0[v]" \
-map "[v]" "${enc[@]}" "$SEG/montage3.mp4"

echo "[E] final: badge grid + watermark + English VO + score -> 16:9"
ffmpeg -y -loglevel error \
 -i "$SEG/montage3.mp4" \
 -ss 66 -t 27 -i audio/certuvo_score.mp3 \
 -i "$VO/l1.mp3" -i "$VO/l2.mp3" -i "$VO/l3.mp3" -i "$VO/l4.mp3" -i "$VO/l5.mp3" \
 -i "$L" -loop 1 -i "$SC/grid.png" \
 -filter_complex \
"[7:v]scale=150:-1,format=rgba,colorchannelmixer=aa=0.92[wm];\
[0:v][wm]overlay=44:36[bg];\
[8:v]scale=1480:-1,format=rgba,fade=in:st=11.1:d=0.4:alpha=1,fade=out:st=14.4:d=0.5:alpha=1[grid];\
[bg][grid]overlay=(W-w)/2:(H-h)/2:enable='between(t,11.1,14.9)'[v];\
[1:a]volume=0.42,afade=t=in:st=0:d=0.6,afade=t=out:st=25.6:d=1.4[mus];\
[2:a]adelay=2500|2500,volume=1.6[a1];\
[3:a]adelay=7000|7000,volume=1.6[a2];\
[4:a]adelay=13000|13000,volume=1.6[a3];\
[5:a]adelay=18800|18800,volume=1.7[a4];\
[6:a]adelay=23000|23000,volume=1.7[a5];\
[mus][a1][a2][a3][a4][a5]amix=inputs=6:duration=first:normalize=0,alimiter=limit=0.95[a]" \
 -map "[v]" -map "[a]" -t 27 "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_v3_16x9.mp4

echo "[F] 9:16 vertical"
ffmpeg -y -loglevel error -i renders/certuvo_v3_16x9.mp4 -filter_complex \
"[0:v]scale=1080:1920,boxblur=26:4[bg];[0:v]scale=1080:-1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1[v]" \
 -map "[v]" -map 0:a "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_v3_9x16.mp4

echo DONE
for f in renders/certuvo_v3_16x9.mp4 renders/certuvo_v3_9x16.mp4; do
  echo "$f dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$f") size=$(du -h "$f"|cut -f1)"
done