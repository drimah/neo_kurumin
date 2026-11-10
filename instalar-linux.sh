#!/usr/bin/env bash
# ============================================================
#  NEO KURUMIN LAB v0.1 - cria a máquina virtual no Linux Mint
#  Uso:  bash instalar-linux.sh
# ============================================================
set -u
VM="Neo Kurumin"
BASE="$HOME/NeoKurumin-Lab"
DIR="$(cd "$(dirname "$0")" && pwd)"
PACOTE="$DIR/pacote/neo-kurumin-pacote.iso"

verde(){ printf '\n\e[1;32m%s\e[0m\n' "$*"; }
ok(){ printf '  \e[32m✔\e[0m %s\n' "$*"; }
aviso(){ printf '  \e[33m!\e[0m %s\n' "$*"; }
erro(){ printf '\n\e[1;31m✖ %s\e[0m\n' "$*"; exit 1; }

[ "$(id -u)" = "0" ] && erro "Rode SEM sudo:  bash instalar-linux.sh"
mkdir -p "$BASE"
printf '\e[1;32m==============================================\n       NEO KURUMIN LAB v0.1 - Linux\n==============================================\e[0m\n'

# ---------- 1. VirtualBox ----------
verde "[1/4] VirtualBox"
if ! command -v VBoxManage >/dev/null; then
  echo "  Instalando a VirtualBox. Digite sua senha:"
  sudo apt update && sudo apt install -y virtualbox || erro "Não consegui instalar a VirtualBox."
  if command -v mokutil >/dev/null && mokutil --sb-state 2>/dev/null | grep -qi enabled; then
    aviso "Seu PC usa Secure Boot: se aparecer uma tela azul (MOK) ao reiniciar, escolha 'Enroll MOK' e digite a senha que você criou."
  fi
fi
command -v VBoxManage >/dev/null || erro "A VirtualBox não foi instalada."
ok "VirtualBox $(VBoxManage --version)"

# ---------- se a VM já existe ----------
if VBoxManage showvminfo "$VM" >/dev/null 2>&1; then
  verde "A máquina \"$VM\" já existe."
  read -rp "  Você já terminou de instalar o Kubuntu nela? (S/n) " r
  if [ "${r,,}" != "n" ]; then
    VBoxManage storageattach "$VM" --storagectl SATA --port 1 --device 0 --type dvddrive --medium emptydrive >/dev/null 2>&1
    ok "DVD do Kubuntu removido (agora ela liga direto no sistema instalado)"
  fi
  VBoxManage storageattach "$VM" --storagectl SATA --port 2 --device 0 --type dvddrive --medium "$PACOTE" >/dev/null 2>&1
  VBoxManage startvm "$VM" --type gui >/dev/null && ok "Máquina ligada!"
  exit 0
fi

# ---------- 2. Baixar o Kubuntu 26.04 ----------
verde "[2/4] Kubuntu 26.04 LTS (base do Neo Kurumin)"
NOME=""; URL=""
for u in https://cdimage.ubuntu.com/kubuntu/releases/26.04/release/ \
         https://cdimage.ubuntu.com/kubuntu/releases/resolute/release/; do
  NOME=$(curl -fsSL "$u" 2>/dev/null | grep -oE 'kubuntu-26\.04(\.[0-9]+)?-desktop-amd64\.iso' | sort -uV | tail -1)
  [ -n "$NOME" ] && { URL="$u"; break; }
done
[ -n "$NOME" ] || erro "Não encontrei o Kubuntu 26.04 no site do Ubuntu. Verifique a internet."
ISO="$BASE/$NOME"
ESPERADO=$(curl -fsSL "${URL}SHA256SUMS" | grep -F "$NOME" | head -1 | cut -d' ' -f1)

if [ -f "$ISO" ] && echo "$ESPERADO  $ISO" | sha256sum -c --status 2>/dev/null; then
  ok "$NOME já baixado"
else
  echo "  Baixando $NOME (cerca de 5 GB). Se cair a internet, rode de novo que ele continua."
  curl -L -C - --retry 5 -o "$ISO" "${URL}${NOME}" || erro "O download falhou. Rode de novo para continuar."
  echo "  Conferindo se o download veio perfeito..."
  echo "$ESPERADO  $ISO" | sha256sum -c --status || { rm -f "$ISO"; erro "Arquivo corrompido (apagado). Rode de novo."; }
  ok "Download conferido"
fi

# ---------- 3. Criar a máquina ----------
verde "[3/4] Criando a máquina virtual \"$VM\""
RAM_GB=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) / 1024 / 1024 ))
if   [ "$RAM_GB" -ge 15 ]; then MEM=8192
elif [ "$RAM_GB" -ge 11 ]; then MEM=6144
else MEM=4096; fi
CPU=$(( $(nproc) / 2 )); [ "$CPU" -lt 2 ] && CPU=2; [ "$CPU" -gt 8 ] && CPU=8

VBoxManage createvm --name "$VM" --ostype Ubuntu_64 --register --basefolder "$BASE" >/dev/null || erro "Falha ao criar a máquina."
VBoxManage modifyvm "$VM" --memory $MEM --cpus $CPU --vram 128 --graphicscontroller vmsvga --firmware efi \
  --ioapic on --nic1 nat --mouse usbtablet --boot1 disk --boot2 dvd --boot3 none --boot4 none || erro "Falha ao configurar."
VBoxManage modifyvm "$VM" --accelerate-3d on 2>/dev/null || VBoxManage modifyvm "$VM" --accelerate3d on 2>/dev/null
VBoxManage modifyvm "$VM" --clipboard-mode bidirectional 2>/dev/null || VBoxManage modifyvm "$VM" --clipboard bidirectional 2>/dev/null
VBoxManage modifyvm "$VM" --drag-and-drop bidirectional 2>/dev/null || VBoxManage modifyvm "$VM" --draganddrop bidirectional 2>/dev/null
VBoxManage modifyvm "$VM" --audio-enabled on 2>/dev/null || VBoxManage modifyvm "$VM" --audio pulse 2>/dev/null
VDI="$BASE/$VM/NeoKurumin.vdi"
VBoxManage createmedium disk --filename "$VDI" --size 61440 --format VDI >/dev/null || erro "Falha ao criar o disco."
VBoxManage storagectl "$VM" --name SATA --add sata --controller IntelAhci --portcount 4 --bootable on
VBoxManage storageattach "$VM" --storagectl SATA --port 0 --device 0 --type hdd --medium "$VDI"
VBoxManage storageattach "$VM" --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$ISO"
VBoxManage storageattach "$VM" --storagectl SATA --port 2 --device 0 --type dvddrive --medium "$PACOTE"
ok "Memória: $MEM MB | Processadores: $CPU | Disco: 60 GB"

# ---------- 4. Ligar ----------
verde "[4/4] Ligando a máquina"
VBoxManage startvm "$VM" --type gui >/dev/null && ok "Pronto! Siga o LEIA-ME para instalar o Kubuntu e virar Neo Kurumin."
