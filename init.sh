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
    # Set variables (adjust these according to your setup)
    # MOODLE_PATH="/var/www/html"
    # MOODLE_DATA="/var/www/moodledata"
    # MOODLE_URL="http://$DOMAIN_MOODLE"
    # ADMIN_USER="admin"
    # ADMIN_PASS="admin_password"
    # ADMIN_EMAIL="admin@example.com"

    # Navigate to Moodle directory
    # cd $MOODLE_PATH

    # Run the installation command
    # bash wrapper.sh $selected_env run --rm \
    #     -v ./moodle:/var/www/html \
    #     -v ./moodledata:/var/www/moodledata \
    #     workspace-moodle \
    #     php admin/cli/install.php \
    #     --wwwroot="$MOODLE_URL" \
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

    bash wrapper.sh $selected_env run --rm \
        -v ./moodle:/var/www/html \
        -v ./moodledata:/var/www/moodledata \
        workspace-moodle \
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
elif [ "$1" == "install" ]
then
    check_folder "$script_dir/moodle";
    check_folder "$script_dir/moodledata";

    # Use the standard /tmp directory
    tmp_dir="/tmp"

    # Download the Moodle zip file to the temporary directory
    wget "https://github.com/moodle/moodle/archive/refs/tags/v$VERSION_MOODLE.zip" -O "$tmp_dir/moodle-docker.zip"

    # Unzip directly to the script directory
    unzip "$tmp_dir/moodle-docker.zip" -d "$script_dir"

    # Rename the extracted directory to 'moodle'
    mv "$script_dir/moodle-$VERSION_MOODLE" "$script_dir/moodle"


    # Set ownership
    sudo chown 1000:33 "$script_dir/moodle" -R

    # Remove the temporary zip file
    rm "$tmp_dir/moodle-docker.zip"

    mkdir moodledata && sudo chown 33:33 -R moodledata && sudo chmod 770 moodledata -R

    setup_htaccess
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
    echo "bash init.sh install"
    echo "bash init.sh install_moodle"
    echo "bash init.sh clean"
    echo "bash init.sh setup_htaccess"
    echo "bash init.sh setup_fake_https_cert"

fi
