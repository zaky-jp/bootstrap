#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use File::Basename 'fileparse';

# parse args
my $file;
my $mirror_file;
if ($#ARGV > 0) {
	$file = shift;
	$mirror_file = shift;
} else {
	# default
	$file = '/etc/apt/sources.list.d/ubuntu.sources';
	$mirror_file = '/etc/apt/mirrors.txt'
}

sub read_list {
	my $file = shift;
	my @chunks = ();
	open(IN, $file) or die "Cannot open $file\n";
	while (<IN>) {
		if (index($_, '#') == 0) {
			next;
		} elsif ($_ eq "\n") {
			next;
		}
		push @chunks, $_;
	}
	close(IN);
	return @chunks;
}

sub list_replace_mirrors {
	my @chunks = @_;
	my @results;

	foreach (@chunks) {
		if ($_ !~ /https?\S+\/ \S+security/) {
			$_ =~ s/https?\S+\//mirror+file:$mirror_file/;
		}
		push @results, $_;
	}
	return @results;
}

sub read_deb822 {
	my $file = shift;
	my @chunks = ();
	my $n = 0;
	open(IN, $file) or die "Cannot open $file\n";
	while (<IN>) {
		if (index($_, '#') == 0) {
			next;
		} elsif ($_ eq "\n") {
			next;
		} elsif (/^Types:/) {
			$n ++;
		}
		$chunks[$n] .= $_;
	}
	close(IN);
	shift @chunks;
	return @chunks;
}

sub deb822_replace_uri_with_mirror {
	my $input = shift;
	my $output;
	foreach (split(/\n/, $input)) {
		if (/URIs:/) {
			$_ =~ s/(URIs: )\S+/$1mirror+file:$mirror_file/;
		}
		$output .= $_ . "\n";
	}
	return $output;
}

sub deb822_replace_mirrors {
	my @chunks = @_;
	my @results;
	foreach (@chunks) {
		if (/Suites: \S+security/) { # keep security genuine mirror
			push @results, $_;
		} else {
			push @results, deb822_replace_uri_with_mirror($_);
		}
	}
	return join("\n", @results);
}

# decide format
my @parse = fileparse($file, qr/\.\S+$/);
my @results;
if ($parse[2] eq '.sources') {
	my @chunks = read_deb822($file);
	@results = deb822_replace_mirrors(@chunks);
} elsif ($parse[2] eq '.list') {
	my @chunks = read_list($file);
	@results = list_replace_mirrors(@chunks);
}
print @results;

