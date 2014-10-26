
&addCommand("rehash", \&doRehash);

sub doRehash
{
  my ($nick, $msg, $sock) = @_;
  if(&canUseRestrictedCommands($nick))
  {
    &log("Rehashing: called by $nick");
    &rehash();
    &tell($sock, "NOTICE $nick :Rehash complete");
  }
}#sub doRehash

1;
