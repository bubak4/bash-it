# dirclip -- simple directory bookmarks

# usage: in one window
#   cd long/long/path
#   mcd
# in another window
#   cd another/long/long/path
#   cp file `rcd`
# file is copied to directory from the first window
if which seq > /dev/null; then
    DIRCLIP="$HOME/.config/dirclip"
    mkdir -p $DIRCLIP
    for i in "" `seq 0 9`; do
        alias mcd$i="pwd > $DIRCLIP/dirclip$i"
        alias rcd$i='cd $(cat $DIRCLIP/dirclip'"$i"'); pwd'
    done
    alias cds='for i in " " `seq 1 9` "0"; do if [ -e $DIRCLIP/dirclip$i ]; then echo -n "$i "; cat $DIRCLIP/dirclip$i | sed "s:^$HOME:~:"; else echo ""; fi; done'
fi
