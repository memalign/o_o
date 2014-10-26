#!/usr/bin/perl

use IO::Socket;
use IO::Select;
use Time::HiRes qw (usleep);

$count = 0;
$reload = 1;
$eventid = 0;
%events = ( );
%config = ( );
%protocol = ( );
%usermodes = ( );
%users = ( );
%commands = ( );

$select = IO::Select->new();

&initialize();

sub initialize
{
  &log("-----INITIALIZATION-----");
  &rehash();
  &initUsers();
  &doConnect();
  &addEvent(time(), \&sockIO, 1);
  &addEvent(time()+30, \&doPings, 0);
  &eventLoop();
}#sub initialize

sub rehash
{
  &loadSrc();
  &loadConfig();
  &loadCommands();
  &initProt();
  &initModes();
}#sub rehash

sub eventLoop()
{
  &log("Entering event loop");
  while(1)
  {
    &doEvents();
    usleep(25000);
  }
}#sub eventLoop

sub log
{
  if($config{'log'})
  {
    open(OUT, ">> ./log/o_o.log");
    print OUT "[$count] $_[0]\n";
    close OUT;
  }
  else
  {
    print "[$count] $_[0]\n";
  }
  $count++;
}#sub log

sub loadSrc
{
  &log("Loading sources:");
  my $srcdir = "./src/";

  opendir (DIR, $srcdir);
  while ($file = readdir DIR)
  {
    next unless $file =~ /\.pl$/;
    &log("    $srcdir$file");
    &reload("$srcdir$file");
  }
  closedir DIR;
  &log("Done loading sources");
}#sub loadSrc

sub loadCommands
{
  &log("Loading commands:");
  my $srcdir = "./src/commands/";

  opendir (DIR, $srcdir);
  while ($file = readdir DIR)
  {
    next unless $file =~ /\.pl$/;
    &log("    $srcdir$file");
    &reload("$srcdir$file");
  }
  closedir DIR;
  &log("Done loading commands");
}#sub loadCommands

sub loadConfig
{
  &log("Loading config file");
  my $config = "./etc/o_o.conf";
  &reload("$config");
  &log("Done loading config");
}#sub loadConfig

sub reload
{
  &log("[reload] Requiring $_[0]");
  `cp $_[0] ./tmp/$reload`;
  require("./tmp/$reload");
  `rm -f ./tmp/$reload`;
  &log("[reload] done");
  $reload++;
}#sub reload

sub doConnect
{
  &log("Begin connect:");
  my $sock = IO::Socket::INET->new(
                                    "PeerAddr" => $config{'ip'}.":".$config{'port'},
                                    "Proto"    => "tcp",
                                    "Blocking" => 0
                                  );
  my $waitCount = 0;
  while(!$sock || !$sock->connected())
  {
    &log("Sock isn't ready, sleep for 1");
    $waitCount++;

    if ($waitCount > 10) {
        &killDeadSocket($sock); # schedules a reconnect
        return;
    }
    sleep 1;
  }
  if($config{'password'})
  {
    print $sock "PASS $config{'password'}\n";
  }
  
  if($config{'hybrid'})
  {
    until(($line = <$sock>) =~ /NOTICE AUTH \:\*\*\* No Ident response/)
    {
      print "LINE: $line";
      usleep 100000;
    }
    #sleep 5;
    print $sock "NICK $config{'nick'}\n";
    #sleep 1;
    print $sock "USER 0 0 0 0\n";
  }
  else
  {
    print $sock "NICK $config{'nick'}\nUSER $config{'ident'} 0 0 :$config{'realname'}\n";
  }
  $select->add($sock);
  &log("Connected");
  &addEvent(time()+3, \&sendPing, 0, ($sock));
}#sub doConnect

sub cap
{
  my $line = $_[0];
  $line =~ tr/[a-z]/[A-Z]/;
  return $line;
}#sub cap

sub alphabetize
{
  my ($str) = @_;
  my @arr = ( );
  for(my $cc = 0; $cc < length($str); $cc++)
  {
    $arr[@arr] = substr($str, $cc, 1);
  }
  @arr = sort(@arr);
  $str = "";
  foreach my $char (@arr)
  {
    $str .= $char;
  }
  return $str;
}#sub alphabetize
