package data_saver;
use strict;
use DBI;
use Data::Dumper;
use utils;

#保存数据，更新爬虫状态
sub save
{
    shift;
    my @data_list = shift;
    my $task_id = shift;

    #数据库连接实例
    my $now = time();
    my $dbh = utils->get_dbh();
    
    my $count = 0;
    my $index = 0;
    #最终妥协选择了这种写法
    while($data_list[0][$index]) {
        my $data = $data_list[0][$index];
        $index++; 

        my $price = utils->sample_filter( $data->{'price'} );
        my $area = utils->sample_filter( $data->{'area'} );
        my $location = utils->sample_filter( $data->{'location'} );
        my $desc = utils->sample_filter( $data->{'desc'} );
        my $url = utils->sample_filter( $data->{'url'} );
        my $sql = "insert into hotel_data.hotel values('', '${price}', '${area}', '${location}', '${desc}', '${url}', $now, $now)";

        if($dbh->do($sql)) {
            $count++;
            utils->log("Success Insert: ${url}");
        } else {
            utils->log("Fail to Insert: ${url}");
        }
    }

    my $sql_task_done = "update task_url set status=2, processer='', fetch_count=${count}, update_time=${now} where id=${task_id}"; 
    utils->log("Fail to Update Task: ${sql_task_done}") unless($dbh->do($sql_task_done));
}

return 1;
