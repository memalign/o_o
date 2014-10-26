sub doPings
{
  my @socks = $select->handles;
  my @canwrite = $select->can_write(0);
  my $found = 0;
  
  foreach my $sock (@socks)
  {
    foreach my $write (@canwrite)
    {
      if($sock == $write)
      {
        $found = 1;
        last;
      }
    }
    
    if(!$found)
    {
      $select->remove($sock);
      &doConnect();
    }
  }
  
  &addEvent(time()+30, \&doPings, 0);
}#sub doPings

1;
