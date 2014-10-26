
sub doEvents
{
  foreach my $evt (keys %events)
  {
      if (exists $events{$evt}) { # an event can be cancelled after keys %events is resolved
          if(time() >= $events{$evt}{'time'})
          {
              &{$events{$evt}{'code'}}($events{$evt}{'args'});
              if(!$events{$evt}{'infinite'})
              {
                  delete $events{$evt};
              }
          }
      }
  }
}#sub doEvents

sub cancelEvent
{
  my ($cancelID) = @_;
  delete $events{$cancelID};
  &log("Cancelled event $cancelID");
}

sub addEvent
{
  &log("Adding event $eventid");
  my $currentEvent = $eventid;
  $events{$eventid}{'time'} = $_[0];
  $events{$eventid}{'code'} = $_[1];
  $events{$eventid}{'infinite'} = $_[2];
  $events{$eventid}{'args'} = $_[3];
  $eventid++;

  return $currentEvent;
}#sub addEvent

1;
