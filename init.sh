# Setup path
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
current_dir=$(pwd)
selected_env="dev-local"

# load env
function load_env {
    # Source the .env file
    if [ -f $1 ]; then
        echo "source $1"
        export $(grep -v '^#' $1 | xargs)
    else
        echo "No .env file found in $1"
        exit
    fi
}

check_folder() {
  if [ -d "$1" ]; then
    echo "Folder $1 already exists, exiting"
    exit
  fi
}


setup_htaccess() {
    htpasswd -bc "$script_dir/docker/nginx/.htpasswd" "$ADMIN_PANEL_USERNAME" "$ADMIN_PANEL_PASSWORD"

    sudo chown "$USER:www-data" "$script_dir/moodle/" -R
    sudo chmod 775 "$script_dir/moodle/" -R

    echo "Admin Panel berjalan di port 57710 user = $ADMIN_PANEL_USERNAME | password = $ADMIN_PANEL_PASSWORD"
}

setup_fake_https_cert() {
        
    sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -keyout "$script_dir/docker/traefik/certs/server.key" -out "$script_dir/docker/traefik/certs/server.crt"

}

setup_network() {
    # Check if the network "$NETWORK" exists
    found=$(docker network ls --format "{{.Name}}" | awk -v net="$NETWORK" '$0 == net {count++} END {print count}')
    if [ -n "$found" ]; then
        echo "Network '$NETWORK' already exists."
    else
        echo "Network '$NETWORK' does not exist, creating it..."
        docker network create $NETWORK
    fi
}

install_moodle() {


    # Run the installation command
    # bash wrapper.sh $selected_env exec \
    #     moodle \
    #     php admin/cli/install.php \
    #     --wwwroot="/var/www/html" \
    #     --dataroot="/var/www/moodledata" \
    #     --dbtype="$DB_TYPE" \
    #     --dbhost="$DB_HOST" \
    #     --dbname="$DB_DATABASE" \
    #     --dbuser="$DB_USERNAME" \
    #     --dbpass="$DB_PASSWORD" \
    #     --fullname="Moodle Site" \
    #     --shortname="Moodle" \
    #     --adminuser="$ADMIN_USER" \
    #     --adminpass="$ADMIN_PASS" \
    #     --adminemail="$ADMIN_EMAIL" \
    #     --non-interactive \
    #     --agree-license

    bash wrapper.sh $selected_env exec \
        moodle \
        php admin/cli/install_database.php \
        --fullname="Moodle Site" \
        --shortname="Moodle" \
        --adminuser="$ADMIN_USER" \
        --adminpass="$ADMIN_PASS" \
        --adminemail="$ADMIN_EMAIL" \
        --agree-license

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "Moodle installation completed successfully."
        echo "Admin credentials:"
        echo "    ADMIN_USER=\"$ADMIN_USER\""
        echo "    ADMIN_PASS=\"$ADMIN_PASS\""
        echo "    ADMIN_EMAIL=\"$ADMIN_EMAIL\""
    else
        echo "Moodle installation failed. Please check the error messages above."
    fi
}

if [[ "$1" =~ ^(dev-|prod-|staging-|pre-prod-) ]]; then
    load_env "$script_dir/docker/.env-$1"
    shift 1
else 
    selected_env="dev-local"
    load_env "$script_dir/docker/.env-dev-local"
fi

# exit
base_recipe_url=${BASE_RECIPE_URL:-https://raw.githubusercontent.com/tongkolspace/dockerized-php-recipes/main}
if  [ "$1" == "install_moodle" ]
then
    install_moodle
elif [ "$1" == "upgrade_moodle" ]
then
    tmp_dir="$script_dir/tmp"

    if [ ! -d "$script_dir/tmp" ]; then
        mkdir "$script_dir/tmp"
    fi

    # Prompt for confirmation
    read -p "Are you sure you want to upgrade? This will delete all files on $script_dir/moodle folder (y/n): " confirm

    # Check confirmation
    if [[ $confirm != [yY] ]]; then
        echo "Upgrade cancelled."
        exit 1
    fi

    # Remove existing moodle directory if it exists
    if [ ! -d "$script_dir/moodle" ]; then
        echo "Previous moodle instalation not found"
    fi

    echo "Removing delete all files on moodle folder"
    rm "$script_dir/moodle"/* -rf 


    # # Download the Moodle zip file to the temporary directory
    echo "Downloading Moodle version $VERSION_MOODLE_UPGRADE..."
    wget "https://github.com/moodle/moodle/archive/refs/tags/v$VERSION_MOODLE_UPGRADE.zip" -O "$tmp_dir/moodle-docker.zip"

    # # Unzip directly to the script directory
    echo "Extracting zip file..."
    unzip "$tmp_dir/moodle-docker.zip" -d "$tmp_dir"

    # Rename the extracted directory to 'moodle'
    echo "Moving extracted folder..."
    mv "$tmp_dir/moodle-$VERSION_MOODLE_UPGRADE/"* "$script_dir/moodle/"

    # Set ownership
    echo "Setting folder ownership..."
    sudo chown 1000:33 "$script_dir/moodle" -R

    # Remove the temporary zip file
    echo "Cleaning up temporary files..."
    rm "$tmp_dir"  -rf

    echo "Upgrade complete.."
    echo "Run symlink.sh to symlink custom file and config"

elif [ "$1" == "install" ]
then
    check_folder "$script_dir/moodle";
    check_folder "$script_dir/moodledata";

    tmp_dir="$script_dir/tmp"

    if [ ! -d "$script_dir/tmp" ]; then
        mkdir "$script_dir/tmp"
    fi

    # Download the Moodle zip file to the temporary directory
    wget "https://github.com/moodle/moodle/archive/refs/tags/v$VERSION_MOODLE.zip" -O "$tmp_dir/moodle-docker.zip"

    # Unzip directly to the script directory
    unzip "$tmp_dir/moodle-docker.zip" -d "$script_dir"

    # Rename the extracted directory to 'moodle'
    mv "$script_dir/moodle-$VERSION_MOODLE" "$script_dir/moodle"


    # Set ownership
    sudo chown 1000:33 "$script_dir/moodle" -R

    # Remove the temporary zip file
    rm "$tmp_dir -rf"

    mkdir moodledata && sudo chown 1000:1000 -R moodledata && sudo chmod 770 moodledata -R

    setup_fake_https_cert
    setup_network

    echo "Instalasi Moodle dockerized selesai, jalankan dengan : bash wrapper.sh $selected_env up"
    echo "Untuk instalasi Moodle otomatis jalankan bash init.sh install_moodle setelah menjalankan docker"

elif [ "$1" == "setup_htaccess" ]
then
    setup_htaccess
elif [ "$1" == "clean" ]
then
    # echo "Clean Moodle and .env file.."
    sudo rm "$script_dir/moodle" -rf
    sudo rm "$script_dir/moodledata" -rf
    # rm "$script_dir/docker/.env"
    # rm "$script_dir/docker/.env-dev-local"
    # rm "$script_dir/docker/.env-dev-proxy"
    sudo rm -rf "$script_dir/docker/nginx/.htpasswd"
    sudo rm -rf "$script_dir/docker/mysql/datadir/" 
else 
    echo "penggunaan"
    echo "bash init.sh dev-local install"
    echo "bash init.sh dev-local upgrade_moodle"
    echo "bash init.sh dev-local install_moodle"
    echo "bash init.sh dev-local clean"
    echo "bash init.sh dev-local setup_htaccess"
    echo "bash init.sh dev-local setup_fake_https_cert"

fi
