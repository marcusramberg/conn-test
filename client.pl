use Mojo::Base -signatures;
use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new;
$ua->inactivity_timeout(300);
my @promises;
for(1 .. 10_0000) {
  push @promises, $ua->websocket_p('ws://localhost:3000/echo')->then(sub ($tx) {

      # Prepare a followup promise so we can wait for messages
      my $promise = Mojo::Promise->new;

      # Wait for WebSocket to be closed
      $tx->on(finish => sub ($tx, $code, $reason) {
          $promise->resolve;
        });

      # Close WebSocket after receiving one message
      $tx->on(message => sub ($tx, $msg) {
          Mojo::Promise->timer(250)->then(sub { $tx->finish });
        });

      # Send a message to the server
      $tx->send('Hi!');

      # Insert a new promise into the promise chain
      return $promise;
    })->catch(sub ($err) {

      # Handle failed WebSocket handshakes and other exceptions
      warn "WebSocket error: $err";
    });
}
Mojo::Promise->all_settled(@promises)->wait;
