# image manipulation

# $1 .. resolution
# $2 .. img file
function img-resize()
{
    local resolution=$1
    local img_file=$2
    local img_file_no_suffix=${img_file%.*}
    local img_file_ext=${img_file##*.}
    local img_file_no_suffix_target=${img_file_no_suffix}-${resolution}
    if test $resolution = "427x240" ; then
        img_file_no_suffix_target=${img_file_no_suffix}-240p
    elif test $resolution = "640x360" ; then
        img_file_no_suffix_target=${img_file_no_suffix}-360p
    elif test $resolution = "1280x720" ; then
        img_file_no_suffix_target=${img_file_no_suffix}-720p
    elif test $resolution = "1920x1080" ; then
        img_file_no_suffix_target=${img_file_no_suffix}-1080p
    fi
    convert -resize $resolution $img_file ${img_file_no_suffix_target}.${img_file_ext}
    convert -resize $resolution $img_file ${img_file_no_suffix_target}.jpg
}

function img-resize-240p() { img-resize 427x240 $1 ; }
function img-resize-360p() { img-resize 640x360 $1 ; }
function img-resize-360p() { img-resize 640x360 $1 ; }
function img-resize-720p() { img-resize 1280x720 $1 ; }
function img-resize-1080p() { img-resize 1920x1080 $1 ; }
function img-resize-2160p() { img-resize 3840x2160 $1 ; }
function img-resize-4320p() { img-resize 7680x4320 $1 ; }
function img-resize-1k() { img-resize 1920x1080 $1 ; }
function img-resize-4k() { img-resize 3840x2160 $1 ; }
function img-resize-8k() { img-resize 7680x4320 $1 ; }

# $1 .. $n image files
function img-gallery()
{
    local gallery_basename="000"
    local gallery_format="jpg"
    if test -z "$1" ; then
        echo "E: please specify input image files"
        return 2
    fi

    for i in "360x360" "720x720" "1440x1440"; do
        local tmp=${gallery_basename}_${i}
        if test "$gallery_format" = "jpg" ; then
            montage -geometry ${i}+2+2 "$@" ${tmp}.jpg
        elif test "$gallery_format" = "jpg" ; then
            montage -geometry ${i}+2+2 "$@" ${tmp}.png
        else
            echo "E: please specify gallery image format"
        fi
    done
}
