#!/usr/bin/perl -w

use strict;

use CGI qw/:standard/;
use Dpkg::Version;
# two BDB modules, packages.db is a multi-DB file
use DB_File;
use BerkeleyDB;

my $dbdir = "/cb/www.df7cb.de/public_html/projects/postgresql-apt/db";

print header(-type => 'text/html', -charset => 'utf-8');

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
my (%dists, %dist_pgversions);

my %hash;
tie %hash, 'DB_File', "$dbdir/packages.db", 0, 0666, $DB_BTREE;
my @dbs = keys %hash;
untie %hash;

foreach my $db (@dbs) {
	$db =~ /(.*)\|(.*)\|(.*)/;
	my ($dist, $component, $arch) = ($1, $2, $3);
	my $bdb = tie %hash, 'BerkeleyDB::Btree',
		-Filename => "$dbdir/packages.db",
		-Subname => $db,
		-Flags => DB_RDONLY
			or die $! . $BerkeleyDB::Error;
	my @packages = keys %hash;
	foreach my $pkg0 (@packages) {
		my $data = $hash{$pkg0};
		next unless defined $data;
		my $pkg = $pkg0;
		chop $pkg; # strip trailing \0

		my $source = $pkg;
		$source = $1 if ($data =~ /^Source: (\S+)/m);

		$data =~ /^Version: (.*)/m or die "no Version in $data";
		my $version = my $realversion = $1;
		$version =~ s/~pgapt\d\d\+\d//;

		my $pgversion = '';
		$pgversion = $1 if ($pkg =~ /(\d\.\d)/);

		push @{$archive{$source}->{$version}->{$dist}->{$pgversion}->{$arch}}, "$pkg=$realversion";
		#print "pkg $pkg source $source version $version pgversion $pgversion\n";

		$dists{$dist} = dist_version($dist);
		$dist_pgversions{$dist}->{$pgversion} = 1;
	}
	undef $bdb;
	untie %hash;
}

my @dists = sort { $dists{$a} <=> $dists{$b} } keys %dists;

print "<table border=\"1\">\n";
print "<tr><td></td><td></td>\n";
foreach my $dist (@dists) {
	print " <th colspan=\"" . scalar (keys %{$dist_pgversions{$dist}}) . "\">$dist</th>\n";
}
print "</tr>\n";
print "<tr><td></td><td></td>\n";
foreach my $dist (@dists) {
	print " <th>$_</th>" foreach (sort keys %{$dist_pgversions{$dist}});
	print "\n";
}
print "</tr>\n";

my $even = 0;
foreach my $source (sort { stripver($a) cmp stripver($b) or $a cmp $b } keys %archive) {
	my $prefix = $1 if ($source =~ /^((?:lib)?.)/);
	my $rowspan = scalar keys %{$archive{$source}};
	my $background = $even ? 'white' : '#dddddd';
	$even = ! $even;

	my $firstrow = 0;
	foreach my $version (sort { version_compare ($a, $b) } keys %{$archive{$source}}) {
		print "<tr style=\"background: $background;\">\n";
		print " <th rowspan=\"$rowspan\"><a href=\"../pool/main/$prefix/$source/\">$source</a></th>\n"
			unless ($firstrow++);
		print " <th>$version</th>\n";

		foreach my $dist (@dists) {
			foreach my $pgversion (sort keys %{$dist_pgversions{$dist}}) {
				unless (exists $archive{$source}->{$version}->{$dist}->{$pgversion}) {
					print " <td>&nbsp;</td>";
					next;
				}
				print " <td>";
				foreach my $arch (sort keys %{$archive{$source}->{$version}->{$dist}->{$pgversion}}) {
					my $pkgs = join " \n", @{$archive{$source}->{$version}->{$dist}->{$pgversion}->{$arch}};
					print "<span title=\"$pkgs\">$arch<span><br /> ";
				}

				print "</td>";
			}
			print "\n";
		}
		print "</tr>\n";
	}
}

print "</table>\n";
