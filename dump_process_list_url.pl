#!/usr/bin/perl -w
use strict;
use LWP;
use utils;
use data_picker;
use data_saver;
use Data::Dumper;

$| = 1;

process_list_url();

#处理列表页
sub process_list_url
{
    #得到列表页信息
    my $row = "1######http://www.360buy.com/products/1319-1523-7052-0-0-0-0-0-0-0-1-1-1.html######1######1######gb2312";
    my ($task_id, $url, $domain_id, $cat_id, $page_code) = split '######', $row;

    #认领任务
    my $dbh = utils->get_dbh();
    my $sql_crawlling = 'update task_url set processer=\'' . $$ . '\' where id=' . $task_id;
    utils->log("failToWriteInCrawler        $sql_crawlling") unless($dbh->do($sql_crawlling));

    my $content = utils->fetch_page($url, $page_code);
    #获取所需数据
    my @data = data_picker->process($content, $domain_id, $page_code);

    #遍历商品信息，根据数据完整度，添加子任务及完成情况,确定是否插入
    #图片下载到本地
    #将数据插入数据库
    data_saver->save(\@data, $domain_id, $task_id);
}
