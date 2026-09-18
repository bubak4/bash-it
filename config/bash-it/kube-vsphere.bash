# vSphere-with-Tanzu clusters. `kubectl vsphere login` mints a token that lasts
# ten hours, so unlike Hetzner or AKS there is no durable file to drop into
# ~/.kube -- left alone, a vSphere kubeconfig is stale by the next morning.
#
# kubectl already has the mechanism for credentials that expire: an exec plugin,
# which it re-runs whenever the cached one lapses. VMware's binary does not speak
# that protocol (login/logout/version/vm is all it has), so kubectl-vsphere-credential
# bridges it -- see config/bin. With that in place a vSphere cluster becomes an
# ordinary static kubeconfig and kubectl keeps it fresh by itself.
#
#   kube-vsphere-ls            list the clusters that can be bootstrapped
#   kube-login pre-test        log in once and write ~/.kube/pre-test-config.yaml
#   kube-use pre-test          select it, from then on -- see kube.bash
#
# So kube-login is a one-off per cluster, not a daily chore: it exists to capture
# the cluster's CA and address, which only a real login will tell us. Run it again
# only if a cluster is rebuilt with a new CA.
#
# The password lives in gnome-keyring, which the desktop session unlocks, and is
# handed to the plugin over KUBECTL_VSPHERE_PASSWORD scoped to the login itself.
# Nothing is ever typed. The keyring item is addressed by attributes rather than
# a path -- `secret-tool search --all service vsphere` lists them.
#
# Adding a cluster is one line below plus the matching `secret-tool store`, which
# kube-login prints in full if the password is not there yet.

# name|server|namespace|cluster|username
KUBE_VSPHERE_CLUSTERS=(
    "pre-test|https://linsvsvck1svisor.pre.cz|ns-test01|vks-test01|xmslou00@pre.cz"
)

# Bare short names, one per line -- the source for both lookups and completion.
function kube-vsphere-names()
{
    local entry

    for entry in "${KUBE_VSPHERE_CLUSTERS[@]}" ; do
        echo "${entry%%|*}"
    done
}

# The configured clusters with the namespace and guest cluster each one targets.
function kube-vsphere-ls()
{
    local entry name server namespace cluster

    for entry in "${KUBE_VSPHERE_CLUSTERS[@]}" ; do
        IFS='|' read -r name server namespace cluster _ <<< "$entry"
        printf '  %-18s %-24s %s\n' "$name" "${namespace}/${cluster}" "$server"
    done
}

function kube-login()
{
    local name=$1

    if test -z "$name"; then
        echo "Usage: kube-login <cluster>"
        kube-vsphere-ls
        return 1
    fi

    local entry spec=""
    for entry in "${KUBE_VSPHERE_CLUSTERS[@]}" ; do
        if test "${entry%%|*}" = "$name"; then
            spec=$entry
            break
        fi
    done

    if test -z "$spec"; then
        echo "Not a vSphere cluster: $name"
        kube-vsphere-ls
        return 1
    fi

    local server namespace cluster username
    IFS='|' read -r _ server namespace cluster username <<< "$spec"

    # --insecure matches how the supervisor has always been logged in to: it
    # presents a certificate our trust store knows nothing about. It applies to
    # the login only -- the guest cluster's own CA is captured and verified.
    local kubeconfig="${KUBE_CONFIG_DIR:-$HOME/.kube}/${name}-config.yaml"
    kubectl-vsphere-credential \
        --bootstrap "$kubeconfig" \
        --name "$name" \
        --server "$server" \
        --username "$username" \
        --namespace "$namespace" \
        --cluster "$cluster" \
        --insecure || return 1

    echo "Select it with: kube-use $name"
}

# -F (not -W) so a newly configured cluster is offered without re-sourcing.
function _kube_login_complete()
{
    mapfile -t COMPREPLY < <(compgen -W "$(kube-vsphere-names)" -- "${COMP_WORDS[COMP_CWORD]}")
}
complete -F _kube_login_complete kube-login
