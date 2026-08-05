# mise for k8s tooling management
# curl https://mise.run | sh

if command -v mise > /dev/null ; then
    eval "$(~/.local/bin/mise activate bash)"
fi

# list available versions
#mise ls-remote kubectl

# install (latest version) globally
#mise use -g kubectl
# install specific version
#mise use -g kubectl@1.36.2

# auto-complete for kubectl if installed
if command -v kubectl > /dev/null ; then
    source <(kubectl completion bash)
fi
