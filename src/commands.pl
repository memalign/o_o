
#%commands is our hash

sub addCommand
{
  my ($commandstr, $coderef) = @_;#note, commandstr does not have the command char at the beginning
  $commands{$commandstr}{'code'} = $coderef;
  $commands{$commandstr}{'exist'} = 1;  
}#sub addCommand

sub removeCommand
{
  my ($commandstr) = @_;
  $commands{$commandstr}{'exist'} = 0;
}#sub removeCommand

sub execCommand
{
  my ($nick, $msg, $sock, $line) = @_;
  my @data = split(" ", $msg);
  my $l = $data[0];
  my $char = substr($l, 0, 1);
  $l = substr($l, 1);
  #&log("MSG: $msg L: $l");
  if(&canUseCommands($nick) || $l eq "login")
  {
    if($char eq $config{'commandchar'} && $commands{$l}{'exist'})
    {
      &log("Execing command: [[nick] $nick] [[cmd] $l]");
      &{$commands{$l}{'code'}}($nick, $msg, $sock, $line);
    }
  }
}#sub execCommand

1;
