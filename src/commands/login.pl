
&addCommand("login", \&doLogin);

sub doLogin
{
  my ($nick, $msg, $sock) = @_;
  &log("Login attempt: $nick");
  my @data = split(" ", $msg);
  if(&login($nick, $data[1], $sock))
  {
    &tell($sock, "NOTICE $nick :You are now logged in.");
  }
}#sub doLogin

1;
