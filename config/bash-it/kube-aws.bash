# Clusters that are only reachable through an AWS Session Manager tunnel: the
# nodes have no public IP, no bastion and no VPN, so the API is forwarded to a
# local port and the kubeconfig points at 127.0.0.1.
#
#   kube-aws-ls                list the clusters that tunnel
#   kube-tunnel op-prod        hold the tunnel open -- runs in the foreground
#   kube-use op-prod           select it, as usual -- see kube.bash
#
# The tunnel is a second thing that has to be running, not a property of the
# kubeconfig, so it lives in its own terminal. Session Manager hangs up on idle
# sessions, hence the reconnect loop rather than a single call.
#
# Unlike the vSphere clusters nothing here expires -- the credential is a
# cluster-admin certificate. What breaks is the tunnel, and a dead tunnel makes
# "no resources found" look like a real answer, so check `kubectl get --raw
# /version` before believing an empty result.

# name|profile|local-port|remote-port|instance-ids
KUBE_AWS_TUNNELS=(
    "op-prod|livesystems|16444|6443|i-03223b05e50c22e24 i-0cbed721901aa8a25 i-02787c84413194c90"
)

# Bare short names, one per line -- the source for both lookups and completion.
function kube-aws-names()
{
    local entry

    for entry in "${KUBE_AWS_TUNNELS[@]}" ; do
        echo "${entry%%|*}"
    done
}

function kube-aws-ls()
{
    local entry name profile local_port remote_port instances

    for entry in "${KUBE_AWS_TUNNELS[@]}" ; do
        IFS='|' read -r name profile local_port remote_port instances <<< "$entry"
        printf '  %-18s %-14s 127.0.0.1:%s -> :%s\n' "$name" "$profile" "$local_port" "$remote_port"
    done
}

# First instance in the list that is actually running. The nodes are stopped
# between work sessions to save cost, and any one of them answers the API.
function _kube_aws_running_instance()
{
    local profile=$1
    shift

    aws --profile "$profile" ec2 describe-instances \
        --instance-ids "$@" \
        --filters 'Name=instance-state-name,Values=running' \
        --query 'Reservations[].Instances[0].InstanceId' \
        --output text 2> /dev/null | awk '{print $1}'
}

function kube-tunnel()
{
    local name=$1

    if test -z "$name"; then
        echo "Usage: kube-tunnel <cluster>"
        kube-aws-ls
        return 1
    fi

    local entry spec=""
    for entry in "${KUBE_AWS_TUNNELS[@]}" ; do
        if test "${entry%%|*}" = "$name"; then
            spec=$entry
            break
        fi
    done

    if test -z "$spec"; then
        echo "Not a tunnelled cluster: $name"
        kube-aws-ls
        return 1
    fi

    local profile local_port remote_port instances
    IFS='|' read -r _ profile local_port remote_port instances <<< "$spec"

    # The instance ids are a deliberate word list, not one argument.
    local target
    # shellcheck disable=SC2086
    target=$(_kube_aws_running_instance "$profile" $instances)

    if test -z "$target"; then
        echo "No running instance among: $instances"
        echo "Start them (all of them -- etcd needs two of three for quorum):"
        echo "  aws --profile $profile ec2 start-instances --instance-ids $instances"
        return 1
    fi

    echo "Tunnelling 127.0.0.1:${local_port} -> ${target}:${remote_port}  (Ctrl-C to stop)"

    # Session Manager closes idle sessions, so reconnect until interrupted. The
    # trap is what makes Ctrl-C end the loop instead of just the current session.
    local stop=""
    trap 'stop=1' INT

    while test -z "$stop" ; do
        aws --profile "$profile" ssm start-session \
            --target "$target" \
            --document-name AWS-StartPortForwardingSession \
            --parameters "{\"portNumber\":[\"${remote_port}\"],\"localPortNumber\":[\"${local_port}\"]}"

        test -z "$stop" && echo "-- session ended, reconnecting" && sleep 3
    done

    trap - INT
    echo "Tunnel closed."
}

# -F (not -W) so a newly configured cluster is offered without re-sourcing.
function _kube_tunnel_complete()
{
    mapfile -t COMPREPLY < <(compgen -W "$(kube-aws-names)" -- "${COMP_WORDS[COMP_CWORD]}")
}
complete -F _kube_tunnel_complete kube-tunnel
