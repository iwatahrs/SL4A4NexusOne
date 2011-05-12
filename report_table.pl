#
# 都内の環境放射線測定結果を Android 上で表示するスクリプト
# Copyright(C) iwarin 2011 All Rights Reserved.
#

use strict;
use warnings;

use Android;
use HTTP::Lite;

my $droid = Android->new();
my $http = HTTP::Lite->new;
my $url  = "http://ftp.jaist.ac.jp/pub/emergency/monitoring.tokyo-eiken.go.jp/monitoring/hourly_data.html";
my $url2 = "http://www.tokyo-eiken.go.jp.cache.iijgio.com/monitoring/hourly_data.html";
my $url3 = "http://vhost0148.dc1.on.ca.compute.ihost.com/mirror/ftp.jaist.ac.jp/pub/emergency/monitoring.tokyo-eiken.go.jp/monitoring/hourly_data.html";
my $url4 = "http://az26632.vo.msecnd.net/monitoring/hourly_data.html";

$droid->dialogCreateSpinnerProgress("情報を取得中...","jaist.ac.jp");
$droid->dialogShow();
  my $req = $http->request($url);
$droid->dialogDismiss();
my @body = split(/\n/, $http->body());

if (($req != 200) || ($#body == -1)) {
  $droid->dialogCreateSpinnerProgress("情報を取得中...","tokyo-eiken.go.jp");
  $droid->dialogShow();
    my $req = $http->request($url2);
  $droid->dialogDismiss();
  
  @body = ();
  @body = split(/\n/, $http->body());
  if (($req != 200) || ($#body == -1)) {
    $droid->makeToast("接続に失敗しました($req,$#body)");
    exit;
  }
}

my $buffer = "";
my $count = 0;

foreach my $line (@body) {
  $line =~ s/\x0D?\x0A$//g;
  $line =~ s/<.*?>//g;
  $line =~ s/\&nbsp//g;
  $line =~ s/^\s+//g;
  if ($count >= 1) {
    if ($count == 3) {
      $buffer = $buffer . sprintf(" %s\n", $line);
    }
    $count--;
  }
  if ($line =~ /^([0-9]{4})\/([0-9]{2})\/([0-9]{2})\;*(.+)/) {
    $buffer = $buffer . sprintf("%s/%s %s", $2, $3, $4);
    $count = 3;
  }
}

my $title = '新宿区百人町の最大値 (μGr/h)';
$droid->dialogCreateAlert($title, $buffer);
$droid->dialogSetPositiveButtonText('OK');
$droid->dialogShow();
$droid->dialogGetResponse();
$droid->dialogDismiss();

