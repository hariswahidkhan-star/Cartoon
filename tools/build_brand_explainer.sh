#!/bin/bash
set -e
cd /home/user/Cartoon
SP=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad
SEG=$SP/bseg; mkdir -p "$SEG"
BL=$SP/bg_light.png
BB=$SP/bg_blue.png
LOGO=art/brand/prepped/certuvo_logo_t.png
LW=$SP/logo_white.png
G4=art/brand/certuvo_4judges.png
GC=art/brand/certuvo_course_lineup.png
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf
enc=(-c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -r 30)
NAVY=0x0B1E3F; BLUE=0x2F6BFF; YEL=0xFFD24D

# white logo for blue CTA
convert "$LOGO" -channel RGB -fill white -colorize 100 "$LW"
# "70% OFF" badge (ImageMagick handles % cleanly)
OFF=$SP/off_badge.png
convert -background none -fill '#FFD24D' -font "$FONT" -pointsize 230 label:'70%% OFF' "$OFF"

dt(){ echo "drawtext=fontfile=$FONT:text='$1':fontcolor=$2:fontsize=$3:x=(w-text_w)/2:y=$4"; }

echo "[S1] hook"
ffmpeg -y -loglevel error -loop 1 -t 3.0 -i "$BL" -loop 1 -t 3.0 -i "$LOGO" -filter_complex \
"[1:v]scale=360:-1[lg];[0:v][lg]overlay=(W-w)/2:150[b];\
[b]$(dt 'Pass smarter.' $NAVY 104 820),$(dt 'Not harder.' $BLUE 104 960),fade=in:st=0:d=0.5[v]" \
-map "[v]" "${enc[@]}" "$SEG/1.mp4"

echo "[S2] 4-judge panel (your graphic, static card)"
ffmpeg -y -loglevel error -loop 1 -t 10.2 -i "$BL" -loop 1 -t 10.2 -i "$G4" -filter_complex \
"[1:v]scale=1040:-1[g];[0:v][g]overlay=(W-w)/2:(H-h)/2,fade=in:st=0:d=0.5[v]" \
-map "[v]" "${enc[@]}" "$SEG/2.mp4"

echo "[S3] AI coach"
ffmpeg -y -loglevel error -loop 1 -t 5.4 -i "$BL" -loop 1 -t 5.4 -i "$LOGO" -filter_complex \
"[1:v]scale=360:-1[lg];[0:v][lg]overlay=(W-w)/2:150[b];\
[b]$(dt 'A private tutor' $NAVY 82 720),$(dt 'by chat or voice' $BLUE 82 835),$(dt 'inside every question.' $NAVY 72 980),$(dt 'AI COACH' $BLUE 44 1120),fade=in:st=0:d=0.5[v]" \
-map "[v]" "${enc[@]}" "$SEG/3.mp4"

echo "[S4] peers"
ffmpeg -y -loglevel error -loop 1 -t 4.0 -i "$BL" -loop 1 -t 4.0 -i "$LOGO" -filter_complex \
"[1:v]scale=360:-1[lg];[0:v][lg]overlay=(W-w)/2:150[b];\
[b]$(dt 'Study live with' $NAVY 86 780),$(dt 'your peers.' $NAVY 86 895),$(dt 'Win together.' $BLUE 92 1055),fade=in:st=0:d=0.5[v]" \
-map "[v]" "${enc[@]}" "$SEG/4.mp4"

echo "[S5] scope (course graphic, static card)"
ffmpeg -y -loglevel error -loop 1 -t 7.4 -i "$BL" -loop 1 -t 7.4 -i "$GC" -filter_complex \
"[1:v]scale=1040:-1[g];[0:v][g]overlay=(W-w)/2:(H-h)/2-50[c];\
[c]$(dt '1,200+ real exam simulations' $BLUE 52 1748),fade=in:st=0:d=0.5[v]" \
-map "[v]" "${enc[@]}" "$SEG/5.mp4"

echo "[S6] CTA (blue)"
ffmpeg -y -loglevel error -loop 1 -t 5.3 -i "$BB" -loop 1 -t 5.3 -i "$LW" -loop 1 -t 5.3 -i "$OFF" -filter_complex \
"[1:v]scale=460:-1[lg];[0:v][lg]overlay=(W-w)/2:330[b];\
[2:v]scale=780:-1[off];[b][off]overlay=(W-w)/2:840[b2];\
[b2]$(dt 'Founding members get' white 66 730),$(dt 'certuvo.com' white 92 1180),fade=in:st=0:d=0.5[v]" \
-map "[v]" "${enc[@]}" "$SEG/6.mp4"

echo "[concat]"
list="$SEG/list.txt"; : > "$list"
for i in 1 2 3 4 5 6; do echo "file '$SEG/$i.mp4'" >> "$list"; done
ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$SEG/montage.mp4"
echo "montage dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$SEG/montage.mp4")"