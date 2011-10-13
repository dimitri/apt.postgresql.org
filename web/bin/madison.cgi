#!/usr/bin/perl -w

use strict;

use CGI qw/:standard/;
# two BDB modules, packages.db is a multi-DB file
use DB_File;
use BerkeleyDB;

my $dbdir = "/cb/www.df7cb.de/public_html/projects/postgresql-apt/db";
my @versions = qw(8.1 8.2 8.3 8.4 9.0 9.1 9.2 9.3);

print header(-type => 'text/html', -charset => 'utf-8');

my @pkgs;
foreach my $pkg (split /\s+/, param('package')) {
	if ($pkg =~ /-?\*/) {
		# add package name without -*
		my $p = $pkg; $p =~ s/-?\*//; push @pkgs, $p;
		# add package names for each -version
		push @pkgs, map { my $p = $pkg; $p =~ s/-?\*/-$_/; $p; } @versions;
	} else {
		push @pkgs, $pkg;
	}
}

my %hash;
tie %hash, 'DB_File', "$dbdir/packages.db", 0, 0666, $DB_BTREE;
my @dbs = keys %hash;
untie %hash;

sub dist_version ($)
{
	my $_ = shift;
	return 4 if /^etch/;
	return 5 if /^lenny/;
	return 6 if /^squeeze/;
	return 7 if /^wheezy/;
	return 100 if /^sid/;
	return 1000 if /^experimental/;
	return 99; # for future releases not yet in the list
}

sub stripver ($)
{
	my $pkg = shift;
	$pkg =~ s/-\d\.\d//;
	return $pkg;
}

my %archive;
my %source;
my %dists;

foreach my $db (@dbs) {
	$db =~ /(.*)\|(.*)\|(.*)/;
	my ($dist, $component, $arch) = ($1, $2, $3);
	my $bdb = tie %hash, 'BerkeleyDB::Btree',
		-Filename => "$dbdir/packages.db",
		-Subname => $db,
		-Flags => DB_RDONLY
			or die $! . $BerkeleyDB::Error;
	foreach my $pkg (@pkgs) {
		my $data = $hash{"$pkg\0"};
		next unless defined $data;
		$source{$pkg} = $1 if ($data =~ /^Source: (\S+)/m);
		my $source = $source{$pkg} || $pkg;
		$data =~ /^Version: (.*)/m or die "no Version in $data";
		my $version = $1;
		my $pgversion = $1 if ($pkg =~ /(\d\.\d)/);
		$archive{$source}->{"$dist"}->{$pgversion ? "$pgversion:$version" : $version}->{$arch} = 1;
		$dists{$dist} = dist_version($dist);
	}
	undef $bdb;
	untie %hash;
}

my @dists = sort { $dists{$a} <=> $dists{$b} } keys %dists;

print "<table border=\"1\">\n";
print "<tr><td></td>\n";
foreach my $dist (@dists) {
	print " <th>$dist</th>\n";
}
print "</tr>\n";

foreach my $pkg (sort { stripver($a) cmp stripver($b) or $a cmp $b } keys %archive) {
	my $srcpkg = $source{$pkg} || $pkg;
	$srcpkg =~ /^((?:lib)?.)/;
	print "<tr><th><a href=\"../pool/main/$1/$srcpkg/\">$pkg</a></th>\n";
	foreach my $dist (@dists) {
		my @versions = sort keys %{$archive{$pkg}->{$dist}};
		print " <td>";
		unless (@versions) {
			print "&nbsp;</td>\n";
			next;
		}
		foreach my $version (@versions) {
			my $archs = join (" ", sort keys %{$archive{$pkg}->{$dist}->{$version}});
			$version =~ s!^(\d\.\d):!<b>$1</b>:!;
			#print "<span title=\"$archs\">$version</span> <br />";
			print "$version <small>$archs</small> <br />";
		}
		print "</td>\n";
	}
	print "</tr>\n";
}

print "</table>\n";
