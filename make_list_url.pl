#!/usr/bin/perl -w
use strict;
use DBI;
use config;
use utils;
use Data::Dumper;

$| = 1;
#这个工具用来导入列表页url
#具体情况具体分析



#淘宝孕婴
sub taobao_baby()
{

}

#淘宝列表页最大值
sub taobao_max_page
{


}


#jingdong_baby();

#京东，孕婴
sub jingdong_baby
{
    #配置区
    my $url = 'http://www.360buy.com/baby.html';
    my $page_code = 'gb2312';
    my $domain_id = 6;
    my $cat_id = 1;

    my $content = utils->fetch_page($url, $page_code);
    $content =~ m/<div id="sortlist" class="m">(.+)<!--sortlist/s;
    my $block = $1;
    my @code = $block =~ m/<a href="http:\/\/www\.360buy\.com\/products\/([^.]+)\.html" title='[^']+'>/g;
    
    #得到母婴子分类链接
    foreach my $code (@code) {
        next if($code =~ m/000$/);
        my $cat_url = "http://www.360buy.com/products/${code}-0-0-0-0-0-0-0-1-1-[page].html";
        my $first_page = "http://www.360buy.com/products/${code}-0-0-0-0-0-0-0-1-1-1.html";        
        my $max_page = jingdong_max_page($first_page, $page_code);
        print $first_page . "\t${max_page}\n";

        make_list($cat_url, $domain_id, $max_page, $cat_id);
    }
}

#得到京东商品列表页最大页数
sub jingdong_max_page
{
    my $url = shift;
    my $page_code = shift;
    my $content = utils->fetch_page($url, $page_code); 

    return ($content =~ m/class='pagin pagin-m'><span class='text'>\d+\/(\d+)/) ? $1 : 1;
}

sub make_list
{
    my $init_url = shift;
    my $domain_id = shift;
    my $max_page =  shift;
    my $cat_id = shift;
    
    #数据库连接信息
    my $dbh = utils->get_dbh();
    
    my $i = 1;
    while($i <= $max_page) {
        my $url = $init_url;
        $url =~ s/\[page\]/$i/;
        $url = utils->add_slashes($url);
    
        my $timestamp = time();
        my $sql = "insert into task_url values('', '$url', $domain_id, $cat_id, 0, '', 0, $timestamp, $timestamp);";
        $dbh->do($sql);
        $i++;
    }
}

