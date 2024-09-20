#!/bin/bash
# JURUS NAGABONAR 
# SYMLINK MOODLE

current_dir=$(pwd)
moodle_mod="moodle_mod"
moodle="moodle"

# Daftar target
targets_symlink=(
    "admin/cli/delete_backup.php"
    "local/restrictrestore"
    "config.php"
    "config-docker.php"
    "config-standard.php"
)

target_cp=(
    "theme/moove"
)

# Fungsi untuk menjalankan atau hanya menampilkan perintah
run_command() {
    echo "Menjalankan: $1"
    if [ "$dry_run" != true ]; then
        eval "$1"
    fi
}

# Periksa apakah --dry-run atau --force digunakan
dry_run=false
force=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            dry_run=true
            echo ""
            echo "============================================================"
            echo "Mode dry run aktif. Tidak ada perubahan yang akan dilakukan."
            echo "============================================================"
            echo ""
            ;;
        --force)
            force=true
            ;;
    esac
done

# Menampilkan informasi tentang file yang akan diganti
echo "Skrip ini akan mengganti file di folder berikut:"
echo "Symlink:"
for target in "${targets_symlink[@]}"; do
    echo "./$moodle_mod/$target --> ./$moodle/$target (symlink)"
done
echo "Copy:"
for target in "${targets_cp[@]}"; do
    echo "./$moodle_mod/$target --> ./$moodle/$target (copy)"
done

# Konfirmasi untuk melanjutkan jika bukan dry run dan bukan force
if [ "$dry_run" = false ] && [ "$force" = false ]; then
    read -p "Lanjutkan? (y/n): " confirm
    if [[ $confirm != [yY] ]]; then
        echo "Operasi dibatalkan."
        exit 1
    fi
fi

# Hitung panjang teks
text="Menjalankan symlink dan copy script dari folder $current_dir/$moodle"
text_length=${#text}

# Buat garis pemisah dengan panjang yang sama
separator=$(printf '=%.0s' $(seq 1 $text_length))

echo ""
echo "$separator"
echo "$text"
echo "$separator"
echo ""

# Proses penggantian file dengan symlink
for target in "${targets_symlink[@]}"; do
    # Hapus target yang ada
    run_command "rm -rf $moodle/$target"
    relative_path=$(realpath --relative-to="$moodle/$(dirname $target)" "$moodle_mod/$target")
    # Buat symlink dengan path relatif
    run_command "ln -s $relative_path $moodle/$target"
done

# Proses penggantian file dengan copy
for target in "${targets_cp[@]}"; do
    # Hapus target yang ada
    run_command "rm -rf $moodle/$target"
    run_command "cp -r $moodle_mod/$target $moodle/$target"
done

cd $current_dir
echo "Semua operasi selesai."