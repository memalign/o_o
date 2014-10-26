
#These are the currently supported modes:
#G        - god -- only one user may have this mode
#r        - can use restricted commands
#c        - can use commands
#v[#chan1,#chan2] - autovoice  -- yeah, so the channel names cant have ] in them, if its that big of a deal, then you can change it yourself
#h[#chan] - autohop
#o[#chan] - autoop
#b[#chan] - autoban
#k[#chan] - autokick
#i[#chan] - invite (invited to channels listed when they first login)
#NOTE: Replace #chan with * to make it so that the user gets voice on all channels

sub initModes
{
  &loadModes();
}#sub initModes

sub doInvites
{
  my ($nick, $sock) = @_;
  if($users{&cap($nick)}{'loggedin'})
  {
    foreach my $chan (keys %{$usermodes{&cap($nick)}{"i"}})
    {
      if($usermodes{&cap($nick)}{"i"}{$chan})
      {
        &tell($sock, "INVITE $nick $chan");
      }
    }
  }
}

sub isGod
{
  my $nick = &cap($_[0]);
  return $usermodes{$nick}{"G"} && $users{$nick}{'loggedin'};
}

sub canUseRestrictedCommands
{
  my $nick = &cap($_[0]);
  return ($usermodes{$nick}{"r"} || $usermodes{$nick}{"G"}) && $users{$nick}{'loggedin'};
}

sub canUseCommands
{
  my $nick = &cap($_[0]);
  return ($usermodes{$nick}{"c"} || $usermodes{$nick}{"G"}) && $users{$nick}{'loggedin'};
}

sub autoVoice
{
  my ($nick, $chan) = @_;
  $nick = &cap($nick);
  $chan = &cap($chan);
  return ($usermodes{$nick}{"v"}{$chan} || $usermodes{$nick}{"v"}{"*"}) && $users{$nick}{'loggedin'};
}

sub autoHop
{
  my ($nick, $chan) = @_;
  $nick = &cap($nick);
  $chan = &cap($chan);
  return ($usermodes{$nick}{"h"}{$chan} || $usermodes{$nick}{"h"}{"*"}) && $users{$nick}{'loggedin'};
}

sub autoOp
{
  my ($nick, $chan) = @_;
  $nick = &cap($nick);
  $chan = &cap($chan);
  return ($usermodes{$nick}{"o"}{$chan} || $usermodes{$nick}{"o"}{"*"}) && $users{$nick}{'loggedin'};
}

sub autoBan
{
  my ($nick, $chan) = @_;
  $nick = &cap($nick);
  $chan = &cap($chan);
  return ($usermodes{$nick}{"b"}{$chan} || $usermodes{$nick}{"b"}{"*"}) && $users{$nick}{'loggedin'};
}

sub autoKick
{
  my ($nick, $chan) = @_;
  $nick = &cap($nick);
  $chan = &cap($chan);
  return ($usermodes{$nick}{"k"}{$chan} || $usermodes{$nick}{"k"}{"*"}) && $users{$nick}{'loggedin'};
}

sub loadModes
{
  &log("Loading modes");
  open(IN, "./etc/usermodes.conf");
  while(<IN>)
  {
    my @data = split(" ", $_);
    my $nick = &cap(pop(@data));
    foreach my $l (@data)
    {
      my $char = substr($l, 0, 1);
      if($char eq "i" || $char eq "v" || $char eq "h" || $char eq "o" || $char eq "b" || $char eq "k")
      {
        if($l =~ /^${char}\[([^\]]+)\]/)#this line is one of the aforementioned evils
        {
          my $channels = $1;
          my @dat = split(",", &cap($channels));
          foreach my $c (@dat)
          {
            $usermodes{$nick}{$char}{$c} = 1;
          }
        }
      }#if its one of our special characters
      else
      {
        $usermodes{$nick}{$char} = 1;
      }
    }
  }#while in
  close IN;
}#sub loadModes

sub saveModes
{
  &log("Saving modes");
  open(OUT, "> ./etc/usermodes.conf");
  foreach my $nick (keys %usermodes)
  {
    my $line = "$nick";
    if(!$users{$nick}{'exist'})
    {
      next;
    }
    foreach my $char (keys %{$usermodes{$nick}})
    {
      #&log("Saving mode: $char");
      if($char eq "i" || $char eq "v" || $char eq "h" || $char eq "o" || $char eq "b" || $char eq "k")
      {
        $line .= " " . $char . "[";
        foreach my $chan (keys %{$usermodes{$nick}{$char}})
        {
          #&log("CHAN: $chan");
          if($usermodes{$nick}{$char}{$chan})
          {
            $line .= $chan . ",";
          }
        }
        $line =~ s/\,$//;
        $line .= "]";
      }
      else
      {
        if($usermodes{$nick}{$char})
        {
          $line .= " " . $char;
        }
      }
      #$line =~ s/^ //;
    }
    print OUT $line . "\n";
  }
  close OUT;
}#sub saveModes

sub modifyModes
{
  my ($modify, $nick) = @_;
  
  #if the user doesnt exist, we cannot change the modes:
  if(!$users{&cap($nick)}{'exist'})
  {
    &log("Modify failed, user doesnt exist");
    return;
  }
  
  #modify will be in the format [+modes][-modes] or opposite order (there wont be the []s around them)
  my $char = substr($modify, 0, 1);
  
  my $adding = 1;#start with + by default
  if($char eq "-")
  {
    $adding = 0;
  }
  elsif($char ne "+")
  {
    return;
  }
  
  #split this into sections: vhobk each needs a channel array
  my $toAdd = "";
  my $toSub = "";
  for(my $cc = 1; $cc < length($modify); $cc++)
  {
    my $letter = substr($modify, $cc, 1);
    &log("Modify letter: $letter");
    if($letter eq "-")
    {
      $adding = 0;
    }
    elsif($letter eq "+")
    {
      $adding = 1;
    }
    
    if($letter ne "i" && $letter ne "v" && $letter ne "h" && $letter ne "o" && $letter ne "b" && $letter ne "k")
    {
      if($adding)
      {
        $toAdd .= $letter;
      }
      else
      {
        $toSub .= $letter;
      }
    }#if its not one of the specials
    else
    {
      my $tstr = substr($modify, $cc);
      if($tstr =~ /^([ivhobk]\[[^\]]+\])/)#this is the line that makes channels with a "]" a big no no (there are four more lines like this below)
      {
        my $l = $1;
        #&log("L IS $l");
        if($adding)
        {
          &addModeWithChannel($nick, $l);
        }
        else
        {
          &subModeWithChannel($nick, $l);
        }
        $cc += length($l)-1;
      }
    }#one of the specials
  }#for each character
  #&log("TOADD: $toAdd TOSUB: $toSub");
  &addModes($nick, $toAdd);
  &subtractModes($nick, $toSub);
}#sub modifyModes

sub addModeWithChannel
{
  my ($nick, $mode) = @_;
  $nick = &cap($nick);
  #make sure its not already there
  my $char = substr($mode, 0, 1);
  if($mode =~ /^${char}\[([^\]]+)\]/)#this line is one of the aforementioned evils
  {
    my $channels = $1;
    my @arr = split(",", &cap($channels));

    foreach my $c (@arr)
    {
      $usermodes{$nick}{$char}{$c} = 1;
    }
  }
  &saveModes();
}#sub addModeWithChannel

sub subModeWithChannel
{
  my ($nick, $mode) = @_;
  $nick = &cap($nick);

  my $char = substr($mode, 0, 1);
  if($mode =~ /^${char}\[([^\]]+)\]/)#this line is one of the aforementioned evils
  {
    my $channels = $1;
    my @arr = split(",", &cap($channels));

    foreach my $c (@arr)
    {
      $usermodes{$nick}{$char}{$c} = 0;
    }
  }
  &saveModes();
}

sub addModes
{
  my ($nick, $modes) = @_;
  #check to make sure the modes arent already there
  for(my $cc = 0; $cc < length($modes); $cc++)
  {
    my $char = substr($modes, $cc, 1);
    #&log("Adding mode: $char");
    if($char eq "G")
    {
      next;
    }
    
    if(!$usermodes{&cap($nick)}{$char})
    {
      $usermodes{&cap($nick)}{$char} = 1;
    }
  }
  &saveModes();
}#sub addModes

sub subtractModes
{
  my ($nick, $modes) = @_;
  #check to make sure the modes are there first
  for(my $cc = 0; $cc < length($modes); $cc++)
  {
    my $char = substr($modes, $cc, 1);
    #&log("Subtracting mode: $char");
    if($char eq "G")
    {
      next;
    }
    
    if($usermodes{&cap($nick)}{$char})
    {
      $usermodes{&cap($nick)}{$char} = 0;
    }
  }
  &saveModes();
}#sub subtractModes

1;
