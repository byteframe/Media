# oculus side-by-side-by-s
for FILE in *.mp4; do
  ffmpeg -i ${FILE} -i ${FILE} -filter_complex hstack -c:v libx264 _a_${FILE}
  ffmpeg -i _a_${FILE} -vf scale=1280:720 _b_${FILE}
  rm _a_${FILE};
done

# 2021 youtube playlist ripper bash blurb second version
PLAYLISTS=(
  "LINK" "ALBUM" "ARTIST"
)
for ((i = 0 ; i < ${#PLAYLISTS[@]} ; i+=3)); do
  mkdir -p /mnt/c/Users/byteframe/Desktop/"${PLAYLISTS[i+2]}"/"${PLAYLISTS[i+2]} ${PLAYLISTS[i+1]}"
  cd /mnt/c/Users/byteframe/Desktop/"${PLAYLISTS[i+2]}"/"${PLAYLISTS[i+2]} ${PLAYLISTS[i+1]}"
  youtube-dl --audio-format=mp3 -x "${PLAYLISTS[i]}"
  echo
  sleep 90
done

# 2021 youtube playlist ripper bash blurb first version
ARTIST="__XXX"
mkdir -p /mnt/c/Users/byteframe/Desktop/"${ARTIST}" ; cd /mnt/c/Users/byteframe/Desktop/"${ARTIST}"
ALBUMS=(
  "https://www.youtube.com/playlist?list=qwertyuiop1234567890" "Album Name"
)
for ((i = 0 ; i < ${#ALBUMS[@]} ; i+=2)); do
  mkdir -p "${ARTIST} ${ALBUMS[i+1]}" ; cd "${ARTIST} ${ALBUMS[i+1]}"
  youtube-dl --audio-format=mp3 -x "${ALBUMS[i]}"
  cd .. ; sleep 60
done

# merge mp3 files
cat ${FILES} > out.mp3

# dump mp3 stream
mplayer -dumpaudio -dumpfile "${FILE}.mp3" "${FILE}"

# extract audio stream as wav file and encode it to mp3
mplayer -ao pcm:fast:file="${FILE}".wav -vc dummy -vo null "${FILE}" \
 && lame -b${AB} "${FILE}".wav "${FILE}".mp3 && rm "${FILE}".wav

# flac to lame directory
AB=224
flac -d *
for FILE in *.wav; do lame -b ${AB} "${FILE}"; done
rm *.wav *.flac

# flac to lame find
AB=160
find . -name *.flac -exec flac -d {} \;
find . -name *.wav -exec lame -b ${AB} {} \;
find . -name *.wav -exec rm -v {} \;
find . -name *.flac -exec rm -v {} \;

# ffmpeg flac to mp3
for FILE in *.flac; do
  ffmpeg -i "${FILE}" -ab ${AB}k -map_metadata 0 -id3v2_version 3 "${FILE/flac/mp3}"
done

# increase mp3 volume
lame --scale 2 "${FILE}" "${FILE/.mp3/-MoreVolume.mp3}"

# merge like avi
mencoder -oac copy -ovc copy -forceidx -o out.avi ${FILES}

# merge like flv
mencoder -of lavf -oac copy -ovc copy -forceidx -o out.flv ${FILES}

# merge like mp4
AUDIO=copy
[ ! -z ${AAC} ] && AUDIO=mp3lame
mencoder -of lavf -oac ${AUDIO} -ovc copy -lavfopts format=mp4 -o out.mp4 ${FILES}

# convert audio stream from ac3 to mp3
A="-lameopts cbr:br=${AB}"
A="${A} -af volume=+${G}db"
mencoder -oac mp3lame -ovc copy ${A} -o "_${FILE}" "${FILE}"

# change aspect ratio in avi header
AR=1.778
mencoder -oac copy -ovc copy -force-avi-aspect ${AR} -o "_${FILE}" "${FILE}"

# fix sync
mencoder -oac mp3lame -ovc copy -forceidx -mc 0 -noskip -o .out.avi "${FILE}"

# insert subtitles
VB=1000
V="${V} -sub ${SRT}"
mencoder -oac copy -ovc lavc -lavcopts vpass=1:vbitrate=${VB} ${V} -forceidx -o /dev/null ${FILES}
mencoder -oac copy -ovc lavc -lavcopts vpass=2:vbitrate=${VB} ${V} -forceidx -o out.avi ${FILES}

# 2-pass mencode
IF_WMV="-ofps 23.976"
V="-vf crop=${W}:${H}:${X}:${Y}"
V="${V},aspect=${AR}"
V="${V},scale=${W}:${H}"
VB=1000
AB=112
A="-lameopts cbr:br=${AB}"
A="${A} -af volume=+${G}db"
mencoder ${IF_WMV} -oac mp3lame -ovc lavc -lavcopts vpass=1:vbitrate=${VB} ${V} ${A} -forceidx -o /dev/null "${FILE}"
mencoder ${IF_WMV} -oac mp3lame -ovc lavc -lavcopts vpass=2:vbitrate=${VB} ${V} ${A} -forceidx -o "new_${FILE##*/}" "${FILE}"

# duplicate file search with diff
for i in *; do
  for j in *; do
    diff $i $j > /dev/null
    if [ $? == "0" ]; then
      if [ "$i" != "$j" ]; then
        echo "$i,$j are duplicates";
      fi
    fi
  done
done
