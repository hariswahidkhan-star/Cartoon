#!/bin/bash
set -e
cd /home/user/Cartoon
SP=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad
SEG=$SP/tseg; mkdir -p "$SEG"
BG=$SP/bg_dark.png
BB=$SP/bg_blue.png
LW=$SP/logo_white.png
OFF=$SP/off_badge.png
DEF=$SP/defect.png
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf
enc=(-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30)
W=0xFFFFFF; BLU=0x4D9FFF; YEL=0xFFD24D; RED=0xFF6B6B
[ -f "$LW" ] || convert art/brand/prepped/certuvo_logo_t.png -channel RGB -fill white -colorize 100 "$LW"
[ -f "$OFF" ] || convert -background none -fill '#FFD24D' -font "$FONT" -pointsize 230 label:'70%% OFF' "$OFF"
convert -background none -fill '#4D9FFF' -font "$FONT" -pointsize 76 label:'< 0.1%% defect rate' "$DEF"

dt(){ echo "drawtext=fontfile=$FONT:text='$1':fontcolor=$2:fontsize=$3:x=(w-text_w)/2:y=$4"; }
# card bg-only text clip: $1 dur  $2 drawchain  $3 out
card(){ ffmpeg -y -loglevel error -loop 1 -t "$1" -i "$BG" -filter_complex "[0:v]$2,fade=in:st=0:d=0.12[v]" -map "[v]" "${enc[@]}" "$3"; }

echo building cards
card 3.9 "$(dt 'Nobody warns you' $W 94 760),$(dt 'about certification' $W 70 900),$(dt 'exams.' $W 70 1000)" "$SEG/1.mp4"
card 4.2 "$(dt 'Study 500 hours.' $W 92 820),$(dt 'Still fail.' $RED 124 970)" "$SEG/2.mp4"
card 3.7 "$(dt 'Most prep drills the' $W 70 780),$(dt 'WRONG questions.' $YEL 90 900)" "$SEG/3.mp4"
card 5.3 "$(dt 'Certuvo is different.' $BLU 86 680),$(dt 'Every question faces' $W 68 850),$(dt 'a 4-JUDGE panel.' $W 84 960)" "$SEG/4.mp4"
# c5 with defect png
ffmpeg -y -loglevel error -loop 1 -t 7.9 -i "$BG" -loop 1 -t 7.9 -i "$DEF" -filter_complex \
"[0:v]$(dt 'Accurate. On-blueprint.' $W 62 700),$(dt 'Relevant. Exam-level.' $W 62 800)[a];[1:v]scale=820:-1[d];[a][d]overlay=(W-w)/2:960,fade=in:st=0:d=0.12[v]" \
-map "[v]" "${enc[@]}" "$SEG/5.mp4"
card 5.8 "$(dt 'An AI tutor inside' $W 74 700),$(dt 'every question.' $BLU 78 820),$(dt 'Study live with peers.' $W 68 990)" "$SEG/6.mp4"
card 3.9 "$(dt '11 certifications.' $W 96 800),$(dt 'One platform.' $BLU 90 950)" "$SEG/7.mp4"
# c8 with logo
ffmpeg -y -loglevel error -loop 1 -t 2.9 -i "$BG" -loop 1 -t 2.9 -i "$LW" -filter_complex \
"[1:v]scale=360:-1[lg];[0:v][lg]overlay=(W-w)/2:430[b];[b]$(dt 'Pass smarter.' $W 100 820),$(dt 'Not harder.' $BLU 100 970),fade=in:st=0:d=0.12[v]" \
-map "[v]" "${enc[@]}" "$SEG/8.mp4"
# c9 CTA blue
ffmpeg -y -loglevel error -loop 1 -t 5.3 -i "$BB" -loop 1 -t 5.3 -i "$LW" -loop 1 -t 5.3 -i "$OFF" -filter_complex \
"[1:v]scale=440:-1[lg];[0:v][lg]overlay=(W-w)/2:330[b];[2:v]scale=760:-1[o];[b][o]overlay=(W-w)/2:840[b2];[b2]$(dt 'Founding members get' white 64 740),$(dt 'certuvo.com' white 90 1180),fade=in:st=0:d=0.2[v]" \
-map "[v]" "${enc[@]}" "$SEG/9.mp4"

echo concat
list="$SEG/list.txt"; : > "$list"; for i in 1 2 3 4 5 6 7 8 9; do echo "file '$SEG/$i.mp4'" >> "$list"; done
ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$SEG/montage.mp4"
DUR=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$SEG/montage.mp4"); echo "montage=$DUR"

echo mux
VO=$SP/tvo
ffmpeg -y -loglevel error -i "$SEG/montage.mp4" -ss 0 -t "$DUR" -i audio/certuvo_score.mp3 \
 -i "$VO/t1.mp3" -i "$VO/t2.mp3" -i "$VO/t3.mp3" -i "$VO/t4.mp3" -i "$VO/t5.mp3" -i "$VO/t6.mp3" -i "$VO/t7.mp3" -i "$VO/t8.mp3" -i "$VO/t9.mp3" \
 -filter_complex \
"[1:a]volume=0.32,afade=t=in:st=0:d=0.6,afade=t=out:st=$(python3 -c "print(max(0,float('$DUR')-1.5))"):d=1.5[mus];\
[2:a]adelay=200|200,volume=1.5[a1];[3:a]adelay=4100|4100,volume=1.5[a2];[4:a]adelay=8300|8300,volume=1.5[a3];\
[5:a]adelay=12000|12000,volume=1.5[a4];[6:a]adelay=17300|17300,volume=1.5[a5];[7:a]adelay=25200|25200,volume=1.5[a6];\
[8:a]adelay=31000|31000,volume=1.5[a7];[9:a]adelay=34900|34900,volume=1.55[a8];[10:a]adelay=37800|37800,volume=1.55[a9];\
[mus][a1][a2][a3][a4][a5][a6][a7][a8][a9]amix=inputs=10:duration=first:normalize=0,alimiter=limit=0.95[a]" \
 -map 0:v -map "[a]" -t "$DUR" "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_truths_9x16.mp4
echo "DONE dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 renders/certuvo_truths_9x16.mp4) size=$(du -h renders/certuvo_truths_9x16.mp4|cut -f1)"