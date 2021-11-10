# tar

function tarc() { tar czvf "$1".tgz "$1" ; }
function tarx() { tar xvf "$1" ; }
function tart() { tar tzvf "$1" ; }
function tarjc() { tar cjvf "$1".tar.bz2 "$1" ; }
function tarjt() { tar tjvf "$1" ; }

# zip

function zipc() { zip -g -r -y "$1".zip "$1" ; }
