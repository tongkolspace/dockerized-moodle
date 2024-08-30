## Langkah menjalankan dev
1. Jalankan command `bash init.sh dev-local install` untuk mendownload moodle
2. Gunakan folder moodle_mod untuk mounting semua plugin dan theme ke folder moodle
3. Ubah folder yang akan dimounting dari moodle_mod ke moodle pada script symlink.sh
```
targets=(
    "admin/cli/delete_backup.php"
    "theme/moove"
    "local/restrictrestore"
    "config.php"
)
``` 
4. Jalankan symlink.sh
```
symlink.sh --dry-run
symlink.sh --force
```
 
5. `config.php` akan menggunakan hasil symlink dari `moodle_mod`
6. copy env, menggunakna command `bash wrapper.sh copy_env .env-dev-local-sample .env-dev-local`
7. Set local dns `127.0.0.1 moodle.local`
8. Jalankan docker compose dengan perintah `bash wrapper.sh dev-local up`
9. Jalankan command `bash init.sh install_moodle` untuk install dari climoodle
10. Input dns local `127.0.0.1 moodle.local` buka browser dan ketik `http://moodle.local`

# Catatan Moodle

## Import database
```
tar -xvzf backup.tar.gz -O backup.sql | docker exec -i db-moodle-moodle-local mariadb -u root -p nama_db
```

## Masuk ke workspace
```
bash wrapper.sh run --rm workspace-moodle bash
# jalankan command
php admin/cli/reset_password.php -u username -p password
```

## Langkah menjalankan dev/prod

1. copy env, menggunakan command `bash wrapper.sh copy_env .env-dev-tongkolspace-sample .env-tongkolspace`
1. copy env, menggunakan command `bash wrapper.sh copy_env .env-dev-proxy-sample .env-prxoy-sample`
2. Jalankan `bash wrapper.sh dev-local dev-tongkolspace up dev-proxy`

URL 
- https://moodle.local:57710/
- https://proxy.dev.local:57710/
- https://moodle.local/

## Deploy script
1. Gunakan deploy script untuk deploy pada deploy/dev-local.sh
2. script ini akan melakukan mounting sebelum deploy docker 

# Catatan Pengembangan 

## Catatan moodle_mod

Proses moodle upgrade memerlukan source code moodle fresh tanpa modifikasi. Hal ini menimbulkan kesulitan kaerna pada setiap kali proses upgrade moodle diperlukan "pemetaan" untuk identifikasi modifikasi moolde yang sudah dilakukan.

Folder moodle_mod adalah sebuah solusi untuk memisahkan sourcecode inti moodle dan modifikasi moodle dalam bentuk mod dan themes.
Dengan adanya folder ini, semua modifikasi moodle dapat dipindah ke folder di luar source code moodle sehingga pada waktu upgrade

### Hal yang perlu diperhatikan

- Pada folder moodle_mod jangan gunakan `__DIR__` untuk loading file, gunakan `$CFG->dirroot`
- Jika config belum di load dapat gunakan relative path seperti pada file `admin/cli/delete_backup.php` 
```
require('../../config.php');
```

## config.php

Config.php dibuat dinamis agar dapat meload tergantung kondisi.
Template terlepak pada file `moodle_mod/config-template.php`
Copy dan modidifikasi file sesuai kebutuhan
Untuk file `config-standard.php` digunakan untuk deployment tanpa docker, file ini masuk git ignore karena pada env tanpa docker secret tertulis pada config file