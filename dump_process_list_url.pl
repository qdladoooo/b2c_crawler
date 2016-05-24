#!/usr/bin/perl -w
use strict;
use LWP;
use utils;
use data_picker;
use data_saver;
use Data::Dumper;

$| = 1;

process_list_url();

sub process_list_url
{
    #得到列表页信息
    my $row = "1######北京######http://bj.xiaozhu.com/search-duanzufang-p1-0/";

    my ($task_id, $city,  $url) = split '######', $row;

    #认领任务
    my $dbh = utils->get_dbh();
    my $sql_crawlling = 'update task_url set processer=\'' . $$ . '\' where id=' . $task_id;
    utils->log("failToWriteInCrawler        $sql_crawlling") unless($dbh->do($sql_crawlling));

    my $page_code = 'utf-8';
    my $content = utils->fetch_page($url, $page_code);
    #获取所需数据
    my @data = data_picker->process($content, $page_code);

    #遍历商品信息，根据数据完整度，添加子任务及完成情况,确定是否插入
    #图片下载到本地
    #将数据插入数据库
    data_saver->save(\@data, $task_id);
}
