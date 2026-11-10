# Neo Kurumin Lab v0.1

Pacote único (Windows e Linux) que cria uma VM VirtualBox "Neo Kurumin" e transforma o Kubuntu 26.04 no Neo Kurumin.

## Decisões
- Base: **Kubuntu 26.04 LTS**, porque o Mint não tem edição KDE.
- Visual moderno: Breeze Dark, cores NeoKurumin, painel flutuante centralizado com o botão NK (script Plasma em layout/painel-moderno.js).
- Ícones Mágicos v0.1: app PyQt6 em /opt/neo-kurumin/icones-magicos. Categorias: Programas (Flathub), Windows (Wine + Bottles), Jogos (Steam, Heroic, Lutris, GameMode), Android (Waydroid), Drivers, Multimídia, Brasil, Sistema. Cada ação roda num terminal Konsole.

## Como funciona a VM
- INSTALAR-WINDOWS.bat → windows/criar-vm.ps1 (winget instala a VirtualBox). No Linux: instalar-linux.sh (apt).
- Baixa a ISO mais nova do Kubuntu 26.04 em cdimage.ubuntu.com/kubuntu/releases/26.04/release/ e confere o SHA256.
- VM: EFI, VMSVGA com 3D, 4/6/8 GB de RAM conforme o PC, metade dos núcleos, disco de 60 GB.
- O pacote vai como um segundo DVD (rótulo NEOKURUMIN). Comando dentro da VM: `udisksctl mount -b /dev/disk/by-label/NEOKURUMIN; bash /media/$USER/NEOKURUMIN/instalar.sh`
- Rodar o criador de novo remove o DVD do Kubuntu depois da instalação.

## Ainda não testado num PC de verdade
- Ícones de flatpak não instalados mostram o NK como substituto.
