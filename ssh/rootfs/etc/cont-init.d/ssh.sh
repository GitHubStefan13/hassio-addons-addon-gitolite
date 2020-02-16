#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: SSH & Web Terminal
# Configures the SSH daemon
# ==============================================================================
readonly SSH_AUTHORIZED_KEYS_PATH=/etc/ssh/authorized_keys
readonly SSH_CONFIG_PATH=/etc/ssh/sshd_config
readonly SSH_HOST_ED25519_KEY=/data/ssh_host_ed25519_key
readonly SSH_HOST_RSA_KEY=/data/ssh_host_rsa_key
declare port

port=$(bashio::addon.port 2022)

# Don't execute this when SSH is disabled
if ! bashio::var.has_value "${port}"; then
    exit 0
fi

# Generate host keys
if ! bashio::fs.file_exists "${SSH_HOST_RSA_KEY}"; then
    bashio::log.notice 'RSA host key missing, generating one...'

    ssh-keygen -t rsa -f "${SSH_HOST_RSA_KEY}" -N "" \
        || bashio::exit.nok 'Failed to generate RSA host key'
fi

if ! bashio::fs.file_exists "${SSH_HOST_ED25519_KEY}"; then
    bashio::log.notice 'ED25519 host key missing, generating one...'
    ssh-keygen -t ed25519 -f "${SSH_HOST_ED25519_KEY}" -N "" \
        || bashio::exit.nok 'Failed to generate ED25519 host key'
fi

# Port
sed -i "s/Port\\ .*/Port\\ ${port}/" "${SSH_CONFIG_PATH}" \
    || bashio::exit.nok 'Failed configuring port'

# This enabled less strict ciphers, macs, and keyx.
if bashio::config.true 'ssh.compatibility_mode'; then
    sed -i '/Ciphers\ .*/s/^/#/g' "${SSH_CONFIG_PATH}"
    sed -i '/MACs\ .*/s/^/#/g' "${SSH_CONFIG_PATH}"
    sed -i '/KexAlgorithms\.* /s/^/#/g' "${SSH_CONFIG_PATH}"
    bashio::log.notice 'SSH is running in compatibility mode!'
    bashio::log.warning 'Compatibility mode is less secure!'
    bashio::log.warning 'Please only enable it when you know what you are doing!'
fi

# Enable Agent forwarding
if bashio::config.true 'ssh.allow_agent_forwarding'; then
    sed -i "s/AllowAgentForwarding.*/AllowAgentForwarding\\ yes/" \
        "${SSH_CONFIG_PATH}" \
          || bashio::exit.nok 'Failed to setup SSH Agent Forwarding'
fi

# Allow remote port forwarding
if bashio::config.true 'ssh.allow_remote_port_forwarding'; then
    sed -i "s/GatewayPorts.*/GatewayPorts\\ yes/" \
        "${SSH_CONFIG_PATH}" \
          || bashio::exit.nok 'Failed to setup remote port forwarding'
fi

# Allow TCP forewarding
if bashio::config.true 'ssh.allow_tcp_forwarding'; then
    sed -i "s/AllowTcpForwarding.*/AllowTcpForwarding\\ yes/" \
        "${SSH_CONFIG_PATH}" \
          || bashio::exit.nok 'Failed to setup SSH TCP Forwarding'
fi
