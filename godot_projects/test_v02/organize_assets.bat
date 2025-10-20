@echo off
echo ========================================
echo   ORGANIZACAO DE ASSETS
echo ========================================
echo.
echo AVISO: Execute este script APENAS se o Godot estiver FECHADO!
echo O Godot vai precisar re-importar os assets depois.
echo.
pause

echo.
echo Organizando sprites de personagens...

:: Player sprites
if exist "art\Liron*.png" (
    move "art\Liron*.png" "art\characters\player\" 2>nul
    echo   [OK] Sprites do Liron movidos
)

:: Enemy sprites
if exist "art\black_wolf_32x32_spritesheet.png" (
    move "art\black_wolf_32x32_spritesheet.png" "art\characters\enemies\" 2>nul
    echo   [OK] Sprite do wolf movido
)

echo.
echo Organizando sprites de armas...

if exist "art\arco*.png" (
    move "art\arco*.png" "art\weapons\" 2>nul
    echo   [OK] Sprites de arco movidos
)

if exist "art\flecha.png" (
    move "art\flecha.png" "art\weapons\" 2>nul
    echo   [OK] Sprite da flecha movido
)

if exist "art\lanca.png" (
    move "art\lanca.png" "art\weapons\" 2>nul
    echo   [OK] Sprite da lanca movido
)

echo.
echo Organizando sprites de ambiente...

if exist "art\Arvore.png" (
    move "art\Arvore.png" "art\environment\" 2>nul
    echo   [OK] Sprite da arvore movido
)

if exist "art\mesa.png" (
    move "art\mesa.png" "art\environment\" 2>nul
    echo   [OK] Sprite da mesa movido
)

echo.
echo Organizando sprites de UI...

if exist "art\moeda_game1.png" (
    move "art\moeda_game1.png" "art\ui\" 2>nul
    echo   [OK] Sprite de moeda movido
)

echo.
echo Movendo arquivos de desenvolvimento...

if exist "art\*.aseprite" (
    move "art\*.aseprite" "dev\aseprite\" 2>nul
    echo   [OK] Arquivos .aseprite movidos
)

if exist "art\Captura*.png" (
    move "art\Captura*.png" "dev\screenshots\" 2>nul
    echo   [OK] Screenshots movidos
)

if exist "art\ChatGPT*.png" (
    move "art\ChatGPT*.png" "dev\screenshots\" 2>nul
    echo   [OK] Imagens do ChatGPT movidas
)

if exist "art\Sprite-*.png" (
    move "art\Sprite-*.png" "dev\screenshots\" 2>nul
    echo   [OK] Sprites temporarios movidos
)

if exist "art\pixil-frame-*.png" (
    move "art\pixil-frame-*.png" "dev\screenshots\" 2>nul
    echo   [OK] Frames do Pixil movidos
)

echo.
echo ========================================
echo   ORGANIZACAO CONCLUIDA!
echo ========================================
echo.
echo IMPORTANTE:
echo   1. Abra o Godot
echo   2. O Godot vai re-importar os arquivos
echo   3. Verifique se as referencias estao corretas
echo   4. Se algo quebrou, desfaca o commit do Git
echo.
pause
