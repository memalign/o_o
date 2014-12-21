
sub initProt
{
  &log("Initializing protocol");
  &addProt("JOIN", \&prot_join);       
	#&addProt("PART", \&prot_part);       
	&addProt("PRIVMSG", \&prot_privmsg); 
	#&addProt("NOTICE", \&prot_notice);   
	#&addProt("KICK", \&prot_kick);       
	&addProt("PING", \&prot_ping);
	&addProt("PONG", \&prot_pong);
	#&addProt("QUIT", \&prot_quit);       
	#&addProt("MODE", \&prot_mode);       
	#&addProt("332", \&prot_topic_onjoin);
	#&addProt("TOPIC", \&prot_topic);     
	#&addProt("352", \&prot_who);         
	#&addProt("315", \&prot_endofwho);    
	#&addProt("433", \&prot_nickinuse);
	#&addProt("422", \&prot_nomotd);      
	#&addProt("376", \&prot_endofmotd);   
	#&addProt("372", \&prot_motd);        
	&addProt("375", \&prot_motdbegin);   
	#&addProt("NICK", \&prot_nick);       
	#&addProt("ERROR", \&prot_error);     
	&log("Protocol init done");
}#sub initProt

sub addProt
{
  &log("Adding protocol: $_[0]");
  $protocol{$_[0]}{'coderef'} = $_[1];
  $protocol{$_[0]}{'enabled'} = 1;
}#sub addProt

sub procProt
{
  #&log("Processing...");
  if($protocol{$_[0]}{'enabled'})
  {
    &{$protocol{$_[0]}{'coderef'}}($_[1], $_[2]);
  }
}#sub procProt

sub killDeadSocket
{
    my ($sock) = @_;
    if (defined $sock) {
        $sock->close();
        $select->remove($sock);
    }
    &doConnect();
}

sub sendPing
{
    my ($sock) = @_;
    my $killEvent = &addEvent(time()+10, \&killDeadSocket, 0, ($sock));
    &tell($sock, "PING :$killEvent");
}

#----begin protocol functions----#
sub prot_ping
{
  my ($line, $sock) = @_;
  $line =~ s/PING/PONG/;
  &tell($sock, $line);
}#sub prot_ping

sub prot_pong
{
  my ($line, $sock) = @_;
  my @data = split(" ", $line, 4);
  my $msg = substr($data[3], 1);
  &cancelEvent($msg + 0) # cancel the killDeadSocket event
  &addEvent(time()+30, \&sendPing, 0, ($sock));
}

sub prot_motdbegin
{
  my ($line, $sock) = @_;
  foreach my $chan (@{$config{'channels'}})
  {
    &tell($sock, "JOIN $chan");
  }
}#sub prot_motd

sub prot_privmsg
{ 
  #:Ashen!~maniakal@staff.synatek PRIVMSG #test :oh
  my ($line, $sock) = @_;
  my @data = split(" ", $line, 4);
  my $msg = substr($data[3], 1);
  my $char = substr($msg, 0, 1);
  my $nick = substr($line, 1, index($line, "!")-1);
  if($char eq $config{'commandchar'})
  {
    &execCommand($nick, $msg, $sock, $line);
  }
  else
  {
    &aiMsg($line, $sock);
  }
}#sub prot_privmsg

sub prot_join
{
  my ($line, $sock) = @_;
  my @data = split(" ", $line, 4);
  my $chan = substr($data[2], 1);
  my $nick = substr($line, 1, index($line, "!")-1);
  my $host = substr($line, index($line, "@")+1, length($line)-(index($line, " ")-1));
  
  &autoLogin($nick, $host, $sock);
  
  #&log("Nick is $nick | Host is $host | Chan is $chan");
  #[613] [sock] :Ashen!~maniakal@staff.synatek JOIN :#test
  if(&autoBan($nick, $chan))
  {
    &tell($sock, "MODE $chan +b $nick!*@$host");
  }
  elsif(&autoKick($nick, $chan))
  {
    &tell($sock, "KICK $chan $nick :Auto-Kick");
  }
  elsif(&autoOp($nick, $chan))
  {
    &tell($sock, "MODE $chan +o $nick");
  }
  elsif(&autoHop($nick, $chan))
  {
    &tell($sock, "MODE $chan +h $nick");
  }
  elsif(&autoVoice($nick, $chan))
  {
    &tell($sock, "MODE $chan +v $nick");
  }
}#sub prot_join

1;
