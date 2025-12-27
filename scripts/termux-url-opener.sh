#!/bin/bash

# Pega a URL compartilhada
URL=$1

# Verifica se tem URL
if [ -z "$URL" ]; then
    termux-toast "Nenhuma URL recebida!"
    exit 1
fi

# Cria pasta temporária
mkdir -p ~/storage/dcim/TermuxDownloads
cd ~/storage/dcim/TermuxDownloads

# Notifica início
termux-notification --title "yt-dlp" --content "Baixando: $URL"

# Executa o download (Configurado para melhor vídeo + melhor áudio)
# --no-mtime: usa a data de hoje, não a do upload do vídeo (bom pra galeria organizar)
yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b" --no-mtime -o "%(title)s.%(ext)s" "$URL"

# Checa o status de saída
if [ $? -eq 0 ]; then
    termux-notification --title "yt-dlp" --content "Download Concluído com Sucesso!"
    # Opcional: Escanear mídia para aparecer na galeria imediatamente
    termux-media-scan ./*.mp4
else
    termux-notification --title "yt-dlp" --content "Erro no Download." --priority high
fi
