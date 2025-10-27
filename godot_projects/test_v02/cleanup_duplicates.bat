@echo off
echo ========================================
echo   LIMPEZA DE ARQUIVOS DUPLICADOS
echo ========================================
echo.
echo Este script vai DELETAR os seguintes arquivos da raiz:
echo   - bow.tscn
echo   - enemy.tscn
echo   - entidades.tscn
echo   - projectile.tscn
echo   - main_menu.tscn
echo   - game_over.tscn
echo.
echo As versoes corretas estao em scenes/
echo.
pause

echo.
echo Deletando arquivos duplicados...

if exist "bow.tscn" (
    del "bow.tscn"
    echo   [OK] bow.tscn removido
) else (
    echo   [SKIP] bow.tscn nao encontrado
)

if exist "enemy.tscn" (
    del "enemy.tscn"
    echo   [OK] enemy.tscn removido
) else (
    echo   [SKIP] enemy.tscn nao encontrado
)

if exist "entidades.tscn" (
    del "entidades.tscn"
    echo   [OK] entidades.tscn removido
) else (
    echo   [SKIP] entidades.tscn nao encontrado
)

if exist "projectile.tscn" (
    del "projectile.tscn"
    echo   [OK] projectile.tscn removido
) else (
    echo   [SKIP] projectile.tscn nao encontrado
)

if exist "main_menu.tscn" (
    del "main_menu.tscn"
    echo   [OK] main_menu.tscn removido
) else (
    echo   [SKIP] main_menu.tscn nao encontrado
)

if exist "game_over.tscn" (
    del "game_over.tscn"
    echo   [OK] game_over.tscn removido
) else (
    echo   [SKIP] game_over.tscn nao encontrado
)

echo.
echo ========================================
echo   LIMPEZA CONCLUIDA!
echo ========================================
echo.
echo Proximos passos:
echo   1. Abra o Godot
echo   2. O Godot pode pedir para recarregar arquivos
echo   3. Verifique se tudo funciona normalmente
echo.
pause
