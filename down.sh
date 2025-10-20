#!/bin/bash

# Este script baixa o áudio (MP3) de um vídeo do YouTube usando yt-dlp.

# 1. Verifica se o yt-dlp está instalado
if ! command -v yt-dlp &> /dev/null
then
    echo "Erro: yt-dlp não foi encontrado. Por favor, instale-o para usar este script."
    echo "Você pode instalá-lo com 'pip install yt-dlp' ou via seu gerenciador de pacotes."
    exit 1
fi

# 2. Solicita o link do YouTube ao usuário
echo "--- Baixador de MP3 do YouTube (via yt-dlp) ---"
read -p "Por favor, cole o link do vídeo do YouTube e pressione [ENTER]: " YOUTUBE_URL

# 3. Verifica se o link foi fornecido
if [ -z "$YOUTUBE_URL" ]; then
    echo "Nenhum link fornecido. Saindo."
    exit 1
fi

# 4. Executa o yt-dlp com as opções para baixar apenas o áudio e converter para mp3
echo ""
echo "Iniciando o download do MP3..."
echo "O arquivo será salvo nesta pasta."

# Opções do yt-dlp:
# -x ou --extract-audio: Extrai a faixa de áudio.
# --audio-format mp3: Converte o áudio extraído para o formato MP3.
# -o "%(title)s.%(ext)s": Define o template de saída para usar o título do vídeo.
yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" "$YOUTUBE_URL"

# 5. Verifica o status de saída do comando
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Download do MP3 concluído com sucesso!"
else
    echo ""
    echo "❌ Ocorreu um erro durante o download. Verifique o link e a conexão."
fi

exit 0

