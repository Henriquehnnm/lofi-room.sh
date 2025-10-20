#!/bin/bash

# Script interativo para modificar metadados de arquivos MP3 usando ffmpeg.

# Verifica se o ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "Erro: ffmpeg não está instalado."
    echo "Instale-o usando: sudo apt-get install ffmpeg (Debian/Ubuntu)"
    exit 1
fi

# Pergunta o caminho do arquivo MP3
read -p "Digite o caminho para o arquivo MP3: " ARQUIVO_MP3

# Verifica se o arquivo MP3 existe
if [ ! -f "$ARQUIVO_MP3" ]; then
    echo "Erro: O arquivo MP3 '''$ARQUIVO_MP3''' não foi encontrado."
    exit 1
fi

# Pergunta os novos metadados
read -p "Digite o novo título da música: " TITULO
read -p "Digite o nome do artista: " ARTISTA
read -p "Digite o nome do álbum: " ALBUM
read -p "Digite o caminho para a imagem de capa: " IMAGEM_CAPA

# Verifica se o arquivo de imagem existe
if [ -n "$IMAGEM_CAPA" ] && [ ! -f "$IMAGEM_CAPA" ]; then
    echo "Erro: O arquivo de imagem '''$IMAGEM_CAPA''' não foi encontrado."
    exit 1
fi

# Define um nome de arquivo temporário
ARQUIVO_TEMP="temp_$(basename "$ARQUIVO_MP3")"

# Constrói o comando do ffmpeg em um array para lidar com espaços e caracteres especiais
cmd=("ffmpeg" "-i" "$ARQUIVO_MP3")

if [ -n "$IMAGEM_CAPA" ]; then
    cmd+=("-i" "$IMAGEM_CAPA" "-map" "0:a" "-map" "1" "-c:a" "copy" "-c:v" "copy")
else
    cmd+=("-c:a" "copy")
fi

# Adiciona os metadados se fornecidos
if [ -n "$TITULO" ]; then
    cmd+=("-metadata" "title=$TITULO")
fi
if [ -n "$ARTISTA" ]; then
    cmd+=("-metadata" "artist=$ARTISTA")
fi
if [ -n "$ALBUM" ]; then
    cmd+=("-metadata" "album=$ALBUM")
fi

# Adiciona as opções de saída
cmd+=("-id3v2_version" "3" "-y" "$ARQUIVO_TEMP")

# Modifica os metadados e a capa do arquivo MP3
echo "Modificando metadados de: $ARQUIVO_MP3"
"${cmd[@]}"

# Verifica se o ffmpeg executou com sucesso
if [ $? -eq 0 ]; then
    # Substitui o arquivo original pelo arquivo modificado
    mv "$ARQUIVO_TEMP" "$ARQUIVO_MP3"
    echo "Metadados atualizados com sucesso!"
else
    echo "Erro ao modificar os metadados do MP3."
    # Remove o arquivo temporário em caso de erro
    rm -f "$ARQUIVO_TEMP"
    exit 1
fi