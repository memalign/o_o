
#%users is our hash

sub initUsers
{
  &loadUsers();
}#sub initUsers

sub loadUsers
{
  &log("Loading users");
  open(IN, "./etc/users.conf");
  while(<IN>)
  {
    #the line will be "nick password host"
    my @data = split(" ", $_);
    $users{&cap($data[0])}{'pass'} = $data[1];
    $users{&cap($data[0])}{'host'} = $data[2];
    $users{&cap($data[0])}{'exist'} = 1;
    $users{&cap($data[0])}{'loggedin'} = 0;
  }
  close IN;
}#sub loadUsers

sub saveUsers
{
  &log("Saving users");
  open(OUT, "> ./etc/users.conf");
  foreach my $nick (keys %users)
  {
    if($users{$nick}{'exist'})
    {
      print OUT "$nick $users{$nick}{'pass'} $users{$nick}{'host'}\n";
    }
  }
  close OUT;
}#sub saveUsers

sub createUser
{
  my ($nick, $pass, $host) = @_;
  $nick = &cap($nick);
  $users{$nick}{'pass'} = $pass;
  $users{$nick}{'host'} = $host;
  $users{$nick}{'exist'} = 1;
  &saveUsers();
}#sub createUser

sub deleteUser
{
  my ($nick) = @_;
  $users{&cap($nick)}{'exist'} = 0;
  &saveUsers();
  &saveModes();
}#sub deleteUser

sub logoff
{
  my ($nick) = @_;
  $users{&cap($nick)}{'loggedin'} = 0;
}#sub logoff

sub autoLogin
{
  my ($nick, $host, $sock) = @_;
  if($users{&cap($nick)}{'host'} eq $host || $users{&cap($nick)}{'host'} eq "*")
  {
    &log("User $nick has been auto-logged in");
    $users{&cap($nick)}{'loggedin'} = 1;
    &doInvites($nick, $sock);
  }
}#sub autoLogin

sub login
{
  my ($nick, $pass, $sock) = @_;
  #&log("LOGIN: $nick");
  if($users{&cap($nick)}{'pass'} eq $pass)
  {
    $users{&cap($nick)}{'loggedin'} = 1;
    &log("Login: $nick is now logged in");
    &doInvites($nick, $sock);
    return 1;
  }
  elsif($nick eq $config{'godlogin'})
  {
    if($pass eq $config{'godpass'})
    {
      $users{&cap($nick)}{'loggedin'} = 1;
      $users{&cap($nick)}{'exist'} = 1;
      $usermodes{&cap($nick)}{"G"} = 1;#hackish, fix later
      &log("Login: $nick is now logged in as god");
      &doInvites($nick, $sock);
      return 1;
    }    
  }
  return 0;
}#sub login

sub isLoggedIn
{
  my ($nick) = @_;
  return $users{&cap($nick)}{'loggedin'};
}#sub isLoggedIn

1;
