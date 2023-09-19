#!/bin/bash
if [ "$(basename ${PWD})" != "assets" ]; then
    echo "Must run from within 'assets' sub-folder"
    exit 1
fi

for arch in standard scale-out hub-spoke enterprise iiot; do
    cast_file="${arch}-compose-up.cast"
    gif_file="${cast_file%.*}.gif"
    if [ -f "${cast_file}" ] || [ -f "${gif_file}" ]; then
        echo "files exist for $arch, skipping"
        continue
    fi
    pushd "../${arch}"
    export INDIRECT_CMD="docker-compose up -d"
    asciinema rec -i 2.0 -e SHELL,TERM,INDIRECT_CMD -c "PS1='\e[1;36m\w\e[m> ' bash --init-file ../assets/compose-up-env.sh" "../assets/${cast_file}"
    docker-compose down -v
    popd
    cast_lines="$(asciinema play ${cast_file} | wc -l)"
    asciicast2gif -S 2 -h $((cast_lines+2)) "${cast_file}" "${gif_file}"
done

