#!/bin/bash
# Installs the drivers for every GPU that lspci finds (Intel, AMD, NVIDIA).
# Called from install.sh before pkglist, so steam finds the 32-bit Vulkan driver already in place.
# Needs yay (NVIDIA legacy branches come from the AUR).

sudo pacman -S --needed --noconfirm pciutils
gpus=$(lspci -nn | grep -E '\[03(00|02|80)\]:')
gpu_pkgs=()

if grep -q '\[8086:' <<< "$gpus"; then
    # intel-media-driver does VA-API on Broadwell and newer, libva-intel-driver on older chips
    gpu_pkgs+=(vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver)
fi
if grep -q '\[1002:' <<< "$gpus"; then
    gpu_pkgs+=(vulkan-radeon lib32-vulkan-radeon)
fi

# NVIDIA: driver branch chosen from the chip family that lspci reports (TU117, AD102, GP107...)
nvidia=false
nvidia_gpu=$(grep '\[10de:' <<< "$gpus" | head -n1)
if [ -n "$nvidia_gpu" ]; then
    chip=$(grep -oE '\b(TU|G[A-Z]?)[0-9]{2,3}' <<< "$nvidia_gpu" | head -n1)
    case "$chip" in
        GK*)             branch=470xx ;;   # Kepler (AUR)
        GM*|GP*|GV*)     branch=580xx ;;   # Maxwell, Pascal, Volta (AUR)
        GF*|GT*|G[0-9]*) branch=none ;;    # Fermi and older: only nouveau
        *)               branch=open ;;    # Turing and newer, or too new for the PCI ID database
    esac

    kernels=$(pacman -Qq linux linux-lts linux-zen linux-hardened 2>/dev/null)
    dkms=true
    case "$branch" in
        open)
            if [ "$kernels" = "linux" ]; then
                gpu_pkgs+=(nvidia-open)
                dkms=false
            else
                gpu_pkgs+=(nvidia-open-dkms)
            fi
            gpu_pkgs+=(nvidia-utils lib32-nvidia-utils)
            nvidia=true
            ;;
        470xx|580xx)
            gpu_pkgs+=("nvidia-$branch-dkms" "nvidia-$branch-utils" "lib32-nvidia-$branch-utils")
            nvidia=true
            ;;
        none)
            echo "NVIDIA GPU too old for the proprietary driver, keeping nouveau: $nvidia_gpu"
            ;;
    esac

    if $nvidia; then
        # dkms builds the module for every installed kernel, which needs its headers
        if $dkms; then
            for k in $kernels; do gpu_pkgs+=("$k-headers"); done
        fi
        # Hybrid graphics (Intel/AMD iGPU + NVIDIA): prime-run renders an app on the NVIDIA GPU
        if grep -qE '\[(8086|1002):' <<< "$gpus"; then
            gpu_pkgs+=(nvidia-prime)
        fi
    fi
fi

if [ ${#gpu_pkgs[@]} -gt 0 ]; then
    echo "GPUs:"
    echo "$gpus"
    echo "Installing: ${gpu_pkgs[*]}"
    yay -S --needed --noconfirm "${gpu_pkgs[@]}" || echo "Failed to install GPU drivers"
fi

# Drop the kms hook so nouveau is not loaded from the initramfs before nvidia
if $nvidia && grep -q "^HOOKS=.*\bkms\b" /etc/mkinitcpio.conf; then
    sudo sed -i '/^HOOKS=/ s/ kms\b//' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi
