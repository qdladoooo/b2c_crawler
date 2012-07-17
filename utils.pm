package utils;
use strict;
use LWP;
use Encode;
use Data::Dumper;
use config;


sub fetch_page
{
    shift;
    my $url = shift;
    my $code = shift;

    my $ua = LWP::UserAgent->new;
    $ua->default_header('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    $ua->default_header('Accept-Charset' => 'GBK,utf-8;q=0.7,*;q=0.3');
    $ua->default_header('Accept-Language' => 'zh-CN,zh;q=0.8');
    $ua->default_header('Connection' => 'keep-alive');
    $ua->default_header('Keep-Alive' => '115');
    $ua->default_header('Content-Type' => 'application/x-www-form-urlencoded');
    $ua->default_header('User-Agent' => ' Mozilla/5.0 (Windows NT 5.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'); 

    my $res = $ua->get($url);
    $res->is_success or print "Wrong:", $res->message, "\n";

    my $content = $res->content;
    if($code ne 'utf-8') {
        $content = encode('utf-8', decode($code, $content));
    }

    return $content; 
}

sub store_pic
{
    shift;

}

#记录日志文件
sub log
{
    shift;
    my $content = shift @_;
    my $upath = shift @_;
    my $path = "./log/";      #设置默认目录

    if($upath) {
        open FH, ">>$upath";
        print FH $content . "\n";
        close FH;
    } else {
        open FH, ">>${path}crawl.log";
        print FH $content . "\n";
        close FH;
    }
}

sub trim
{
    shift;
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
} 

sub get_dbh
{
    my $host = config->mysql_host();
    my $user = config->mysql_user();
    my $pw = config->mysql_pw();
    my $dbh = DBI->connect("DBI:mysql:database=yr_match;host=$host", "$user", "$pw", {"RaiseError"=>1});
    $dbh->do("set names utf8");

    return $dbh;
}

sub add_slashes {
    shift;
    my $text = shift;
    ## Make sure to do the backslash first!
    if($text) {
        $text =~ s/\\/\\\\/g;
        $text =~ s/'/\\'/g;
        $text =~ s/"/\\"/g;
        $text =~ s/\\0/\\\\0/g;
    }
    return $text;
}

sub sample_filter
{
    shift;
    my $str = shift;
    $str = utils->trim($str);
    $str = utils->add_slashes($str);
    
    return $str;
}

sub var_dump
{
    shift;
    my $var = shift;
    print Dumper($var);
}

return 1;
