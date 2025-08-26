#!/usr/bin/env bash
export SHELLOPTS
set -eou pipefail

LOGFILE="/var/log/consul-cloud-init.log"
PRODUCT="consul"
CONSUL_VERSION="${consul_version}"
VERSION=$CONSUL_VERSION

CONSUL_DIR_BIN="/usr/bin"

CONSUL_DIR_HOME="/opt/consul/"
CONSUL_DIR_LICENSE="$${CONSUL_DIR_HOME}/license"
CONSUL_DIR_DATA="$${CONSUL_DIR_HOME}/data"
CONSUL_DIR_CONFIG="/etc/consul.d"
CONSUL_DIR_TLS="$${CONSUL_DIR_CONFIG}/tls"
CONSUL_USER="consul"
CONSUL_GROUP="consul"

function log {
  local level="$1"
  local message="$2"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local log_entry="$timestamp [$level] - $message"

  echo "$log_entry" | tee -a "$LOGFILE"
}
exit_script() {
  if [[ "$1" == 0 ]]; then
    log "INFO" "Vault custom_data script finished successfully!"
  else
    log "ERROR" "Vault custom_data script finished with error code $1."
  fi

  exit "$1"
}

function detect_architecture {
  local ARCHITECTURE=""
  local OS_ARCH_DETECTED=$(uname -m)

  case "$OS_ARCH_DETECTED" in
    "x86_64"*)
      ARCHITECTURE="linux_amd64"
      ;;
    "aarch64"*)
      ARCHITECTURE="linux_arm64"
      ;;
		"arm"*)
      ARCHITECTURE="linux_arm"
			;;
    *)
      log "ERROR" "Unsupported architecture detected: '$OS_ARCH_DETECTED'. "
		  exit_script 1
  esac

  echo "$ARCHITECTURE"
}

function determine_os_distro {
  local os_distro_name=$(grep "^NAME=" /etc/os-release | cut -d"\"" -f2)

  case "$os_distro_name" in
    "Ubuntu"*)
      os_distro="ubuntu"
      ;;
    "CentOS Linux"*)
      os_distro="centos"
      ;;
    "Red Hat"*)
      os_distro="rhel"
      ;;
    *)
      log "ERROR" "'$os_distro_name' is not a supported Linux OS distro for BOUNDARY."
      exit_script 1
  esac

  echo "$os_distro"
}

# directory_creates creates the necessary directories for $PRODUCT
function directory_create {
  # Define all directories needed as an array
  directories=( $CONSUL_DIR_CONFIG $CONSUL_DIR_TLS $CONSUL_DIR_LICENSE $CONSUL_DIR_DATA )

  # Loop through each item in the array; create the directory and configure permissions
  for directory in "$${directories[@]}"; do
    mkdir -p $directory
		log "INFO" "Creating directory $directory"
    sudo chown $CONSUL_USER:$CONSUL_GROUP $directory
    sudo chmod 750 $directory
		log "INFO" "Directory $directory created with appropriate permissions"
  done
}

function checksum_verify {
  local OS_ARCH="$1"

  # https://www.hashicorp.com/en/trust/security
  # checksum_verify downloads the $$PRODUCT binary and verifies its integrity
  log "INFO" "Verifying the integrity of the $${PRODUCT} binary."
  export GNUPGHOME=./.gnupg
  log "INFO" "Importing HashiCorp GPG key."
  sudo curl -s https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import

	log "INFO" "Downloading $${PRODUCT} binary"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_"$${OS_ARCH}".zip
	log "INFO" "Downloading $${PRODUCT}  Enterprise binary checksum files"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_SHA256SUMS
	log "INFO" "Downloading $${PRODUCT}  Enterprise binary checksum signature file"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig
  log "INFO" "Verifying the signature file is untampered."
  gpg --verify "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS
	if [[ $? -ne 0 ]]; then
		log "ERROR" "Gpg verification failed for SHA256SUMS."
		exit_script 1
	fi
  if [ -x "$(command -v sha256sum)" ]; then
		log "INFO" "Using sha256sum to verify the checksum of the $${PRODUCT} binary."
		sha256sum -c "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS --ignore-missing
	else
		log "INFO" "Using shasum to verify the checksum of the $${PRODUCT} binary."
		shasum -a 256 -c "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS --ignore-missing
	fi
	if [[ $? -ne 0 ]]; then
		log "ERROR" "Checksum verification failed for the $${PRODUCT} binary."
		exit_script 1
	fi

	log "INFO" "Checksum verification passed for the $${PRODUCT} binary."

	log "INFO" "Removing the downloaded files to clean up"
	sudo rm -f "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig
}

# install_consul_binary downloads the Vault binary and puts it in dedicated bin directory
function install_consul_binary {
  local OS_ARCH="$1"

  log "INFO" "Deploying $${PRODUCT} Enterprise binary to $CONSUL_DIR_BIN unzip and set permissions"
  sudo unzip "$${PRODUCT}"_"$${CONSUL_VERSION}"_"$${OS_ARCH}".zip  consul -d $CONSUL_DIR_BIN
  sudo unzip "$${PRODUCT}"_"$${CONSUL_VERSION}"_"$${OS_ARCH}".zip -x consul -d $CONSUL_DIR_LICENSE
  sudo rm -f "$${PRODUCT}"_"$${CONSUL_VERSION}"_"$${OS_ARCH}".zip

	log "INFO" "Deploying Consul $CONSUL_DIR_BIN set permissions"
  sudo chmod 0755 $CONSUL_DIR_BIN/consul
  sudo chown $CONSUL_USER:$CONSUL_GROUP $CONSUL_DIR_BIN/consul

  log "INFO" "Deploying Consul create symlink "
  sudo ln -sf $CONSUL_DIR_BIN/consul /usr/local/bin/consul

  log "INFO" "Consul binary installed successfully at $CONSUL_DIR_BIN/consul"
}

# curl -Lo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_$DLARCH.zip

# unzip consul.zip
# install consul /usr/local/bin/

# rm -f consul.zip consul

# echo "Consul Enterprise installation - complete"

main() {
  log "INFO" "Beginning Consul Enterprise installation"
  OS_ARCH=$(detect_architecture)

  directory_create

  checksum_verify $OS_ARCH
  log "INFO" "Checksum verification completed for $${PRODUCT} binary."

  install_consul_binary $OS_ARCH
  log "INFO" "Consul Enterprise installation - complete"
}

main "$@"
