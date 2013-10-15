package TaoKe;

use strict;
use warnings;

use POSIX qw(strftime);
use LWP::UserAgent;
use Digest::MD5 qw/md5_hex/;
use URL::Encode qw/url_encode/;

use Data::Dumper;

my $env = 'Product'; # {Test Product}
#my $env = 'Test'; # {Test Product}

sub new {
  my $class = shift;
  my $self = {
    ua => LWP::UserAgent->new(),
    url => $env eq 'Product' ? 'http://gw.api.taobao.com/router/rest?' : 'http://gw.api.tbsandbox.com/router/rest?',
    @_,
  };
  return bless $self, $class;
}

sub find_products {
  my ($self, $keyword, $fields, $start_price, $end_price,) = @_;
  $fields ||= 'num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume';
  $start_price ||= 50;
  $end_price ||= 5000;

  my $method = 'taobao.taobaoke.items.get';
  my $base_args = get_base_args($self->{app_key}, $method);
  $base_args->{fields} = $fields;
  $base_args->{keyword} = $keyword;
  $base_args->{start_price} = $start_price;
  $base_args->{end_price} = $end_price;
  $base_args->{start_credit} = '4diamond';
  $base_args->{end_credit} = '5goldencrown';
  $base_args->{sort} = 'commissionRate_asc';
  $base_args->{guarantee} = 'true';                     # 是否是消保
  $base_args->{start_commissionNum} = '30';             # 30 天推广量
  $base_args->{end_commissionNum} = '50000';
  $base_args->{sevendays_return} = 'true';              # 支持 7 天退货
  $base_args->{start_commissionRate} = 1500;            # 佣金比例范围
  $base_args->{end_commissionRate} = 10000;
  $base_args->{start_totalnum} = 10;
  $base_args->{end_totalnum} = 99999999;
  $base_args->{sevendays_return} = 'true';
  $base_args->{page_no} = 1;
  $base_args->{page_size} = 200;

  my $sign = &get_sign($base_args, $self->{app_secret});
  my $req_url .= $self->{url} . join('&', map { "$_=" . url_encode($base_args->{$_}) } sort keys %$base_args);
  $req_url .= "&sign=$sign";
  #print "URL: $req_url\n";
  my $res = $self->{ua}->get($req_url);
  print Dumper( $res->content() );
  <>;
  return $res->is_success ? $res->content : undef;

}

# 得到所有的基本参数
sub get_base_args {
  my ($app_key, $method) = @_;

  die "Must has app_key and method argment" unless $app_key && $method;
  my $base_args = {
    method => $method,
    timestamp => get_timestamp(),
    format => 'json',
    app_key => $app_key,
    v => '2.0',
    sign_method => 'md5',
  };

}

# 签名
sub get_sign {
  my ($args, $secret_code) = @_;

  my $sign .= $secret_code;
  foreach (sort keys %$args){
    $sign .= $_ . $args->{$_}
  }
  $sign .= $secret_code;

  my $hex = uc(md5_hex($sign));
  #print "$hex\n";
  return $hex;
}

sub get_timestamp {
  my $time = time();
  return strftime("%Y-%m-%d %H:%M:%S",localtime( $time));
}

1;
