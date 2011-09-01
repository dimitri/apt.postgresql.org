function get-full-pg-version()
{
    dirname=$1
    major=`echo $dirname| cut -d- -f2`
    minor=`awk "/${major}/ {print \\$2}" ${versions}`

    if `echo ${minor}|egrep -q 'alpha|beta|rc'`; then
	version=${major}${minor}
    else
	version=${major}.${minor}
    fi

    echo ${version}
}

function get-major-pg-version()
{
    dirname=$1
    major=`echo $dirname| cut -d- -f2`
    echo ${major}
}
