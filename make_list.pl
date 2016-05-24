#!/usr/bin/perl -w
use strict;
use DBI;
use utils;

open FILE, '<input';
open OUTPUT, '>>output';

#my $dbh = utils->get_dbh();
while(<FILE>) {
    chomp;
    my @line = split(',');
    $line[0] =~ /'([^']+)'/;
    my $city = $1;
    $line[1] =~ /'([^']+)'/;
    my $code = $1;
    my $url;
    my $sql;
    for(my $i=1; $i<14; $i++) {
        $url = "http://${code}.xiaozhu.com/search-duanzufang-p${i}-0/";  
        my $now = time();
        $sql = "insert into hotel_data.task_url values('', '${city}', '${url}', 0, 0, '$now', '$now');";
        print OUTPUT $sql . "\n";
    }

}

close OUTPUT;
close FILE;
