package data_picker;
use strict;
use utils;
use LWP;
use Data::Dumper;

sub process
{
    shift;
    my $content = shift;
    my $page_code = shift;
    
    my @data_list;
    #解析content，输出data_list
    my @detail_url_list = $content  =~ /<div class="result_btm_con lodgeunitname" detailurl="([^"]+)"/g;
    foreach my $detail_url (@detail_url_list) {
        my $detail_content = utils->fetch_page($detail_url, $page_code);
        my %data;

        #页面网址
        $data{'url'} = $detail_url;
        #价格
        $detail_content =~ /<div class="day_l">￥<span>(\d+)/;
        $data{'price'} = $1;
        #面积
        $detail_content =~ /房屋面积：(\d+)平米/;
        $data{'area'} = $1;
        #位置
        $detail_content =~ /<td>\s+房源位置：([^<]+)\s*</;
        $data{'location'} = $1;
        $data{'location'} =~ s/^\s*//;
        $data{'location'} =~ s/\s*i$//;
        $data{'location'} =~ s/\n//;
        #描述
        $detail_content =~ /<p>个性描述<\/p>.*?" intro_item_content">(.*?)<\/div>/sm;
        $data{'desc'} = $1;
        $data{'desc'} =~ s/^\s+//;
        $data{'desc'} =~ s/\s+$//;

        push @data_list, {%data};
    }

    return @data_list;
}

return 1;

