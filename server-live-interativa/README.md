# server-live-interativa

Este diretório descreve a integração da live TikTok com o servidor open.mp/SAMP.

## Arquivos relevantes

- `../gamemodes/main.pwn`: callbacks e polling da bridge HTTP (`RequestsClient` + `RequestJSON`).
- `../tiktok_bot/tiktok.js`: bridge local que recebe chat/presentes do TikTok e expõe `/events`.

## Fluxo

1. `tiktok.js` coleta eventos do TikTok (`chat` e `gift`) e coloca numa fila local.
2. `main.pwn` cria `RequestsClient("http://127.0.0.1:3001")`.
3. `main.pwn` chama `/health` e, depois, faz polling em `/events` a cada 1s.
4. Cada evento recebido é impresso no console do servidor:
   - `[ TIKTOK CHAT ] ...`
   - `[ TIKTOK GIFT ] ...`

## Teste rápido (sem live real)

```bash
TIKTOK_MOCK=1 node tiktok_bot/tiktok.js
```

No servidor open.mp, ao iniciar o gamemode, os eventos mock devem aparecer no console.
