#!/bin/sh

# startup
MSD_SIZE=16
SRC=/mnt/Datavault/Audio
if [ ! -d "${SRC}" ]; then
  echo "fatal: source directory not found"
  exit 1
fi
if [ -z "${1}" ] || [ -z "${2}" ]; then
  echo "fatal: missing input"
  exit 1
fi
mkdir -p "${1}"/.temp "${2}"/Playlists || exit 1
rm -f "${2}"/Playlists/*
mv "${1}"/* "${1}"/.temp 2> /dev/null

# process each top level item in the source directory
for TOP in "${SRC}"/*; do
  TOP="$(basename "${TOP}")"

  # mv/cp only artist playlists and tracks for 32 and below (with unsorted rsync)
  if [ ${MSD_SIZE} = 16 ] || [ ${MSD_SIZE} = 32 ]; then
    if [ "${TOP}" = Unsorted ]; then
      if [ -d "${1}"/.temp/"${TOP}" ]; then
        mv "${1}"/.temp/"${TOP}" "${1}"
      fi
      rsync --delete -ruv "${SRC}"/"${TOP}"/ "${1}"/"${TOP}"/  
    elif [ -e "${SRC}"/"${TOP}"/"${TOP}".m3u ]; then
      cat "${SRC}"/"${TOP}"/"${TOP}".m3u | while read MP3; do
        if [ ! "${MP3:0:1}" = "#" ]; then
          DIR=$(dirname "${MP3}")
          mkdir -p "${1}"/"${TOP}"/"${DIR}"
          if [ -e "${1}"/.temp/"${TOP}"/"${MP3}" ]; then
            mv "${1}"/.temp/"${TOP}"/"${MP3}" "${1}"/"${TOP}"/"${DIR}"
          else
            cp -v "${SRC}"/"${TOP}"/"${MP3}" "${1}"/"${TOP}"/"${DIR}" || exit 1
          fi
        fi
      done
      cat "${SRC}"/"${TOP}"/"${TOP}".m3u | sed -e "s/\.\//\//" \
        > "${1}"/"${TOP}"/"${TOP}".m3u
      continue
    fi

  # skip non-artist directory for less than 128
  elif [ ${MSD_SIZE} = 64 ] && [[ GameSpeechSoundtrack = *${TOP}* ]]; then
    continue

  # mv/rsync whole directory for 64/128
  else
    if [ -e "${SRC}"/"${TOP}"/"${TOP}".m3u ]; then
      cat "${SRC}"/"${TOP}"/"${TOP}".m3u | sed -e '/#EXT/d' -e "s/\.\//\//" \
        -e "s/^/\/<microSD1>\/${TOP}\//" > "${2}"/Playlists/"${TOP}".m3u
    fi
    if [ -d "${1}"/.temp/"${TOP}" ]; then
      mv "${1}"/.temp/"${TOP}" "${1}"
    fi
    rsync --delete -ruv "${SRC}"/"${TOP}"/ "${1}"/"${TOP}"/
  fi
done

# clean and create master playlist
find "${1}"/.temp -name *.mp3 -printf "%f\n"
rm -fr "${1}"/.temp
find "${1}" -type f -name "*.mp3" -printf "/<microSD1>/%P\n" | sort -R \
  > "${2}"/Playlists/4.m3u
