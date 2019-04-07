# works the same way as dirname
# but does not return '.' if there is no directory in the path
# and returns an empty string in such case.

gd_dirname() {
    D=$(dirname $1)
    if [ $D == "." ]
    then
        D=""
    fi
    echo $D
}
