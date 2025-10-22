#!/usr/bin/env bash
# lofi-service.sh - Player terminal que roda como "service" (mpv) e permite reabrir UI
# Comportamento:
# - PID: ~/.cache/lofi-player/mpv.pid
# - Arquivo atual: ~/.cache/lofi-player/current
# - Log: ~/.cache/lofi-player/lofi.log
#
# Dependências: mpv, ffprobe, dbus-send, gum, jq

set -u

# --- Cores / Ícones (Monokai Pro + Nerd Fonts) ---
BG="#2d2a2e"; FG="#fcfcfa"; RED="#ff6188"; GREEN="#a9dc76"; BLUE="#fc9867"; PURPLE="#ab9df2"; COMMENT="#727072"
ICON_PLAY=""; ICON_PLAY_PAUSE="/"; ICON_MUSIC=""; ICON_EXIT=""; ICON_ERROR=""; ICON_INFO=""

# --- Paths ---
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/lofi-player"
PID_FILE="$CACHE_DIR/mpv.pid"
CURRENT_FILE="$CACHE_DIR/current"
LOG_FILE="$CACHE_DIR/lofi.log"
mkdir -p "$CACHE_DIR"

# --- Utils ---
is_running() {
    local pid=$1
    if [ -z "$pid" ]; then return 1; fi
    if kill -0 "$pid" &>/dev/null;
 then
        return 0
    else
        return 1
    fi
}

check_deps() {
    local missing=0
    for cmd in mpv ffprobe dbus-send gum jq chafa ffmpeg; do
        if ! command -v "$cmd" &>/dev/null;
 then
            gum style --foreground "$RED" "$ICON_ERROR Erro: Dependência '$cmd' não encontrada." >&2
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        gum style --foreground "$COMMENT" "Instale as dependências e tente novamente." >&2
        exit 1
    fi
}

# Cria um arquivo de playlist com todas as músicas encontradas
create_playlist() {
    local playlist_file="$CACHE_DIR/playlist.m3u"
    find ~/Músicas -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.wav" \) > "$playlist_file"
    echo "$playlist_file"
}

# Extrai metadados do arquivo informado (title, album, artist)
get_metadata_for_file() {
    local file="$1"
    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo '{"title":"Título Desconhecido","album":"Álbum Desconhecido","artist":"Artista Desconhecido"}'
        return
    fi
    local meta
    meta=$(ffprobe -v quiet -print_format json -show_format "$file" 2>/dev/null) || meta=""
    if [ -z "$meta" ]; then
        echo '{"title":"Título Desconhecido","album":"Álbum Desconhecido","artist":"Artista Desconhecido"}'
        return
    fi
    local title album artist
    title=$(echo "$meta" | jq -r '.format.tags.title // empty')
    album=$(echo "$meta" | jq -r '.format.tags.album // empty')
    artist=$(echo "$meta" | jq -r '.format.tags.artist // empty')
    title=${title:-"Título Desconhecido"}
    album=${album:-"Álbum Desconhecido"}
    artist=${artist:-"Artista Desconhecido"}
    printf '{"title":"%s","album":"%s","artist":"%s"}' \
        "$(printf '%s' "$title" | sed 's/"/\\"/g')" \
        "$(printf '%s' "$album" | sed 's/"/\\"/g')" \
        "$(printf '%s' "$artist" | sed 's/"/\\"/g')"
}

# Inicia mpv em background com o arquivo dado. Salva PID e arquivo atual.
start_play() {
    local file="$1"
    local playlist_file="$2"
    if [ -z "$file" ] || [ ! -f "$file" ]; then
        gum style --foreground "$RED" "$ICON_ERROR Arquivo inválido: $file"
        return 1
    fi

    # Se mpv já estiver rodando, só manda Play e troca música via DBus
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if is_running "$pid"; then
            # Troca a música sem reiniciar o mpv
            dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.mpv \
                /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri \
                string:"file://$file" > /dev/null 2>&1
            printf '%s' "$file" > "$CURRENT_FILE"
            return 0
        fi
    fi

    # Se não tiver mpv rodando, inicia normalmente
    nohup mpv --idle --no-video --script="$HOME/.config/mpv/scripts/mpris.lua" --playlist="$playlist_file" --playlist-start=$(grep -nF "$file" "$playlist_file" | cut -d: -f1) --loop-playlist=inf "$file" &>> "$LOG_FILE" &
    local pid=$!
    echo "$pid" > "$PID_FILE"
    printf '%s' "$file" > "$CURRENT_FILE"
    sleep 0.25
    return 0
}


stop_service() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if is_running "$pid"; then
            # Tenta terminar suavemente
            kill "$pid" &>/dev/null || true
            sleep 0.2
            # Verifica se ainda tá rodando e força kill se necessário
            if is_running "$pid"; then
                kill -9 "$pid" &>/dev/null || true
                sleep 0.1
            fi
        fi
    fi
    rm -f "$PID_FILE" "$CURRENT_FILE"
    gum style --foreground "$COMMENT" "Service parado e arquivos de controle removidos."
}

# Mostra menu principal (anexa ao service se estiver rodando)
u_main() {
    # Cria a playlist
    local playlist_file
    playlist_file=$(create_playlist)

    # Carrega lista de músicas do diretório ~/Músicas (apenas 1º nível)
    mapfile -d '' songs < <(find ~/Músicas -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.wav" \) -print0)
    if [ ${#songs[@]} -eq 0 ]; then
        gum style --bold --foreground "$RED" "$ICON_ERROR Nenhum arquivo de áudio encontrado em '~/Músicas'."
        echo "$(gum style --foreground "$COMMENT" "Formatos suportados: .mp3, .flac, .ogg, .wav")"
        return 1
    fi
    song_names=()
    for s in "${songs[@]}"; do song_names+=("$(basename "$s")"); done

    while true; do
        clear
        # Estado do service
        local service_alive=false current_path current_meta title album artist pid_text
        if [ -f "$PID_FILE" ]; then
            local pid
            pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
            if is_running "$pid"; then
                service_alive=true
                pid_text="PID: $pid"
                if [ -f "$CURRENT_FILE" ]; then
                    current_path=$(cat "$CURRENT_FILE" 2>/dev/null || echo "")
                    current_meta=$(get_metadata_for_file "$current_path")
                    title=$(echo "$current_meta" | jq -r '.title')
                    album=$(echo "$current_meta" | jq -r '.album')
                    artist=$(echo "$current_meta" | jq -r '.artist')
                else
                    title="Título Desconhecido"
                    album="Álbum Desconhecido"
                    artist="Artista Desconhecido"
                fi
            else
                rm -f "$PID_FILE" "$CURRENT_FILE" 2>/dev/null || true
            fi
        fi

        if [ "$service_alive" = true ]; then
            # --- Custom UI with Album Art ---
            # 1. Prepare text info
            text_info_block=$(gum style --padding "1 2" \
                "$(gum style --bold --foreground "$BLUE" "$ICON_PLAY Tocando Agora")" \
                "" \
                "Título:  $(gum style --bold --foreground "$FG" "$title")" \
                "Álbum:   $(gum style --foreground "$GREEN" "$album")" \
                "Artista: $(gum style --foreground "$PURPLE" "$artist")" \
                "" \
                "$(gum style --foreground "$COMMENT" "$pid_text")")

            # 2. Prepare image art
            local cover_art=""
            if [ -n "$current_path" ] && [ -f "$current_path" ]; then
                tmp_cover_file="$CACHE_DIR/cover_art.jpg"
                # Extract cover art using ffmpeg, supressing output
                ffmpeg -i "$current_path" -an -vcodec copy "$tmp_cover_file" -y &> /dev/null
                if [ -s "$tmp_cover_file" ]; then
                    # Render with chafa if the file is not empty
                    cover_art=$(chafa --size 20x20 "$tmp_cover_file" 2>/dev/null)
                    rm "$tmp_cover_file"
                fi
            fi

            # If no cover art, use a placeholder
            if [ -z "$cover_art" ]; then
                cover_art=$(gum style --width 30 --height 30 --border none --align center --vertical-align middle "$ICON_MUSIC")
            fi

            # 3. Join image and text
            combined_view=$(gum join "$cover_art" "$text_info_block")

            # 4. Display inside a single box
            gum style --border rounded --margin "1 2" --padding "0" --border-foreground "$COMMENT" "$combined_view"

            action=$(gum choose --no-show-help --header "Opções:" --item.foreground "$FG" --item.background "$BG" --selected.foreground "$FG" --selected.background "$BLUE" --header.foreground "$COMMENT" --header.background "$BG" --cursor.foreground="$BLUE"  \
                "$ICON_PLAY_PAUSE Pause/Play" \
                "$ICON_MUSIC Selecionar outra música" \
                " Parar service (encerrar player)" \
                "$ICON_EXIT Sair pacificamente")
            case "$action" in
                "$ICON_PLAY_PAUSE Pause/Play")
                    # enviar PlayPause via dbus
                    dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.mpv \
                      /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause > /dev/null 2>&1 || \
                      gum style --foreground "$RED" "$ICON_ERROR Falha ao enviar PlayPause"
                    ;; 
                "$ICON_MUSIC Selecionar outra música")
                    # escolhe nova música do diretório
                    chosen=$(gum choose --header "Selecione outra música:" --no-show-help --item.foreground "$FG" --item.background "$BG" --selected.foreground "$FG" --selected.background "$BLUE" --header.foreground "$COMMENT" --header.background "$BG" --cursor.foreground="$BLUE" "${song_names[@]}" "$ICON_EXIT Cancelar")
                    if [ -z "$chosen" ] || [[ "$chosen" == "$ICON_EXIT Cancelar" ]]; then
                        continue
                    fi
                    # resolve caminho
                    selected_path=""
                    for i in "${!song_names[@]}"; do
                        if [[ "${song_names[$i]}" == "$chosen" ]]; then
                            selected_path="${songs[$i]}"
                            break
                        fi
done
                    if [ -z "$selected_path" ]; then
                        gum style --foreground "$RED" "$ICON_ERROR Arquivo não encontrado."
                        continue
                    fi
                    gum style --foreground "$COMMENT" "Trocando para: $chosen"
                    start_play "$selected_path" "$playlist_file"
                    ;; 
                " Parar service (encerrar player)")
                    gum confirm --no-show-help --prompt.foreground "$FG" --prompt.background "$BG" --selected.foreground "$FG" --selected.background "$BLUE" --unselected.foreground "$FG" --unselected.background "$BG" "Tem certeza que quer encerrar o service e parar a música?" || continue
                    stop_service
                    gum style --foreground "$GREEN" "Service encerrado."
                    return 0
                    ;; 
                "$ICON_EXIT Sair pacificamente")
                    # Fecha só a UI; não mata o mpv
                    gum style --foreground "$COMMENT" "Fechando UI sem parar a música..."
                    return 0
                    ;; 
                *) # ctrl+c ou cancel
                    gum style --foreground "$COMMENT" "Fechando UI..."
                    return 0
                    ;; 
            esac
        else
            # Sem service rodando: escolher música para iniciar
            chosen_song_name=$(gum choose --no-show-help --header "Escolha uma música:" --item.foreground "$FG" --item.background "$BG" --selected.foreground "$FG" --selected.background "$BLUE" --header.foreground "$COMMENT" --header.background "$BG" --cursor.foreground="$BLUE" "${song_names[@]}" "$ICON_EXIT Sair")
            if [[ "$chosen_song_name" == "$ICON_EXIT Sair" ]] || [[ -z "$chosen_song_name" ]]; then
                gum style --foreground "$COMMENT" "Nada feito. Tchau~"
                return 0
            fi
            # Encontrar o caminho completo do arquivo da música escolhida
            chosen_song_file=""
            for i in "${!song_names[@]}"; do
                if [[ "${song_names[$i]}" == "$chosen_song_name" ]]; then
                    chosen_song_file="${songs[$i]}"
                    break
                fi
            done
            if [ -z "$chosen_song_file" ]; then
                gum style --foreground "$RED" "$ICON_ERROR Arquivo não encontrado."
                continue
            fi
            gum style --foreground "$COMMENT" "Iniciando reprodução: $chosen_song_name"
            start_play "$chosen_song_file" "$playlist_file"
            # volta ao topo do loop para mostrar UI anexada
            continue
        fi
    done
}

# --- Execução ---
check_deps
u_main
exit 0
