#!/usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;

use lib 'lib';
use FindBin qw/$Bin/;
use Encode;
use TaoKe;
use YAML::Syck qw/ LoadFile /;
use Digest::MD5 qw/ md5_hex /;
use JSON;

$| = 1;

our $DEBUG = 0;
our $MAX_POST = 1;

my $conf_file = "$Bin/conf/edm.yaml";
my $key_word_file = "$Bin/conf/keywords.txt";

my $conf = LoadFile( $conf_file );
my $taoke = init_taoke( $conf );

my $keys = get_key_words( $key_word_file );


# we proces all keywords
foreach my $key ( @$keys ) {

  my $products = get_product_by_key_words( $key );

  print Dumper( $products );

}

sub get_can_post {
  my ( $all_products, $dbh ) = @_;

  my %can_post;

  foreach my $by_key ( keys %$all_products ) {
    print "Key: $by_key\n" if $DEBUG;

    foreach my $prod ( sort { $b->{commission} <=> $a->{commission} } @{ $all_products->{ $by_key } } ) {
      print $prod->{commission},"\n" if $DEBUG;

      next if $prod->{ commission } > 100 || $prod->{ commission } < 5; # 不推广利润> 100 && < 10 元的产品
      my $title_md5 = md5_hex( $prod->{ title } );
      $prod->{ title_md5 } = $title_md5;
      $prod->{ key_words } = $by_key;

      next if check_is_posted( $dbh, $by_key, $title_md5 );
      next if exists $can_post{ $by_key } && scalar @{ $can_post{ $by_key } } > $MAX_POST;

      push @{ $can_post{ $by_key } }, $prod;
    }
  }

  return \%can_post;
}


sub check_is_posted {
  my ( $dbh, $key_words, $title_md5 ) = @_;
  my $sql = qq/select count(1) from post_logs where title_md5 = '$title_md5'
    and key_words = '$key_words'/;

  my ($is_posted) = $dbh->selectrow_array($sql);

  print "IS Post: $is_posted\n" if $DEBUG;
  return $is_posted ? $is_posted : 0;
}


sub get_product_by_key_words {
  my ($key_word) = @_;
  my $products = $taoke->find_products( $key_word );

  my @prods;

  if ($products) {

    my $json = from_json($products);

    foreach my $product ( @{$json->{taobaoke_items_get_response}->{taobaoke_items}->{taobaoke_item}}){
      my ($title, $click_url, $price, $commission) = @$product{qw/title click_url price commission/};
      $title = decode( 'utf8', $title );
      $title = encode( 'utf8', $title );
      $title =~ s/<.*?>/ /g;
      $title =~ s/\d//g;
      $title =~ s/【.*?】//g;

      print "$title\n$click_url\n$price\n$commission\n\n" if $DEBUG;

      push @prods, {
        title => $title,
        click_url => $click_url,
        price => $price,
        commission => $commission
      };
    }
    return \@prods;
  }
  return undef;
}


sub get_key_words {
  my ($file) = @_;

  return unless -e $file;
  my %keys;

  open (my $fh, '<', $file) || die "Can't open keywords file: $file\n";
  while (<$fh>){
    next if /^\s*#/;
    s/\r\n//g;
    s/^\s+$//g;
    my @tk = split /\s+/;
    $keys{$_}++ foreach @tk;
  }

  return [ keys %keys ];
}


sub init_taoke {
  my ( $conf ) = @_;

  if ($conf->{ TaoKe }->{app_key} && $conf->{TaoKe}->{app_secret}) {
    return TaoKe->new( app_key => $conf->{ TaoKe }->{app_key}, app_secret => $conf->{ TaoKe }->{app_secret});
  }else{
    die "Must has App key and App Secret\n";
  }
}
