#this is a rewrite/redo of usermodes.pl

#%usermodes is our hash

#G - God
#r - restricted commands
#c - commands

sub initModes
{
  #do nothing so far
  #&loadModes();
}#initModes

sub loadModes
{
  #UNFINISHED
  &log("Loading modes");
  open(IN, "./etc/usermodes.conf");
  while(<IN>)
  {
    #each line will have the format:
    $l = $_;
    $l =~ s/[\r\n]+//g;
    my @dat = split(" ", $l);
    
    #$usermodes{$dat[0]}{
    
    #NICK [MODECHAR] <?arg>
  }#while in
  close IN;
}

sub saveModes
{

  #UNFINISHED
  &log("Saving modes");
  open(OUT, "> ./etc/usermodes.conf");
  
  foreach my $nick (keys %usermodes)
  {
    my $line = &cap($nick);
    if(!$users{$nick}{'exist'})
    {
      next;
    }
    foreach my $char (keys %{$usermodes{$nick}})
    {
      my @arr = (values %{$usermodes{$nick}{$char}});#look for channels inside
      foreach my $chnl (@arr)
      {
        if($chnl)
        {
          print OUT "$line $char $chnl\n";
        }
      }#foreach channel
    }
    #print OUT $line . "\n";
  }
  
  close OUT;
}

sub doInvites
{
  #no longer does anything
}

sub autoBan
{

}

sub autoKick
{

}

sub autoOp
{

}

sub autoHop
{

}

sub autoVoice
{
  return 1;
}

sub canUseCommands
{
  my $nick = &cap($_[0]);
  return isGod($nick);
}

sub canUseRestrictedCommands
{
  my $nick = &cap($_[0]);
  return isGod($nick);
}

sub modifyModes
{

}

sub isGod
{
  my $nick = &cap($_[0]);
  return $users{$nick}{'loggedin'} && ($nick eq &cap($config{'godlogin'}));#$usermodes{$nick}{"G"} && $users{$nick}{'loggedin'};
}


1;
