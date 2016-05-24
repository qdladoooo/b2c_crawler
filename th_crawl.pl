#!/usr/bin/perl -w
use strict;
use LWP;
use DBI;
use threads;
use threads::shared;
use Thread::Queue;
use utils;
use data_picker;
use data_saver;

#配置区
my $thread_num = 5;

$| = 1;

#队列
my $q = Thread::Queue->new();
#生产者
my $p = threads->create(\&url_producer, '');

while(1) {
    if(threads->list() > $thread_num) {
        foreach(threads->list(threads::joinable)) {
           $_->join();
        }
    } else {
        threads->create(\&process_list_url, '');
    }
}

#维护容量200的链接池
sub url_producer
{
    #数据库连接信息
    my $dbh = utils->get_dbh();
    while(1) {
        if($q->pending() < 50) {
            #获取列表页网址，加入队列
            my $sql = 'select * from task_url where status=0 order by id limit 1';
            my $sth = $dbh->prepare($sql);
            $sth->execute();
            my @row = $sth->fetchrow_array();

            if(@row) {
                $dbh->do('UPDATE task_url SET STATUS=1 WHERE id=' . $row[0]);
                my $row_str = join('######', @row);
                $q->enqueue($row_str);
            } else {
                print "no more list url\n";
                sleep(5);
            }
        } else {
            sleep(1);
        } 

    }
}

#处理列表页
sub process_list_url
{
    #得到列表页信息
    my $row = $q->dequeue();

    my ($task_id, $city,  $url) = split '######', $row;

    #认领任务
    my $dbh = utils->get_dbh();
    my $sql_crawlling = 'update task_url set processer=\'' . $$ . '\' where id=' . $task_id;
    utils->log("Fail to Update Task: $sql_crawlling") unless($dbh->do($sql_crawlling));

    my $page_code = 'utf-8';
    my $content = utils->fetch_page($url, $page_code);
    #获取所需数据
    my @data = data_picker->process($content, $page_code);

    #遍历商品信息，根据数据完整度，添加子任务及完成情况,确定是否插入
    #图片下载到本地
    #将数据插入数据库
    data_saver->save(\@data, $task_id);
}




