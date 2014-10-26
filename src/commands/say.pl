&addCommand("say", \&rawSend);

sub rawSend
{
  my ($nick, $msg, $sock) = @_;
  if(&canUseRestrictedCommands($nick))
  {
    my @data = split(" ", $msg, 2);
    &tell($sock, $data[1]);
  }
}#sub rawSend

1;
