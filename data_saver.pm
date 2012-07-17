package data_saver;
use strict;
use DBI;
use Data::Dumper;
use utils;

sub pre_save
{

}

#保存数据，更新爬虫状态
sub save
{
    shift;
    my @data_list = shift;
    my $domain_id = shift;
    my $task_id = shift;

    #数据库连接实例
    my $now = time();
    my $dbh = utils->get_dbh();
    

    my $count = 0;
    my $index = 0;
    #最终妥协选择了这种写法
    while($data_list[0][$index]) {
    #foreach my $data (@data_list) {
        my $data = $data_list[0][$index];
        $index++;

        my $name_full = utils->sample_filter($data->{'name_full'});
        my $aka = $domain_id . '_' . utils->sample_filter($data->{'code'});
        my $url = utils->sample_filter($data->{'url'});
        my $pic_url = utils->sample_filter($data->{'pic_url'});        
        my $price = utils->sample_filter($data->{'price'});

        my $cat_name = utils->sample_filter($data->{'cat_name'});
        my $cat_id = $cat_name ? data_saver->get_cat_id($cat_name) : 0;

        my $brand_name = utils->sample_filter($data->{'brand_name'});
        my $brand_id = $brand_name ? data_saver->get_brand_id($brand_name) : 0; 

        #插入前先判断数据是否已存在
        my $sql_if_exist = "select id from product_on_sale where aka='${aka}'"; 
        my $sth = $dbh->prepare($sql_if_exist);
        $sth->execute();
        my $ref = $sth->fetchrow_hashref();
        if($ref) {
            $count++;
            utils->log("productAlreadyExist     ${sql_if_exist}");
            #商品已存在，更新价格
            if($price && $price=~m/^[0-9.]+$/) {
                my $sql_update_price = "update product_on_sale set price=${price}, update_time=${now} where id=" . $ref->{'id'};
                utils->log("priceUpdated        ${sql_update_price}") if($dbh->do($sql_update_price));
            }
            next;
        }
 
        my $sql = "INSERT INTO product_on_sale VALUES('', '${name_full}', '', '${aka}', '${price}', '${brand_id}', '${cat_id}', '${domain_id}', '${url}', '${pic_url}', '', '', '', '${task_id}', '${now}', '${now}')";
        if($dbh->do($sql)) {
            $count++;
            utils->log("productInserted     ${sql}");
        } else {
            utils->log("productInsertingFail     ${sql}");
        }
    }

    #存储完成，任务状态更新为2
    my $sql_task_done = "update task_url set status=2,processer='',product_count=${count},update_time=${now} where id=${task_id}"; 
    utils->log("failToUpdateTaskStatus      ${sql_task_done}") unless($dbh->do($sql_task_done));
}

sub get_cat_id
{
    shift;
    my $cat_name = shift;

    my $dbh = utils->get_dbh();
    my $sql = "select id from category where name='${cat_name}'";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    if($ref) {
        return $ref->{'id'};
    } else {
        my $now = time();
        $sql = "INSERT INTO category VALUES('', '${cat_name}', '-1', '2', '$now', '$now')";
        $dbh->do($sql);
        my $id = $dbh->{q{mysql_insertid}};

        return $id ? $id : 0;
    }
}

sub get_brand_id
{
    shift;
    my $brand_name = shift;

    my $dbh = utils->get_dbh();
    my $sql = "select id from brand where name='${brand_name}'";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    if($ref) {
        return $ref->{'id'};
    } else {
        my $now = time();
        $sql = "INSERT INTO brand VALUES('', '${brand_name}', '-1', '2', '$now', '$now')";
        $dbh->do($sql);
        my $id = $dbh->{q{mysql_insertid}};

        return $id ? $id : 0;
    }
}

return 1;
