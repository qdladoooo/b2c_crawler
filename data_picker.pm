package data_picker;
use strict;
use utils;
use LWP;
use Data::Dumper;


my @domain_map = ('6'=>'process_jingdong');

sub process
{
    shift;
    my $content = shift;
    my $domain_id = shift;
    my $page_code = shift;
    my $processer = $domain_map[$domain_id];
    
    my @data_list = data_picker->$processer($content, $page_code, $domain_id);
    return @data_list;
}


sub process_jingdong
{
    shift;
    my $content = shift;
    my $page_code = shift;
    my $domain_id = shift;
    
    my @data_list;
    my @product_info_list = $content =~ m/<li sku='\d+'[^>]+>.+<\/li>/g;
    
    #todo:dump
    my $count = @product_info_list;
    print $count . "\n";

    foreach my $product_info (@product_info_list) {
        my %data;
        
        $product_info =~ m/>([^<]+)<font/;
        $data{'name_full'} = $1; 

        $product_info =~ m/<a target='_blank' href='([^']+)'><img/;
        $data{'url'} = $1;
        
        $data{'url'} =~ m/([^\/]+)\.html/;
        $data{'code'} = $1;    
 
        my $detail = utils->fetch_page($data{'url'}, $page_code);
        $detail =~ m/&nbsp;&gt;&nbsp;<a href="[^"]+">([^<]+)</;
        $data{'cat_name'} = $1;

        $detail =~ m/生产厂家：<a target="_blank" href="[^"]+">([^<]+)</;
        $data{'brand_name'} = $1;
        
        $detail =~ m/jqimg="([^"]+)"/;
        $data{'pic_url'} = $1;

        #京东价格数据，需伪造请求
        my $agent = LWP::UserAgent->new();
        $agent->default_header('Host' => 'cart.360buy.com');
        $agent->default_header('Origin' => 'http://cart.360buy.com');
        $agent->default_header('Accept-Charset' => 'GBK,utf-8;q=0.7,*;q=0.3');
        $agent->default_header('Accept' => 'application/json, text/javascript, */*');
        $agent->default_header('Accept-Language' => 'zh-CN,zh;q=0.8');
        $agent->default_header('Connection' => 'keep-alive');
        $agent->default_header('Content-Type' => 'application/x-www-form-urlencoded');
        $agent->default_header('Referer' => 'http://cart.360buy.com/cart/initCart.html?pid=247728&pcount=1&ptype=1');
        $agent->default_header('User-Agent' => ' Mozilla/5.0 (Windows NT 5.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5');
        my $request = HTTP::Request->new(POST=>'http://cart.360buy.com/cart/addSkuToCart.action?rd=0.6476697344451797');
        $request->content_type('application/x-www-form-urlencoded');
        $request->content('pid=' . $data{'code'} . '&pcount=1&ptype=1&ybId=');

        my $response = $agent->request($request);
        if($response->is_success) {
            my $cart_content = $response->content;
            $cart_content =~ m/price":"([^"]+)"/;
            $data{'price'} = $1;
        } else {
            $data{'price'} = 0;
            utils->log("360BuyPriceServerDeny:     " . $response->message);
        }

        push @data_list, {%data};
    }

    return @data_list;
}

return 1;

