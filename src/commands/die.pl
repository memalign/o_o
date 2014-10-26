#our first command!

&addCommand("die", \&botShutdown);

sub botShutdown
{
  my ($nick, $msg, $sock) = @_;
  &log("Entering botShutdown command");
  if(&canUseRestrictedCommands($nick))
  {
    &log("Bot is being shut down by $nick");
    my @data = split(" ", $msg, 2);
    my $qmsg = $data[1];
    my @avail = $select->can_write(0);
    foreach my $sock (@avail)
    {
      &tell($sock, "QUIT :[shutdown by $nick] [$qmsg]");
    }
    exit();
  }
}#sub botShutdown

1;
