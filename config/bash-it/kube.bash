# kubeconfig selection -- one file per cluster under ~/.kube/<name>-config.yaml.
# ~/.kube/config is intentionally empty so no cluster is targeted by accident.
#
#   kube-ls                    list clusters, contexts and servers
#   kube-use op-dev            select a cluster for this shell
#   kube-current               show what is selected right now
#
# Adding a cluster needs no change here -- drop the file in as
# ~/.kube/<name>-config.yaml and it is listed and completed automatically.

KUBE_CONFIG_DIR="$HOME/.kube"

# Bare short names, one per line -- the source for both lookups and completion.
function kube-names()
{
    local f

    for f in "${KUBE_CONFIG_DIR}"/*-config.yaml ; do
        test -f "$f" || continue
        basename "$f" | sed 's/-config\.yaml$//'
    done
}

# List every kubeconfig with the context and server inside it, so the short
# name can be matched to the cluster it actually targets. Active one marked '*'.
function kube-ls()
{
    local f name context server

    for f in "${KUBE_CONFIG_DIR}"/*-config.yaml ; do
        test -f "$f" || continue

        name=$(basename "$f" | sed 's/-config\.yaml$//')
        context=$(kubectl config --kubeconfig="$f" current-context 2>/dev/null)
        server=$(kubectl config --kubeconfig="$f" view -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null)

        if test "$f" = "$KUBECONFIG"; then
            printf '* %-18s %-34s %s\n' "$name" "${context:-<none>}" "$server"
        else
            printf '  %-18s %-34s %s\n' "$name" "${context:-<none>}" "$server"
        fi
    done
}

function kube-use()
{
    local name=$1

    if test -z "$name"; then
        echo "Usage: kube-use <cluster>"
        kube-ls
        return 1
    fi

    local kubeconfig="${KUBE_CONFIG_DIR}/${name}-config.yaml"
    if ! test -f "$kubeconfig"; then
        echo "No such kubeconfig: $kubeconfig"
        kube-ls
        return 1
    fi

    export KUBECONFIG="$kubeconfig"
    kubectl config current-context
}

function kube-current()
{
    if test -z "$KUBECONFIG"; then
        echo "KUBECONFIG unset -- no cluster selected"
        return 1
    fi

    echo "$KUBECONFIG"
    kubectl config current-context
}

# -F (not -W) so a newly added kubeconfig is offered without re-sourcing.
function _kube_use_complete()
{
    mapfile -t COMPREPLY < <(compgen -W "$(kube-names)" -- "${COMP_WORDS[COMP_CWORD]}")
}
complete -F _kube_use_complete kube-use
