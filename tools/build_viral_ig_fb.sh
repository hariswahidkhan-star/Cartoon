#!/bin/bash
set -e
cd /home/user/Cartoon
SC=/tmp/claude-0/-home-user-Cartoon/e3326a14-7063-5cb6-9560-0116c1e549d3/scratchpad
R=renders/certuvo
NORM=$SC/norm
VO=$SC/viral_vo
TX=$SC/viral_txt
SG=$SC/viral_seg
mkdir -p "$VO" "$TX" "$SG"
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf
enc=(-c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p)

echo "[A] English VO"
python3 -I - "$VO" <<'PY'
import sys
from gtts import gTTS
sp=sys.argv[1]
L=[("v1","Studying hard, and still failing? Here is why."),
   ("v2","Most prep drills you on questions that aren't even on your exam."),
   ("v3","Certuvo screens every question through four judges. Fail one, and you never see it."),
   ("v4","Eleven certifications, one platform, with an A.I. coach and thousands of peers."),
   ("v5","Certuvo dot com. Start free.")]
for n,t in L:
    gTTS(t,lang="en",tld="com").save(f"{sp}/{n}.mp3"); print("saved",n)
PY

echo "[B] vertical badge grid (2x4)"
montage "$SC/tiles/cpa.png" "$SC/tiles/cma.png" "$SC/tiles/cia.png" "$SC/tiles/cfa.png" \
        "$SC/tiles/pmp.png" "$SC/tiles/cisa.png" "$SC/tiles/pci.png" "$SC/tiles/nclex.png" \
        -tile 2x4 -geometry +16+16 -background none "$SC/grid_v.png"
identify "$SC/grid_v.png"

# text files (multiline)
printf 'Studying hard —\nstill failing?\n' > "$TX/1.txt"
printf 'Most prep drills you on\nquestions not even on\nyour real exam.\n' > "$TX/2.txt"
printf 'Certuvo screens every\nquestion through 4 judges\n' > "$TX/3.txt"
printf 'ACCURACY · BLUEPRINT\nRELEVANCE · EXAM-LEVEL\n' > "$TX/4.txt"
printf 'Fail one judge →\nyou never see it.\n' > "$TX/5.txt"
printf '11 certifications.\nOne platform.\n' > "$TX/6.txt"
printf '+ AI coach\n+ thousands of peers\n' > "$TX/7.txt"
printf 'certuvo.com\nStart free\n' > "$TX/8.txt"

# seg: src ss dur txt fontsize yexpr outidx
vseg(){ # $1src $2ss $3dur $4txt $5fs $6y $7out
ffmpeg -y -loglevel error -ss "$2" -i "$1" -t "$3" -filter_complex \
"[0:v]scale=-2:1920,crop=1080:1920,fps=30,setsar=1[bg];\
[bg]drawtext=textfile=$4:fontfile=$FONT:fontsize=$5:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=30:line_spacing=12:x=(w-text_w)/2:y=$6[v]" \
-map "[v]" -an "${enc[@]}" "$7"; }

echo "[C] build segments"
vseg "$R/c00_hook.mp4"     0.0 2.6 "$TX/1.txt" 100 "h*0.40" "$SG/1.mp4"
vseg "$R/c09_arena.mp4"    1.0 3.0 "$TX/2.txt" 70  "h*0.60" "$SG/2.mp4"
vseg "$R/c04_judges.mp4"   0.6 2.6 "$TX/3.txt" 72  "h*0.62" "$SG/3.mp4"
vseg "$R/c05_accuracy.mp4" 0.8 2.8 "$TX/4.txt" 60  "h*0.62" "$SG/4.mp4"
vseg "$R/c06_relevance.mp4" 1.0 2.4 "$TX/5.txt" 84 "h*0.60" "$SG/5.mp4"
# seg6 with badge grid
ffmpeg -y -loglevel error -ss 0.5 -i "$R/c03_eleven.mp4" -t 3.8 -i "$SC/grid_v.png" -filter_complex \
"[0:v]scale=-2:1920,crop=1080:1920,fps=30,setsar=1[bg];\
[1:v]scale=520:-1[g];[bg][g]overlay=(W-w)/2:250[bg2];\
[bg2]drawtext=textfile=$TX/6.txt:fontfile=$FONT:fontsize=72:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=26:line_spacing=12:x=(w-text_w)/2:y=h*0.84[v]" \
-map "[v]" -an "${enc[@]}" "$SG/6.mp4"
vseg "$R/c08_peers.mp4"    0.6 3.0 "$TX/7.txt" 76  "h*0.62" "$SG/7.mp4"
# seg8 CTA from branded champion (has logo reveal)
vseg "$NORM/s12.mp4"       2.0 4.2 "$TX/8.txt" 92  "h*0.72" "$SG/8.mp4"

echo "[D] concat"
list="$SG/list.txt"; : > "$list"
for i in 1 2 3 4 5 6 7 8; do echo "file '$SG/$i.mp4'" >> "$list"; done
ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$SG/montage.mp4"
DUR=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$SG/montage.mp4")
echo "montage dur=$DUR"

echo "[E] music + VO -> final"
ffmpeg -y -loglevel error -i "$SG/montage.mp4" \
 -ss 66 -t "$DUR" -i audio/certuvo_score.mp3 \
 -i "$VO/v1.mp3" -i "$VO/v2.mp3" -i "$VO/v3.mp3" -i "$VO/v4.mp3" -i "$VO/v5.mp3" \
 -filter_complex \
"[1:a]volume=0.4,afade=t=in:st=0:d=0.5,afade=t=out:st=$(python3 -c "print(max(0,float('$DUR')-1.4))"):d=1.4[mus];\
[2:a]adelay=100|100,volume=1.7[a1];\
[3:a]adelay=2700|2700,volume=1.7[a2];\
[4:a]adelay=6300|6300,volume=1.7[a3];\
[5:a]adelay=13300|13300,volume=1.7[a4];\
[6:a]adelay=20700|20700,volume=1.8[a5];\
[mus][a1][a2][a3][a4][a5]amix=inputs=6:duration=first:normalize=0,alimiter=limit=0.95[a]" \
 -map 0:v -map "[a]" -t "$DUR" "${enc[@]}" -c:a aac -b:a 192k renders/certuvo_viral_9x16.mp4

echo DONE
echo "final dur=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 renders/certuvo_viral_9x16.mp4) size=$(du -h renders/certuvo_viral_9x16.mp4|cut -f1)"