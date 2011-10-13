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

function set-archive-md5sum()
{
    distro=`lsb_release -sc`

    case $distro in
	lenny)
	    Z=gz
	    archive=postgresql-${version}.tar.gz
	    md5sum=postgresql-${version}.tar.gz.md5
	    ;;

	*)
	    Z=bz2
	    archive=postgresql-${version}.tar.bz2
	    md5sum=postgresql-${version}.tar.bz2.md5
	    ;;
    esac
}
