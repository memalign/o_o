&addCommand("seed", \&doSeed);
#&addProt("PRIVMSG", \&aiMsg);

my %aidict = ( );

&loadAI();

sub doSeed
{
  my ($nick, $msg, $sock, $line) = @_;
  
  my @data = split(" ", $line, 4);
  #print "LINE: $line\n";
  #my $msg = substr($data[3], 1);
  my $chan = $data[2];
  
  my @d = split(" ", $msg);
  my $input = $d[1];
  $input =~ tr/[A-Z]/[a-z]/;
  
  my $answer = $input;
  my $word = $answer;
  
  my @arr = keys %{$dict{$word}};
  my $l = @arr;
  my $one = $arr[int(rand()*$l)];
  $answer .= " ".$one;
  
  my $done = 0;

  my $two, $three, $four, $five;
  
#  while(1)#for(my $cc = 0; $cc < 10; $cc++)
#  {


    my @a2 = keys %{$dict{$word}{$one}};
    $l = @a2;
    $done = 1 if $l == 0;
    $two = $a2[int(rand()*$l)];
    
    if(!$done)
    {
      my @a3 = keys %{$dict{$word}{$one}{$two}};
      $l = @a3;
      $done = 1 if $l == 0;
      $three = $a3[int(rand()*$l)];
    }
    
    if(!$done)
    {
      my @a4 = keys %{$dict{$word}{$one}{$two}{$three}};
      $l = @a4;
      $done = 1 if $l == 0;
      $four = $a4[int(rand()*$l)];
    }
    
    if(!$done)
    {
      my @a5 = keys %{$dict{$word}{$one}{$two}{$three}{$four}};
      $l = @a5;
      $done = 1 if $l == 0;
      $five = $a5[int(rand()*$l)];
    }    
    #last if $five eq $word;
    
    #$word = $four;
    #$one = $five;
    $answer .= " ".$two." ".$three." ".$four." ".$five;
#  }#for the amount of words we want
  
  while($five ne $word && !$done)
  {
    $word = $one;
    $one = $two;
    $two = $three;
    $three = $four;
    $four = $five;
    
    my @a5 = keys %{$dict{$word}{$one}{$two}{$three}{$four}};
    my $ll = @a5;
    last if $ll == 0;
    $done = 1 if $ll == 0;
    $five = $a5[int(rand()*$ll)];
    $answer .= " $five";
  }


  &tell($sock, "PRIVMSG $chan :[$input] $answer");
  
}#sub doSeed

sub aiMsg
{
  my ($line, $sock) = @_;
  my @data = split(" ", $line, 4);
  my $msg = substr($data[3], 1);
  #print "MSG: $msg\n";
  &aiLog($msg);
  &aiProcess($msg);
}#sub aiMsg

sub aiLog
{
  my ($msg) = @_;
  open(OUT, ">>./log/ailog.txt");
  print OUT "$msg\n";
  close OUT;
}#sub aiLog

sub loadAI
{
  my $in = `cat ./log/ailog.txt`;
  $in =~ tr/[A-Z]/[a-z]/;

  my @arr = split("\n", $in);
  foreach $l (@arr)
  {
    &aiProcess($l);
  }
}#sub loadAI

sub aiProcess
{
  my $l = $_[0];
  my $ctcp = "\001";
  $l =~ s/${ctcp}ACTION//g;
  $l =~ s/${ctcp}//g;
  $l =~ tr/[A-Z]/[a-z]/;
  my @words = split(" ", $l);

  my $len = @words;
  for(my $cc = 0; $cc < $len; $cc++)#foreach my $word (@words)
  {
    if($cc < $len-5)
    {
      $dict{$words[$cc]}{$words[$cc+1]}{$words[$cc+2]}{$words[$cc+3]}{$words[$cc+4]}{$words[$cc+5]} = 1;
    }
    elsif($cc < $len-4)
    {
      $dict{$words[$cc]}{$words[$cc+1]}{$words[$cc+2]}{$words[$cc+3]}{$words[$cc+4]} = 1;
    }
    elsif($cc < $len-3)
    {
      $dict{$words[$cc]}{$words[$cc+1]}{$words[$cc+2]}{$words[$cc+3]} = 1;
    }
    elsif($cc < $len-2)
    {
      $dict{$words[$cc]}{$words[$cc+1]}{$words[$cc+2]} = 1;
    }
    elsif($cc < $len-1)
    {
      $dict{$words[$cc]}{$words[$cc+1]} = 1;
    }
  }#for each word
}#sub aiProcess

1;
