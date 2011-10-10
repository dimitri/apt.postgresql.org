#! /usr/bin/awk
#
# Poor's man HTML parser to fetch latest minor version of each major version
# See http://www.postgresql.org/ftp/source/

BEGIN { FS="[ =\"v]"  }

/alt="v/ {
    s=gensub(/(beta|rc)/, ".\\1", 1, $14);
    split(s, x, /\./); maj=x[1]"."x[2]; min=x[3];
    if( ! maj in v || min !~ /beta|rc/ )
	v[maj]=min;
}

END {
    for(i in v) print i " " v[i]
}
