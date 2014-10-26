
sub sockIO
{
  my @avail = $select->can_read(0);
  foreach my $sock (@avail)
  {
    my $line = <$sock>;
    $line =~ s/[\r\n]+//g;
    if($line)
    {
      &log("[sock] $line");
      @data = split(" ", $line);
      
      &procProt($data[0], $line, $sock);
      &procProt($data[1], $line, $sock);
    }
  }#for each sock
}#sub sockIO

sub tell
{
  my ($sock, $line) = @_;
  &log("[tell] $line");
  if($sock && $sock->connected)
  {
    print $sock "$line\n";
  }
}#sub tell

1;
