功能介绍
    1.th_crawl.pl       主程序。顺序读取列表页url，多线程抓取、解析、保存产品信息
    2.make_list_url.pl  制造列表页url。需根据不同网站编写专用函数
    3.data_picker.pm    解析网站html，获取所需数据。需根据不同网站编写对应代码（主要工作是替换正则，特殊情况具体分析：如图片验证码；ajax加载产品信息）
    4.data_saver.pm     保存数据到数据库。通用模块，无需改动
    5.utils.pm          简单工具包
    6.config.pm         主要是数据库配置

    *另有dump_process_list.pl，与主程序中的线程内代码保持一致，方便调试。


使用步骤
    1.perl make_list.url.pl
    插入网站所有列表页网址。
    2.perl th_crawl.pl 
    抓取、解析、保存产品信息

    推荐示例：
    保证守护进程，程序将轮询task_url表领取任务，插入或更新产品数据
    nohup perl th_crawl.pl &
    期望抓取或更新数据时，操作task_url表，新增或更新数据设置status=0
    perl make_list_url.pl 或 update task_url set status=0 where domain_id=6



注意事项
    1.若爬虫异常中断，需执行sql: update task_url set status=0 where status=1; 否则会有列表页不能被抓取和更新
    2.自行决定上一步操作的时机和方式
    

                                                                            author: dlad@wobu2.com
                                                                            2012年6月26日10:33:50
