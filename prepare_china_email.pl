#!/usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;

use Smart::Comments;
use GetPassword;
use DBI;

$|++;
my ( $user, $pass ) = GetPassword->get_password();

my @dbs = qw/data5/;
my @dbhs;
my @china_email_list = qw/126.com 163.com yeah.net sina.com.cn/;

my $dbh_object = DBI->connect( "dbi:msyql:EDM", $user, $pass ) || die "Can't connect to EDM database\n";


foreach my $db ( @dbs ) {
  my $dbh = DBI->connect( "dbi:mysql:$db", $user, $pass );
  push @dbhs, $dbh;
}


my $sql = qq/select email, first_name, last_name from user_addressbook where email like ? limit 10/;

#my $where = join( ' OR ', map{ "email like '%$_'" } @china_email_list );


foreach my $dbh ( @dbhs ) {

  foreach my $email_suffix ( @china_email_list ) {
    my $rows = $dbh->selectall_arrayref( $sql, undef, ( '%' . $email_suffix ) );
    save_email( undef, $rows, $email_suffix );
  }
}


sub save_email {
  my ( $dbh, $rows, $email_suffix ) = @_;

  my $table_name = get_table_name( $email_suffix );

  foreach my $row ( @$rows ) {
    unless ( check_email_exists( $dbh, $row->[0], $table_name ) ) {
      my $sql = qq/insert into $table_name ( email, name ) values ( ?, ? )/;
      my $first_name = make_first_name( $row->[1] );

      $dbh->do( $sql, undef, ( $row->[0], $first_name ));
    }
    ### $row
  }
}


sub make_first_name {
  my $first_name = shift;
  $first_name = lc( $first_name );
  $first_name =~ s/[^a-z]/ /g;
  $first_name =~ s/^\s*//;

  my @words = split( /\s+/, $first_name );
  my $name = '';
  while ( 1 ) {
    last if length( $name ) > 3;
    my $tmp = shift @words;
    last unless $tmp;

    $name .= ucfirst( $tmp );
  }

  return $name;
}

sub check_email_exists {
  my ( $dbh, $email, $table_name ) = @_;

  my $sql = qq/select count(1) from $table_name where email = ? /;
  my ( $is_exists ) = $dbh->getrow_array( $sql, undef, $email );

  return defined $is_exists && $is_exists > 0 ? 1:0;
}

sub get_table_name {
  my ( $email_suffix ) = @_;

  $email_suffix =~ s/\./_/g;
  return $email_suffix;
}

sub check_and_create_table {
  my ( $dbh, $table_name ) = @_;

  my $sql = qq/
    CREATE  TABLE IF NOT EXISTS $table_name (
    `id` INT NOT NULL AUTO_INCREMENT ,
    `email` VARCHAR(64) NOT NULL ,
    `name` VARCHAR(64) NULL ,
    `ipaddress` VARCHAR(45) NULL ,
    `join_data` TIMESTAMP NULL ,
    PRIMARY KEY (`id`) ,
    UNIQUE INDEX `email_UNIQUE` (`email` ASC)
    ) ENGINE = MyISAM
  /;

  $dbh->do( $sql );
}