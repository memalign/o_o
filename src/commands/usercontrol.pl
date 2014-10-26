
&addCommand("mkusr", \&mkUser);
&addCommand("rmusr", \&rmUser);
&addCommand("chmod", \&changeModes);

sub mkUser
{
  my ($nick, $msg, $sock) = @_;
  if(&canUseRestrictedCommands($nick))
  {
    #the message will be in the format "!mkusr nick password host"
    my @data = split(" ", $msg);
    my ($cmd, $n, $p, $h) = @data;
    &createUser($n, $p, $h);
    &tell($sock, "NOTICE $nick :User [$n] has been created with password [$p] and host [$h]");
  }
}#sub createUser

sub rmUser
{
  my ($nick, $msg, $sock) = @_;
  if(&canUseRestrictedCommands($nick))
  {
    my @data = split(" ", $msg);
    my ($cmd, $n) = @data;
    &deleteUser($n);
    &tell($sock, "NOTICE $nick :User $n has been deleted");
  }
}#sub deleteUser

sub changeModes
{
  my ($nick, $msg, $sock) = @_;
  if(&canUseRestrictedCommands($nick))
  {
    my @data = split(" ", $msg);
    my ($cmd, $n, $modechange) = @data;
    &modifyModes($modechange, $n);
    &tell($sock, "NOTICE $nick :User $n modes changed to include $modechange");
  }
}#sub changeModes

1;
