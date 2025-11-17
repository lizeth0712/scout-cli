# Dockerfile mínimo para terminar el build y escanear con Scout
FROM alpine:3.18

# No instalamos nada -> evitamos fallos de APK/mirror
# Tampoco copiamos el contexto -> build rapidísimo
CMD ["sh", "-c", "echo Hello from scout-cli image"]
