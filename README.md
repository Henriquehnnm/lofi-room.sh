<div align="center" style="background-color: #1a1b26; color: #c0caf5; font-family: monospace; padding: 2rem;">

<h1 style="color: #7aa2f7; font-size: 3rem; font-weight: bold; text-shadow: 0 0 10px #7aa2f7;">
  lofi-room.sh
</h1>

<p style="color: #bb9af7; font-size: 1.2rem;">
  seu cantinho lofi no terminal
</p>

<br>

---

<p style="color: #c0caf5;">
  um mini estúdio para criar e curtir sua própria coleção de lofi, diretamente do seu terminal.
</p>
<p style="color: #c0caf5;">
  baixe do youtube, organize suas faixas e mergulhe na vibe.
</p>

---

<br>

<h2 style="color: #9ece6a;">✨ screenshots ✨</h2>

<p style="color: #565f89;">(coloque aqui um gif ou imagem do seu player rodando)</p>

<pre style="background-color: #24283b; border: 1px solid #565f89; border-radius: 5px; padding: 1rem; text-align: left; display: inline-block; font-size: 12px;">
<span style="color: #7aa2f7;">┌──────────────────────────────────────────────────┐</span>
<span style="color: #7aa2f7;">│</span>                                                  <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">│</span>   <span style="color: #bb9af7;">🎵 Tocando Agora...</span>                           <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">│</span>                                                  <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">│</span>   <span style="color: #c0caf5;">Título:</span>  <span style="color: #ff9e64;">lofi hip hop radio</span>                  <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">│</span>   <span style="color: #c0caf5;">Artista:</span> <span style="color: #9ece6a;">Lofi Girl</span>                         <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">│</span>   <span style="color: #c0caf5;">Álbum:</span>   <span style="color: #7dcfff;">beats to relax/study to</span>           <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">│</span>                                                  <span style="color: #7aa2f7;">│</span>
<span style="color: #7aa2f7;">└──────────────────────────────────────────────────┘</span>
</pre>

<br>
<br>

<h2 style="color: #9ece6a;">🚀 funcionalidades</h2>

<div style="display: flex; justify-content: center; gap: 1rem; flex-wrap: wrap;">
  <div style="background-color: #24283b; border: 1px solid #565f89; border-radius: 5px; padding: 1rem; width: 200px;">
    <h3 style="color: #7aa2f7;">down.sh</h3>
    <p style="color: #c0caf5;">Baixe áudios de vídeos do YouTube em formato MP3.</p>
  </div>
  <div style="background-color: #24283b; border: 1px solid #565f89; border-radius: 5px; padding: 1rem; width: 200px;">
    <h3 style="color: #bb9af7;">edit-mp3.sh</h3>
    <p style="color: #c0caf5;">Edite os metadados (título, artista, álbum) e adicione uma capa.</p>
  </div>
  <div style="background-color: #24283b; border: 1px solid #565f89; border-radius: 5px; padding: 1rem; width: 200px;">
    <h3 style="color: #9ece6a;">lofi.sh</h3>
    <p style="color: #c0caf5;">Player com UI no terminal, exibindo capa e informações da faixa.</p>
  </div>
</div>

<br>

<h2 style="color: #9ece6a;">💿 como usar</h2>

<ol style="text-align: left; display: inline-block; color: #c0caf5;">
  <li>Clone este repositório.</li>
  <li>Instale as dependências listadas abaixo.</li>
  <li>Coloque seus arquivos de áudio em <code>~/Músicas</code>.</li>
  <li>Execute <code>./lofi.sh</code> para iniciar a vibe.</li>
</ol>

<br>
<br>

<details>
  <summary style="color: #7aa2f7; cursor: pointer;">
    <span style="font-size: 1.1rem;">🔧 dependências</span>
  </summary>
  <ul style="text-align: left; list-style-type: '➤ '; color: #c0caf5; padding-left: 2rem;">
    <li><code>mpv</code> (o player de áudio)</li>
    <li><code>yt-dlp</code> (para baixar do YouTube)</li>
    <li><code>ffmpeg</code> (para edição de metadados e extração de capa)</li>
    <li><code>gum</code> (para a interface no terminal)</li>
    <li><code>chafa</code> (para exibir a arte do álbum no terminal)</li>
    <li><code>jq</code> (para processar dados JSON dos metadados)</li>
    <li><code>dbus-send</code> (para controlar o player)</li>
  </ul>
</details>

<br>
<br>

<p style="color: #565f89;">feito com <span style="color: #f7768e;">♥</span> no terminal</p>

</div>
